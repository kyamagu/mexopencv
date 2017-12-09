classdef DISOpticalFlow < handle
    %DISOPTICALFLOW  DIS optical flow algorithm
    %
    % This class implements the Dense Inverse Search (DIS) optical flow
    % algorithm. More details about the algorithm can be found at
    % [Kroeger2016]. Includes three presets with preselected parameters to
    % provide reasonable trade-off between speed and quality. However, even
    % the slowest preset is still relatively fast, use cv.calcOpticalFlowDF
    % if you need better quality and don't care about speed.
    %
    % This implementation includes several additional features compared to the
    % algorithm described in the paper, including spatial propagation of flow
    % vectors (cv.DISOpticalFlow.UseSpatialPropagation), as well as an option
    % to utilize an initial flow approximation passed to cv.DISOpticalFlow.calc
    % (which is, essentially, temporal propagation, if the previous frame's
    % flow field is passed).
    %
    % ## References
    % [Kroeger2016]:
    % > Till Kroeger, Radu Timofte, Dengxin Dai, and Luc Van Gool.
    % > "Fast optical flow using dense inverse search". In Proceedings of the
    % > European Conference on Computer Vision (ECCV), 2016.
    %
    % See also: cv.DISOpticalFlow.calc
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % Finest level of the Gaussian pyramid on which the flow is computed
        % (zero level corresponds to the original image resolution). The final
        % flow is obtained by bilinear upscaling.
        FinestScale
        % Size of an image patch for matching (in pixels). Normally, default
        % 8x8 patches work well enough in most cases.
        PatchSize
        % Stride between neighbor patches. Must be less than patch size. Lower
        % values correspond to higher flow quality.
        PatchStride
        % Maximum number of gradient descent iterations in the patch inverse
        % search stage. Higher values may improve quality in some cases.
        GradientDescentIterations
        % Number of fixed point iterations of variational refinement per scale.
        % Set to zero to disable variational refinement completely. Higher
        % values will typically result in more smooth and high-quality flow.
        VariationalRefinementIterations
        % Weight of the smoothness term.
        VariationalRefinementAlpha
        % Weight of the color constancy term.
        VariationalRefinementDelta
        % Weight of the gradient constancy term.
        VariationalRefinementGamma
        % Whether to use mean-normalization of patches when computing patch
        % distance. It is turned on by default as it typically provides a
        % noticeable quality boost because of increased robustness to
        % illumination variations. Turn it off if you are certain that your
        % sequence doesn't contain any changes in illumination.
        UseMeanNormalization
        % Whether to use spatial propagation of good optical flow vectors.
        % This option is turned on by default, as it tends to work better on
        % average and can sometimes help recover from major errors introduced
        % by the coarse-to-fine scheme employed by the DIS optical flow
        % algorithm. Turning this option off can make the output flow field a
        % bit smoother, however.
        UseSpatialPropagation
    end

    %% Constructor/destructor
    methods
        function this = DISOpticalFlow(varargin)
            %DISOPTICALFLOW  Creates an instance of DISOpticalFlow
            %
            %     obj = cv.DISOpticalFlow()
            %     obj = cv.DISOpticalFlow('OptionName',optionValue, ...)
            %
            % ## Options
            % * __Preset__ preset one of:
            %   * __UltraFast__
            %   * __Fast__ (default)
            %   * __Medium__
            %
            % See also: cv.DISOpticalFlow.calc
            %
            this.id = DISOpticalFlow_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.DISOpticalFlow
            %
            if isempty(this.id), return; end
            DISOpticalFlow_(this.id, 'delete');
        end
    end

    %% DenseOpticalFlow
    methods
        function flow = calc(this, I0, I1, varargin)
            %CALC  Calculates an optical flow
            %
            %     flow = obj.calc(I0, I1)
            %     flow = obj.calc(I0, I1, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __I0__ first 8-bit single-channel input image.
            % * __I1__ second input image of the same size and the same type
            %   as `I0`.
            %
            % ## Output
            % * __flow__ computed flow image that has the same size as `I0`
            %   and type `single` (2-channels).
            %
            % ## Options
            % * __InitialFlow__ specify the initial flow. Not set by default.
            %
            % See also: cv.DISOpticalFlow
            %
            flow = DISOpticalFlow_(this.id, 'calc', I0, I1, varargin{:});
        end

        function collectGarbage(this)
            %COLLECTGARBAGE  Releases all inner buffers
            %
            %     obj.collectGarbage()
            %
            DISOpticalFlow_(this.id, 'collectGarbage');
        end
    end

    %% Algorithm
    methods (Hidden)
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.DISOpticalFlow.empty
            %
            DISOpticalFlow_(this.id, 'clear');
        end

        function b = empty(this)
            %EMPTY  Returns true if the algorithm is empty
            %
            %     b = obj.empty()
            %
            % ## Output
            % * __b__ Returns true if the algorithm is empty (e.g. in the very
            %   beginning or after unsuccessful read).
            %
            % See also: cv.DISOpticalFlow.clear
            %
            b = DISOpticalFlow_(this.id, 'empty');
        end

        function name = getDefaultName(this)
            %GETDEFAULTNAME  Returns the algorithm string identifier
            %
            %     name = obj.getDefaultName()
            %
            % ## Output
            % * __name__ This string is used as top level XML/YML node tag
            %   when the object is saved to a file or string.
            %
            % See also: cv.DISOpticalFlow.save, cv.DISOpticalFlow.load
            %
            name = DISOpticalFlow_(this.id, 'getDefaultName');
        end

        function save(this, filename)
            %SAVE  Saves the algorithm to a file
            %
            %     obj.save(filename)
            %
            % ## Input
            % * __filename__ Name of the file to save to.
            %
            % This method stores the algorithm parameters in a file storage.
            %
            % See also: cv.DISOpticalFlow.load
            %
            DISOpticalFlow_(this.id, 'save', filename);
        end

        function load(this, fname_or_str, varargin)
            %LOAD  Loads algorithm from a file or a string
            %
            %     obj.load(fname)
            %     obj.load(str, 'FromString',true)
            %     obj.load(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __fname__ Name of the file to read.
            % * __str__ String containing the serialized model you want to
            %   load.
            %
            % ## Options
            % * __ObjName__ The optional name of the node to read (if empty,
            %   the first top-level node will be used). default empty
            % * __FromString__ Logical flag to indicate whether the input is a
            %   filename or a string containing the serialized model.
            %   default false
            %
            % This method reads algorithm parameters from a file storage.
            % The previous model state is discarded.
            %
            % See also: cv.DISOpticalFlow.save
            %
            DISOpticalFlow_(this.id, 'load', fname_or_str, varargin{:});
        end
    end

    %% Getters/Setters
    methods
        function value = get.FinestScale(this)
            value = DISOpticalFlow_(this.id, 'get', 'FinestScale');
        end
        function set.FinestScale(this, value)
            DISOpticalFlow_(this.id, 'set', 'FinestScale', value);
        end

        function value = get.PatchSize(this)
            value = DISOpticalFlow_(this.id, 'get', 'PatchSize');
        end
        function set.PatchSize(this, value)
            DISOpticalFlow_(this.id, 'set', 'PatchSize', value);
        end

        function value = get.PatchStride(this)
            value = DISOpticalFlow_(this.id, 'get', 'PatchStride');
        end
        function set.PatchStride(this, value)
            DISOpticalFlow_(this.id, 'set', 'PatchStride', value);
        end

        function value = get.GradientDescentIterations(this)
            value = DISOpticalFlow_(this.id, 'get', 'GradientDescentIterations');
        end
        function set.GradientDescentIterations(this, value)
            DISOpticalFlow_(this.id, 'set', 'GradientDescentIterations', value);
        end

        function value = get.VariationalRefinementIterations(this)
            value = DISOpticalFlow_(this.id, 'get', 'VariationalRefinementIterations');
        end
        function set.VariationalRefinementIterations(this, value)
            DISOpticalFlow_(this.id, 'set', 'VariationalRefinementIterations', value);
        end

        function value = get.VariationalRefinementAlpha(this)
            value = DISOpticalFlow_(this.id, 'get', 'VariationalRefinementAlpha');
        end
        function set.VariationalRefinementAlpha(this, value)
            DISOpticalFlow_(this.id, 'set', 'VariationalRefinementAlpha', value);
        end

        function value = get.VariationalRefinementDelta(this)
            value = DISOpticalFlow_(this.id, 'get', 'VariationalRefinementDelta');
        end
        function set.VariationalRefinementDelta(this, value)
            DISOpticalFlow_(this.id, 'set', 'VariationalRefinementDelta', value);
        end

        function value = get.VariationalRefinementGamma(this)
            value = DISOpticalFlow_(this.id, 'get', 'VariationalRefinementGamma');
        end
        function set.VariationalRefinementGamma(this, value)
            DISOpticalFlow_(this.id, 'set', 'VariationalRefinementGamma', value);
        end

        function value = get.UseMeanNormalization(this)
            value = DISOpticalFlow_(this.id, 'get', 'UseMeanNormalization');
        end
        function set.UseMeanNormalization(this, value)
            DISOpticalFlow_(this.id, 'set', 'UseMeanNormalization', value);
        end

        function value = get.UseSpatialPropagation(this)
            value = DISOpticalFlow_(this.id, 'get', 'UseSpatialPropagation');
        end
        function set.UseSpatialPropagation(this, value)
            DISOpticalFlow_(this.id, 'set', 'UseSpatialPropagation', value);
        end
    end

end
