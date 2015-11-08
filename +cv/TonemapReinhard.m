classdef TonemapReinhard < handle
    %TONEMAPREINHARD  Tonemapping algorithm used to map HDR image to 8-bit range
    %
    % This is a global tonemapping operator that models human visual system.
    %
    % Mapping function is controlled by adaptation parameter, that is computed
    % using light adaptation and color adaptation.
    %
    % For more information see [RD05].
    %
    % ## References
    % [RD05]:
    % > Erik Reinhard and Kate Devlin.
    % > "Dynamic range reduction inspired by photoreceptor physiology".
    % > Visualization and Computer Graphics, IEEE Transactions on,
    % > 11(1):13-24, 2005.
    %
    % See also: cv.Tonemap, cv.TonemapDrago, cv.TonemapDurand,
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
        % result intensity in [-8, 8] range.
        %
        % Greater intensity produces brighter results.
        Intensity
        % light adaptation in [0, 1] range.
        %
        % If 1 adaptation is based only on pixel value, if 0 it's global,
        % otherwise it's a weighted mean of this two cases.
        LightAdaptation
        % chromatic adaptation in [0, 1] range.
        %
        % If 1 channels are treated independently, if 0 adaptation level is
        % the same for each channel.
        ColorAdaptation
    end

    %% TonemapReinhard
    methods
        function this = TonemapReinhard(varargin)
            %TONEMAPREINHARD  Creates TonemapReinhard object
            %
            %    obj = cv.TonemapReinhard()
            %    obj = cv.TonemapReinhard('OptionName',optionValue, ...)
            %
            % ## Options
            % * __Gamma__ default 1.0
            % * __Intensity__ default 0.0
            % * __LightAdaptation__ default 1.0
            % * __ColorAdaptation__ default 0.0
            %
            % See also: cv.TonemapReinhard.process
            %
            this.id = TonemapReinhard_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also cv.TonemapReinhard
            %
            TonemapReinhard_(this.id, 'delete');
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
            % See also: cv.TonemapReinhard.TonemapReinhard
            %
            dst = TonemapReinhard_(this.id, 'process', src);
        end
    end

    %% Algorithm
    methods (Hidden)
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %    obj.clear()
            %
            % See also: cv.TonemapReinhard.empty, cv.TonemapReinhard.load
            %
            TonemapReinhard_(this.id, 'clear');
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
            % See also: cv.TonemapReinhard.clear, cv.TonemapReinhard.load
            %
            b = TonemapReinhard_(this.id, 'empty');
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
            % See also: cv.TonemapReinhard.save, cv.TonemapReinhard.load
            %
            name = TonemapReinhard_(this.id, 'getDefaultName');
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
            % See also: cv.TonemapReinhard.load
            %
            TonemapReinhard_(this.id, 'save', filename);
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
            % See also: cv.TonemapReinhard.save
            %
            TonemapReinhard_(this.id, 'load', fname_or_str, varargin{:});
        end
    end

    %% Getters/Setters
    methods
        function value = get.Gamma(this)
            value = TonemapReinhard_(this.id, 'get', 'Gamma');
        end
        function set.Gamma(this, value)
            TonemapReinhard_(this.id, 'set', 'Gamma', value);
        end

        function value = get.Intensity(this)
            value = TonemapReinhard_(this.id, 'get', 'Intensity');
        end
        function set.Intensity(this, value)
            TonemapReinhard_(this.id, 'set', 'Intensity', value);
        end

        function value = get.LightAdaptation(this)
            value = TonemapReinhard_(this.id, 'get', 'LightAdaptation');
        end
        function set.LightAdaptation(this, value)
            TonemapReinhard_(this.id, 'set', 'LightAdaptation', value);
        end

        function value = get.ColorAdaptation(this)
            value = TonemapReinhard_(this.id, 'get', 'ColorAdaptation');
        end
        function set.ColorAdaptation(this, value)
            TonemapReinhard_(this.id, 'set', 'ColorAdaptation', value);
        end
    end

end
