classdef OpticalFlowPCAFlow < handle
    %OPTICALFLOWPCAFLOW  PCAFlow algorithm
    %
    % Implementation of the PCAFlow algorithm from the following paper:
    % [Wulffcvpr2015].
    %
    % There are some key differences which distinguish this algorithm from the
    % original PCAFlow (see paper):
    %
    % - Discrete Cosine Transform basis is used instead of basis extracted
    %   with PCA. Reasoning: DCT basis has comparable performance and it
    %   doesn't require additional storage space. Also, this decision helps to
    %   avoid overloading the algorithm with a lot of external input.
    % - Usage of built-in OpenCV feature tracking instead of libviso.
    %
    % ## References
    % [Wulffcvpr2015]:
    % > Jonas Wulff, Michael J. Black, "Efficient Sparse-to-Dense Optical Flow
    % > Estimation using a Learned Basis and Layers".
    % > [PDF](http://files.is.tue.mpg.de/black/papers/cvpr2015_pcaflow.pdf)
    %
    % See also: cv.OpticalFlowPCAFlow.calc
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    %% Constructor/destructor
    methods
        function this = OpticalFlowPCAFlow()
            %OPTICALFLOWPCAFLOW  Creates an instance of PCAFlow
            %
            %     obj = cv.OpticalFlowPCAFlow()
            %     obj = cv.OpticalFlowPCAFlow('OptionName',optionValue, ...)
            %
            % ## Options
            % * __Prior__ Learned prior or no prior (default). Specified as a
            %   path to prior. This instantiates a class used for imposing a
            %   learned prior on the resulting optical flow. Solution will be
            %   regularized according to this prior. You need to generate
            %   appropriate prior file with "learn_prior.py" script beforehand.
            % * __BasisSize__ Number of basis vectors. default [18,14]
            % * __SparseRate__ Controls density of sparse matches.
            %   default 0.024
            % * __RetainedCornersFraction__ Retained corners fraction.
            %   default 0.2
            % * __OcclusionsThreshold__ Occlusion threshold. default 0.0003
            % * __DampingFactor__ Regularization term for solving
            %   least-squares. It is not related to the prior regularization.
            %   default 0.00002
            % * __ClaheClip__ Clip parameter for CLAHE. default 14
            %
            % See also: cv.OpticalFlowPCAFlow.calc
            %
            this.id = OpticalFlowPCAFlow_(0, 'new');
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.OpticalFlowPCAFlow
            %
            if isempty(this.id), return; end
            OpticalFlowPCAFlow_(this.id, 'delete');
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
            % See also: cv.OpticalFlowPCAFlow
            %
            flow = OpticalFlowPCAFlow_(this.id, 'calc', I0, I1, varargin{:});
        end

        function collectGarbage(this)
            %COLLECTGARBAGE  Releases all inner buffers
            %
            %     obj.collectGarbage()
            %
            OpticalFlowPCAFlow_(this.id, 'collectGarbage');
        end
    end

    %% Algorithm
    methods (Hidden)
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.OpticalFlowPCAFlow.empty
            %
            OpticalFlowPCAFlow_(this.id, 'clear');
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
            % See also: cv.OpticalFlowPCAFlow.clear
            %
            b = OpticalFlowPCAFlow_(this.id, 'empty');
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
            % See also: cv.OpticalFlowPCAFlow.save, cv.OpticalFlowPCAFlow.load
            %
            name = OpticalFlowPCAFlow_(this.id, 'getDefaultName');
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
            % See also: cv.OpticalFlowPCAFlow.load
            %
            OpticalFlowPCAFlow_(this.id, 'save', filename);
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
            % See also: cv.OpticalFlowPCAFlow.save
            %
            OpticalFlowPCAFlow_(this.id, 'load', fname_or_str, varargin{:});
        end
    end

end
