classdef Estimator < handle
    %ESTIMATOR  Rotation estimator base class
    %
    % It takes features of all images, pairwise matches between all images
    % and estimates rotations of all cameras.
    %
    % Note: The coordinate system origin is implementation-dependent, but you
    % can always normalize the rotations in respect to the first camera, for
    % instance.
    %
    % See also: cv.Stitcher, cv.BundleAdjuster
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    methods
        function this = Estimator(estimatorType, varargin)
            %ESTIMATOR  Constructor
            %
            %     obj = cv.Estimator(estimatorType)
            %     obj = cv.Estimator(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __estimatorType__ Estimator type. One of:
            %   * __HomographyBasedEstimator__ Homography based rotation
            %     estimator.
            %   * __AffineBasedEstimator__ Affine transformation based
            %     estimator. This estimator uses pairwise transformations
            %     estimated by matcher to estimate final transformation for
            %     each camera.
            %
            % The following are options for the various algorithms:
            %
            % ### `HomographyBasedEstimator`
            % * __IsFocalsEstimated__ default false
            %
            % See also: cv.Estimator.estimate
            %
            this.id = Estimator_(0, 'new', estimatorType, varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.Estimator
            %
            if isempty(this.id), return; end
            Estimator_(this.id, 'delete');
        end

        function typename = typeid(this)
            %TYPEID  Name of the C++ type (RTTI)
            %
            %     typename = obj.typeid()
            %
            % ## Output
            % * __typename__ Name of C++ type
            %
            typename = Estimator_(this.id, 'typeid');
        end
    end

    %% Estimator
    methods
        function [cameras,success] = estimate(this, features, pairwise_matches)
            %ESTIMATE  Estimates camera parameters
            %
            %     cameras = obj.estimate(features, pairwise_matches)
            %     [cameras, success] = obj.estimate(...)
            %
            % ## Input
            % * __features__ Features of images. See cv.FeaturesFinder.
            % * **pairwise_matches** Pairwise matches of images. See
            %   cv.FeaturesMatcher.
            %
            % ## Output
            % * __cameras__ Estimated camera parameters. Structure that
            %   describes camera parameters with the following fields:
            %   * __aspect__ Aspect ratio.
            %   * __focal__ Focal length.
            %   * __ppx__ Principal point X.
            %   * __ppy__ Principal point Y.
            %   * __R__ 3x3 camera rotation matrix.
            %   * __t__ 3x1 camera translation vector.
            %   * __K__ 3x3 camera intrinsic parameters.
            % * __success__ True in case of success, false otherwise.
            %
            % See also: cv.Estimator.Estimator
            %
            [cameras,success] = Estimator_(this.id, 'estimate', features, pairwise_matches);
        end
    end

    %% Auto-calibration methods
    methods (Static)
        function [K,success] = calibrateRotatingCamera(Hs)
            %CALIBRATEROTATINGCAMERA  Calibrate rotating camera
            %
            %     K = cv.Estimator.calibrateRotatingCamera(Hs)
            %     [K,success] = cv.Estimator.calibrateRotatingCamera(Hs)
            %
            % ## Input
            % * __Hs__ Cell-array of 3x3 double matrices.
            %
            % ## Output
            % * __K__ 3x3 double matrix.
            % * __success__ True in case of success, false otherwise.
            %
            [K,success] = Estimator_(0, 'calibrateRotatingCamera', Hs);
        end

        function focals = estimateFocal(features, pairwise_matches)
            %ESTIMATEFOCAL  Estimates focal lengths for each given camera
            %
            %     focals = cv.Estimator.estimateFocal(features, pairwise_matches)
            %
            % ## Input
            % * __features__ Features of images.
            % * **pairwise_matches** Matches between all image pairs.
            %
            % ## Output
            % * __focals__ Estimated focal lengths for each camera, vector of
            %   doubles.
            %
            focals = Estimator_(0, 'estimateFocal', features, pairwise_matches);
        end

        function [f0, f1, f0_ok, f1_ok] = focalsFromHomography(H)
            %FOCALSFROMHOMOGRAPHY  Tries to estimate focal lengths from the given homography under the assumption that the camera undergoes rotations around its centre only
            %
            %     [f0, f1] = cv.Estimator.focalsFromHomography(H)
            %     [f0, f1, f0_ok, f1_ok] = cv.Estimator.focalsFromHomography(H)
            %
            % ## Input
            % * __H__ Homography, 3x3 double matrix.
            %
            % ## Output
            % * __f0__ Estimated focal length along X axis.
            % * __f1__ Estimated focal length along Y axis.
            % * **f0_ok** True, if `f0` was estimated successfully, false
            %   otherwise.
            % * **f1_ok** True, if `f1` was estimated successfully, false
            %   otherwise.
            %
            % ## References
            % > Heung-Yeung Shum and Richard Szeliski. "Construction of
            % > of Panoramic Image Mosaics with Global and Local Alignment".
            %
            [f0, f1, f0_ok, f1_ok] = Estimator_(0, 'focalsFromHomography', H);
        end
    end

end
