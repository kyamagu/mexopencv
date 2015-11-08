classdef CalibrateDebevec < handle
    %CALIBRATEDEBEVEC  Camera Response Calibration algorithm
    %
    % Inverse camera response function is extracted for each brightness value
    % by minimizing an objective function as linear system. Objective function
    % is constructed using pixel values on the same position in all images,
    % extra term is added to make the result smoother.
    %
    % For more information see [DM97].
    %
    % ## References
    % [DM97]:
    % > Paul E Debevec and Jitendra Malik.
    % > "Recovering high dynamic range radiance maps from photographs".
    % > In ACM SIGGRAPH 2008 classes, page 31. ACM, 2008.
    %
    % See also: cv.CalibrateRobertson
    %

    properties (SetAccess = private)
        id % Object ID
    end

    properties (Dependent)
        % number of pixel locations to use.
        Samples
        % smoothness term weight.
        %
        % Greater values produce smoother results, but can alter the response.
        Lambda
        % if true sample pixel locations are chosen at random, otherwise
        % the form a rectangular grid.
        Random
    end

    %% CalibrateDebevec
    methods
        function this = CalibrateDebevec(varargin)
            %CALIBRATEDEBEVEC  Creates CalibrateDebevec object
            %
            %    obj = cv.CalibrateDebevec()
            %    obj = cv.CalibrateDebevec('OptionName',optionValue, ...)
            %
            % ## Options
            % * __Samples__ default 70
            % * __Lambda__ default 10.0
            % * __Random__ default false
            %
            % See also: cv.CalibrateDebevec.process
            %
            this.id = CalibrateDebevec_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also cv.CalibrateDebevec
            %
            CalibrateDebevec_(this.id, 'delete');
        end
    end

    %% CalibrateCRF
    methods
        function dst = process(this, src, times)
            %PROCESS  Recovers inverse camera response
            %
            %    dst = obj.process(src, times)
            %
            % ## Input
            % * __src__ cell array of input images, all of the same size and
            %       `uint8` type.
            % * __times__ vector of exposure time values for each image.
            %
            % ## Output
            % * __dst__ 256x1xCN `single` matrix with inverse camera response
            %       function. It has the same number of channels as images
            %       `src{i}`.
            %
            % See also: cv.CalibrateDebevec.CalibrateDebevec
            %
            dst = CalibrateDebevec_(this.id, 'process', src, times);
        end
    end

    %% Algorithm
    methods (Hidden)
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %    obj.clear()
            %
            % See also: cv.CalibrateDebevec.empty, cv.CalibrateDebevec.load
            %
            CalibrateDebevec_(this.id, 'clear');
        end

        function b = empty(this)
            %EMPTY  Returns true if the Algorithm is empty
            %
            %    b = obj.empty()
            %
            % ## Output
            % * __b__ Returns true if the object is empty (e.g in the
            %       very beginning or after unsuccessful read).
            %
            % See also: cv.CalibrateDebevec.clear, cv.CalibrateDebevec.load
            %
            b = CalibrateDebevec_(this.id, 'empty');
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
            % See also: cv.CalibrateDebevec.save, cv.CalibrateDebevec.load
            %
            name = CalibrateDebevec_(this.id, 'getDefaultName');
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
            % See also: cv.CalibrateDebevec.load
            %
            CalibrateDebevec_(this.id, 'save', filename);
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
            % See also: cv.CalibrateDebevec.save
            %
            CalibrateDebevec_(this.id, 'load', fname_or_str, varargin{:});
        end
    end

    %% Getters/Setters
    methods
        function value = get.Samples(this)
            value = CalibrateDebevec_(this.id, 'get', 'Samples');
        end
        function set.Samples(this, value)
            CalibrateDebevec_(this.id, 'set', 'Samples', value);
        end

        function value = get.Lambda(this)
            value = CalibrateDebevec_(this.id, 'get', 'Lambda');
        end
        function set.Lambda(this, value)
            CalibrateDebevec_(this.id, 'set', 'Lambda', value);
        end

        function value = get.Random(this)
            value = CalibrateDebevec_(this.id, 'get', 'Random');
        end
        function set.Random(this, value)
            CalibrateDebevec_(this.id, 'set', 'Random', value);
        end
    end

end
