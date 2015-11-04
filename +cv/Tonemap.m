classdef Tonemap < handle
    %TONEMAP  Tonemapping algorithm used to map HDR image to 8-bit range
    %
    % See also: cv.TonemapDrago, cv.TonemapDurand, cv.TonemapReinhard,
    %  cv.TonemapMantiuk, tonemap
    %

    properties (SetAccess = private)
        id % Object ID
    end

    properties (Dependent)
        % positive value for gamma correction.
        %
        % Gamma value of 1.0 implies no correction, gamma equal to 2.2 is
        % suitable for most displays. Generally gamma > 1 brightens the image
        % and gamma < 1 darkens it.
        Gamma
    end

    %% Tonemap
    methods
        function this = Tonemap(varargin)
            %TONEMAP  Creates simple linear mapper with gamma correction
            %
            %    obj = cv.Tonemap()
            %    obj = cv.Tonemap('OptionName',optionValue, ...)
            %
            % ## Options
            % * __Gamma__ default 1.0
            %
            % See also: cv.Tonemap.process
            %
            this.id = Tonemap_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also cv.Tonemap
            %
            Tonemap_(this.id, 'delete');
        end
    end

    %% Tonemap
    methods
        function dst = process(this, src)
            %PROCESS  Tonemaps image
            %
            %    dst = obj.process(src)
            %
            % ## Input
            % * __src__ source RGB image, 32-bit `single` 3-channel array.
            %
            % ## Output
            % * __dst__ destination image of same size as `src`, 32-bit
            %       `single` 3-channel array with values in [0,1] range.
            %
            % See also: cv.Tonemap.Tonemap
            %
            dst = Tonemap_(this.id, 'process', src);
        end
    end

    %% Algorithm
    methods (Hidden)
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %    obj.clear()
            %
            % See also: cv.Tonemap.empty, cv.Tonemap.load
            %
            Tonemap_(this.id, 'clear');
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
            % See also: cv.Tonemap.clear, cv.Tonemap.load
            %
            b = Tonemap_(this.id, 'empty');
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
            % See also: cv.Tonemap.save, cv.Tonemap.load
            %
            name = Tonemap_(this.id, 'getDefaultName');
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
            % See also: cv.Tonemap.load
            %
            Tonemap_(this.id, 'save', filename);
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
            % See also: cv.Tonemap.save
            %
            Tonemap_(this.id, 'load', fname_or_str, varargin{:});
        end
    end

    %% Getters/Setters
    methods
        function value = get.Gamma(this)
            value = Tonemap_(this.id, 'get', 'Gamma');
        end
        function set.Gamma(this, value)
            Tonemap_(this.id, 'set', 'Gamma', value);
        end
    end

end
