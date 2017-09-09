classdef GraphSegmentation < handle
    %GRAPHSEGMENTATION  Graph Based Segmentation algorithm
    %
    % The class implements the algorithm described in [PFF2004].
    %
    % ## References
    % [PFF2004]:
    % > Pedro F Felzenszwalb and Daniel P Huttenlocher. "Efficient graph-based
    % > image segmentation". volume 59, pages 167-181. Springer, 2004.
    %
    % See also: cv.GraphSegmentation.GraphSegmentation
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % The sigma parameter, used to smooth image.
        Sigma
        % The k parameter of the algorithm.
        K
        % The minimum size of segments.
        MinSize
    end

    methods
        function this = GraphSegmentation(varargin)
            %GRAPHSEGMENTATION  Creates a graph based segmentor
            %
            %     obj = cv.GraphSegmentation()
            %     obj = cv.GraphSegmentation('OptionName',optionValue, ...)
            %
            % ## Options
            % * __Sigma__ The sigma parameter, used to smooth image.
            %   default 0.5
            % * __K__ The k parameter of the algorithm. default 300
            % * __MinSize__ The minimum size of segments. default 100
            %
            % See also: cv.GraphSegmentation.processImage
            %
            this.id = GraphSegmentation_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.GraphSegmentation
            %
            if isempty(this.id), return; end
            GraphSegmentation_(this.id, 'delete');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.GraphSegmentation.empty, cv.GraphSegmentation.load
            %
            GraphSegmentation_(this.id, 'clear');
        end

        function b = empty(this)
            %EMPTY  Checks if detector object is empty
            %
            %     b = obj.empty()
            %
            % ## Output
            % * __b__ Returns true if the detector object is empty (e.g in the
            %   very beginning or after unsuccessful read).
            %
            % See also: cv.GraphSegmentation.clear, cv.GraphSegmentation.load
            %
            b = GraphSegmentation_(this.id, 'empty');
        end

        function save(this, filename)
            %SAVE  Saves the algorithm parameters to a file
            %
            %     obj.save(filename)
            %
            % ## Input
            % * __filename__ Name of the file to save to.
            %
            % This method stores the algorithm parameters in the specified
            % XML or YAML file.
            %
            % See also: cv.GraphSegmentation.load
            %
            GraphSegmentation_(this.id, 'save', filename);
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
            % This method reads algorithm parameters from the specified XML or
            % YAML file (either from disk or serialized string). The previous
            % algorithm state is discarded.
            %
            % See also: cv.GraphSegmentation.save
            %
            GraphSegmentation_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.GraphSegmentation.save, cv.GraphSegmentation.load
            %
            name = GraphSegmentation_(this.id, 'getDefaultName');
        end
    end

    %% GraphSegmentation
    methods
        function dst = processImage(this, src)
            %PROCESSIMAGE  Segment an image and store output in dst
            %
            %     dst = obj.processImage(src)
            %
            % ## Input
            % * __src__ The input image. Any number of channel (1 (Eg: Gray),
            %   3 (Eg: RGB), 4 (Eg: RGB-D)) can be provided.
            %
            % ## Output
            % * __dst__ The output segmentation. It's a `int32` matrix with
            %   the same number of cols and rows as input image, with a
            %   unique sequential id for each pixel.
            %
            % See also: cv.GraphSegmentation.GraphSegmentation
            %
            dst = GraphSegmentation_(this.id, 'processImage', src);
        end
    end

    %% Getters/Setters
    methods
        function value = get.Sigma(this)
            value = GraphSegmentation_(this.id, 'get', 'Sigma');
        end
        function set.Sigma(this, value)
            GraphSegmentation_(this.id, 'set', 'Sigma', value);
        end

        function value = get.K(this)
            value = GraphSegmentation_(this.id, 'get', 'K');
        end
        function set.K(this, value)
            GraphSegmentation_(this.id, 'set', 'K', value);
        end

        function value = get.MinSize(this)
            value = GraphSegmentation_(this.id, 'get', 'MinSize');
        end
        function set.MinSize(this, value)
            GraphSegmentation_(this.id, 'set', 'MinSize', value);
        end
    end

end
