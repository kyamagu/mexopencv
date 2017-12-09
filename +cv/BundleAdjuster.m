classdef BundleAdjuster < handle
    %BUNDLEADJUSTER  Class for all camera parameters refinement methods
    %
    % See also: cv.Stitcher, cv.Estimator
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % Threshold to filter out poorly matched image pairs.
        ConfThresh
        % 3x3 8-bit mask, where 0 means don't refine respective parameter,
        % non-zero means refine.
        RefinementMask
        % Levenberg-Marquardt algorithm termination criteria.
        TermCriteria
    end

    methods
        function this = BundleAdjuster(adjusterType, varargin)
            %BUNDLEADJUSTER  Construct a bundle adjuster instance
            %
            %     obj = cv.BundleAdjuster(adjusterType)
            %     obj = cv.BundleAdjuster(adjusterType, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __adjusterType__ Bundle adjustment cost function. One of:
            %   * __NoBundleAdjuster__ Stub bundle adjuster that does nothing.
            %   * __BundleAdjusterRay__ Implementation of the camera
            %     parameters refinement algorithm which minimizes sum of the
            %     distances between the rays passing through the camera center
            %     and a feature. It can estimate focal length. It ignores the
            %     refinement mask for now.
            %   * __BundleAdjusterReproj__ Implementation of the camera
            %     parameters refinement algorithm which minimizes sum of the
            %     reprojection error squares. It can estimate focal length,
            %     aspect ratio, principal point. You can affect only on them
            %     via the refinement mask.
            %   * __BundleAdjusterAffine__ Bundle adjuster that expects affine
            %     transformation represented in homogeneous coordinates in R
            %     for each camera param. Implements camera parameters
            %     refinement algorithm which minimizes sum of the reprojection
            %     error squares. It estimates all transformation parameters.
            %     Refinement mask is ignored. See also cv.AffineBasedEstimator
            %     and `AffineBestOf2NearestMatcher`.
            %   * __BundleAdjusterAffinePartial__ Bundle adjuster that expects
            %     affine transformation with 4 DOF represented in homogeneous
            %     coordinates in R for each camera param. Implements camera
            %     parameters refinement algorithm which minimizes sum of the
            %     the reprojection error squares. It estimates all
            %     transformation parameters. Refinement mask is ignored.
            %
            % ## Options
            % The following are options accepted by all adjusters:
            %
            % * __ConfThresh__ Threshold to filter out poorly matched image
            %   pairs. default 1
            % * __RefinementMask__ 3x3 8-bit mask, where 0 means don't refine
            %   respective parameter, non-zero means refine.
            %   default `eye(3,'uint8')`
            % * __TermCriteria__ Levenberg-Marquardt algorithm termination
            %   criteria. default
            %   `struct('type','Count+EPS', 'maxCount',1000, 'epsilon',eps)`
            %
            % See also: cv.BundleAdjuster.estimate
            %
            this.id = BundleAdjuster_(0, 'new', adjusterType, varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.BundleAdjuster
            %
            if isempty(this.id), return; end
            BundleAdjuster_(this.id, 'delete');
        end

        function typename = typeid(this)
            %TYPEID  Name of the C++ type (RTTI)
            %
            %     typename = obj.typeid()
            %
            % ## Output
            % * __typename__ Name of C++ type
            %
            typename = BundleAdjuster_(this.id, 'typeid');
        end
    end

    %% Estimator
    methods
        function [cameras,success] = refine(this, features, pairwise_matches, cameras)
            %REFINE  Refine camera parameters
            %
            %     cameras = obj.refine(features, pairwise_matches, cameras)
            %     [cameras,success] = obj.refine(...)
            %
            % ## Input
            % * __features__ Features of images. See cv.FeaturesFinder.
            % * **pairwise_matches** Pairwise matches of images. See
            %   cv.FeaturesMatcher.
            % * __cameras__ Initial camera parameters to refine. See
            %   cv.Estimator.
            %
            % ## Output
            % * __cameras__ Refined camera parameters.
            % * __success__ True in case of success, false otherwise.
            %
            % Runs bundle adjustment.
            %
            % See also: cv.BundleAdjuster.BundleAdjuster
            %
            [cameras,success] = BundleAdjuster_(this.id, 'refine', features, pairwise_matches, cameras);
        end
    end

    %% Auxiliary methods
    methods (Static)
        function rmats = waveCorrect(rmats, varargin)
            %WAVECORRECT  Tries to make panorama more horizontal (or vertical)
            %
            %     rmats = cv.BundleAdjuster.waveCorrect(rmats)
            %     rmats = cv.BundleAdjuster.waveCorrect(rmats, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __rmats__ Input camera rotation matrices. Cell-array of 3x3
            %   matrices.
            %
            % ## Output
            % * __rmats__ Output camera rotation matrices, wave corrected.
            %
            % ## Options
            % * __Kind__ Wave correction kind, one of:
            %   * __Horiz__ horizontal (default)
            %   * __Vert__ vertical
            %
            rmats = BundleAdjuster_(0, 'waveCorrect', rmats, varargin{:});
        end
    end

    %% Getters/Setters
    methods
        function value = get.ConfThresh(this)
            value = BundleAdjuster_(this.id, 'get', 'ConfThresh');
        end
        function set.ConfThresh(this, value)
            BundleAdjuster_(this.id, 'set', 'ConfThresh', value);
        end

        function value = get.RefinementMask(this)
            value = BundleAdjuster_(this.id, 'get', 'RefinementMask');
        end
        function set.RefinementMask(this, value)
            BundleAdjuster_(this.id, 'set', 'RefinementMask', value);
        end

        function value = get.TermCriteria(this)
            value = BundleAdjuster_(this.id, 'get', 'TermCriteria');
        end
        function set.TermCriteria(this, value)
            BundleAdjuster_(this.id, 'set', 'TermCriteria', value);
        end
    end

end
