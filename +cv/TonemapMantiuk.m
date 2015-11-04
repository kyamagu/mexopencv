classdef TonemapMantiuk < handle
    %TONEMAPMANTIUK  Tonemapping algorithm used to map HDR image to 8-bit range
    %
    % This algorithm transforms image to contrast using gradients on all
    % levels of gaussian pyramid, transforms contrast values to HVS response
    % and scales the response. After this the image is reconstructed from new
    % contrast values.
    %
    % For more information see [MM06].
    %
    % ## References
    % [MM06]:
    % > Rafal Mantiuk, Karol Myszkowski, and Hans-Peter Seidel. "A perceptual
    % > framework for contrast processing of high dynamic range images".
    % > ACM Transactions on Applied Perception (TAP), 3(3):286-308, 2006.
    %
    % See also: cv.Tonemap, cv.TonemapDrago, cv.TonemapDurand,
    %  cv.TonemapReinhard, tonemap
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
        % contrast scale factor.
        %
        % HVS response is multiplied by this parameter, thus compressing
        % dynamic range. Values from 0.6 to 0.9 produce best results.
        Scale
        % positive saturation enhancement value.
        %
        % 1.0 preserves saturation, values greater than 1 increase saturation
        % and values less than 1 decrease it.
        Saturation
    end

    %% TonemapMantiuk
    methods
        function this = TonemapMantiuk(varargin)
            %TONEMAPMANTIUK  Creates TonemapMantiuk object
            %
            %    obj = cv.TonemapMantiuk()
            %    obj = cv.TonemapMantiuk('OptionName',optionValue, ...)
            %
            % ## Options
            % * __Gamma__ default 1.0
            % * __Scale__ default 0.7
            % * __Saturation__ default 1.0
            %
            % See also: cv.TonemapMantiuk.process
            %
            this.id = TonemapMantiuk_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also cv.TonemapMantiuk
            %
            TonemapMantiuk_(this.id, 'delete');
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
            % See also: cv.TonemapMantiuk.TonemapMantiuk
            %
            dst = TonemapMantiuk_(this.id, 'process', src);
        end
    end

    %% Algorithm
    methods (Hidden)
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %    obj.clear()
            %
            % See also: cv.TonemapMantiuk.empty, cv.TonemapMantiuk.load
            %
            TonemapMantiuk_(this.id, 'clear');
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
            % See also: cv.TonemapMantiuk.clear, cv.TonemapMantiuk.load
            %
            b = TonemapMantiuk_(this.id, 'empty');
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
            % See also: cv.TonemapMantiuk.save, cv.TonemapMantiuk.load
            %
            name = TonemapMantiuk_(this.id, 'getDefaultName');
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
            % See also: cv.TonemapMantiuk.load
            %
            TonemapMantiuk_(this.id, 'save', filename);
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
            % See also: cv.TonemapMantiuk.save
            %
            TonemapMantiuk_(this.id, 'load', fname_or_str, varargin{:});
        end
    end

    %% Getters/Setters
    methods
        function value = get.Gamma(this)
            value = TonemapMantiuk_(this.id, 'get', 'Gamma');
        end
        function set.Gamma(this, value)
            TonemapMantiuk_(this.id, 'set', 'Gamma', value);
        end

        function value = get.Scale(this)
            value = TonemapMantiuk_(this.id, 'get', 'Scale');
        end
        function set.Scale(this, value)
            TonemapMantiuk_(this.id, 'set', 'Scale', value);
        end

        function value = get.Saturation(this)
            value = TonemapMantiuk_(this.id, 'get', 'Saturation');
        end
        function set.Saturation(this, value)
            TonemapMantiuk_(this.id, 'set', 'Saturation', value);
        end
    end

end
