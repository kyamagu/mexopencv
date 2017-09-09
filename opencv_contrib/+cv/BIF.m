classdef BIF < handle
    %BIF  Implementation of bio-inspired features (BIF)
    %
    % An implementation of the bio-inspired features (BIF) approach for
    % computing image descriptors, applicable for human age estimation. For
    % more details we refer to [BIF09] and [BIF2015].
    %
    % ## References
    % [BIF09]:
    % > Guo, Guodong, et al. "Human age estimation using bio-inspired
    % > features". Computer Vision and Pattern Recognition, 2009. CVPR 2009.
    %
    % [BIF2015]:
    % > Spizhevoi, A. S., and A. V. Bovyrin. "Estimating human age using
    % > bio-inspired features and the ranking method." Pattern Recognition and
    % > Image Analysis 25.3 (2015): 547-552.
    %
    % See also: cv.BIF.BIF, cv.BIF.compute
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent, SetAccess = private)
        % The number of filter bands used for computing BIF
        NumBands
        % The number of image rotations
        NumRotations
    end

    %% Constructor/destructor
    methods
        function this = BIF(varargin)
            %BIF  Constructor
            %
            %     obj = cv.BIF()
            %     obj = cv.BIF('OptionName',optionValue, ...)
            %
            % ## Options
            % * __NumBands__ The number of filter bands (`<= 8`) used for
            %   computing BIF. default 8
            % * __NumRotations__ The number of image rotations for computing
            %   BIF. default 12
            %
            % See also: cv.BIF.compute
            %
            this.id = BIF_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.BIF
            %
            if isempty(this.id), return; end
            BIF_(this.id, 'delete');
        end
    end

    %% BIF
    methods
        function features = compute(this, img)
            %COMPUTE  Computes features sby input image
            %
            %     features = model.compute(img)
            %
            % ## Input
            % * __image__ Input image (1-channel `single`).
            %
            % ## Output
            % * __features__ Feature vector (`single` type).
            %
            % See also: cv.BIF.BIF
            %
            features = BIF_(this.id, 'compute', img);
        end
    end

    %% Algorithm
    methods (Hidden)
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.BIF.empty, cv.BIF.load
            %
            BIF_(this.id, 'clear');
        end

        function b = empty(this)
            %EMPTY  Checks if detector object is empty.
            %
            %     b = obj.empty()
            %
            % ## Output
            % * __b__ Returns true if the detector object is empty (e.g in the
            %   very beginning or after unsuccessful read).
            %
            % See also: cv.BIF.clear, cv.BIF.load
            %
            b = BIF_(this.id, 'empty');
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
            % See also: cv.BIF.load
            %
            BIF_(this.id, 'save', filename);
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
            % See also: cv.BIF.save
            %
            BIF_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.BIF.save, cv.BIF.load
            %
            name = BIF_(this.id, 'getDefaultName');
        end
    end

    %% Getters/Setters
    methods
        function value = get.NumBands(this)
            value = BIF_(this.id, 'get', 'NumBands');
        end

        function value = get.NumRotations(this)
            value = BIF_(this.id, 'get', 'NumRotations');
        end
    end

end
