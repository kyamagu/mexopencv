classdef LearningBasedWB < handle
    %LEARNINGBASEDWB  More sophisticated learning-based automatic white balance algorithm
    %
    % As cv.GrayworldWB, this algorithm works by applying different gains to
    % the input image channels, but their computation is a bit more involved
    % compared to the simple gray-world assumption. More details about the
    % algorithm can be found in [Cheng2015].
    %
    % To mask out saturated pixels this function uses only pixels that satisfy
    % the following condition:
    %
    %     max(R,G,B)/RangeMaxVal < SaturationThreshold
    %
    % Currently supports RGB images of type `uint8` and `uint16`.
    %
    % ## References
    % [Cheng2015]:
    % > Dongliang Cheng, Brian Price, Scott Cohen, and Michael S Brown.
    % > "Effective learning-based illuminant estimation using simple features".
    % > In Proceedings of the IEEE Conference on Computer Vision and Pattern
    % > Recognition, pages 1000-1008, 2015.
    %
    % See also: cv.LearningBasedWB.balanceWhite, cv.SimpleWB, cv.GrayworldWB
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % Maximum possible value of the input image (e.g. 255 for 8 bit images,
        % 4095 for 12 bit images). default 255
        RangeMaxVal
        % Threshold that is used to determine saturated pixels, i.e. pixels
        % where at least one of the channels exceeds
        % `SaturationThreshold*RangeMaxVal` are ignored. default 0.98
        SaturationThreshold
        % Defines the size of one dimension of a three-dimensional RGB
        % histogram that is used internally by the algorithm. It often makes
        % sense to increase the number of bins for images with higher bit
        % depth (e.g. 256 bins for a 12 bit image). default 64
        HistBinNum
    end

    %% Constructor/destructor
    methods
        function this = LearningBasedWB(varargin)
            %LEARNINGBASEDWB  Creates an instance of LearningBasedWB
            %
            %     obj = cv.LearningBasedWB()
            %     obj = cv.LearningBasedWB('OptionName',optionValue, ...)
            %
            % ## Options
            % * __PathToModel__ Path to a .yml file with the model. If not
            %   specified, the default model is used. Not set by default.
            %
            % See also: cv.LearningBasedWB.balanceWhite
            %
            this.id = LearningBasedWB_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.LearningBasedWB
            %
            if isempty(this.id), return; end
            LearningBasedWB_(this.id, 'delete');
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
            dst = LearningBasedWB_(this.id, 'balanceWhite', src);
        end
    end

    %% LearningBasedWB
    methods
        function dst = extractSimpleFeatures(this, src)
            %EXTRACTSIMPLEFEATURES  Implements the feature extraction part of the algorithm
            %
            %     dst = obj.extractSimpleFeatures(src)
            %
            % ## Input
            % * __src__ Input 3-channel image (BGR color space is assumed).
            %
            % ## Output
            % * __dst__ An array of four (r,g) chromaticity tuples
            %   corresponding to the features listed below.
            %
            % In accordance with [Cheng2015], computes the following features
            % for the input image:
            %
            % 1. Chromaticity of an average (R,G,B) tuple
            % 2. Chromaticity of the brightest (R,G,B) tuple (while ignoring
            %    saturated pixels)
            % 3. Chromaticity of the dominant (R,G,B) tuple (the one that has
            %    the highest value in the RGB histogram)
            % 4. Mode of the chromaticity palette, that is constructed by
            %    taking 300 most common colors according to the RGB histogram
            %    and projecting them on the chromaticity plane. Mode is the
            %    most high-density point of the palette, which is computed by
            %    a straightforward fixed-bandwidth kernel density estimator
            %    with a Epanechnikov kernel function.
            %
            % See also: cv.LearningBasedWB.balanceWhite
            %
            dst = LearningBasedWB_(this.id, 'extractSimpleFeatures', src);
        end
    end

    %% Algorithm
    methods (Hidden)
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.LearningBasedWB.empty
            %
            LearningBasedWB_(this.id, 'clear');
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
            % See also: cv.LearningBasedWB.clear
            %
            b = LearningBasedWB_(this.id, 'empty');
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
            % See also: cv.LearningBasedWB.save, cv.LearningBasedWB.load
            %
            name = LearningBasedWB_(this.id, 'getDefaultName');
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
            % See also: cv.LearningBasedWB.load
            %
            LearningBasedWB_(this.id, 'save', filename);
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
            % See also: cv.LearningBasedWB.save
            %
            LearningBasedWB_(this.id, 'load', fname_or_str, varargin{:});
        end
    end

    %% Getters/Setters
    methods
        function value = get.RangeMaxVal(this)
            value = LearningBasedWB_(this.id, 'get', 'RangeMaxVal');
        end
        function set.RangeMaxVal(this, value)
            LearningBasedWB_(this.id, 'set', 'RangeMaxVal', value);
        end

        function value = get.SaturationThreshold(this)
            value = LearningBasedWB_(this.id, 'get', 'SaturationThreshold');
        end
        function set.SaturationThreshold(this, value)
            LearningBasedWB_(this.id, 'set', 'SaturationThreshold', value);
        end

        function value = get.HistBinNum(this)
            value = LearningBasedWB_(this.id, 'get', 'HistBinNum');
        end
        function set.HistBinNum(this, value)
            LearningBasedWB_(this.id, 'set', 'HistBinNum', value);
        end
    end

end
