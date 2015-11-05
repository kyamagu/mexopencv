classdef SuperResolution < handle
    %SUPERRESOLUTION  Class for a whole family of Super Resolution algorithms
    %
    % The Super Resolution module contains a set of functions and classes that
    % can be used to solve the problem of resolution enhancement. There are a
    % few methods implemented, most of them are descibed in the papers
    % [Farsiu03] and [Mitzel09].
    %
    % ## Example
    %
    %    superres = cv.SuperResolution();
    %    superres.Scale = 2;       % 2x scale
    %    superres.Iterations = 10; % careful alg is computationally expensive!
    %    superres.setOpticalFlow('FarnebackOpticalFlow', 'LevelsNumber',3);
    %    superres.setInput('Video', 'video.avi');
    %    while true
    %        tic, frame = superres.nextFrame(); toc
    %        if isempty(frame), break; end
    %        imshow(frame), drawnow
    %    end
    %
    % ## References
    % [Farsiu03]:
    % > Sina Farsiu, Dirk Robinson, Michael Elad, and Peyman Milanfar.
    % > "Fast and robust super-resolution". In Image Processing, 2003. ICIP
    % > 2003. Proceedings. 2003 International Conference on, volume 2, pages
    % > II-291. IEEE, 2003.
    %
    % [Mitzel09]:
    % > Dennis Mitzel, Thomas Pock, Thomas Schoenemann, and Daniel Cremers.
    % > "Video super resolution using duality based tv-l 1 optical flow".
    % > In Pattern Recognition, pages 432-441. Springer, 2009.
    %
    % See also: cv.SuperResolution.SuperResolution
    %

    properties (SetAccess = private)
        id % Object ID
    end

    properties (Dependent)
        % Scale factor.
        Scale
        % Iterations count.
        Iterations
        % Asymptotic value of steepest descent method.
        Tau
        % Weight parameter to balance data term and smoothness term.
        Labmda
        % Parameter of spacial distribution in Bilateral-TV.
        Alpha
        % Kernel size of Bilateral-TV filter.
        KernelSize
        % Gaussian blur kernel size.
        BlurKernelSize
        % Gaussian blur sigma.
        BlurSigma
        % Radius of the temporal search area.
        TemporalAreaRadius
    end

    %% SuperResolution
    methods
        function this = SuperResolution(superresType)
            %SUPERRESOLUTION  Create Bilateral TV-L1 Super Resolution
            %
            %    obj = cv.SuperResolution(superresType)
            %
            % ## Input
            % * __superresType__ Super resolution algorithm type, one of:
            %       * __BTVL1__ Bilateral TV-L1 on CPU. This is the default.
            %       * **BTVL1_CUDA** Bilateral TV-L1 on GPU (requires CUDA).
            %
            % This class implements Super Resolution algorithm described in
            % the papers [Farsiu03] and [Mitzel09].
            %
            % Here are important members of the class that control the
            % algorithm, which you can set after constructing the class
            % instance:
            %
            % * `Scale` (int) Scale factor.
            % * `Iterations` (int) Iteration count.
            % * `Tau` (double) Asymptotic value of steepest descent method.
            % * `Lambda` (double) Weight parameter to balance data term and
            %   smoothness term.
            % * `Alpha` (double) Parameter of spacial distribution in
            %   Bilateral-TV.
            % * `KernelSize` (int) Kernel size of Bilateral-TV filter.
            % * `BlurKernelSize` (int) Gaussian blur kernel size.
            % * `BlurSigma` (double) Gaussian blur sigma.
            % * `TemporalAreaRadius` (int) Radius of the temporal search area.
            % * `OpticalFlow` Dense optical flow algorithm.
            %
            % See also: cv.SuperResolution.nextFrame
            %
            if nargin < 1, superresType = 'BTVL1'; end
            this.id = SuperResolution_(0, 'new', superresType);
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also: cv.SuperResolution
            %
            SuperResolution_(this.id, 'delete');
        end

        function collectGarbage(this)
            %COLLECTGARBAGE  Clear all inner buffers
            %
            %    obj.collectGarbage()
            %
            % See also: cv.SuperResolution.SuperResolution
            %
            SuperResolution_(this.id, 'collectGarbage');
        end

        function setInput(this, frameSourceType, varargin)
            %SETINPUT  Set input frame source for Super Resolution algorithm
            %
            %    obj.setInput(frameSourceType, ...)
            %
            %    obj.setInput('Camera', deviceId)
            %    obj.setInput('Video', filename)
            %
            % ## Input
            % * __frameSourceType__ Input frame source type. One of:
            %       * __Camera__ wrapper around cv.VideoCapture with a camera
            %             device as source.
            %       * __Video__ wrapper around cv.VideoCapture with a video
            %             file as source.
            % * __deviceId__ id of the opened video capturing device (i.e. a
            %       camera index). If there is a single camera connected, just
            %       pass 0. default 0
            % * __filename__ name of the opened video file (eg. `video.avi`)
            %       or image sequence (eg. `img_%02d.jpg`, which will read
            %       samples like `img_00.jpg`, `img_01.jpg`, `img_02.jpg`, ...)
            %
            % See also: cv.SuperResolution.nextFrame
            %
            SuperResolution_(this.id, 'setInput', frameSourceType, varargin{:});
        end

        function setOpticalFlow(this, optFlowType, varargin)
            %SETOPTICALFLOW  Dense optical flow algorithm
            %
            %    obj.setOpticalFlow(optFlowType)
            %    obj.setOpticalFlow(optFlowType, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __optFlowType__ Dense optical flow algorithm. One of:
            %       * __FarnebackOpticalFlow__ wrapper for
            %             cv.calcOpticalFlowFarneback function.
            %       * __DualTVL1OpticalFlow__ wrapper for
            %             cv.DualTVL1OpticalFlow class.
            %       * __FarnebackOpticalFlowCUDA__ wrapper for
            %             `cv::cuda::FarnebackOpticalFlow` (requires CUDA)
            %       * __DualTVL1OpticalFlowCUDA__ wrapper for
            %             `cv::cuda::OpticalFlowDual_TVL1` (requires CUDA)
            %       * __BroxOpticalFlowCUDA__ wrapper for
            %             `cv::cuda::BroxOpticalFlow` (requires CUDA)
            %       * __PyrLKOpticalFlowCUDA__ wrapper for
            %             `cv::cuda::DensePyrLKOpticalFlow` (requires CUDA)
            %
            % ## Options
            % The following are options for the various algorithms:
            %
            % ### `FarnebackOpticalFlow`, `FarnebackOpticalFlowCUDA`
            % See cv.calcOpticalFlowFarneback for a description of the options:
            %
            % * __PyrScale__ default 0.5
            % * __LevelsNumber__ default 5
            % * __WindowSize__ default 13
            % * __Iterations__ default 10
            % * __PolyN__ default 5
            % * __PolySigma__ default 1.1
            % * __Flags__ default 0
            %
            % ### `DualTVL1OpticalFlow`, `DualTVL1OpticalFlowCUDA`
            % See cv.DualTVL1OpticalFlow for a description of the options:
            %
            % * __Tau__ default 0.25
            % * __Lambda__ default 0.15
            % * __Theta__ default 0.3
            % * __ScalesNumber__ default 5
            % * __WarpingsNumber__ default 5
            % * __Epsilon__ default 0.01
            % * __Iterations__ default 10
            % * __UseInitialFlow__ default false
            %
            % ### `BroxOpticalFlowCUDA`
            %
            % * __Alpha__ default 0.197
            % * __Gamma__ default 50.0
            % * __ScaleFactor__ default 0.8
            % * __InnerIterations__ default 10
            % * __OuterIterations__ default 77
            % * __SolverIterations__ default 10
            %
            % ### `PyrLKOpticalFlowCUDA`
            % See cv.calcOpticalFlowPyrLK for a description of the options:
            %
            % * __WindowSize__ default 13
            % * __MaxLevel__ default 3
            % * __Iterations__ default 30
            %
            % See also: cv.SuperResolution.getOpticalFlow
            %
            SuperResolution_(this.id, 'setOpticalFlow', optFlowType, varargin{:});
        end

        function optFlow = getOpticalFlow(this)
            %GETOPTICALFLOW  Dense optical flow algorithm
            %
            %    optFlow = obj.getOpticalFlow()
            %
            % ## Output
            % * __optFlow__ output struct containing properties of the
            %       optical flow algorithm.
            %
            % See also: cv.SuperResolution.setOpticalFlow,
            %  cv.calcOpticalFlowPyrLK, cv.DualTVL1OpticalFlow
            %
            optFlow = SuperResolution_(this.id, 'getOpticalFlow');
        end
    end

    %% FrameSource
    methods
        function frame = nextFrame(this, varargin)
            %NEXTFRAME  Process next frame from input and return output result
            %
            %    frame = obj.nexFrame()
            %    frame = obj.nexFrame('OptionName',optionValue, ...)
            %
            % ## Options
            % * __FlipChannels__ in case the output is color image, flips the
            %       color order from OpenCV's BGR/BGRA to MATLAB's RGB/RGBA
            %       order. default true
            %
            % ## Output
            % * __frame__ Output result
            %
            % See also: cv.SuperResolution.reset
            %
            frame = SuperResolution_(this.id, 'nextFrame', varargin{:});
        end

        function reset(this)
            %RESET Reset the frame source
            %
            %    obj.reset()
            %
            % See also: cv.SuperResolution.nextFrame
            %
            SuperResolution_(this.id, 'reset');
        end
    end

    %% Algorithm
    methods (Hidden)
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %    obj.clear()
            %
            % See also: cv.SuperResolution.empty, cv.SuperResolution.load
            %
            SuperResolution_(this.id, 'clear');
        end

        function b = empty(this)
            %EMPTY  Returns true if the algorithm is empty
            %
            %    b = obj.empty()
            %
            % ## Output
            % * __b__ Returns true if the detector object is empty (e.g in the
            %       very beginning or after unsuccessful read).
            %
            % See also: cv.SuperResolution.clear, cv.SuperResolution.load
            %
            b = SuperResolution_(this.id, 'empty');
        end

        function name = getDefaultName(this)
            %GETDEFAULTNAME  Returns the algorithm string identifier
            %
            %    name = obj.getDefaultName()
            %
            % ## Output
            % * __name__ This string is used as top level XML/YML node tag
            %       when the object is saved to a file or string.
            %
            % See also: cv.SuperResolution.save, cv.SuperResolution.load
            %
            name = SuperResolution_(this.id, 'getDefaultName');
        end

        function save(this, filename)
            %SAVE  Saves the algorithm parameters to a file
            %
            %    obj.save(filename)
            %
            % ## Input
            % * __filename__ Name of the file to save to.
            %
            % This method stores the algorithm parameters in the specified
            % XML or YAML file.
            %
            % See also: cv.SuperResolution.load
            %
            SuperResolution_(this.id, 'save', filename);
        end

        function load(this, fname_or_str, varargin)
            %LOAD  Loads algorithm from a file or a string
            %
            %    obj.load(fname)
            %    obj.load(str, 'FromString',true)
            %    obj.load(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __fname__ Name of the file to read.
            % * __str__ String containing the serialized model you want to
            %       load.
            %
            % ## Options
            % * __ObjName__ The optional name of the node to read (if empty,
            %       the first top-level node will be used). default empty
            % * __FromString__ Logical flag to indicate whether the input is
            %       a filename or a string containing the serialized model.
            %       default false
            %
            % This method reads algorithm parameters from the specified XML or
            % YAML file (either from disk or serialized string). The previous
            % algorithm state is discarded.
            %
            % See also: cv.SuperResolution.save
            %
            SuperResolution_(this.id, 'load', fname_or_str, varargin{:});
        end
    end

    %% Getters/Setters
    methods
        function value = get.Scale(this)
            value = SuperResolution_(this.id, 'get', 'Scale');
        end
        function set.Scale(this, value)
            SuperResolution_(this.id, 'set', 'Scale', value);
        end

        function value = get.Iterations(this)
            value = SuperResolution_(this.id, 'get', 'Iterations');
        end
        function set.Iterations(this, value)
            SuperResolution_(this.id, 'set', 'Iterations', value);
        end

        function value = get.Tau(this)
            value = SuperResolution_(this.id, 'get', 'Tau');
        end
        function set.Tau(this, value)
            SuperResolution_(this.id, 'set', 'Tau', value);
        end

        function value = get.Labmda(this)
            value = SuperResolution_(this.id, 'get', 'Labmda');
        end
        function set.Labmda(this, value)
            SuperResolution_(this.id, 'set', 'Labmda', value);
        end

        function value = get.Alpha(this)
            value = SuperResolution_(this.id, 'get', 'Alpha');
        end
        function set.Alpha(this, value)
            SuperResolution_(this.id, 'set', 'Alpha', value);
        end

        function value = get.KernelSize(this)
            value = SuperResolution_(this.id, 'get', 'KernelSize');
        end
        function set.KernelSize(this, value)
            SuperResolution_(this.id, 'set', 'KernelSize', value);
        end

        function value = get.BlurKernelSize(this)
            value = SuperResolution_(this.id, 'get', 'BlurKernelSize');
        end
        function set.BlurKernelSize(this, value)
            SuperResolution_(this.id, 'set', 'BlurKernelSize', value);
        end

        function value = get.BlurSigma(this)
            value = SuperResolution_(this.id, 'get', 'BlurSigma');
        end
        function set.BlurSigma(this, value)
            SuperResolution_(this.id, 'set', 'BlurSigma', value);
        end

        function value = get.TemporalAreaRadius(this)
            value = SuperResolution_(this.id, 'get', 'TemporalAreaRadius');
        end
        function set.TemporalAreaRadius(this, value)
            SuperResolution_(this.id, 'set', 'TemporalAreaRadius', value);
        end
    end

end
