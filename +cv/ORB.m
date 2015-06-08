classdef ORB < handle
    %ORB  Class implementing the ORB (oriented BRIEF) keypoint detector and descriptor extractor.
    %
    % As described in [RRKB11]. The algorithm uses FAST in pyramids to detect
    % stable keypoints, selects the strongest features using FAST or Harris
    % response, finds their orientation using first-order moments and computes
    % the descriptors using BRIEF (where the coordinates of random point pairs
    % (or k-tuples) are rotated according to the measured orientation).
    %
    % ## References:
    % [RRKB11]:
    % > Ethan Rublee, Vincent Rabaud, Kurt Konolige, and Gary Bradski.
    % > "ORB: An efficient alternative to SIFT or SURF".
    % > In IEEE International Conference on Computer Vision (ICCV) 2011,
    % > pages 2564-2571. IEEE, 2011.
    %
    % See also: cv.FeatureDetector, cv.DescriptorExtractor
    %

    properties (SetAccess = private)
        id    % Object ID
    end

    properties (Dependent)
        MaxFeatures
        ScaleFactor
        NLevels
        EdgeThreshold
        FirstLevel
        WTA_K
        ScoreType
        PatchSize
        FastThreshold
    end

    methods
        function this = ORB(varargin)
            %ORB  The ORB constructor.
            %
            %    obj = cv.ORB()
            %    obj = cv.ORB(..., 'OptionName',optionValue, ...)
            %
            % ## Options
            % * __NFeatures__ The maximum number of features to retain.
            %       default 500
            % * __ScaleFactor__ Pyramid decimation ratio, greater than 1.
            %       `ScaleFactor=2` means the classical pyramid, where each
            %       next level has 4x less pixels than the previous, but such
            %       a big scale factor will degrade feature matching scores
            %       dramatically. On the other hand, too close to 1 scale
            %       factor will mean that to cover certain scale range you
            %       will need more pyramid levels and so the speed will suffer.
            %       default 1.2
            % * __NLevels__ The number of pyramid levels. The smallest level
            %       will have linear size equal to
            %       `numel(input_image)/(ScaleFactor ^ NLevels)`. default 8
            % * __EdgeThreshold__ This is size of the border where the features
            %       are not detected. It should roughly match the `PatchSize`
            %       parameter. default 31
            % * __FirstLevel__ It should be 0 in the current implementation.
            %       default 0
            % * **WTA_K** The number of points that produce each element of the
            %       oriented BRIEF descriptor. The default value 2 means the
            %       BRIEF where we take a random point pair and compare their
            %       brightnesses, so we get 0/1 response. Other possible values
            %       are 3 and 4. For example, 3 means that we take 3 random
            %       points (of course, those point coordinates are random, but
            %       they are generated from the pre-defined seed, so each
            %       element of BRIEF descriptor is computed deterministically
            %       from the pixel rectangle), find point of maximum brightness
            %       and output index of the winner (0, 1 or 2). Such output
            %       will occupy 2 bits, and therefore it will need a special
            %       variant of Hamming distance, denoted as `Hamming2` (2 bits
            %       per bin). When `WTA_K=4`, we take 4 random points to
            %       compute each bin (that will also occupy 2 bits with
            %       possible values 0, 1, 2 or 3). default 2
            % * __ScoreType__ The default value `Harris` means that Harris
            %       algorithm is used to rank features (the score is written to
            %       `keypoint.response` and is used to retain best `NFeatures`
            %       features); `FAST` is alternative value of the parameter
            %       that produces slightly less stable keypoints, but it is a
            %       little faster to compute. default 'Harris'
            % * __PatchSize__ size of the patch used by the oriented BRIEF
            %       descriptor. Of course, on smaller pyramid layers the
            %       perceived image area covered by a feature will be larger.
            %       default 31
            % * __FastThreshold__ default 20
            %
            % See also: cv.ORB.detectAndCompute
            %
            this.id = ORB_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also: cv.ORB
            %
            ORB_(this.id, 'delete');
        end

        function typename = typeid(this)
            %TYPEID  Name of the C++ type (RTTI)
            %
            typename = ORB_(this.id, 'typeid');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state.
            %
            %    obj.clear()
            %
            % See also: cv.ORB.empty
            %
            ORB_(this.id, 'clear');
        end

        function name = getDefaultName(this)
            %GETDEFAULTNAME  Returns the algorithm string identifier.
            %
            %    name = obj.getDefaultName()
            %
            % ## Output
            % * __name__ This string is used as top level XML/YML node tag
            %       when the object is saved to a file or string.
            %
            % See also: cv.ORB.save, cv.ORB.load
            %
            name = ORB_(this.id, 'getDefaultName');
        end

        function save(this, filename)
            %SAVE  Saves the algorithm to a file.
            %
            %    obj.save(filename)
            %
            % ## Input
            % * __filename__ Name of the file to save to.
            %
            % This method stores the algorithm parameters in a file storage.
            %
            % See also: cv.ORB.load
            %
            ORB_(this.id, 'save', filename);
        end

        function load(this, fname_or_str, varargin)
            %LOAD  Loads algorithm from a file or a string.
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
            % This method reads algorithm parameters from a file storage.
            % The previous model state is discarded.
            %
            % See also: cv.ORB.save
            %
            ORB_(this.id, 'load', fname_or_str, varargin{:});
        end
    end

    %% Features2D
    methods
        function b = empty(this)
            %EMPTY  Checks if detector object is empty.
            %
            %    b = obj.empty()
            %
            % ## Output
            % * __b__ Returns true if the detector object is empty
            %       (e.g. in the very beginning or after unsuccessful read).
            %
            % See also: cv.ORB.clear
            %
            b = ORB_(this.id, 'empty');
        end

        function n = defaultNorm(this)
            %DEFAULTNORM  Returns the default norm type
            %
            %    norm = obj.defaultNorm()
            %
            % ## Output
            % * __norm__ Norm type. One of `cv::NormTypes`:
            %       * __Inf__
            %       * __L1__
            %       * __L2__
            %       * __L2Sqr__
            %       * __Hamming__
            %       * __Hamming2__
            %
            n = ORB_(this.id, 'defaultNorm');
        end

        function sz = descriptorSize(this)
            %DESCRIPTORSIZE  Returns the descriptor size in bytes
            %
            %    sz = obj.descriptorSize()
            %
            % ## Output
            % * __sz__ Descriptor size
            %
            sz = ORB_(this.id, 'descriptorSize');
        end

        function dtype = descriptorType(this)
            %DESCRIPTORTYPE  Returns the descriptor type
            %
            %    dtype = obj.descriptorType()
            %
            % ## Output
            % * __dtype__ Descriptor type, one of numeric MATLAB class names.
            %
            dtype = ORB_(this.id, 'descriptorType');
        end

        function keypoints = detect(this, image, varargin)
            %DETECT  Detects keypoints in an image or image set.
            %
            %    keypoints = obj.detect(image)
            %    keypoints = obj.detect(images)
            %    [...] = obj.detect(..., 'OptionName',optionValue, ...)
            %
            % ## Inputs
            % * __image__ Image.
            % * __images__ Image set.
            %
            % ## Outputs
            % * __keypoints__ The detected keypoints.
            %       A 1-by-N structure array with the following fields:
            %       * __pt__ coordinates of the keypoint `[x,y]`
            %       * __size__ diameter of the meaningful keypoint neighborhood
            %       * __angle__ computed orientation of the keypoint (-1 if not
            %             applicable). Its possible values are in a range
            %             [0,360) degrees. It is measured relative to image
            %             coordinate system (y-axis is directed downward), i.e
            %             in clockwise.
            %       * __response__ the response by which the most strong
            %             keypoints have been selected. Can be used for further
            %             sorting or subsampling.
            %       * __octave__ octave (pyramid layer) from which the keypoint
            %             has been extracted.
            %       * **class_id** object id that can be used to clustered
            %             keypoints by an object they belong to.
            %
            %       In the second variant of the method `keypoints(i)` is a
            %       set of keypoints detected in `images{i}`.
            %
            % ## Options
            % * __Mask__ In the first variant, a mask specifying where to look
            %       for keypoints (optional). It must be a logical or 8-bit
            %       integer matrix with non-zero values in the region of
            %       interest.
            %       In the second variant, a cell-array of masks for each input
            %       image specifying where to look for keypoints (optional).
            %       `masks{i}` is a mask for `images{i}`.
            %       default none
            %
            % See also: cv.ORB.compute, cv.ORB.detectAndCompute
            %
            keypoints = ORB_(this.id, 'detect', image, varargin{:});
        end

        function [descriptors, keypoints] = compute(this, image, keypoints)
            %COMPUTE  Computes the descriptors for a set of keypoints detected in an image or image set.
            %
            %    [descriptors, keypoints] = obj.compute(image, keypoints)
            %    [descriptors, keypoints] = obj.compute(images, keypoints)
            %
            % ## Inputs
            % * __image__ Image.
            % * __images__ Image set.
            % * __keypoints__ Input collection of keypoints. Keypoints for
            %       which a descriptor cannot be computed are removed.
            %       Sometimes new keypoints can be added, for example: cv.SIFT
            %       duplicates keypoint with several dominant orientations
            %       (for each orientation).
            %
            % ## Outputs
            % * __descriptors__ Computed descriptors. In the second variant of
            %       the method `descriptors{i}` are descriptors computed for a
            %       `keypoints(i)`. Row `j` in `descriptors` (or
            %       `descriptors{i}`) is the descriptor for `j`-th keypoint.
            % * __keypoints__ Optional output with possibly updated keypoints.
            %
            % See also: cv.ORB.detect, cv.ORB.detectAndCompute
            %
            [descriptors, keypoints] = ORB_(this.id, 'compute', image, keypoints);
        end

        function [keypoints, descriptors] = detectAndCompute(this, image, varargin)
            %DETECTANDCOMPUTE  Finds keypoints in an image and computes their descriptors
            %
            %    [keypoints, descriptors] = obj.detectAndCompute(image)
            %    [...] = obj.detectAndCompute(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __image__ Image, input 8-bit grayscale image.
            %
            % ## Output
            % * __keypoints__ The output vector of detected keypoints.
            % * __descriptors__ Computed descriptors. The output concatenated
            %       vectors of descriptors. Each descriptor is a 32-element
            %       vector, as returned by `cv.ORB.descriptorSize()`. So the
            %       total size of descriptors will be
            %       `numel(keypoints)*cv.ORB.descriptorSize()`, i.e a matrix
            %       of size `N-by-32` of class `uint8`, one row per keypoint.
            %
            % ## Options
            % * __Mask__ optional operation mask specifying where to look for
            %       keypoints. default none
            % * __Keypoints__ If passed, then the method will use the provided
            %       vector of keypoints instead of detecting them.
            %
            % See also: cv.ORB.detect, cv.ORB.compute
            %
            [keypoints, descriptors] = ORB_(this.id, 'detectAndCompute', image, varargin{:});
        end
    end

    %% Getters/Setters
    methods
        function value = get.MaxFeatures(this)
            value = ORB_(this.id, 'get', 'MaxFeatures');
        end
        function set.MaxFeatures(this, value)
            ORB_(this.id, 'set', 'MaxFeatures', value);
        end

        function value = get.ScaleFactor(this)
            value = ORB_(this.id, 'get', 'ScaleFactor');
        end
        function set.ScaleFactor(this, value)
            ORB_(this.id, 'set', 'ScaleFactor', value);
        end

        function value = get.NLevels(this)
            value = ORB_(this.id, 'get', 'NLevels');
        end
        function set.NLevels(this, value)
            ORB_(this.id, 'set', 'NLevels', value);
        end

        function value = get.EdgeThreshold(this)
            value = ORB_(this.id, 'get', 'EdgeThreshold');
        end
        function set.EdgeThreshold(this, value)
            ORB_(this.id, 'set', 'EdgeThreshold', value);
        end

        function value = get.FirstLevel(this)
            value = ORB_(this.id, 'get', 'FirstLevel');
        end
        function set.FirstLevel(this, value)
            ORB_(this.id, 'set', 'FirstLevel', value);
        end

        function value = get.WTA_K(this)
            value = ORB_(this.id, 'get', 'WTA_K');
        end
        function set.WTA_K(this, value)
            ORB_(this.id, 'set', 'WTA_K', value);
        end

        function value = get.ScoreType(this)
            value = ORB_(this.id, 'get', 'ScoreType');
        end
        function set.ScoreType(this, value)
            ORB_(this.id, 'set', 'ScoreType', value);
        end

        function value = get.PatchSize(this)
            value = ORB_(this.id, 'get', 'PatchSize');
        end
        function set.PatchSize(this, value)
            ORB_(this.id, 'set', 'PatchSize', value);
        end

        function value = get.FastThreshold(this)
            value = ORB_(this.id, 'get', 'FastThreshold');
        end
        function set.FastThreshold(this, value)
            ORB_(this.id, 'set', 'FastThreshold', value);
        end
    end

end
