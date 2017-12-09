classdef GrayworldWB < handle
    %GRAYWORLDWB  Gray-world white balance algorithm
    %
    % This algorithm scales the values of pixels based on a gray-world
    % assumption which states that the average of all channels should result
    % in a gray image.
    %
    % It adds a modification which thresholds pixels based on their saturation
    % value and only uses pixels below the provided threshold in finding
    % average pixel values.
    %
    % Saturation is calculated using the following for a 3-channel RGB image
    % per pixel `I` and is in the range `[0,1]`:
    %
    %     Saturation[I] = (max(R,G,B) - min(R,G,B)) / max(R,G,B)
    %
    % A threshold of 1 means that all pixels are used to white-balance, while
    % a threshold of 0 means no pixels are used. Lower thresholds are useful
    % in white-balancing saturated images.
    %
    % Currently supports RGB images of type `uint8` and `uint16`.
    %
    % See also: cv.GrayworldWB.balanceWhite, cv.SimpleWB, cv.LearningBasedWB
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % Maximum saturation for a pixel to be included in the gray-world
        % assumption. default 0.9
        SaturationThreshold
    end

    %% Constructor/destructor
    methods
        function this = GrayworldWB()
            %GRAYWORLDWB  Creates an instance of GrayworldWB
            %
            %     obj = cv.GrayworldWB()
            %
            % See also: cv.GrayworldWB.balanceWhite
            %
            this.id = GrayworldWB_(0, 'new');
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.GrayworldWB
            %
            if isempty(this.id), return; end
            GrayworldWB_(this.id, 'delete');
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
            % * __src__ Input image, `uint8` or `uint16` color image.
            %
            % ## Output
            % * __dst__ White balancing result.
            %
            % See also: cv.cvtColor, cv.equalizeHist
            %
            dst = GrayworldWB_(this.id, 'balanceWhite', src);
        end
    end

    %% Algorithm
    methods (Hidden)
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.GrayworldWB.empty
            %
            GrayworldWB_(this.id, 'clear');
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
            % See also: cv.GrayworldWB.clear
            %
            b = GrayworldWB_(this.id, 'empty');
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
            % See also: cv.GrayworldWB.save, cv.GrayworldWB.load
            %
            name = GrayworldWB_(this.id, 'getDefaultName');
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
            % See also: cv.GrayworldWB.load
            %
            GrayworldWB_(this.id, 'save', filename);
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
            % See also: cv.GrayworldWB.save
            %
            GrayworldWB_(this.id, 'load', fname_or_str, varargin{:});
        end
    end

    %% Getters/Setters
    methods
        function value = get.SaturationThreshold(this)
            value = GrayworldWB_(this.id, 'get', 'SaturationThreshold');
        end
        function set.SaturationThreshold(this, value)
            GrayworldWB_(this.id, 'set', 'SaturationThreshold', value);
        end
    end

end
