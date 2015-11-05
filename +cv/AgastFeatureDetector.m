classdef AgastFeatureDetector < handle
    %AGASTFEATUREDETECTOR  Wrapping class for feature detection using the AGAST method.
    %
    % Detects corners using the AGAST algorithm by [mair2010].
    %
    % ## References:
    % [mair2010]:
    % > E. Mair, G. D. Hager, D. Burschka, M. Suppa, and G. Hirzinger.
    % > "Adaptive and generic corner detection based on the accelerated segment test".
    % > In "European Conference on Computer Vision (ECCV'10)", Sept 2010.
    % > (http://www6.in.tum.de/Main/ResearchAgast)
    %
    % See also: cv.AGAST, cv.FAST, cv.FeatureDetector
    %

    properties (SetAccess = private)
        id    % Object ID
    end

    properties (Dependent)
        % Threshold on difference between intensity of the central pixel
        % and pixels of a circle around this pixel.
        %
        % Default is 10
        Threshold
        % If true, non-maximum suppression is applied to detected corners
        % (keypoints).
        %
        % Default is true.
        NonmaxSuppression
        % One of the four neighborhoods as defined in the paper:
        %
        % * **AGAST_5_8**
        % * **AGAST_7_12d**
        % * **AGAST_7_12s**
        % * **OAST_9_16** (default)
        Type
    end

    methods
        function this = AgastFeatureDetector(varargin)
            %AGASTFEATUREDETECTOR  Constructor
            %
            %    obj = cv.AgastFeatureDetector()
            %    obj = cv.AgastFeatureDetector(..., 'OptionName',optionValue, ...)
            %
            % ## Options
            % * __Threshold__  See cv.AgastFeatureDetector.Threshold,
            %       default 10
            % * __NonmaxSuppression__ See
            %       cv.AgastFeatureDetector.NonmaxSuppression, default true
            % * __Type__ See cv.AgastFeatureDetector.Type, default 'OAST_9_16'
            %
            % See also: cv.AgastFeatureDetector.detect
            %
            this.id = AgastFeatureDetector_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also: cv.AgastFeatureDetector
            %
            AgastFeatureDetector_(this.id, 'delete');
        end

        function typename = typeid(this)
            %TYPEID  Name of the C++ type (RTTI)
            %
            %    typename = obj.typeid()
            %
            % ## Output
            % * __typename__ Name of C++ type
            %
            typename = AgastFeatureDetector_(this.id, 'typeid');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %    obj.clear()
            %
            % See also: cv.AgastFeatureDetector.empty,
            %  cv.AgastFeatureDetector.load
            %
            AgastFeatureDetector_(this.id, 'clear');
        end

        function b = empty(this)
            %EMPTY  Checks if detector object is empty.
            %
            %    b = obj.empty()
            %
            % ## Output
            % * __b__ Returns true if the detector object is empty (e.g in the
            %       very beginning or after unsuccessful read).
            %
            % See also: cv.AgastFeatureDetector.clear,
            %  cv.AgastFeatureDetector.load
            %
            b = AgastFeatureDetector_(this.id, 'empty');
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
            % See also: cv.AgastFeatureDetector.load
            %
            AgastFeatureDetector_(this.id, 'save', filename);
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
            % See also: cv.AgastFeatureDetector.save
            %
            AgastFeatureDetector_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.AgastFeatureDetector.save, cv.AgastFeatureDetector.load
            %
            name = AgastFeatureDetector_(this.id, 'getDefaultName');
        end
    end

    %% Features2D: FeatureDetector
    methods
        function keypoints = detect(this, img, varargin)
            %DETECT  Detects keypoints in an image or image set.
            %
            %    keypoints = obj.detect(img)
            %    keypoints = obj.detect(imgs)
            %    [...] = obj.detect(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __img__ Image (first variant), 8-bit grayscale image where
            %       keypoints (corners) are detected.
            % * __imgs__ Image set (second variant), cell array of images.
            %
            % ## Output
            % * __keypoints__ The detected keypoints. In the first variant,
            %       a 1-by-N structure array. In the second variant of the
            %       method, `keypoints{i}` is a set of keypoints detected in
            %       `imgs{i}`.
            %
            % ## Options
            % * __Mask__ A mask specifying where to look for keypoints
            %       (optional). It must be a logical or 8-bit integer matrix
            %       with non-zero values in the region of interest. In the
            %       second variant, it is a cell-array of masks for each input
            %       image, `masks{i}` is a mask for `imgs{i}`.
            %       Not set by default.
            %
            % See also: cv.AgastFeatureDetector.AgastFeatureDetector
            %
            keypoints = AgastFeatureDetector_(this.id, 'detect', img, varargin{:});
        end
    end

    %% Getters/Setters
    methods
        function value = get.Threshold(this)
            value = AgastFeatureDetector_(this.id, 'get', 'Threshold');
        end
        function set.Threshold(this, value)
            AgastFeatureDetector_(this.id, 'set', 'Threshold', value);
        end

        function value = get.NonmaxSuppression(this)
            value = AgastFeatureDetector_(this.id, 'get', 'NonmaxSuppression');
        end
        function set.NonmaxSuppression(this, value)
            AgastFeatureDetector_(this.id, 'set', 'NonmaxSuppression', value);
        end

        function value = get.Type(this)
            value = AgastFeatureDetector_(this.id, 'get', 'Type');
        end
        function set.Type(this, value)
            AgastFeatureDetector_(this.id, 'set', 'Type', value);
        end
    end

end
