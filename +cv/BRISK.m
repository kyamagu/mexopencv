classdef BRISK < handle
    %BRISK  Class implementing the BRISK keypoint detector and descriptor extractor
    %
    % As described in [LCS11].
    %
    % ## References:
    % [LCS11]:
    % > Stefan Leutenegger, Margarita Chli, and Roland Yves Siegwart.
    % > "BRISK: Binary Robust Invariant Scalable Keypoints".
    % > In IEEE International Conference on Computer Vision (ICCV) 2011,
    % > pages 2548-2555. IEEE, 2011.
    %
    % See also: cv.BRISK.BRISK, cv.FeatureDetector, cv.DescriptorExtractor,
    %  detectBRISKFeatures, extractFeatures
    %

    properties (SetAccess = private)
        id    % Object ID
    end

    methods
        function this = BRISK(varargin)
            %BRISK  The BRISK constructor.
            %
            %    obj = cv.BRISK()
            %    obj = cv.BRISK(radiusList, numberList)
            %    obj = cv.BRISK(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __radiusList__ defines the radii (in pixels) where the samples
            %       around a keypoint are taken (for keypoint scale 1).
            % * __numberList__ defines the number of sampling points on the
            %       sampling circle. Must be the same size as `radiusList`.
            %
            % ## Options
            % Options accepted by first variant:
            %
            % * __Threshold__ FAST/AGAST detection threshold score. default 30
            % * __Octaves__ detection octaves. Use 0 to do single scale.
            %       default 3
            % * __PatternScale__ apply this scale to the pattern used for
            %       sampling the neighbourhood of a keypoint. default 1.0
            %
            % Options accepted by second variant for a custom pattern:
            %
            % * __DMax__ threshold for the short pairings used for descriptor
            %       formation (in pixels for keypoint scale 1). default 5.85
            % * __DMin__ threshold for the long pairings used for orientation
            %       determination (in pixels for keypoint scale 1). default 8.2
            % * __IndexChange__ index remapping of the bits.
            %       default empty vector.
            %
            % See also: cv.BRISK.detectAndCompute
            %
            this.id = BRISK_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also: cv.BRISK
            %
            BRISK_(this.id, 'delete');
        end

        function typename = typeid(this)
            %TYPEID  Name of the C++ type (RTTI)
            %
            %    typename = obj.typeid()
            %
            % ## Output
            % * __typename__ Name of C++ type
            %
            typename = BRISK_(this.id, 'typeid');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %    obj.clear()
            %
            % See also: cv.BRISK.empty, cv.BRISK.load
            %
            BRISK_(this.id, 'clear');
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
            % See also: cv.BRISK.clear, cv.BRISK.load
            %
            b = BRISK_(this.id, 'empty');
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
            % See also: cv.BRISK.load
            %
            BRISK_(this.id, 'save', filename);
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
            % See also: cv.BRISK.save
            %
            BRISK_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.BRISK.save, cv.BRISK.load
            %
            name = BRISK_(this.id, 'getDefaultName');
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
            % Always `Hamming` for BRISK.
            %
            % See also: cv.BRISK.compute, cv.DescriptorMatcher
            %
            ntype = BRISK_(this.id, 'defaultNorm');
        end

        function sz = descriptorSize(this)
            %DESCRIPTORSIZE  Returns the descriptor size in bytes
            %
            %    sz = obj.descriptorSize()
            %
            % ## Output
            % * __sz__ Descriptor size.
            %
            % See also: cv.BRISK.descriptorType, cv.BRISK.compute
            %
            sz = BRISK_(this.id, 'descriptorSize');
        end

        function dtype = descriptorType(this)
            %DESCRIPTORTYPE  Returns the descriptor type
            %
            %    dtype = obj.descriptorType()
            %
            % ## Output
            % * __dtype__ Descriptor type, one of numeric MATLAB class names.
            %
            % Always `uint8` for BRISK.
            %
            % See also: cv.BRISK.descriptorSize, cv.BRISK.compute
            %
            dtype = BRISK_(this.id, 'descriptorType');
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
            % See also: cv.BRISK.compute, cv.BRISK.detectAndCompute
            %
            keypoints = BRISK_(this.id, 'detect', img, varargin{:});
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
            % See also: cv.BRISK.detect, cv.BRISK.detectAndCompute
            %
            [descriptors, keypoints] = BRISK_(this.id, 'compute', img, keypoints);
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
            %       vectors of descriptors. Each descriptor is a vector of
            %       length cv.BRISK.descriptorSize, so the total size of
            %       descriptors will be `numel(keypoints) * obj.descriptorSize()`.
            %       A matrix of size N-by-sz of class `uint8`, one row per
            %       keypoint.
            %
            % ## Options
            % * __Mask__ optional mask specifying where to look for keypoints.
            %       Not set by default.
            % * __Keypoints__ If passed, then the method will use the provided
            %       vector of keypoints instead of detecting them, and the
            %       algorithm just computes their descriptors.
            %
            % See also: cv.BRISK.detect, cv.BRISK.compute
            %
            [keypoints, descriptors] = BRISK_(this.id, 'detectAndCompute', img, varargin{:});
        end
    end

end
