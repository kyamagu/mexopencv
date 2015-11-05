classdef SURF < handle
    %SURF  Class for extracting Speeded Up Robust Features from an image.
    %
    % ## References:
    % [Bay06]:
    % > Herbert Bay, Tinne Tuytelaars, and Luc Van Gool.
    % > "SURF: Speeded Up Robust Features".
    % > Computer Vision-ECCV 2006, pages 404-417, 2006.
    % > http://www.vision.ee.ethz.ch/~surf/eccv06.pdf
    %
    % See also: cv.FeatureDetector, cv.DescriptorExtractor,
    %  detectSURFFeatures, extractFeatures
    %

    properties (SetAccess = private)
        id    % Object ID
    end

    properties (Dependent)
        % Threshold for the keypoint detector.
        %
        % Only features, whose hessian is larger than `HessianThreshold` are
        % retained by the detector. Therefore, the larger the value, the less
        % keypoints you will get. A good default value could be from 300 to
        % 500, depending from the image contrast.
        HessianThreshold
        % The number of a gaussian pyramid octaves that the detector uses.
        %
        % It is set to 4 by default. If you want to get very large features,
        % use the larger value. If you want just small features, decrease it.
        NOctaves
        % The number of images within each octave of a gaussian pyramid.
        %
        % It is set to 2 by default.
        NOctaveLayers
        % Basic or Extended descriptors.
        %
        % * __false__ means that the basic descriptors (64 elements each)
        %       shall be computed. This is the default.
        % * __true__ means that the extended descriptors (128 elements each)
        %       shall be computed.
        Extended
        % Up-right or rotated features.
        %
        % * __false__ means that detector computes orientation of each
        %       feature. This is the default.
        % * __true__ means that the orientation is not computed (which is much
        %       much faster). For example, if you match images from a stereo
        %       pair, or do image stitching, the matched features likely have
        %       very similar angles, and you can speed up feature extraction
        %       by setting `Upright=true`.
        Upright
    end

    methods
        function this = SURF(varargin)
            %SURF  Constructor
            %
            %    obj = cv.SURF()
            %    obj = cv.SURF(..., 'OptionName',optionValue, ...)
            %
            % ## Options
            % * __HessianThreshold__ Threshold for hessian keypoint detector
            %       used in SURF. default 100
            % * __NOctaves__ Number of pyramid octaves the keypoint detector
            %       will use. default 4
            % * __NOctaveLayers__ Number of octave layers within each octave.
            %       default 3
            % * __Extended__ Extended descriptor flag (true: use extended
            %       128-element descriptors; false: use 64-element
            %       descriptors). default false
            % * __Upright__ Up-right or rotated features flag (true: do not
            %       compute orientation of features; false: compute
            %       orientation). default false
            %
            % See also: cv.SURF.detectAndCompute
            %
            this.id = SURF_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also: cv.SURF
            %
            SURF_(this.id, 'delete');
        end

        function typename = typeid(this)
            %TYPEID  Name of the C++ type (RTTI)
            %
            %    typename = obj.typeid()
            %
            % ## Output
            % * __typename__ Name of C++ type
            %
            typename = SURF_(this.id, 'typeid');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %    obj.clear()
            %
            % See also: cv.SURF.empty, cv.SURF.load
            %
            SURF_(this.id, 'clear');
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
            % See also: cv.SURF.clear, cv.SURF.load
            %
            b = SURF_(this.id, 'empty');
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
            % See also: cv.SURF.load
            %
            SURF_(this.id, 'save', filename);
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
            % See also: cv.SURF.save
            %
            SURF_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.SURF.save, cv.SURF.load
            %
            name = SURF_(this.id, 'getDefaultName');
        end
    end

    %% Features2D: FeatureDetector + DescriptorExtractor
    methods
        function ntype = defaultNorm(this)
            %DEFAULTNORM  Returns the default norm type
            %
            %    ntype = obj.defaultNorm()
            %
            % ## Output
            % * __ntype__ Norm type. One of `cv::NormTypes`:
            %       * __Inf__
            %       * __L1__
            %       * __L2__
            %       * __L2Sqr__
            %       * __Hamming__
            %       * __Hamming2__
            %
            % Always `L2` for SURF.
            %
            % See also: cv.SURF.compute, cv.DescriptorMatcher
            %
            ntype = SURF_(this.id, 'defaultNorm');
        end

        function sz = descriptorSize(this)
            %DESCRIPTORSIZE  Returns the descriptor size in floats
            %
            %    sz = obj.descriptorSize()
            %
            % ## Output
            % * __sz__ Descriptor size, either 64 or 128 (see the
            %       cv.SURF.Extended property).
            %
            % See also: cv.SURF.descriptorType, cv.SURF.compute
            %
            sz = SURF_(this.id, 'descriptorSize');
        end

        function dtype = descriptorType(this)
            %DESCRIPTORTYPE  Returns the descriptor type
            %
            %    dtype = obj.descriptorType()
            %
            % ## Output
            % * __dtype__ Descriptor type, one of numeric MATLAB class names.
            %
            % Always `single` for SURF.
            %
            % See also: cv.SURF.descriptorSize, cv.SURF.compute
            %
            dtype = SURF_(this.id, 'descriptorType');
        end

        function keypoints = detect(this, img, varargin)
            %DETECT  Detects keypoints in an image or image set.
            %
            %    keypoints = obj.detect(img)
            %    keypoints = obj.detect(imgs)
            %    [...] = obj.detect(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __img__ Image (first variant), 8-bit grayscale image.
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
            % See also: cv.SURF.compute, cv.SURF.detectAndCompute
            %
            keypoints = SURF_(this.id, 'detect', img, varargin{:});
        end

        function [descriptors, keypoints] = compute(this, img, keypoints)
            %COMPUTE  Computes the descriptors for a set of keypoints detected in an image or image set.
            %
            %    [descriptors, keypoints] = obj.compute(img, keypoints)
            %    [descriptors, keypoints] = obj.compute(imgs, keypoints)
            %
            % ## Input
            % * __img__ Image (first variant), 8-bit grayscale image.
            % * __imgs__ Image set (second variant), cell array of images.
            % * __keypoints__ Input collection of keypoints. Keypoints for
            %       which a descriptor cannot be computed are removed.
            %       Sometimes new keypoints can be added, for example: cv.SIFT
            %       duplicates keypoint with several dominant orientations
            %       (for each orientation). In the first variant, this is a
            %       struct-array of detected keypoints. In the second variant,
            %       it is a cell-array, where `keypoints{i}` is a set of keypoints
            %       detected in `images{i}` (a struct-array like before).
            %
            % ## Output
            % * __descriptors__ Computed descriptors. In the second variant of
            %       the method `descriptors{i}` are descriptors computed for a
            %       `keypoints{i}`. Row `j` in `descriptors` (or
            %       `descriptors{i}`) is the descriptor for `j`-th keypoint.
            % * __keypoints__ Optional output with possibly updated keypoints.
            %
            % See also: cv.SURF.detect, cv.SURF.detectAndCompute
            %
            [descriptors, keypoints] = SURF_(this.id, 'compute', img, keypoints);
        end

        function [keypoints, descriptors] = detectAndCompute(this, img, varargin)
            %DETECTANDCOMPUTE  Detects keypoints and computes their descriptors
            %
            %    [keypoints, descriptors] = obj.detectAndCompute(img)
            %    [...] = obj.detectAndCompute(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __img__ Image, input 8-bit grayscale image.
            %
            % ## Output
            % * __keypoints__ The detected keypoints. A 1-by-N structure array
            %       with the following fields:
            %       * __pt__ coordinates of the keypoint `[x,y]`
            %       * __size__ diameter of the meaningful keypoint neighborhood
            %       * __angle__ computed orientation of the keypoint (-1 if not
            %             applicable); it's in [0,360) degrees and measured
            %             relative to image coordinate system (y-axis is
            %             directed downward), i.e in clockwise.
            %       * __response__ the response by which the most strong
            %             keypoints have been selected. Can be used for further
            %             sorting or subsampling.
            %       * __octave__ octave (pyramid layer) from which the keypoint
            %             has been extracted.
            %       * **class_id** object class (if the keypoints need to be
            %             clustered by an object they belong to).
            % * __descriptors__ Computed descriptors. Output concatenated
            %       vectors of descriptors. Each descriptor is a 64- or
            %       128-element vector, as returned by cv.SURF.descriptorSize,
            %       so the total size of descriptors will be
            %       `numel(keypoints) * obj.descriptorSize()`. A matrix of
            %       size N-by-(64/128) of class `single`, one row per keypoint.
            %
            % ## Options
            % * __Mask__ optional mask specifying where to look for keypoints.
            %       Not set by default.
            % * __Keypoints__ If passed, then the method will use the provided
            %       vector of keypoints instead of detecting them, and the
            %       algorithm just computes their descriptors.
            %
            % The function is parallelized with the TBB library.
            %
            % See also: cv.SURF.detect, cv.SURF.compute
            %
            [keypoints, descriptors] = SURF_(this.id, 'detectAndCompute', img, varargin{:});
        end
    end

    %% Getters/Setters
    methods
        function value = get.HessianThreshold(this)
            value = SURF_(this.id, 'get', 'HessianThreshold');
        end
        function set.HessianThreshold(this, value)
            SURF_(this.id, 'set', 'HessianThreshold', value);
        end

        function value = get.NOctaves(this)
            value = SURF_(this.id, 'get', 'NOctaves');
        end
        function set.NOctaves(this, value)
            SURF_(this.id, 'set', 'NOctaves', value);
        end

        function value = get.NOctaveLayers(this)
            value = SURF_(this.id, 'get', 'NOctaveLayers');
        end
        function set.NOctaveLayers(this, value)
            SURF_(this.id, 'set', 'NOctaveLayers', value);
        end

        function value = get.Extended(this)
            value = SURF_(this.id, 'get', 'Extended');
        end
        function set.Extended(this, value)
            SURF_(this.id, 'set', 'Extended', value);
        end

        function value = get.Upright(this)
            value = SURF_(this.id, 'get', 'Upright');
        end
        function set.Upright(this, value)
            SURF_(this.id, 'set', 'Upright', value);
        end
    end

end
