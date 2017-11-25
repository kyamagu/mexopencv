classdef PlaneTracker < handle
    %PLANETRACKER  Multi-target planar tracker
    %
    % Performs tracking with homography matching using features2d framework.
    % ORB features and FLANN matcher are used by default.
    %
    % ## Sources:
    %
    % * https://github.com/opencv/opencv/blob/3.3.1/samples/python/plane_tracker.py
    %

    properties
        % minimum number of keypoints detected to be considered as candidate
        min_kpts_count = 10;  % should be >= 2
        % used in 2-NN ratio test to be considered a good match
        match_ratio = 0.75;
        % minimum number of good matches, otherwise excluded
        min_match_count = 10;  % should be >= 4
        % minimum number of inlier points for a valid homography estimation
        min_inliers = 10;
        % RANSAC maximum reprojection error to treat a point pair as inliers
        ransac_thresh = 3.0;
    end

    properties (SetAccess = private)
        % feature detector / descriptor extractor object
        detector
        % descritpr matcher object
        matcher
        % plane targets to track
        % (struct array as described in PlaneTracker.addTarget)
        targets
    end

    methods
        function obj = PlaneTracker(varargin)
            %PLANETRACKER  Constructor
            %
            %     obj = PlaneTracker()
            %     obj = PlaneTracker(detector, matcher)
            %
            % ## Input
            % * __detector__ feature detector, default `ORB`
            % * __matcher__ descriptor matcher, default `FlannBasedMatcher`
            %

            % feature detector
            if nargin < 1
                obj.detector = cv.ORB('MaxFeatures',1000);
            else
                obj.detector = varargin{1};
            end

            % descriptor matcher
            if nargin < 2
                obj.matcher = cv.DescriptorMatcher('FlannBasedMatcher', ...
                    'Index',...
                    {'LSH', 'TableNumber',6, 'KeySize',12, 'MultiProbeLevel',1});
            else
                obj.matcher = varargin{2};
            end

            % initialize plane targets struct array
            obj.targets = struct('image',{}, 'rect',{}, 'kpts',{}, 'descs',{});
        end

        function varargout = addTarget(obj, img, win)
            %ADDTARGET  Add a new tracking target
            %
            %     t = obj.addTarget(img, win)
            %
            % ## Input
            % * __img__ target image, containing target to track
            % * __win__ rectangle around plane target `[x,y,w,h]`
            %
            % ## Output
            % * __t__ PlaneTarget struct with the following fields:
            %   * __image__ image in which target is tracked
            %   * __rect__ tracked rectangle `[x1,y1,x2,y2]`
            %     (as 2 opposing corners, top-left and bottom-right)
            %   * __kpts__ keypoints detected inside rectangle
            %   * __descrs__ their descriptors
            %

            % new target to track
            t = struct();
            t.image = img;
            t.rect = [cv.Rect.tl(win), cv.Rect.br(win)];

            % create ROI mask
            mask = zeros(size(img,1), size(img,2), 'uint8');
            mask = cv.rectangle(mask, win, 'Color',255, 'Thickness','Filled');

            % detect and compute features of first frame inside ROI region
            [t.kpts, t.descs] = obj.detector.detectAndCompute(img, 'Mask',mask);
            if numel(t.kpts) < obj.min_kpts_count
                disp('Not enough keypoints detected in target');
                return;
            end

            % add descriptors to matcher training set
            obj.matcher.add({t.descs});

            % store target
            obj.targets(end+1) = t;
            if nargout > 0
                varargout{1} = t;
            end
        end

        function clear(obj)
            %CLEAR  Remove all tracked targets
            %
            %     obj.clear()
            %

            obj.detector.clear();
            obj.matcher.clear();
            obj.targets = obj.targets([]);
        end

        function tracked = track(obj, img)
            %TRACK  Return a list of detected tracked objects
            %
            %     tracked = obj.track(img)
            %
            % ## Input
            % * __img__ new input image in which to track targets
            %
            % ## Output
            % * __tracked__ TrackedTarget struct array with these fields:
            %   * __index__ index of tracked target (1-based index into
            %     `targets` array)
            %   * __target__ reference to PlanarTarget
            %   * __pt0__ matched points coords in target image
            %   * __pt1__ matched points coords in new input frame
            %   * __H__ 3x3 homography matrix from `pt0` to `pt1`
            %   * __quad__ target boundary quad in new input frame
            %     (top-left, top-right, bottom-right, bottom-left)
            %

            % initialize tracked target struct array
            tr = struct('index',[], 'target',[], 'pt0',[], 'pt1',[], 'H',[], 'quad',[]);
            tracked = tr([]);

            % check that addTarget was called
            if isempty(obj.targets)
                return;
            end

            % detect and compute features in current frame
            [kpts, descs] = obj.detector.detectAndCompute(img);
            if numel(kpts) < obj.min_kpts_count
                return;
            end

            % match against first frames features (all targets at once) using
            % 2-NN matching with ratio test (if closest match is MATCH_RATIO
            % closer than the second closest one, then its a good match)
            matches = obj.matcher.knnMatch(descs, 2);
            idx = cellfun(@(m) numel(m) == 2 && ...
                (m(1).distance < obj.match_ratio * m(2).distance), matches);
            matches = cellfun(@(m) m(1), matches(idx));
            if numel(matches) < obj.min_match_count
                return;
            end

            % loop over matches for each target
            for i=1:numel(obj.targets)
                % matches by target id
                m = matches([matches.imgIdx] == (i-1));
                if numel(m) < obj.min_match_count
                    continue;
                end

                tr.index = i;
                tr.target = obj.targets(i);

                % estimate homography using RANSAC
                tr.pt0 = cat(1, tr.target.kpts([m.trainIdx] + 1).pt);
                tr.pt1 = cat(1, kpts([m.queryIdx] + 1).pt);
                [tr.H, inliers] = cv.findHomography(tr.pt0, tr.pt1, ...
                    'Method','Ransac', 'RansacReprojThreshold',obj.ransac_thresh);
                inliers = logical(inliers);
                if isempty(tr.H) || nnz(inliers) < obj.min_inliers
                    continue;
                end
                % keep only inlier points
                tr.pt0 = tr.pt0(inliers,:);
                tr.pt1 = tr.pt1(inliers,:);

                % project object bounding box using homography to locate it in new frame
                tr.quad = tr.target.rect([1 2; 3 2; 3 4; 1 4]); % [TL; TR; BR; BL]
                tr.quad = cv.perspectiveTransform(tr.quad, tr.H);

                % append to tracked targets
                tracked(end+1) = tr;
            end

            % sort tracked targets by number of matched points
            [~,ord] = sort(arrayfun(@(tr) size(tr.pt0,1), tracked), 'descend');
            tracked = tracked(ord);
        end
    end
end
