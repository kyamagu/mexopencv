classdef HarrisLaplaceFeatureDetector < handle
    %HARRISLAPLACEFEATUREDETECTOR  Class implementing the Harris-Laplace feature detector
    %
    % As described in [Mikolajczyk2004].
    %
    % ## References
    % [Mikolajczyk2004]:
    % > Krystian Mikolajczyk and Cordelia Schmid. "Scale & affine invariant
    % > interest point detectors". International journal of computer vision,
    % > 60(1):63-86, 2004.
    %
    % See also: cv.HarrisLaplaceFeatureDetector.HarrisLaplaceFeatureDetector,
    %  cv.FeatureDetector
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    methods
        function this = HarrisLaplaceFeatureDetector(varargin)
            %HARRISLAPLACEFEATUREDETECTOR  The full constructor
            %
            %     obj = cv.HarrisLaplaceFeatureDetector()
            %     obj = cv.HarrisLaplaceFeatureDetector('OptionName',optionValue, ...)
            %
            % ## Options
            % * __NumOctaves__ the number of octaves in the scale-space
            %   pyramid. default 6
            % * __CornThresh__ the threshold for the Harris cornerness
            %   measure. default 0.01
            % * __DOGThresh__ the threshold for the Difference-of-Gaussians
            %   scale selection. default 0.01
            % * __MaxCorners__ the maximum number of corners to consider.
            %   default 5000
            % * __NumLayers__ the number of intermediate scales per octave.
            %   default 4
            %
            % See also: cv.HarrisLaplaceFeatureDetector.detect
            %
            this.id = HarrisLaplaceFeatureDetector_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.HarrisLaplaceFeatureDetector
            %
            if isempty(this.id), return; end
            HarrisLaplaceFeatureDetector_(this.id, 'delete');
        end

        function typename = typeid(this)
            %TYPEID  Name of the C++ type (RTTI)
            %
            %     typename = obj.typeid()
            %
            % ## Output
            % * __typename__ Name of C++ type
            %
            typename = HarrisLaplaceFeatureDetector_(this.id, 'typeid');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.HarrisLaplaceFeatureDetector.empty,
            %  cv.HarrisLaplaceFeatureDetector.load
            %
            HarrisLaplaceFeatureDetector_(this.id, 'clear');
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
            % See also: cv.HarrisLaplaceFeatureDetector.clear
            %
            b = HarrisLaplaceFeatureDetector_(this.id, 'empty');
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
            % See also: cv.HarrisLaplaceFeatureDetector.load
            %
            HarrisLaplaceFeatureDetector_(this.id, 'save', filename);
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
            % See also: cv.HarrisLaplaceFeatureDetector.save
            %
            HarrisLaplaceFeatureDetector_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.HarrisLaplaceFeatureDetector.save,
            %  cv.HarrisLaplaceFeatureDetector.load
            %
            name = HarrisLaplaceFeatureDetector_(this.id, 'getDefaultName');
        end
    end

    %% Features2D: FeatureDetector
    methods
        function keypoints = detect(this, img, varargin)
            %DETECT  Detects keypoints in an image or image set
            %
            %     keypoints = obj.detect(img)
            %     keypoints = obj.detect(imgs)
            %     [...] = obj.detect(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __img__ Image (first variant), 8-bit grayscale image.
            % * __imgs__ Image set (second variant), cell array of images.
            %
            % ## Output
            % * __keypoints__ The detected keypoints. In the first variant, a
            %   1-by-N structure array. In the second variant of the method,
            %   `keypoints{i}` is a set of keypoints detected in `imgs{i}`.
            %
            % ## Options
            % * __Mask__ A mask specifying where to look for keypoints
            %   (optional). It must be a logical or 8-bit integer matrix with
            %   non-zero values in the region of interest. In the second
            %   variant, it is a cell-array of masks for each input image,
            %   `masks{i}` is a mask for `imgs{i}`. Not set by default.
            %
            % See also: cv.HarrisLaplaceFeatureDetector.HarrisLaplaceFeatureDetector
            %
            keypoints = HarrisLaplaceFeatureDetector_(this.id, 'detect', img, varargin{:});
        end
    end

end
