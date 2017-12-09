classdef OnePassStabilizer < handle
    %ONEPASSSTABILIZER  A one-pass video stabilizer
    %
    % The video stabilization module contains a set of functions and classes
    % that can be used to solve the problem of video stabilization. There are
    % a few methods implemented, most of them are described in the papers
    % [OF06] and [G11]. However, there are some extensions and deviations from
    % the original paper methods.
    %
    % The video stabilization module contains a set of functions and classes
    % for global motion estimation between point clouds or between images. In
    % the last case features are extracted and matched internally.
    %
    % ## References
    % [OF06]:
    % > Yasuyuki Matsushita, Eyal Ofek, Weina Ge, Xiaoou Tang, Heung-Yeung Shum.
    % > "Full-frame video stabilization with motion inpainting".
    % > Pattern Analysis and Machine Intelligence, IEEE Transactions on,
    % > 28(7):1150-1163, 2006.
    %
    % [G11]:
    % > Matthias Grundmann, Vivek Kwatra, and Irfan Essa.
    % > "Auto-directed video stabilization with robust L1 optimal camera paths".
    % > In Computer Vision and Pattern Recognition (CVPR), 2011 IEEE Conference
    % > on, pages 225-232. IEEE, 2011.
    %
    % See also: cv.TwoPassStabilizer
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % default 15
        Radius
        % default 0
        TrimRatio
        % default false
        CorrectionForInclusion
        % default 'Replicate', see cv.copyMakeBorder
        BorderMode
    end

    methods
        function this = OnePassStabilizer()
            %ONEPASSSTABILIZER  Constructor
            %
            %     obj = cv.OnePassStabilizer()
            %
            % See also: cv.OnePassStabilizer.nextFrame
            %
            this.id = OnePassStabilizer_(0, 'new');
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.OnePassStabilizer
            %
            if isempty(this.id), return; end
            OnePassStabilizer_(this.id, 'delete');
        end
    end

    %% IFrameSource
    methods
        function frame = nextFrame(this, varargin)
            %NEXTFRAME  Process next frame from input and return output result
            %
            %     frame = obj.nexFrame()
            %     frame = obj.nexFrame('OptionName',optionValue, ...)
            %
            % ## Options
            % * __FlipChannels__ in case the output is color image, flips the
            %   color order from OpenCV's BGR/BGRA to MATLAB's RGB/RGBA order.
            %   default false
            %
            % ## Output
            % * __frame__ Output result
            %
            % See also: cv.OnePassStabilizer.reset
            %
            frame = OnePassStabilizer_(this.id, 'nextFrame', varargin{:});
        end

        function reset(this)
            %RESET  Reset the frame source
            %
            %     obj.reset()
            %
            % See also: cv.OnePassStabilizer.nextFrame
            %
            OnePassStabilizer_(this.id, 'reset');
        end
    end

    %% StabilizeBase
    methods
        function setLog(this, logType)
            %SETLOG  Set logger class for the video stabilizer
            %
            %     stab.setLog(logType)
            %
            % ## Input
            % * __logType__ Logging type. One of:
            %   * __NullLog__ no logging.
            %   * __LogToStdout__ (default) log messages to standard output.
            %     Note that standard output is not displayed in MATLAB, you
            %     should use `LogToMATLAB` instead.
            %   * __LogToMATLAB__ log messages to MATLAB command window.
            %
            % The class uses `LogToStdout` by default.
            %
            % See also: cv.OnePassStabilizer.getLog
            %
            OnePassStabilizer_(this.id, 'setLog', logType);
        end
        function value = getLog(this)
            %GETLOG  Get the current logger class
            %
            %     value = stab.getLog()
            %
            % ## Output
            % * __value__ output scalar struct
            %
            % See also: cv.OnePassStabilizer.setLog
            %
            value = OnePassStabilizer_(this.id, 'getLog');
        end

        function setFrameSource(this, frameSourceType, varargin)
            %SETFRAMESOURCE  Set input frame source for the video stabilizer
            %
            %     stab.setInput(frameSourceType, ...)
            %
            %     stab.setFrameSource('NullFrameSource')
            %     stab.setFrameSource('VideoFileSource', filename)
            %     stab.setFrameSource('VideoFileSource', filename, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __frameSourceType__ Input frames source type. One of:
            %   * __NullFrameSource__
            %   * __VideoFileSource__ wrapper around cv.VideoCapture with a
            %     video file or image sequence as source.
            % * __filename__ name of the opened video file (eg. `video.avi`)
            %   or image sequence (eg. `img_%02d.jpg`, which will read samples
            %   like `img_00.jpg`, `img_01.jpg`, `img_02.jpg`, ...)
            %
            % ## Options
            % * __VolatileFrame__ default false
            %
            % The class uses `NullFrameSource` by default.
            %
            % See also: cv.OnePassStabilizer.getFrameSource
            %
            OnePassStabilizer_(this.id, 'setFrameSource', frameSourceType, varargin{:});
        end
        function value = getFrameSource(this)
            %GETFRAMESOURCE  Get the current input frame source
            %
            %     value = stab.getFrameSource()
            %
            % ## Output
            % * __value__ output scalar struct
            %
            % See also: cv.OnePassStabilizer.setFrameSource
            %
            value = OnePassStabilizer_(this.id, 'getFrameSource');
        end

        function setMotionEstimator(this, motionEstType, varargin)
            %SETMOTIONESTIMATOR  Set the motion estimating algorithm for the video stabilizer
            %
            %     stab.setMotionEstimator(motionEstType, ...)
            %
            %     stab.setMotionEstimator('KeypointBasedMotionEstimator', {estType, ...}, 'OptionName',optionValue, ...)
            %     stab.setMotionEstimator('FromFileMotionReader', path, 'OptionName',optionValue, ...)
            %     stab.setMotionEstimator('ToFileMotionWriter', path, {motionEstType, ...}, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __motionEstType__ Global 2D motion estimation methods which
            %   take frames as input. One of:
            %   * __KeypointBasedMotionEstimator__ Describes a global 2D
            %     motion estimation method which uses keypoints detection and
            %     optical flow for matching.
            %   * __FromFileMotionReader__
            %   * __ToFileMotionWriter__
            % * __path__ name of file for motion to read-from/write-to.
            % * __estType__ Global motion estimation method, which estimates
            %   global motion between two 2D point clouds as a 3x3 2D
            %   transformation matrix. One of:
            %   * __MotionEstimatorL1__ Describes a global 2D motion
            %     estimation method which minimizes L1 error. Note: To be able
            %     to use this method you must build OpenCV with CLP library
            %     support.
            %   * __MotionEstimatorRansacL2__ Describes a robust RANSAC-based
            %     global 2D motion estimation method which minimizes L2 error.
            %
            % ## Options
            % The following are options for the various algorithms:
            %
            % ### `KeypointBasedMotionEstimator`, `FromFileMotionReader`, `ToFileMotionWriter`
            % * __MotionModel__ Describes motion model between two point
            %   clouds. Default is based on the estimation method. One of:
            %   * __Translation__
            %   * __TranslationAndScale__
            %   * __Rotation__
            %   * __Rigid__
            %   * __Similarity__
            %   * __Affine__
            %   * __Homography__
            %   * __Unknown__
            %
            % ### `KeypointBasedMotionEstimator`
            % * __Detector__ feature detector, specified in the form:
            %   `{detectorType, 'OptionName',optionValue, ...}`. See
            %   cv.FeatureDetector.FeatureDetector for a list of supported
            %   feature detectors. Default is `{'GFTTDetector'}`.
            % * __OpticalFlowEstimator__ sparse optical flow estimator
            %   specified as: `{optflowType, 'OptionName',optionValue, ...}`,
            %   where `optflowType` is one of:
            %   * __SparsePyrLkOptFlowEstimator__ (default) wrapper around
            %     cv.calcOpticalFlowPyrLK.
            %   * __SparsePyrLkOptFlowEstimatorGpu__
            % * __OutlierRejector__ outlier rejector specified as:
            %   `{rejectorType, 'OptionName',optionValue, ...}`, where
            %   `rejectorType` is one of:
            %   * __NullOutlierRejector__ (default)
            %   * __TranslationBasedLocalOutlierRejector__
            %
            % ### `MotionEstimatorL1` and `MotionEstimatorRansacL2`
            % * __MotionModel__ Describes motion model between two point
            %   clouds. One of:
            %   * __Translation__
            %   * __TranslationAndScale__
            %   * __Rotation__
            %   * __Rigid__
            %   * __Similarity__
            %   * __Affine__ (default)
            %   * __Homography__
            %   * __Unknown__
            %
            % ### `MotionEstimatorRansacL2`
            % * __MinInlierRatio__ default 0.1
            % * __RansacParams__ Describes RANSAC method parameters. A struct
            %   with the following fields:
            %   * __Size__ Subset size.
            %   * __Thresh__ Maximum re-projection error value to classify as
            %     inlier.
            %   * __Eps__ Maximum ratio of incorrect correspondences.
            %   * __Prob__ Required success probability.
            %
            %   If a string is passed, it uses the default RANSAC parameters
            %   for the given motion model. Here are the defaults
            %   corresponding to each motion model:
            %
            %   * __Translation__ `struct('Size',1, 'Thresh',0.5, 'Eps',0.5, 'Prob',0.99)`
            %   * __TranslationAndScale__ `struct('Size',2, 'Thresh',0.5, 'Eps',0.5, 'Prob',0.99)`
            %   * __Rotation__ `struct('Size',1, 'Thresh',0.5, 'Eps',0.5, 'Prob',0.99)`
            %   * __Rigid__ `struct('Size',2, 'Thresh',0.5, 'Eps',0.5, 'Prob',0.99)`
            %   * __Similarity__ `struct('Size',2, 'Thresh',0.5, 'Eps',0.5, 'Prob',0.99)`
            %   * __Affine__ `struct('Size',3, 'Thresh',0.5, 'Eps',0.5, 'Prob',0.99)`
            %   * __Homography__ `struct('Size',4, 'Thresh',0.5, 'Eps',0.5, 'Prob',0.99)`
            %
            %   By default is it set to 'Affine'.
            %
            % ### `SparsePyrLkOptFlowEstimator`
            % * __WinSize__ Size of the search window at each pyramid level.
            %   default [21,21]
            % * __MaxLevel__ 0-based maximal pyramid level number. default 3
            %
            % ### `TranslationBasedLocalOutlierRejector`
            % * __CellSize__ default [50,50]
            % * __RansacParams__ Describes RANSAC method parameters. A struct
            %   with the following fields:
            %   * __Size__ Subset size.
            %   * __Thresh__ Maximum re-projection error value to classify as
            %     inlier.
            %   * __Eps__ Maximum ratio of incorrect correspondences.
            %   * __Prob__ Required success probability.
            %
            %   If a string is passed, it uses the default RANSAC parameters
            %   for the given motion model. Here are the defaults
            %   corresponding to each motion model:
            %
            %   * __Translation__ `struct('Size',1, 'Thresh',0.5, 'Eps',0.5, 'Prob',0.99)`
            %   * __TranslationAndScale__ `struct('Size',2, 'Thresh',0.5, 'Eps',0.5, 'Prob',0.99)`
            %   * __Rotation__ `struct('Size',1, 'Thresh',0.5, 'Eps',0.5, 'Prob',0.99)`
            %   * __Rigid__ `struct('Size',2, 'Thresh',0.5, 'Eps',0.5, 'Prob',0.99)`
            %   * __Similarity__ `struct('Size',2, 'Thresh',0.5, 'Eps',0.5, 'Prob',0.99)`
            %   * __Affine__ `struct('Size',3, 'Thresh',0.5, 'Eps',0.5, 'Prob',0.99)`
            %   * __Homography__ `struct('Size',4, 'Thresh',0.5, 'Eps',0.5, 'Prob',0.99)`
            %
            %   By default is it set to 'Translation'.
            %
            % The class uses `KeypointBasedMotionEstimator` by default with
            % `MotionEstimatorRansacL2`.
            %
            % See also: cv.OnePassStabilizer.getMotionEstimator
            %
            OnePassStabilizer_(this.id, 'setMotionEstimator', motionEstType, varargin{:});
        end
        function value = getMotionEstimator(this)
            %GETMOTIONESTIMATOR  Get the current motion estimating algorithm
            %
            %     value = stab.getMotionEstimator()
            %
            % ## Output
            % * __value__ output scalar struct
            %
            % See also: cv.OnePassStabilizer.setMotionEstimator
            %
            value = OnePassStabilizer_(this.id, 'getMotionEstimator');
        end

        function setDeblurer(this, deblurerType, varargin)
            %SETDEBLURER  Set the deblurring algorithm for the video stabilizer
            %
            %     stab.setDeblurer(deblurerType, ...)
            %
            %     stab.setDeblurer('NullDeblurer')
            %     stab.setDeblurer('WeightingDeblurer', 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __deblurerType__ Deblurring method. One of:
            %   * __NullDeblurer__
            %   * __WeightingDeblurer__
            %
            % ## Options
            % * __Radius__ default 0
            % * __Sensitivity__ default 0.1
            %
            % The class uses `NullDeblurer` by default.
            %
            % See also: cv.OnePassStabilizer.getDeblurer
            %
            OnePassStabilizer_(this.id, 'setDeblurer', deblurerType, varargin{:});
        end
        function value = getDeblurer(this)
            %GETDEBLURER  Gets the current deblurring algorithm
            %
            %     value = stab.getDeblurer()
            %
            % ## Output
            % * __value__ output scalar struct
            %
            % See also: cv.OnePassStabilizer.setDeblurer
            %
            value = OnePassStabilizer_(this.id, 'getDeblurer');
        end

        function setInpainter(this, inpainterType, varargin)
            %SETINPAINTER  Set the inpainting algorithm for the video stabilizer
            %
            %     stab.setInpainter(inpainterType, ...)
            %
            %     stab.setInpainter('NullInpainter')
            %     stab.setInpainter('ColorInpainter', 'OptionName',optionValue, ...)
            %     stab.setInpainter('InpaintingPipeline', {{inpainterType, ...}, {inpainterType, ...}, ...}, 'OptionName',optionValue, ...)
            %     stab.setInpainter('ConsistentMosaicInpainter', 'OptionName',optionValue, ...)
            %     stab.setInpainter('MotionInpainter', 'OptionName',optionValue, ...)
            %     stab.setInpainter('ColorAverageInpainter', 'OptionName',optionValue, ...)
            %     stab.setInpainter('ColorInpainter', 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __inpainterType__ inpainting method. One of:
            %   * __NullInpainter__ Null inpainter.
            %   * __InpaintingPipeline__ A pipeline composed of other
            %     inpainters, applied in sequence.
            %   * __ConsistentMosaicInpainter__
            %   * __MotionInpainter__ (requires CUDA)
            %   * __ColorAverageInpainter__
            %   * __ColorInpainter__
            %
            % ## Options
            % The following are options accepted by all algorithms:
            %
            % * __MotionModel__ Describes motion model between two point
            %   clouds. One of:
            %   * __Translation__
            %   * __TranslationAndScale__
            %   * __Rotation__
            %   * __Rigid__
            %   * __Similarity__
            %   * __Affine__
            %   * __Homography__
            %   * __Unknown__ (default)
            % * __Radius__ default 0
            %
            % The following are options for the various algorithms:
            %
            % ### `ColorInpainter`
            % * __Method__ Inpainting algorithm. One of:
            %   * __NS__ Navier-Stokes based method
            %   * __Telea__ Method by Alexandru Telea (default)
            % * __Radius2__ default 2.0
            %
            % ### `ConsistentMosaicInpainter`
            % * __StdevThresh__ default 20.0
            %
            % ### `MotionInpainter`
            % * __OptFlowEstimator__ dense optical flow estimator specified as
            %   `{optflowType, 'OptionName',optionValue, ...}`, where
            %   `optflowType` is one of:
            %   * __DensePyrLkOptFlowEstimatorGpu__ (default, requires CUDA)
            % * __FlowErrorThreshold__ default 1e-4
            % * __DistThreshold__ default 5.0
            % * __BorderMode__ default 'Replicate'
            %
            % ### `InpaintingPipeline`
            % Same as the common ones, where values set will be propagated to
            % all inpainters in the pipeline.
            %
            % The class uses `NullInpainter` by default.
            %
            % See also: cv.OnePassStabilizer.getInpainter
            %
            OnePassStabilizer_(this.id, 'setInpainter', inpainterType, varargin{:});
        end
        function value = getInpainter(this)
            %GETINPAINTER  Gets the current inpainting algorithm
            %
            %     value = stab.getInpainter()
            %
            % ## Output
            % * __value__ output scalar struct
            %
            % See also: cv.OnePassStabilizer.setInpainter
            %
            value = OnePassStabilizer_(this.id, 'getInpainter');
        end
    end

    %% OnePassStabilizer
    methods
        function setMotionFilter(this, motionFilterType, varargin)
            %SETMOTIONFILTER  Set the motion filtering algorithm for the video stabilizer
            %
            %     stab.setMotionFilter(motionFilterType, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __motionFilterType__ motion filtering method. One of:
            %   * __GaussianMotionFilter__
            %
            % ## Options
            % * __Radius__ default 15
            % * __Stdev__ If negative, uses `sqrt(Radius)`. default -1.0
            %
            % The class uses `GaussianMotionFilter` by default.
            %
            % See also: cv.OnePassStabilizer.getMotionFilter
            %
            OnePassStabilizer_(this.id, 'setMotionFilter', motionFilterType, varargin{:});
        end
        function value = getMotionFilter(this)
            %GETMOTIONFILTER  Get the current motion filtering algorithm
            %
            %     value = stab.getMotionFilter()
            %
            % ## Output
            % * __value__ output scalar struct
            %
            % See also: cv.OnePassStabilizer.setMotionFilter
            %
            value = OnePassStabilizer_(this.id, 'getMotionFilter');
        end
    end

    %%
    methods (Static)
        function ransac = RansacParamsDefault2dMotion(model)
            %RANSACPARAMSDEFAULT2DMOTION  Default RANSAC method parameters for a given motion model
            %
            %     ransac = cv.OnePassStabilizer.RansacParamsDefault2dMotion(model)
            %
            % ## Input
            % * __model__ Motion model. One of:
            %   * __Translation__
            %   * __TranslationAndScale__
            %   * __Rotation__
            %   * __Rigid__
            %   * __Similarity__
            %   * __Affine__
            %   * __Homography__
            %
            % ## Output
            % * __ransac__ Default RANSAC method parameters for the given
            %   motion model. A struct with the following fields:
            %   * __Size__ Subset size.
            %   * __Thresh__ Maximum re-projection error value to classify as
            %     inlier.
            %   * __Eps__ Maximum ratio of incorrect correspondences.
            %   * __Prob__ Required success probability.
            %
            % Here are the parameters corresponding to each motion model:
            %
            % * __Translation__ `struct('Size',1, 'Thresh',0.5, 'Eps',0.5, 'Prob',0.99)`
            % * __TranslationAndScale__ `struct('Size',2, 'Thresh',0.5, 'Eps',0.5, 'Prob',0.99)`
            % * __Rotation__ `struct('Size',1, 'Thresh',0.5, 'Eps',0.5, 'Prob',0.99)`
            % * __Rigid__ `struct('Size',2, 'Thresh',0.5, 'Eps',0.5, 'Prob',0.99)`
            % * __Similarity__ `struct('Size',2, 'Thresh',0.5, 'Eps',0.5, 'Prob',0.99)`
            % * __Affine__ `struct('Size',3, 'Thresh',0.5, 'Eps',0.5, 'Prob',0.99)`
            % * __Homography__ `struct('Size',4, 'Thresh',0.5, 'Eps',0.5, 'Prob',0.99)`
            %
            % See also: cv.OnePassStabilizer.setMotionEstimator
            %
            ransac = OnePassStabilizer_(0, 'RansacParamsDefault2dMotion', model);
        end
    end

    %% Getters/Setters
    methods
        function value = get.Radius(this)
            value = OnePassStabilizer_(this.id, 'get', 'Radius');
        end
        function set.Radius(this, value)
            OnePassStabilizer_(this.id, 'set', 'Radius', value);
        end

        function value = get.TrimRatio(this)
            value = OnePassStabilizer_(this.id, 'get', 'TrimRatio');
        end
        function set.TrimRatio(this, value)
            OnePassStabilizer_(this.id, 'set', 'TrimRatio', value);
        end

        function value = get.CorrectionForInclusion(this)
            value = OnePassStabilizer_(this.id, 'get', 'CorrectionForInclusion');
        end
        function set.CorrectionForInclusion(this, value)
            OnePassStabilizer_(this.id, 'set', 'CorrectionForInclusion', value);
        end

        function value = get.BorderMode(this)
            value = OnePassStabilizer_(this.id, 'get', 'BorderMode');
        end
        function set.BorderMode(this, value)
            OnePassStabilizer_(this.id, 'set', 'BorderMode', value);
        end
    end

end
