classdef TestHOGDescriptor
    %TestHOGDescriptor
    properties (Constant)
        fields = {'scale', 'locations', 'confidences'};  % DetectionROI
    end

    methods (Static)
        function test_class
            hog = cv.HOGDescriptor('NBins',9);
            hog.CellSize = [8 8];
            evalc('disp(hog)');

            ws = hog.getWinSigma();
            validateattributes(ws, {'numeric'}, {'scalar'});

            sz = hog.getDescriptorSize();
            validateattributes(sz, {'numeric'}, {'scalar', 'integer'});

            hog.SvmDetector = randn(1, sz+1);
            hog.SvmDetector = 'DefaultPeopleDetector';
            assert(hog.checkDetectorSize());
            coeffs = hog.SvmDetector;
            validateattributes(coeffs, {'numeric'}, {'vector', 'numel',sz+1});
        end

        function test_compute
            im = get_image();
            hog = cv.HOGDescriptor();
            sz = hog.getDescriptorSize();

            % dense
            descr = hog.compute(im);
            validateattributes(descr, {'numeric'}, {'size',[NaN sz]});

            % sparse
            kpts = cv.FAST(im);
            kpts = cv.KeyPointsFilter.retainBest(kpts, 500);
            descr = hog.compute(im, 'Locations',{kpts.pt});
            validateattributes(descr, {'numeric'}, {'size',[numel(kpts) sz]});
        end

        function test_computeGradient
            im = get_image();
            hog = cv.HOGDescriptor();

            [grad, qangle] = hog.computeGradient(im);
            validateattributes(grad, {'single'}, ...
                {'size',[size(im,1) size(im,2) 2]});
            validateattributes(qangle, {'uint8'}, ...
                {'size',[size(im,1) size(im,2) 2]});
        end

        function test_detect
            im = get_image();
            hog = cv.HOGDescriptor();
            hog.SvmDetector = 'DefaultPeopleDetector';

            % detect
            [pts, weights] = hog.detect(im);
            if ~isempty(pts)
                validateattributes(pts, {'cell'}, {'vector'});
                cellfun(@(p) validateattributes(p, {'numeric'}, ...
                    {'vector', 'numel',2, 'integer'}), pts);
                validateattributes(weights, {'numeric'}, ...
                    {'vector', 'numel',numel(pts)});
            end

            % group similar rectangles
            rects = cellfun(@(p) [p hog.WinSize], pts, 'Uniform',false);
            [rects, weights] = hog.groupRectangles(rects, weights, ...
                'GroupThreshold',1, 'EPS',0.2);
            if ~isempty(rects)
                validateattributes(rects, {'cell'}, {'vector'});
                cellfun(@(r) validateattributes(r, {'numeric'}, ...
                    {'vector', 'numel',4, 'integer'}), rects);
                validateattributes(weights, {'numeric'}, ...
                    {'vector', 'numel',numel(rects)});
            end
        end

        function test_detectMultiScale
            im = get_image();
            hog = cv.HOGDescriptor();
            hog.SvmDetector = 'DefaultPeopleDetector';

            [rects, weights] = hog.detectMultiScale(im);
            if ~isempty(rects)
                validateattributes(rects, {'cell'}, {'vector'});
                cellfun(@(r) validateattributes(r, {'numeric'}, ...
                    {'vector', 'numel',4, 'integer'}), rects);
                validateattributes(weights, {'numeric'}, ...
                    {'vector', 'numel',numel(rects)});
            end
        end

        function test_detectROI
            im = get_image();
            hog = cv.HOGDescriptor();
            hog.SvmDetector = 'DefaultPeopleDetector';

            % get some true object locations, and add some false ones
            locs = hog.detect(im);
            for i=1:10
                locs{end+1} = randi([0 50], [1 2]) .* hog.BlockStride;
            end

            % detect at those ROI locations
            [pts, confs] = hog.detectROI(im, locs);
            if ~isempty(pts)
                validateattributes(pts, {'cell'}, {'vector'});
                cellfun(@(p) validateattributes(p, {'numeric'}, ...
                    {'vector', 'numel',2, 'integer'}), pts);
                validateattributes(confs, {'numeric'}, ...
                    {'vector', 'numel',numel(locs)});
            end
        end

        function test_detectMultiScaleROI
            im = get_image();
            hog = cv.HOGDescriptor();
            hog.SvmDetector = 'DefaultPeopleDetector';

            % get some true object locations at multiple scales, and add some false ones
            rois = struct('scale',{}, 'locations',{}, 'confidences',{});
            scales = [1 1.05];
            for i=1:numel(scales)
                img = cv.resize(im, 1/scales(i), 1/scales(i));
                [p,w] = hog.detect(img);
                for j=1:3
                    p{end+1} = randi([0 20], [1 2]) .* hog.BlockStride;
                    w(end+1) = rand();
                end
                rois(i).scale = scales(i);
                rois(i).locations = p;
                rois(i).confidences = w;
            end

            % detect at those ROI locations
            [rects, rois] = hog.detectMultiScaleROI(im, rois);
            if ~isempty(rects)
                validateattributes(rects, {'cell'}, {'vector'});
                cellfun(@(r) validateattributes(r, {'numeric'}, ...
                    {'vector', 'numel',4, 'integer'}), rects);
                validateattributes(rois, {'struct'}, {'vector'});
                assert(all(ismember(TestHOGDescriptor.fields, fieldnames(rois))));
                arrayfun(@(S) validateattributes(S.scale, ...
                    {'numeric'}, {'scalar'}), rois);
                arrayfun(@(S) validateattributes(S.locations, ...
                    {'cell'}, {'vector'}), rois);
                arrayfun(@(S) cellfun(@(p) validateattributes(p, ...
                    {'numeric'}, {'vector', 'numel',2, 'integer'}), ...
                    S.locations), rois);
                arrayfun(@(S) validateattributes(S.confidences, ...
                    {'numeric'}, {'vector'}), rois);
            end
        end

        function test_save_load
            hog = cv.HOGDescriptor();
            hog.GammaCorrection = false;
            filename = [tempname '.xml'];
            cObj = onCleanup(@() deleteFile(filename));
            hog.save(filename);

            hog2 = cv.HOGDescriptor(filename);
            %hog2.load(filename);
            assert(hog.GammaCorrection == hog2.GammaCorrection);
        end
    end

end

function deleteFile(fname)
    if exist(fname, 'file') == 2
        delete(fname);
    end
end

function img = get_image()
    img = [];
    vidfile = get_pedestrian_video();
    if exist(vidfile, 'file')
        vid = cv.VideoCapture(vidfile);
        img = vid.read();
        vid.release();
    end
    if isempty(img)
        img = imread(fullfile(mexopencv.root(),'test','lena.jpg'));
    end
end

function fname = get_pedestrian_video()
    fname = fullfile(mexopencv.root(),'test','768x576.avi');
    if ~exist(fname, 'file')
        % download video from Github
        url = 'https://cdn.rawgit.com/Itseez/opencv/3.0.0/samples/data/768x576.avi';
        disp('Downloading video...')
        urlwrite(url, fname);
    end
end
