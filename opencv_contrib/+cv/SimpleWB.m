classdef SimpleWB < handle
    %SIMPLEWB  Simple white balance algorithm
    %
    % A simple white balance algorithm that works by independently stretching
    % each of the input image channels to the specified range. For increased
    % robustness it ignores the top and bottom `P` percent of pixel values.
    %
    % See also: cv.SimpleWB.balanceWhite, cv.GrayworldWB, cv.LearningBasedWB,
    %  cv.cvtColor, cv.equalizeHist, imadjust, stretchlim
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % Input image range minimum value. default 0.0
        InputMin
        % Input image range maximum value. default 255.0
        InputMax
        % Output image range minimum value. default 0.0
        OutputMin
        % Output image range maximum value. default 255.0
        OutputMax
        % Percent of top/bottom values to ignore. default 2.0
        P
    end

    %% Constructor/destructor
    methods
        function this = SimpleWB()
            %SIMPLEWB  Creates an instance of SimpleWB
            %
            %     obj = cv.SimpleWB()
            %
            % See also: cv.SimpleWB.balanceWhite
            %
            this.id = SimpleWB_(0, 'new');
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.SimpleWB
            %
            if isempty(this.id), return; end
            SimpleWB_(this.id, 'delete');
        end
    end

    %% WhiteBalancer
    methods
        function dst = balanceWhite(this, src)
            %BALANCEWHITE  Applies white balancing to the input image
            %
            %     dst = obj.balanceWhite(src)
            %
            % ## Input
            % * __src__ Input image.
            %
            % ## Output
            % * __dst__ White balancing result.
            %
            % See also: cv.cvtColor, cv.equalizeHist
            %
            dst = SimpleWB_(this.id, 'balanceWhite', src);
        end
    end

    %% Algorithm
    methods (Hidden)
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.SimpleWB.empty
            %
            SimpleWB_(this.id, 'clear');
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
            % See also: cv.SimpleWB.clear
            %
            b = SimpleWB_(this.id, 'empty');
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
            % See also: cv.SimpleWB.save, cv.SimpleWB.load
            %
            name = SimpleWB_(this.id, 'getDefaultName');
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
            % See also: cv.SimpleWB.load
            %
            SimpleWB_(this.id, 'save', filename);
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
            % See also: cv.SimpleWB.save
            %
            SimpleWB_(this.id, 'load', fname_or_str, varargin{:});
        end
    end

    %% Getters/Setters
    methods
        function value = get.InputMin(this)
            value = SimpleWB_(this.id, 'get', 'InputMin');
        end
        function set.InputMin(this, value)
            SimpleWB_(this.id, 'set', 'InputMin', value);
        end

        function value = get.InputMax(this)
            value = SimpleWB_(this.id, 'get', 'InputMax');
        end
        function set.InputMax(this, value)
            SimpleWB_(this.id, 'set', 'InputMax', value);
        end

        function value = get.OutputMin(this)
            value = SimpleWB_(this.id, 'get', 'OutputMin');
        end
        function set.OutputMin(this, value)
            SimpleWB_(this.id, 'set', 'OutputMin', value);
        end

        function value = get.OutputMax(this)
            value = SimpleWB_(this.id, 'get', 'OutputMax');
        end
        function set.OutputMax(this, value)
            SimpleWB_(this.id, 'set', 'OutputMax', value);
        end

        function value = get.P(this)
            value = SimpleWB_(this.id, 'get', 'P');
        end
        function set.P(this, value)
            SimpleWB_(this.id, 'set', 'P', value);
        end
    end

end
