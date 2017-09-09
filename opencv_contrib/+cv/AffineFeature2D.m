classdef AffineFeature2D < handle
    %AFFINEFEATURE2D  Class implementing affine adaptation for key points
    %
    % A cv.FeatureDetector and a cv.DescriptorExtractor are wrapped to augment
    % the detected points with their affine invariant elliptic region and to
    % compute the feature descriptors on the regions after warping them into
    % circles.
    %
    % The interface is equivalent to Feature2D, adding operations for
    % Elliptic_KeyPoint instead of KeyPoint.
    %
    % See also: cv.FeatureDetector, cv.DescriptorExtractor
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    %% Constructor/destructor
    methods
        function this = AffineFeature2D(varargin)
            %AFFINEFEATURE2D  Constructor
            %
            %     obj = cv.AffineFeature2D(detector)
            %     obj = cv.AffineFeature2D(detector, extractor)
            %
            %     obj = cv.AffineFeature2D({detector, 'key',val,...})
            %     obj = cv.AffineFeature2D({detector, 'key',val,...}, {extractor, 'key',val,...})
            %
            % ## Input
            % * __detector__ Feature detector. It can be spacified by a string
            %   specifying the type of feature detector, such as
            %   'HarrisLaplaceFeatureDetector'. See
            %   cv.FeatureDetector.FeatureDetector for possible types.
            % * __extractor__ Descriptor extractor. It can be specified by a
            %   string containing the type of descriptor extractor. See
            %   cv.DescriptorExtractor.DescriptorExtractor for possible types.
            %
            % In the first variant, it creates descriptor detector/extractor
            % of the given types using default parameters (by calling the
            % default constructors).
            %
            % In the second variant, it creates descriptor detector/extractor
            % of the given types using the specified options.
            % Each algorithm type takes optional arguments. Each of the
            % detector/extractor are specified by a cell-array that starts
            % with the type name followed by option arguments, as in:
            % `{'Type', 'OptionName',optionValue, ...}`.
            % Refer to the individual detector/extractor functions to see a
            % list of possible options of each algorithm.
            %
            % When both detector/extractor are passed, it creates an instance
            % wrapping the given keypoint detector and descriptor extractor.
            %
            % When only the detector is passed, it creates an instance where
            % keypoint detector and descriptor extractor are identical.
            %
            % ## Example
            %
            %     detector = cv.AffineFeature2D('HarrisLaplaceFeatureDetector');
            %
            %     detector = cv.AffineFeature2D(...
            %         {'HarrisLaplaceFeatureDetector', 'NumOctaves',6}, ...
            %         {'SURF', 'Upright',false});
            %
            % See also: cv.AffineFeature2D.detectAndCompute
            %
            this.id = AffineFeature2D_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.AffineFeature2D
            %
            if isempty(this.id), return; end
            AffineFeature2D_(this.id, 'delete');
        end

        function typename = typeid(this)
            %TYPEID  Name of the C++ type (RTTI)
            %
            %     typename = obj.typeid()
            %
            % ## Output
            % * __typename__ Name of C++ type
            %
            typename = AffineFeature2D_(this.id, 'typeid');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.AffineFeature2D.empty, cv.AffineFeature2D.load
            %
            AffineFeature2D_(this.id, 'clear');
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
            % See also: cv.AffineFeature2D.clear, cv.AffineFeature2D.load
            %
            b = AffineFeature2D_(this.id, 'empty');
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
            % See also: cv.AffineFeature2D.load
            %
            AffineFeature2D_(this.id, 'save', filename);
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
            % See also: cv.AffineFeature2D.save
            %
            AffineFeature2D_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.AffineFeature2D.save, cv.AffineFeature2D.load
            %
            name = AffineFeature2D_(this.id, 'getDefaultName');
        end
    end

    %% Features2D: FeatureDetector + DescriptorExtractor
    methods
        function ntype = defaultNorm(this)
            %DEFAULTNORM  Returns the default norm type
            %
            %     ntype = obj.defaultNorm()
            %
            % ## Output
            % * __ntype__ Norm type. One of `cv::NormTypes`:
            %   * __Inf__
            %   * __L1__
            %   * __L2__
            %   * __L2Sqr__
            %   * __Hamming__
            %   * __Hamming2__
            %
            % See also: cv.AffineFeature2D.compute, cv.DescriptorMatcher
            %
            ntype = AffineFeature2D_(this.id, 'defaultNorm');
        end

        function sz = descriptorSize(this)
            %DESCRIPTORSIZE  Returns the descriptor size
            %
            %     sz = obj.descriptorSize()
            %
            % ## Output
            % * __sz__ Descriptor size.
            %
            % See also: cv.AffineFeature2D.descriptorType,
            %  cv.AffineFeature2D.compute
            %
            sz = AffineFeature2D_(this.id, 'descriptorSize');
        end

        function dtype = descriptorType(this)
            %DESCRIPTORTYPE  Returns the descriptor type
            %
            %     dtype = obj.descriptorType()
            %
            % ## Output
            % * __dtype__ Descriptor type, one of numeric MATLAB class names.
            %
            % See also: cv.AffineFeature2D.descriptorSize,
            %  cv.AffineFeature2D.compute
            %
            dtype = AffineFeature2D_(this.id, 'descriptorType');
        end

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
            % See also: cv.AffineFeature2D.compute,
            %  cv.AffineFeature2D.detectAndCompute
            %
            keypoints = AffineFeature2D_(this.id, 'detect', img, varargin{:});
        end

        function [descriptors, keypoints] = compute(this, img, keypoints)
            %COMPUTE  Computes the descriptors for a set of keypoints detected in an image or image set
            %
            %     [descriptors, keypoints] = obj.compute(img, keypoints)
            %     [descriptors, keypoints] = obj.compute(imgs, keypoints)
            %
            % ## Input
            % * __img__ Image (first variant), 8-bit grayscale image.
            % * __imgs__ Image set (second variant), cell array of images.
            % * __keypoints__ Input collection of keypoints. Keypoints for
            %   which a descriptor cannot be computed are removed. Sometimes
            %   new keypoints can be added, for example: cv.AffineFeature2D
            %   duplicates keypoint with several dominant orientations (for
            %   each orientation). In the first variant, this is a
            %   struct-array of detected keypoints. In the second variant, it
            %   is a cell-array, where `keypoints{i}` is a set of keypoints
            %   detected in `imgs{i}` (a struct-array like before).
            %
            % ## Output
            % * __descriptors__ Computed descriptors. In the second variant of
            %   the method `descriptors{i}` are descriptors computed for a
            %   `keypoints{i}`. Row `j` in `descriptors` (or `descriptors{i}`)
            %   is the descriptor for `j`-th keypoint.
            % * __keypoints__ Optional output with possibly updated keypoints.
            %
            % See also: cv.AffineFeature2D.detect,
            %  cv.AffineFeature2D.detectAndCompute
            %
            [descriptors, keypoints] = AffineFeature2D_(this.id, 'compute', img, keypoints);
        end

        function [keypoints, descriptors] = detectAndCompute(this, img, varargin)
            %DETECTANDCOMPUTE  Detects keypoints and computes their descriptors
            %
            %     [keypoints, descriptors] = obj.detectAndCompute(img)
            %     [...] = obj.detectAndCompute(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __img__ Image, input 8-bit grayscale image.
            %
            % ## Output
            % * __keypoints__ The detected keypoints. A 1-by-N structure array
            %   with the following fields:
            %   * __pt__ coordinates of the keypoint `[x,y]`
            %   * __size__ diameter of the meaningful keypoint neighborhood
            %   * __angle__ computed orientation of the keypoint (-1 if not
            %     applicable); it's in [0,360) degrees and measured relative
            %     to image coordinate system (y-axis is directed downward),
            %     i.e in clockwise.
            %   * __response__ the response by which the most strong keypoints
            %     have been selected. Can be used for further sorting or
            %     subsampling.
            %   * __octave__ octave (pyramid layer) from which the keypoint
            %     has been extracted.
            %   * **class_id** object class (if the keypoints need to be
            %     clustered by an object they belong to).
            % * __descriptors__ Computed descriptors. Output concatenated
            %   vectors of descriptors. Each descriptor is a 128-element
            %   vector, as returned by cv.AffineFeature2D.descriptorSize, so
            %   the total size of descriptors will be
            %   `numel(keypoints) * obj.descriptorSize()`. A matrix of size
            %   N-by-128 of class `single`, one row per keypoint.
            %
            % ## Options
            % * __Mask__ optional mask specifying where to look for keypoints.
            %   Not set by default.
            % * __Keypoints__ If passed, then the method will use the provided
            %   vector of keypoints instead of detecting them, and the
            %   algorithm just computes their descriptors.
            %
            % See also: cv.AffineFeature2D.detect, cv.AffineFeature2D.compute
            %
            [keypoints, descriptors] = AffineFeature2D_(this.id, 'detectAndCompute', img, varargin{:});
        end
    end

    %% AffineFeature2D
    methods
        function keypoints = detect_elliptic(this, img, varargin)
            %DETECT_ELLIPTIC  Detects keypoints in an image
            %
            %     keypoints = obj.detect_elliptic(img)
            %     [...] = obj.detect_elliptic(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __img__ Image, 8-bit grayscale image.
            %
            % ## Output
            % * __keypoints__ The detected keypoints, 1-by-N structure array.
            %
            % ## Options
            % * __Mask__ optional mask specifying where to look for keypoints.
            %   Not set by default.
            %
            % Detects keypoints in the image using the wrapped detector and
            % performs affine adaptation to augment them with their elliptic
            % regions.
            %
            % See also: cv.AffineFeature2D.detect,
            %  cv.AffineFeature2D.detectAndCompute_elliptic
            %
            keypoints = AffineFeature2D_(this.id, 'detect_elliptic', img, varargin{:});
        end

        function [keypoints, descriptors] = detectAndCompute_elliptic(this, img, varargin)
            %DETECTANDCOMPUTE_ELLIPTIC  Detects keypoints and computes their descriptors
            %
            %     [keypoints, descriptors] = obj.detectAndCompute_elliptic(img)
            %     [...] = obj.detectAndCompute_elliptic(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __img__ Image, input 8-bit grayscale image.
            %
            % ## Output
            % * __keypoints__ The detected keypoints (elliptic region around
            %   an interest point). A 1-by-N structure array with the
            %   following fields:
            %   * __pt__ coordinates of the keypoint `[x,y]`
            %   * __size__ diameter of the meaningful keypoint neighborhood
            %   * __angle__ computed orientation of the keypoint (-1 if not
            %     applicable); it's in [0,360) degrees and measured relative
            %     to image coordinate system (y-axis is directed downward),
            %     i.e in clockwise.
            %   * __response__ the response by which the most strong
            %     keypoints have been selected. Can be used for further
            %     sorting or subsampling.
            %   * __octave__ octave (pyramid layer) from which the keypoint
            %     has been extracted.
            %   * **class_id** object class (if the keypoints need to be
            %     clustered by an object they belong to).
            %   * __axes__ the lengths of the major and minor ellipse axes
            %     `[ax1,ax2]`
            %   * __si__ the integration scale at which the parameters were
            %     estimated.
            %   * __transf__ the transformation between image space and local
            %     patch space, 2x3 matrix.
            % * __descriptors__ Computed descriptors.
            %
            % ## Options
            % * __Mask__ optional mask specifying where to look for keypoints.
            %   Not set by default.
            % * __Keypoints__ If passed, then the method will use the provided
            %   vector of keypoints instead of detecting them, and the
            %   algorithm just computes their descriptors.
            %
            % Detects keypoints and computes descriptors for their surrounding
            % regions, after warping them into circles.
            %
            % See also: cv.AffineFeature2D.detectAndCompute,
            %  cv.AffineFeature2D.detect_elliptic
            %
            [keypoints, descriptors] = AffineFeature2D_(this.id, 'detectAndCompute_elliptic', img, varargin{:});
        end
    end
end
