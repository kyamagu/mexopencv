classdef FarnebackOpticalFlow < handle
    %FARNEBACKOPTICALFLOW  Dense optical flow using the Gunnar Farneback's algorithm
    %
    % Class computing a dense optical flow using the Gunnar Farneback's
    % algorithm.
    %
    % See also: cv.FarnebackOpticalFlow.calc, cv.calcOpticalFlowFarneback
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % default 5
        NumLevels
        % default 0.5
        PyrScale
        % default false
        FastPyramids
        % default 13
        WinSize
        % default 10
        NumIters
        % default 5
        PolyN
        % default 1.1
        PolySigma
        % default 0
        Flags
    end

    %% Constructor/destructor
    methods
        function this = FarnebackOpticalFlow()
            %FARNEBACKOPTICALFLOW  Creates instance of FarnebackOpticalFlow
            %
            %     obj = cv.FarnebackOpticalFlow()
            %
            % See also: cv.FarnebackOpticalFlow.calc
            %
            this.id = FarnebackOpticalFlow_(0, 'new');
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.FarnebackOpticalFlow
            %
            if isempty(this.id), return; end
            FarnebackOpticalFlow_(this.id, 'delete');
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
            % See also: cv.FarnebackOpticalFlow, cv.calcOpticalFlowFarneback
            %
            flow = FarnebackOpticalFlow_(this.id, 'calc', I0, I1, varargin{:});
        end

        function collectGarbage(this)
            %COLLECTGARBAGE  Releases all inner buffers
            %
            %     obj.collectGarbage()
            %
            FarnebackOpticalFlow_(this.id, 'collectGarbage');
        end
    end

    %% Algorithm
    methods (Hidden)
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.FarnebackOpticalFlow.empty
            %
            FarnebackOpticalFlow_(this.id, 'clear');
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
            % See also: cv.FarnebackOpticalFlow.clear
            %
            b = FarnebackOpticalFlow_(this.id, 'empty');
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
            % See also: cv.FarnebackOpticalFlow.save, cv.FarnebackOpticalFlow.load
            %
            name = FarnebackOpticalFlow_(this.id, 'getDefaultName');
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
            % See also: cv.FarnebackOpticalFlow.load
            %
            FarnebackOpticalFlow_(this.id, 'save', filename);
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
            % See also: cv.FarnebackOpticalFlow.save
            %
            FarnebackOpticalFlow_(this.id, 'load', fname_or_str, varargin{:});
        end
    end

    %% Getters/Setters
    methods
        function value = get.NumLevels(this)
            value = FarnebackOpticalFlow_(this.id, 'get', 'NumLevels');
        end
        function set.NumLevels(this, value)
            FarnebackOpticalFlow_(this.id, 'set', 'NumLevels', value);
        end

        function value = get.PyrScale(this)
            value = FarnebackOpticalFlow_(this.id, 'get', 'PyrScale');
        end
        function set.PyrScale(this, value)
            FarnebackOpticalFlow_(this.id, 'set', 'PyrScale', value);
        end

        function value = get.FastPyramids(this)
            value = FarnebackOpticalFlow_(this.id, 'get', 'FastPyramids');
        end
        function set.FastPyramids(this, value)
            FarnebackOpticalFlow_(this.id, 'set', 'FastPyramids', value);
        end

        function value = get.WinSize(this)
            value = FarnebackOpticalFlow_(this.id, 'get', 'WinSize');
        end
        function set.WinSize(this, value)
            FarnebackOpticalFlow_(this.id, 'set', 'WinSize', value);
        end

        function value = get.NumIters(this)
            value = FarnebackOpticalFlow_(this.id, 'get', 'NumIters');
        end
        function set.NumIters(this, value)
            FarnebackOpticalFlow_(this.id, 'set', 'NumIters', value);
        end

        function value = get.PolyN(this)
            value = FarnebackOpticalFlow_(this.id, 'get', 'PolyN');
        end
        function set.PolyN(this, value)
            FarnebackOpticalFlow_(this.id, 'set', 'PolyN', value);
        end

        function value = get.PolySigma(this)
            value = FarnebackOpticalFlow_(this.id, 'get', 'PolySigma');
        end
        function set.PolySigma(this, value)
            FarnebackOpticalFlow_(this.id, 'set', 'PolySigma', value);
        end

        function value = get.Flags(this)
            value = FarnebackOpticalFlow_(this.id, 'get', 'Flags');
        end
        function set.Flags(this, value)
            FarnebackOpticalFlow_(this.id, 'set', 'Flags', value);
        end
    end

end
