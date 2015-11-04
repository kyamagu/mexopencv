classdef MergeMertens < handle
    %MERGEMERTENS  Merge exposure sequence to a single image
    %
    % Pixels are weighted using contrast, saturation and well-exposedness
    % measures, than images are combined using laplacian pyramids.
    %
    % The resulting image weight is constructed as weighted average of
    % contrast, saturation and well-exposedness measures.
    %
    % The resulting image doesn't require tonemapping and can be converted to
    % 8-bit image by multiplying by 255, but it's recommended to apply gamma
    % correction and/or linear tonemapping.
    %
    % For more information see [MK07].
    %
    % ## References
    % [MK07]:
    % > Tom Mertens, Jan Kautz, and Frank Van Reeth. "Exposure fusion".
    % > In Computer Graphics and Applications, 2007. PG'07. 15th Pacific
    % > Conference on, pages 382-390. IEEE, 2007.
    %
    % See also: cv.MergeDebevec, cv.MergeRobertson, makehdr
    %

    properties (SetAccess = private)
        id % Object ID
    end

    properties (Dependent)
        % contrast measure weight
        ContrastWeight
        % saturation measure weight
        SaturationWeight
        % well-exposedness measure weight
        ExposureWeight
    end

    %% MergeMertens
    methods
        function this = MergeMertens(varargin)
            %MERGEMERTENS  Creates MergeMertens object
            %
            %    obj = cv.MergeMertens()
            %    obj = cv.MergeMertens('OptionName',optionValue, ...)
            %
            % ## Options
            % * __ContrastWeight__ default 1.0
            % * __SaturationWeight__ default 1.0
            % * __ExposureWeight__ default 0.0
            %
            % See also: cv.MergeMertens.process
            %
            this.id = MergeMertens_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also cv.MergeMertens
            %
            MergeMertens_(this.id, 'delete');
        end
    end

    %% MergeExposures
    methods
        function dst = process(this, src)
            %PROCESS  Merges images
            %
            %    dst = obj.process(src)
            %
            % ## Input
            % * __src__ vector of input images (1- or 3-channels), all of the
            %       same size and `uint8` type.
            %
            % ## Output
            % * __dst__ result image, same size as `src{i}` and `single` type.
            %
            % See also: cv.MergeMertens.MergeMertens
            %
            dst = MergeMertens_(this.id, 'process', src);
        end
    end

    %% Algorithm
    methods (Hidden)
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %    obj.clear()
            %
            % See also: cv.MergeMertens.empty, cv.MergeMertens.load
            %
            MergeMertens_(this.id, 'clear');
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
            % See also: cv.MergeMertens.clear, cv.MergeMertens.load
            %
            b = MergeMertens_(this.id, 'empty');
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
            % See also: cv.MergeMertens.save, cv.MergeMertens.load
            %
            name = MergeMertens_(this.id, 'getDefaultName');
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
            % See also: cv.MergeMertens.load
            %
            MergeMertens_(this.id, 'save', filename);
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
            % See also: cv.MergeMertens.save
            %
            MergeMertens_(this.id, 'load', fname_or_str, varargin{:});
        end
    end

    %% Getters/Setters
    methods
        function value = get.ContrastWeight(this)
            value = AlignMTB_(this.id, 'get', 'ContrastWeight');
        end
        function set.ContrastWeight(this, value)
            AlignMTB_(this.id, 'set', 'ContrastWeight', value);
        end

        function value = get.SaturationWeight(this)
            value = AlignMTB_(this.id, 'get', 'SaturationWeight');
        end
        function set.SaturationWeight(this, value)
            AlignMTB_(this.id, 'set', 'SaturationWeight', value);
        end

        function value = get.ExposureWeight(this)
            value = AlignMTB_(this.id, 'get', 'ExposureWeight');
        end
        function set.ExposureWeight(this, value)
            AlignMTB_(this.id, 'set', 'ExposureWeight', value);
        end
    end

end
