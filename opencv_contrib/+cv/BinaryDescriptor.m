classdef BinaryDescriptor < handle
    %BINARYDESCRIPTOR  Class implements both functionalities for detection of lines and computation of their binary descriptor
    %
    % Class' interface is mainly based on the ones of classical detectors and
    % extractors, such as Feature2d's Feature Detection and Description and
    % Descriptor Matchers. Retrieved information about lines is stored in
    % `KeyLine` objects.
    %
    % ## Introduction
    %
    % One of the most challenging activities in computer vision is the
    % extraction of useful information from a given image. Such information,
    % usually comes in the form of points that preserve some kind of property
    % (for instance, they are scale-invariant) and are actually representative
    % of input image.
    %
    % The goal of this module is seeking a new kind of representative
    % information inside an image and providing the functionalities for its
    % extraction and representation. In particular, differently from previous
    % methods for detection of relevant elements inside an image, lines are
    % extracted in place of points; a new class is defined ad hoc to summarize
    % a line's properties, for reuse and plotting purposes.
    %
    % ## Computation of binary descriptors
    %
    % To obtatin a binary descriptor representing a certain line detected from
    % a certain octave of an image, we first compute a non-binary descriptor
    % as described in [LBD]. Such algorithm works on lines extracted using
    % `EDLine` detector, as explained in [EDL]. Given a line, we consider a
    % rectangular region centered at it and called *line support region (LSR)*.
    % Such region is divided into a set of bands `{B_1, B_2, ..., B_m}`,
    % whose length equals the one of line.
    %
    % If we indicate with `d_L` the direction of line, the orthogonal and
    % clockwise direction to line `d_perp` can be determined; these two
    % directions, are used to construct a reference frame centered in the
    % middle point of line. The gradients of pixels `g'` inside LSR can be
    % projected to the newly determined frame, obtaining their local equivalent
    % `g' = (g^T * d_perp, g^T * d_L)^T <=> (g'_{d_perp}, g'_{d_L})^T`.
    %
    % Later on, a Gaussian function is applied to all LSR's pixels along
    % `d_perp` direction; first, we assign a global weighting coefficient
    % `f_g(i) = (1/sqrt(2*pi)*sigma_g)*exp(-d_i^2/2*sigma_g^2)` to `i`-th row
    % in LSR, where `d_i` is the distance of `i`-th row from the center row in
    % LSR, `sigma_g = 0.5(m * w - 1)` and `w` is the width of bands (the same
    % for every band). Secondly, considering a band `B_j` and its neighbor
    % bands `B_{j-1}, B_{j+1}`, we assign a local weighting
    % `F_l(k) = (1/sqrt(2*pi)*sigma_l)*exp(-d_k'^2/2*sigma_l^2)`, where `d_k'`
    % is the distance of `k`-th row from the center row in `B_j` and
    % `sigma_l = w`. Using the global and local weights, we obtain, at the
    % same time, the reduction of role played by gradients far from line and
    % of boundary effect, respectively.
    %
    % Each band `B_j` in LSR has an associated *band descriptor(BD)* which is
    % computed considering previous and next band (top and bottom bands are
    % ignored when computing descriptor for first and last band). Once each
    % band has been assignen its BD, the LBD descriptor of line is simply
    % given by:
    %
    %     LBD = (BD_1^T, BD_2^T, ... , BD_m^T)^T
    %
    % To compute a band descriptor `B_j`, each `k`-th row in it is considered
    % and the gradients in such row are accumulated:
    %
    %     V1_j^k = lambda * sum[g'_{d_perp} > 0] (  g'_{d_perp} )
    %     V2_j^k = lambda * sum[g'_{d_perp} < 0] ( -g'_{d_perp} )
    %     V3_j^k = lambda * sum[g'_{d_L}    > 0] (  g'_{d_L}    )
    %     V4_j^k = lambda * sum[g'_{d_L}    < 0] ( -g'_{d_L}    )
    %
    % with `\lambda = f_g(k) * f_l(k)`
    %
    % By stacking previous results, we obtain the
    % *band description matrix (BDM)*
    %
    %     BDM_j = [V1_j^1, V1_j^2, ..., V1_j^n ;
    %              V2_j^1, V2_j^2, ..., V2_j^n ;
    %              V3_j^1, V3_j^2, ..., V3_j^n ;
    %              V4_j^1, V4_j^2, ..., V4_j^n ] in R^(4xn)
    %
    % with `n` the number of rows in band `B_j`:
    %
    %     n = {2w, j = 1||m;
    %         {3w, else.
    %
    % Each `BD_j` can be obtained using the standard deviation vector `S_j`
    % and mean vector `M_j` of `BDM_J`. Thus, finally:
    %
    %     LBD = (M_1^T, S_1^T, M_2^T, S_2^T, ..., M_m^T, S_m^T)^T in R^(8m)
    %
    % Once the LBD has been obtained, it must be converted into a binary form.
    % For such purpose, we consider 32 possible pairs of BD inside it; each
    % couple of BD is compared bit by bit and comparison generates an 8 bit
    % string. Concatenating 32 comparison strings, we get the 256-bit final
    % binary representation of a single LBD.
    %
    % ## References
    % [LBD]:
    % > HK Yuen, John Princen, John Illingworth, and Josef Kittler.
    % > "Comparative study of hough transform methods for circle finding".
    % > Image and Vision Computing, 8(1):71-77, 1990.
    %
    % [EDL]:
    % > R Grompone Von Gioi, Jeremie Jakubowicz, Jean-Michel Morel, and
    % > Gregory Randall. "LSD: A fast line segment detector with a false
    % > detection control". IEEE Transactions on Pattern Analysis and
    % > Machine Intelligence, 32(4):722-732, 2010.
    %
    % See also: cv.LSDDetector, cv.BinaryDescriptorMatcher
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % Number of octaves
        NumOfOctaves
        % Reduction ratio (used in Gaussian pyramids)
        ReductionRatio
        % Width of bands
        WidthOfBand
    end

    methods
        function this = BinaryDescriptor(varargin)
            %BINARYDESCRIPTOR  Create a BinaryDescriptor object with default parameters (or with the ones provided)
            %
            %     obj = cv.BinaryDescriptor()
            %     obj = cv.BinaryDescriptor('OptionName',optionValue, ...)
            %
            % ## Options
            % * __KSize__ the size of Gaussian kernel: `ksize-by-ksize`.
            %   default 5
            % * __NumOfOctave__ the number of image octaves. default 1
            % * __ReductionRatio__ image's reduction ratio in construction of
            %   Gaussian pyramids. default 2
            % * __WidthOfBand__ the width of band; default 7
            %
            % If no argument is provided, constructor sets default values.
            % Default values are strongly recommended.
            %
            % See also: cv.BinaryDescriptor.detectAndCompute
            %
            this.id = BinaryDescriptor_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.BinaryDescriptor
            %
            if isempty(this.id), return; end
            BinaryDescriptor_(this.id, 'delete');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.BinaryDescriptor.empty, cv.BinaryDescriptor.load
            %
            BinaryDescriptor_(this.id, 'clear');
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
            % See also: cv.BinaryDescriptor.clear, cv.BinaryDescriptor.load
            %
            b = BinaryDescriptor_(this.id, 'empty');
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
            % See also: cv.BinaryDescriptor.load
            %
            BinaryDescriptor_(this.id, 'save', filename);
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
            % See also: cv.BinaryDescriptor.save
            %
            BinaryDescriptor_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.BinaryDescriptor.save, cv.BinaryDescriptor.load
            %
            name = BinaryDescriptor_(this.id, 'getDefaultName');
        end
    end

    %% FeatureDetector + DescriptorExtractor
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
            % Always `Hamming` for BinaryDescriptor.
            %
            % See also: cv.BinaryDescriptor.compute, cv.DescriptorMatcher
            %
            ntype = BinaryDescriptor_(this.id, 'defaultNorm');
        end

        function sz = descriptorSize(this)
            %DESCRIPTORSIZE  Returns the descriptor size
            %
            %     sz = obj.descriptorSize()
            %
            % ## Output
            % * __sz__ Descriptor size.
            %
            % Always 256 for BinaryDescriptor (32*8).
            %
            % See also: cv.BinaryDescriptor.descriptorType,
            %  cv.BinaryDescriptor.compute
            %
            sz = BinaryDescriptor_(this.id, 'descriptorSize');
        end

        function dtype = descriptorType(this)
            %DESCRIPTORTYPE  Returns the descriptor type
            %
            %     dtype = obj.descriptorType()
            %
            % ## Output
            % * __dtype__ Descriptor type, one of numeric MATLAB class names.
            %
            % Always `uint8` for BinaryDescriptor.
            %
            % See also: cv.BinaryDescriptor.descriptorSize,
            %  cv.BinaryDescriptor.compute
            %
            dtype = BinaryDescriptor_(this.id, 'descriptorType');
        end

        function keylines = detect(this, img, varargin)
            %DETECT  Requires line detection
            %
            %     keylines = obj.detect(img)
            %     keylines = obj.detect(imgs)
            %     [...] = obj.detect(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __img__ Input image (first variant), 8-bit grayscale.
            % * __imgs__ Image set (second variant), cell array of images.
            %
            % ## Output
            % * __keylines__ Extracted lines for one or more images. In the
            %   first variant, a 1-by-N structure array. In the second variant
            %   of the method, `keylines{i}` is a set of keylines detected in
            %   `imgs{i}`. Each keyline is described with a `KeyLine`
            %   structure with the following fields:
            %   * __angle__ orientation of the line.
            %   * **class_id** object ID, that can be used to cluster keylines
            %     by the line they represent.
            %   * __octave__ octave (pyramid layer), from which the keyline
            %     has been extracted.
            %   * __pt__ coordinates of the middlepoint `[x,y]`.
            %   * __response__ the response, by which the strongest keylines
            %     have been selected. It's represented by the ratio between
            %     line's length and maximum between image's width and height.
            %   * __size__ minimum area containing line.
            %   * __startPoint__ the start point of the line in the original
            %     image `[x,y]`.
            %   * __endPoint__ the end point of the line in the original image
            %     `[x,y]`.
            %   * __startPointInOctave__ the start point of the line in the
            %     octave it was extracted from `[x,y]`.
            %   * __endPointInOctave__ the end point of the line in the octave
            %     it was extracted from `[x,y]`.
            %   * __lineLength__ the length of line.
            %   * __numOfPixels__ number of pixels covered by the line.
            %
            % ## Options
            % * __Mask__ optional mask matrix to detect only `KeyLines` of
            %   interest. It must be a logical or 8-bit integer matrix with
            %   non-zero values in the region of interest. In the second
            %   variant, it is a cell-array of masks for each input image,
            %   `masks{i}` is a mask for `imgs{i}`. Not set by default.
            %
            % `KeyLine` is a struct to represent a line.
            %
            % As aformentioned, it is been necessary to design a class that
            % fully stores the information needed to characterize completely a
            % line and plot it on image it was extracted from, when required.
            %
            % `KeyLine` class has been created for such goal; it is mainly
            % inspired to Feature2d's `KeyPoint` class, since `KeyLine` shares
            % some of `KeyPoint`'s fields, even if a part of them assumes a
            % different meaning, when speaking about lines. In particular:
            %
            % - the `class_id` field is used to gather lines extracted from
            %   different octaves which refer to same line inside original
            %   image (such lines and the one they represent in original image
            %   share the same `class_id` value)
            % - the `angle` field represents line's slope with respect to
            %   (positive) X axis
            % - the `pt` field represents line's midpoint
            % - the `response` field is computed as the ratio between the
            %   line's length and maximum between image's width and height
            % - the `size` field is the area of the smallest rectangle
            %   containing line
            %
            % Apart from fields inspired to `KeyPoint` class, `KeyLines`
            % stores information about extremes of line in original image and
            % in octave it was extracted from, about line's length and number
            % of pixels it covers.
            %
            % See also: cv.BinaryDescriptor.compute,
            %  cv.BinaryDescriptor.detectAndCompute
            %
            keylines = BinaryDescriptor_(this.id, 'detect', img, varargin{:});
        end

        function [descriptors, keylines] = compute(this, img, keylines, varargin)
            %COMPUTE  Requires descriptors computation
            %
            %     [descriptors, keylines] = obj.compute(img, keylines)
            %     [descriptors, keylines] = obj.compute(imgs, keylines)
            %
            % ## Input
            % * __img__ Input image (first variant), 8-bit grayscale.
            % * __imgs__ Image set (second variant), cell array of images.
            % * __keylines__ Input collection of keylines containing lines for
            %   which descriptors must be computed. In the first variant, this
            %   is a struct-array of detected lines. In the second variant, it
            %   is a cell-array, where `keylines{i}` is a set of lines
            %   detected in `imgs{i}`.
            %
            % ## Output
            % * __descriptors__ Computed descriptors. In the second variant of
            %   the method `descriptors{i}` are descriptors computed for a
            %   `keylines{i}`. Row `j` in `descriptors` (or `descriptors{i}`)
            %   is the descriptor for `j`-th keypoint.
            % * __keylines__ Optional output with possibly updated keylines.
            %
            % ## Options
            % * __ReturnFloatDescr__ flag (when set to true, original
            %   non-binary descriptors are returned). default false
            %
            % See also: cv.BinaryDescriptor.detect,
            %  cv.BinaryDescriptor.detectAndCompute
            %
            [descriptors, keylines] = BinaryDescriptor_(this.id, 'compute', img, keylines, varargin{:});
        end

        function [keylines, descriptors] = detectAndCompute(this, img, varargin)
            %DETECTANDCOMPUTE  Define operator to perform detection of KeyLines and computation of descriptors in a row
            %
            %     [keylines, descriptors] = obj.detectAndCompute(img)
            %     [...] = obj.detectAndCompute(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __img__ Input image, 8-bit grayscale.
            %
            % ## Output
            % * __keylines__ Extracted lines.
            % * __descriptors__ Matrix that will store final descriptors.
            %
            % ## Options
            % * __Mask__ Optional mask matrix to select which lines in
            %   `keylines` must be accepted among the ones extracted (used
            %   when `Keylines` option is not empty). Not set by default.
            % * __Keypoints__ Structure array that contains input lines (when
            %   filled, the detection part will be skipped and input lines
            %   will be passed as input to the algorithm computing
            %   descriptors. So if set, detection phase will be skipped and
            %   only computation of descriptors will be executed, using the
            %   lines provided. Not set by default.
            % * __ReturnFloatDescr__ Flag (when set to true, original
            %   non-binary descriptors are returned). default false
            %
            % See also: cv.BinaryDescriptor.detect, cv.BinaryDescriptor.compute
            %
            [keylines, descriptors] = BinaryDescriptor_(this.id, 'detectAndCompute', img, varargin{:});
        end
    end

    %% Getters/Setters
    methods
        function value = get.NumOfOctaves(this)
            value = BinaryDescriptor_(this.id, 'get', 'NumOfOctaves');
        end
        function set.NumOfOctaves(this, value)
            BinaryDescriptor_(this.id, 'set', 'NumOfOctaves', value);
        end

        function value = get.ReductionRatio(this)
            value = BinaryDescriptor_(this.id, 'get', 'ReductionRatio');
        end
        function set.ReductionRatio(this, value)
            BinaryDescriptor_(this.id, 'set', 'ReductionRatio', value);
        end

        function value = get.WidthOfBand(this)
            value = BinaryDescriptor_(this.id, 'get', 'WidthOfBand');
        end
        function set.WidthOfBand(this, value)
            BinaryDescriptor_(this.id, 'set', 'WidthOfBand', value);
        end
    end

end
