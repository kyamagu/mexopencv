classdef Stitcher < handle
    %STITCHER  High level image stitcher
    %
    % It's possible to use this class without being aware of the entire
    % stitching pipeline. However, to be able to achieve higher stitching
    % stability and quality of the final images at least being familiar with
    % the theory is recommended.
    %
    % ![image](https://docs.opencv.org/3.3.1/StitchingPipeline.jpg)
    %
    % This figure illustrates the stitching module pipeline implemented in the
    % cv.Stitcher class. Using that class it's possible to configure/remove
    % some steps, i.e. adjust the stitching pipeline according to the
    % particular needs.
    %
    % The implemented stitching pipeline is very similar to the one proposed
    % in [BL07].
    %
    % # Camera models
    % There are currently 2 camera models implemented in stitching pipeline.
    %
    % - *Homography model* expecting perspective transformations between
    %   images implemented in `BestOf2NearestMatcher`,
    %   `HomographyBasedEstimator`, `BundleAdjusterReproj`, and
    %   `BundleAdjusterRay`.
    % - *Affine model* expecting affine transformation with 6 DOF or 4 DOF
    %   implemented in `AffineBestOf2NearestMatcher`, `AffineBasedEstimator`,
    %   `BundleAdjusterAffine`, `BundleAdjusterAffinePartial`, and
    %   `AffineWarper`.
    %
    % Homography model is useful for creating photo panoramas captured by
    % camera, while affine-based model can be used to stitch scans and object
    % captured by specialized devices. Use cv.Stitcher.Stitcher to get
    % preconfigured pipeline for one of those models.
    %
    % Note: Certain detailed settings of cv.Stitcher might not make sense.
    % Especially you should not mix classes implementing affine model and
    % classes implementing Homography model, as they work with different
    % transformations.
    %
    % ## Example
    % * A basic example on image stitching can be found in the
    %   `stitching_demo.m` sample
    % * A detailed example on image stitching can be found in the
    %   `stitching_detailed_demo.m` sample.
    %
    % ## References
    % [BL07]:
    % > Matthew Brown and David G Lowe.
    % > "Automatic panoramic image stitching using invariant features".
    % > International journal of computer vision, 74(1):59-73, 2007.
    %
    % See also: cv.Stitcher.Stitcher
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % Registration resolution. default 0.6
        RegistrationResol
        % Seam estimation resolution. default 1
        SeamEstimationResol
        % Compositing resolution. default 'Orig'
        CompositingResol
        % Panorama confidence threshold. default 1
        PanoConfidenceThresh
        % Whether it should try to make panorama more horizontal (or vertical).
        % default true
        WaveCorrection
        % Correction kind. default 'Horiz'
        WaveCorrectKind
    end

    methods
        function this = Stitcher(varargin)
            %STITCHER  Creates a Stitcher configured in one of the stitching modes
            %
            %     obj = cv.Stitcher()
            %     obj = cv.Stitcher('OptionName',optionValue, ...)
            %
            % ## Options
            % * __Mode__ Scenario for stitcher operation. This is usually
            %   determined by source of images to stitch and their
            %   transformation. Default parameters will be chosen for
            %   operation in given scenario. Default 'Panorama'. One of:
            %   * __Panorama__ Mode for creating photo panoramas. Expects
            %     images under perspective transformation and projects
            %     resulting pano to sphere. See also `BestOf2NearestMatcher`,
            %     `SphericalWarper`.
            %   * __Scans__ Mode for composing scans. Expects images under
            %     affine transformation does not compensate exposure by
            %     default. See also `AffineBestOf2NearestMatcher`,
            %     `AffineWarper`
            % * __TryUseGPU__ Flag indicating whether GPU should be used
            %   whenever it's possible. default false
            %
            % See also: cv.Stitcher.stitch
            %
            this.id = Stitcher_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.Stitcher
            %
            if isempty(this.id), return; end
            Stitcher_(this.id, 'delete');
        end
    end

    methods
        function pano = stitch(this, images, varargin)
            %STITCH  Tries to stitch the given images
            %
            %     pano = obj.stitch(images)
            %     pano = obj.stitch(images, rois)
            %     [pano, status] = obj.stitch(...)
            %
            % ## Input
            % * __images__ Input cell-array of images.
            % * __rois__ Optional region of interest rectangles, a cell-array
            %   of cell-arrays of 4-elements vectors `{{[x,y,w,h], ...}, ...}`
            %   or `{[x,y,w,h; ...], ...}`.
            %
            % ## Output
            % * __pano__ Final pano.
            % * __status__ optional output status code. If not requested, the
            %   function throws an error if the operation fails. A string one
            %   of:
            %   * __OK__
            %   * **ERR_NEED_MORE_IMGS**
            %   * **ERR_HOMOGRAPHY_EST_FAIL**
            %   * **ERR_CAMERA_PARAMS_ADJUST_FAIL**
            %
            % The function throws an error if the stitch function returns a
            % non-OK status code.
            %
            % See also: cv.Stitcher.estimateTransform,
            %  cv.Stitcher.composePanorama
            %
            pano = Stitcher_(this.id, 'stitch', images, varargin{:});
        end

        function estimateTransform(this, images, varargin)
            %ESTIMATETRANSFORM  Estimate transformation
            %
            %     obj.estimateTransform(images)
            %     obj.estimateTransform(images, rois)
            %     status = obj.estimateTransform(...)
            %
            % ## Input
            % * __images__ Input cell-array of images.
            % * __rois__ Optional region of interest rectangles, a cell-array
            %   of cell-arrays of 4-elements vectors `{{[x,y,w,h], ...}, ...}`
            %   or `{[x,y,w,h; ...], ...}`.
            %
            % ## Output
            % * __status__ optional output status code. If not requested, the
            %   function throws an error if the operation fails. A string one
            %   of:
            %   * __OK__
            %   * **ERR_NEED_MORE_IMGS**
            %   * **ERR_HOMOGRAPHY_EST_FAIL**
            %   * **ERR_CAMERA_PARAMS_ADJUST_FAIL**
            %
            % This function tries to match the given images and to estimate
            % rotations of each camera.
            %
            % Note: Use the function only if you're aware of the stitching
            % pipeline, otherwise use cv.Stitcher.stitch.
            %
            % See also: cv.Stitcher.composePanorama
            %
            Stitcher_(this.id, 'estimateTransform', images, varargin{:});
        end

        function pano = composePanorama(this, varargin)
            %COMPOSEPANORAMA  Compose panorama
            %
            %     pano = obj.composePanorama()
            %     pano = obj.composePanorama(images)
            %     [pano, status] = obj.composePanorama(...)
            %
            % ## Input
            % * __images__ Input cell-array of images.
            %
            % ## Output
            % * __pano__ Final pano.
            % * __status__ optional output status code. If not requested, the
            %   function throws an error if the operation fails. A string one
            %   of:
            %   * __OK__
            %   * **ERR_NEED_MORE_IMGS**
            %   * **ERR_HOMOGRAPHY_EST_FAIL**
            %   * **ERR_CAMERA_PARAMS_ADJUST_FAIL**
            %
            % This function tries to compose the given images (or images
            % stored internally from the other function calls) into the final
            % `pano` under the assumption that the image transformations were
            % estimated before.
            %
            % Note: Use the function only if you're aware of the stitching
            % pipeline, otherwise use cv.Stitcher.stitch.
            %
            % See also: cv.Stitcher.estimateTransform
            %
            pano = Stitcher_(this.id, 'composePanorama', varargin{:});
        end

        function indices = component(this)
            %COMPONENT  Image indices
            %
            %     indices = obj.component()
            %
            % ## Output
            % * __indices__ Vector of integer indices (0-based).
            %
            % See also: cv.Stitcher.cameras, cv.Stitcher.workScale
            %
            indices = Stitcher_(this.id, 'component');
        end

        function params = cameras(this)
            %CAMERAS  Estimates camera parameters
            %
            %     params = obj.cameras()
            %
            % ## Output
            % * __params__ Describes camera parameters, a struct-array with
            %   the following fields:
            %   * __aspect__ Aspect ratio.
            %   * __focal__ Focal length.
            %   * __ppx__ Principal point X.
            %   * __ppy__ Principal point Y.
            %   * __R__ 3x3 camera rotation matrix.
            %   * __t__ 3x1 camera translation vector.
            %   * __K__ 3x3 camera intrinsic parameters.
            %
            % Note: Translation is assumed to be zero during the whole
            % stitching pipeline.
            %
            % See also: cv.Stitcher.component, cv.Stitcher.workScale
            %
            params = Stitcher_(this.id, 'cameras');
        end

        function wscale = workScale(this)
            %WORKSCALE  Work scale
            %
            %     wscale = obj.workScale()
            %
            % ## Output
            % * __wscale__ scalar double value.
            %
            % See also: cv.Stitcher.cameras, cv.Stitcher.component
            %
            wscale = Stitcher_(this.id, 'workScale');
        end
    end

    methods
        function mask = getMatchingMask(this)
            %GETMATCHINGMASK
            %
            %     mask = obj.getMatchingMask()
            %
            % ## Output
            % * __mask__
            %
            % See also: cv.Stitcher.setMatchingMask
            %
            mask = Stitcher_(this.id, 'getMatchingMask');
        end

        function setMatchingMask(this, mask)
            %SETMATCHINGMASK
            %
            %     obj.setMatchingMask(mask)
            %
            % ## Input
            % * __mask__
            %
            % See also: cv.Stitcher.getMatchingMask
            %
            Stitcher_(this.id, 'setMatchingMask', mask);
        end

        function value = getFeaturesFinder(this)
            %GETFEATURESFINDER  Get the features finder
            %
            %     value = obj.getFeaturesFinder()
            %
            % ## Output
            % * __value__ output scalar struct.
            %
            % See also: cv.Stitcher.setFeaturesFinder
            %
            value = Stitcher_(this.id, 'getFeaturesFinder');
        end

        function setFeaturesFinder(this, finderType, varargin)
            %SETFEATURESFINDER  Set the features finder
            %
            %     obj.setFeaturesFinder(finderType)
            %     obj.setFeaturesFinder(finderType, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __finderType__ Feature finder type. One of:
            %   * __OrbFeaturesFinder__ ORB features finder. See cv.ORB
            %   * __AKAZEFeaturesFinder__ AKAZE features finder. See cv.AKAZE
            %   * __SurfFeaturesFinder__ SURF features finder. See cv.SURF
            %     (requires `xfeatures2d` module)
            %   * __SurfFeaturesFinderGpu__ (requires CUDA and `xfeatures2d`
            %     module)
            %
            % ## Options
            % The following are options for the various finders:
            %
            % ### `OrbFeaturesFinder`
            % * __GridSize__ default [3,1]
            % * __NFeatures__ default 1500
            % * __ScaleFactor__ default 1.3
            % * __NLevels__ default 5
            %
            % ### `AKAZEFeaturesFinder`
            % * __DescriptorType__ default 'MLDB'
            % * __DescriptorSize__ default 0
            % * __DescriptorChannels__ default 3
            % * __Threshold__ default 0.001
            % * __NOctaves__ default 4
            % * __NOctaveLayers__ default 4
            % * __Diffusivity__ default `PM_G2`
            %
            % ### `SurfFeaturesFinder`
            % * __HessThresh__ default 300.0
            % * __NumOctaves__ default 3
            % * __NumLayers__ default 4
            % * __NumOctaveDescr__ default 3
            % * __NumLayersDesc__ default 4
            %
            % The class uses `OrbFeaturesFinder` by default or
            % `SurfFeaturesFinder` if `xfeatures2d` module is available.
            %
            % See also: cv.Stitcher.getFeaturesFinder, cv.FeaturesMatcher
            %
            Stitcher_(this.id, 'setFeaturesFinder', finderType, varargin{:});
        end

        function value = getFeaturesMatcher(this)
            %GETFEATURESMATCHER  Get the features matcher
            %
            %     value = obj.getFeaturesMatcher()
            %
            % ## Output
            % * __value__ output scalar struct.
            %
            % See also: cv.Stitcher.setFeaturesMatcher
            %
            value = Stitcher_(this.id, 'getFeaturesMatcher');
        end

        function setFeaturesMatcher(this, matcherType, varargin)
            %SETFEATURESMATCHER  Set the features matcher
            %
            %     obj.setFeaturesMatcher(matcherType)
            %     obj.setFeaturesMatcher(matcherType, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __matcherType__ Feature matcher type. One of:
            %   * __BestOf2NearestMatcher__ A "best of 2 nearest" matcher.
            %     Features matcher which finds two best matches for each
            %     feature and leaves the best one only if the ratio between
            %     descriptor distances is greater than the threshold
            %     `MatchConf`.
            %   * __BestOf2NearestRangeMatcher__
            %   * __AffineBestOf2NearestMatcher__ A "best of 2 nearest"
            %     matcher that expects affine trasformation between images.
            %     Features matcher similar to `BestOf2NearestMatcher` which
            %     finds two best matches for each feature and leaves the best
            %     one only if the ratio between descriptor distances is
            %     greater than the threshold `MatchConf`. Unlike
            %     `BestOf2NearestMatcher` this matcher uses affine
            %     transformation (affine trasformation estimate will be placed
            %     in `matches_info`).
            %
            % ## Options
            % The following are options accepted by all matchers:
            %
            % * __TryUseGPU__ Should try to use GPU or not. default false
            % * __MatchConf__ Match distances ration threshold. default 0.3
            % * __NumMatchesThresh1__ Minimum number of matches required for
            %   the 2D projective transform estimation used in the inliers
            %   classification step. default 6
            % * __NumMatchesThresh2__ Minimum number of matches required for
            %   the 2D projective transform re-estimation on inliers.
            %   default 6
            %
            % The following are options for the various algorithms:
            %
            % ### `BestOf2NearestRangeMatcher`
            % * __RangeWidth__ default 5
            %
            % ### `AffineBestOf2NearestMatcher`
            % * __FullAffine__ whether to use full affine transformation with
            %   6 degress of freedom or reduced transformation with 4 degrees
            %   of freedom using only rotation, translation and uniform
            %   scaling. default false
            %
            % The class uses `BestOf2NearestMatcher` by default.
            %
            % See also: cv.Stitcher.getFeaturesMatcher, cv.FeaturesMatcher
            %
            Stitcher_(this.id, 'setFeaturesMatcher', matcherType, varargin{:});
        end

        %{
        function value = getEstimator(this)
            %GETESTIMATOR  Get the estimator
            %
            %     value = obj.getEstimator()
            %
            % ## Output
            % * __value__ output scalar struct.
            %
            % See also: cv.Stitcher.setEstimator
            %
            value = Stitcher_(this.id, 'getEstimator');
        end

        function setEstimator(this, estimatorType, varargin)
            %SETESTIMATOR  Set the estimator
            %
            %     obj.setEstimator(estimatorType)
            %     obj.setEstimator(estimatorType, 'OptionName',optionValue, ...)
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
            % See also: cv.Stitcher.getEstimator. cv.Estimator
            %
            Stitcher_(this.id, 'setEstimator', estimatorType, varargin{:});
        end
        %}

        function value = getBundleAdjuster(this)
            %GETBUNDLEADJUSTER  Get the bundle adjuster
            %
            %     value = obj.getBundleAdjuster()
            %
            % ## Output
            % * __value__ output scalar struct.
            %
            % See also: cv.Stitcher.setBundleAdjuster
            %
            value = Stitcher_(this.id, 'getBundleAdjuster');
        end

        function setBundleAdjuster(this, adjusterType, varargin)
            %SETBUNDLEADJUSTER  Set the bundle adjuster
            %
            %     obj.setBundleAdjuster(adjusterType)
            %     obj.setBundleAdjuster(adjusterType, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __adjusterType__ camera parameters refinement method. One of:
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
            %     Refinement mask is ignored. See also
            %     cv.AffineBasedEstimator, `AffineBestOf2NearestMatcher`.
            %   * __BundleAdjusterAffinePartial__ Bundle adjuster that expects
            %     affine transformation with 4 DOF represented in homogeneous
            %     coordinates in R for each camera param. Implements camera
            %     parameters refinement algorithm which minimizes sum of the
            %     reprojection error squares. It estimates all transformation
            %     parameters. Refinement mask is ignored.
            %
            % ## Options
            % The following are options accepted by all adjusters:
            %
            % * __ConfThresh__ default 1
            % * __RefinementMask__ default `eye(3)`
            % * __TermCriteria__ default
            %   `struct('type','Count+EPS', 'maxCount',1000, 'epsilon',eps)`
            %
            % The class uses `BundleAdjusterRay` by default.
            %
            % See also: cv.Stitcher.getBundleAdjuster, cv.BundleAdjuster
            %
            Stitcher_(this.id, 'setBundleAdjuster', adjusterType, varargin{:});
        end

        function value = getWarper(this)
            %GETWARPER  Get the warper
            %
            %     value = obj.getWarper()
            %
            % ## Output
            % * __value__ output scalar struct.
            %
            % See also: cv.Stitcher.setWarper
            %
            value = Stitcher_(this.id, 'getWarper');
        end

        function setWarper(this, warperType, varargin)
            %SETWARPER  Set the image warper
            %
            %     obj.setWarper(warperType)
            %     obj.setWarper(warperType, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __warperType__ image warper factory class type, used to create
            %   the rotation-based warper. One of:
            %   * __PlaneWarper__ Plane warper factory class. Warper that maps
            %     an image onto the `z = 1` plane.
            %   * __PlaneWarperGpu__ (requires CUDA)
            %   * __AffineWarper__ Affine warper factory class. Affine warper
            %     that uses rotations and translations. Uses affine
            %     transformation in homogeneous coordinates to represent both
            %     rotation and translation in camera rotation matrix.
            %   * __CylindricalWarper__ Cylindrical warper factory class.
            %     Warper that maps an image onto the `x*x + z*z = 1` cylinder.
            %   * __CylindricalWarperGpu__ (requires CUDA)
            %   * __SphericalWarper__ Warper that maps an image onto the unit
            %     sphere located at the origin. Projects image onto unit
            %     sphere with origin at [0,0,0] and radius `scale`, measured
            %     in pixels. A 360 panorama would therefore have a resulting
            %     width of `2*scale*pi` pixels. Poles are located at [0,-1,0]
            %     and [0,1,0] points.
            %   * __SphericalWarperGpu__ (requires CUDA)
            %   * __FisheyeWarper__
            %   * __StereographicWarper__
            %   * __CompressedRectilinearWarper__
            %   * __CompressedRectilinearPortraitWarper__
            %   * __PaniniWarper__
            %   * __PaniniPortraitWarper__
            %   * __MercatorWarper__
            %   * __TransverseMercatorWarper__
            %
            % ## Options
            % The following are options for the various warpers:
            %
            % ### `CompressedRectilinearWarper`, `CompressedRectilinearPortraitWarper`, `PaniniWarper`, `PaniniPortraitWarper`
            % * __A__ default 1
            % * __B__ default 1
            %
            % The class uses `SphericalWarper` by default.
            %
            % See also: cv.Stitcher.getWarper, cv.RotationWarper
            %
            Stitcher_(this.id, 'setWarper', warperType, varargin{:});
        end

        function value = getExposureCompensator(this)
            %GETEXPOSURECOMPENSATOR  Get the exposire compensator
            %
            %     value = obj.getExposureCompensator()
            %
            % ## Output
            % * __value__ output scalar struct.
            %
            % See also: cv.Stitcher.setExposureCompensator
            %
            value = Stitcher_(this.id, 'getExposureCompensator');
        end

        function setExposureCompensator(this, compensatorType, varargin)
            %SETEXPOSURECOMPENSATOR  Set the exposure compensator
            %
            %     obj.setExposureCompensator(compensatorType)
            %     obj.setExposureCompensator(compensatorType, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __compensatorType__ exposure compensator type. One of:
            %   * __NoExposureCompensator__ Stub exposure compensator which
            %     does nothing.
            %   * __GainCompensator__ Exposure compensator which tries to
            %     remove exposure related artifacts by adjusting image
            %     intensities, see [BL07] and [WJ10] for details.
            %   * __BlocksGainCompensator__ Exposure compensator which tries
            %     to remove exposure related artifacts by adjusting image
            %     block intensities, see [UES01] for details.
            %
            % ## Options
            % The following are options for the various compensators:
            %
            % ### `BlocksGainCompensator`
            % * __Width__ Block width. default 32
            % * __Heigth__ Block height. default 32
            %
            % The class uses `BlocksGainCompensator` by default.
            %
            % ## References
            % [BL07]:
            % > Matthew Brown and David G Lowe.
            % > "Automatic panoramic image stitching using invariant features".
            % > International journal of computer vision, 74(1):59-73, 2007.
            %
            % [WJ10]:
            % > Wei Xu and Jane Mulligan. "Performance evaluation of color
            % > correction approaches for automatic multi-view image and video
            % > stitching". In Computer Vision and Pattern Recognition (CVPR),
            % > 2010 IEEE Conference on, pages 263-270. IEEE, 2010.
            %
            % [UES01]:
            % > Matthew Uyttendaele, Ashley Eden, and R Skeliski.
            % > "Eliminating ghosting and exposure artifacts in image mosaics".
            % > In Computer Vision and Pattern Recognition, 2001. CVPR 2001.
            % > Proceedings of the 2001 IEEE Computer Society Conference on,
            % > volume 2, pages II-509. IEEE, 2001.
            %
            % See also: cv.Stitcher.getExposureCompensator,
            %  cv.ExposureCompensator
            %
            Stitcher_(this.id, 'setExposureCompensator', compensatorType, varargin{:});
        end

        function value = getSeamFinder(this)
            %GETSEAMFINDER  Get the seam finder
            %
            %     value = obj.getSeamFinder()
            %
            % ## Output
            % * __value__ output scalar struct.
            %
            % See also: cv.Stitcher.setSeamFinder
            %
            value = Stitcher_(this.id, 'getSeamFinder');
        end

        function setSeamFinder(this, seamType, varargin)
            %SETSEAMFINDER  Set the seam finder
            %
            %     obj.setSeamFinder(seamType)
            %     obj.setSeamFinder(seamType, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __seamType__ seam estimator type. One of:
            %   * __NoSeamFinder__ Stub seam estimator which does nothing.
            %   * __VoronoiSeamFinder__ Voronoi diagram-based pairwise seam
            %     estimator.
            %   * __DpSeamFinder__
            %   * __GraphCutSeamFinder__ Minimum graph cut-based seam
            %     estimator. See details in [V03].
            %   * __GraphCutSeamFinderGpu__ (requires CUDA)
            %
            % ## Options
            % The following are options for the various seam finders:
            %
            % ### `DpSeamFinder`
            % * __CostFunction__ default 'Color'. One of:
            %   * __Color__
            %   * __ColorGrad__
            %
            % ### `GraphCutSeamFinder`
            % * __CostType__ default 'ColorGrad'. One of:
            %   * __Color__
            %   * __ColorGrad__
            % * __TerminalCost__ default 10000.0
            % * __BadRegionPenaly__ default 1000.0
            %
            % The class uses `GraphCutSeamFinder` by default.
            %
            % ## References
            % [V03]:
            % > Vivek Kwatra, Arno Schodl, Irfan Essa, Greg Turk, and Aaron
            % > Bobick. "Graphcut textures: image and video synthesis using
            % > graph cuts". In ACM Transactions on Graphics (ToG), volume 22,
            % > pages 277-286. ACM, 2003.
            %
            % See also: cv.Stitcher.getSeamFinder, cv.SeamFinder
            %
            Stitcher_(this.id, 'setSeamFinder', seamType, varargin{:});
        end

        function value = getBlender(this)
            %GETBLENDER  Get the blender
            %
            %     value = obj.getBlender()
            %
            % ## Output
            % * __value__ output scalar struct.
            %
            % See also: cv.Stitcher.setBlender
            %
            value = Stitcher_(this.id, 'getBlender');
        end

        function setBlender(this, blenderType, varargin)
            %SETBLENDER  Set the blender
            %
            %     obj.setBlender(blenderType)
            %     obj.setBlender(blenderType, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __blenderType__ image blender type. One of:
            %   * __NoBlender__ Simple blender which puts one image over
            %     another.
            %   * __FeatherBlender__ Simple blender which mixes images at its
            %     borders.
            %   * __MultiBandBlender__ Blender which uses multi-band blending
            %     algorithm (see [BA83]).
            %
            % ## Options
            % The following are options for the various blenders:
            %
            % ### `FeatherBlender`
            % * __Sharpness__ default 0.02
            %
            % ### `MultiBandBlender`
            % * __TryGPU__ default false
            % * __NumBands__ default 5
            % * __WeightType__ One of:
            %   * __single__ (default)
            %   * __int16__
            %
            % The class uses `MultiBandBlender` by default.
            %
            % ## References
            % [BA83]:
            % > Peter J Burt and Edward H Adelson.
            % > "A multiresolution spline with application to image mosaics".
            % > ACM Transactions on Graphics (TOG), 2(4):217-236, 1983.
            %
            % See also: cv.Stitcher.getBlender, cv.Blender
            %
            Stitcher_(this.id, 'setBlender', blenderType, varargin{:});
        end
    end

    %% Getters/Setters
    methods
        function value = get.RegistrationResol(this)
            value = Stitcher_(this.id, 'get', 'RegistrationResol');
        end
        function set.RegistrationResol(this, value)
            Stitcher_(this.id, 'set', 'RegistrationResol', value);
        end

        function value = get.SeamEstimationResol(this)
            value = Stitcher_(this.id, 'get', 'SeamEstimationResol');
        end
        function set.SeamEstimationResol(this, value)
            Stitcher_(this.id, 'set', 'SeamEstimationResol', value);
        end

        function value = get.CompositingResol(this)
            value = Stitcher_(this.id, 'get', 'CompositingResol');
        end
        function set.CompositingResol(this, value)
            Stitcher_(this.id, 'set', 'CompositingResol', value);
        end

        function value = get.PanoConfidenceThresh(this)
            value = Stitcher_(this.id, 'get', 'PanoConfidenceThresh');
        end
        function set.PanoConfidenceThresh(this, value)
            Stitcher_(this.id, 'set', 'PanoConfidenceThresh', value);
        end

        function value = get.WaveCorrection(this)
            value = Stitcher_(this.id, 'get', 'WaveCorrection');
        end
        function set.WaveCorrection(this, value)
            Stitcher_(this.id, 'set', 'WaveCorrection', value);
        end

        function value = get.WaveCorrectKind(this)
            value = Stitcher_(this.id, 'get', 'WaveCorrectKind');
        end
        function set.WaveCorrectKind(this, value)
            Stitcher_(this.id, 'set', 'WaveCorrectKind', value);
        end
    end

end
