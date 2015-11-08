classdef TonemapDrago < handle
    %TONEMAPDRAGO  Tonemapping algorithm used to map HDR image to 8-bit range
    %
    % Adaptive logarithmic mapping is a fast global tonemapping algorithm that
    % scales the image in logarithmic domain.
    %
    % Since it's a global operator the same function is applied to all the
    % pixels, it is controlled by the bias parameter.
    %
    % Optional saturation enhancement is possible as described in [FL02].
    %
    % For more information see [DM03].
    %
    % ## References
    % [FL02]:
    % > Raanan Fattal, Dani Lischinski, and Michael Werman.
    % > "Gradient domain high dynamic range compression". In ACM Transactions
    % > on Graphics (TOG), volume 21, pages 249-256. ACM, 2002.
    %
    % [DM03]:
    % > Frederic Drago, Karol Myszkowski, Thomas Annen, and Norishige Chiba.
    % > "Adaptive logarithmic mapping for displaying high contrast scenes".
    % > In Computer Graphics Forum, volume 22, pages 419-426. Wiley Online
    % > Library, 2003.
    %
    % See also: cv.Tonemap, cv.TonemapDurand, cv.TonemapReinhard,
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
        % positive saturation enhancement value.
        %
        % 1.0 preserves saturation, values greater than 1 increase saturation
        % and values less than 1 decrease it.
        Saturation
        % value for bias function in [0, 1] range.
        %
        % Values from 0.7 to 0.9  usually give best results, default value
        % is 0.85
        Bias
    end

    %% TonemapDrago
    methods
        function this = TonemapDrago(varargin)
            %TONEMAPDRAGO  Creates TonemapDrago object
            %
            %    obj = cv.TonemapDrago()
            %    obj = cv.TonemapDrago('OptionName',optionValue, ...)
            %
            % ## Options
            % * __Gamma__ default 1.0
            % * __Saturation__ default 1.0
            % * __Bias__ default 0.85
            %
            % See also: cv.TonemapDrago.process
            %
            this.id = TonemapDrago_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also cv.TonemapDrago
            %
            TonemapDrago_(this.id, 'delete');
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
            % See also: cv.TonemapDrago.TonemapDrago
            %
            dst = TonemapDrago_(this.id, 'process', src);
        end
    end

    %% Algorithm
    methods (Hidden)
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %    obj.clear()
            %
            % See also: cv.TonemapDrago.empty, cv.TonemapDrago.load
            %
            TonemapDrago_(this.id, 'clear');
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
            % See also: cv.TonemapDrago.clear, cv.TonemapDrago.load
            %
            b = TonemapDrago_(this.id, 'empty');
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
            % See also: cv.TonemapDrago.save, cv.TonemapDrago.load
            %
            name = TonemapDrago_(this.id, 'getDefaultName');
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
            % See also: cv.TonemapDrago.load
            %
            TonemapDrago_(this.id, 'save', filename);
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
            % See also: cv.TonemapDrago.save
            %
            TonemapDrago_(this.id, 'load', fname_or_str, varargin{:});
        end
    end

    %% Getters/Setters
    methods
        function value = get.Gamma(this)
            value = TonemapDrago_(this.id, 'get', 'Gamma');
        end
        function set.Gamma(this, value)
            TonemapDrago_(this.id, 'set', 'Gamma', value);
        end

        function value = get.Saturation(this)
            value = TonemapDrago_(this.id, 'get', 'Saturation');
        end
        function set.Saturation(this, value)
            TonemapDrago_(this.id, 'set', 'Saturation', value);
        end

        function value = get.Bias(this)
            value = TonemapDrago_(this.id, 'get', 'Bias');
        end
        function set.Bias(this, value)
            TonemapDrago_(this.id, 'set', 'Bias', value);
        end
    end

end
