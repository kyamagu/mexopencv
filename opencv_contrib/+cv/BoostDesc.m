classdef BoostDesc < handle
    %BOOSTDESC  Class implementing BoostDesc (Learning Image Descriptors with Boosting)
    %
    % As described in [Trzcinski13a] and [Trzcinski13b].
    %
    % ## References
    % [Trzcinski13a]:
    % > V. Lepetit T. Trzcinski, M. Christoudias and P. Fua.
    % > "Boosting Binary Keypoint Descriptors". In Computer Vision and
    % > Pattern Recognition, 2013.
    %
    % [Trzcinski13b]:
    % > M. Christoudias T. Trzcinski and V. Lepetit.
    % > "Learning Image Descriptors with Boosting". Submitted to IEEE
    % > Transactions on Pattern Analysis and Machine Intelligence (PAMI), 2013.
    %
    % See also: cv.BoostDesc.BoostDesc, cv.DescriptorExtractor
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % Sample patterns using keypoints orientation.
        UseScaleOrientation
        % Adjust the sampling window of detected keypoints.
        ScaleFactor
    end

    methods
        function this = BoostDesc(varargin)
            %BOOSTDESC  Constructor
            %
            %     obj = cv.BoostDesc()
            %     obj = cv.BoostDesc('OptionName',optionValue, ...)
            %
            % ## Options
            % * __Desc__ Type of descriptor to use, 'BinBoost256' is default
            %   (256 bit long dimension). Available types are:
            %   * __BGM__
            %   * __BGMHard__
            %   * __BGMBilinear__
            %   * __LBGM__
            %   * __BinBoost64__
            %   * __BinBoost128__
            %   * __BinBoost256__
            % * __UseScaleOrientation__ Sample patterns using keypoints
            %   orientation. default true
            % * __ScaleFactor__ Adjust the sampling window of detected
            %   keypoints.
            %   * 6.25 is default and fits for cv.KAZE, cv.SURF detected
            %     keypoints window ratio
            %   * 6.75 should be the scale for cv.SIFT detected keypoints
            %     window ratio
            %   * 5.00 should be the scale for cv.AKAZE, cv.MSDDetector,
            %     cv.AgastFeatureDetector, cv.FastFeatureDetector, cv.BRISK
            %     keypoints window ratio
            %   * 0.75 should be the scale for cv.ORB keypoints ratio
            %   * 1.50 was the default in original implementation
            %
            % ### Note
            % `BGM` is the base descriptor where each binary dimension is
            % computed as the output of a single weak learner. `BGMHard` and
            % `BGMBilinear` refer to same `BGM` but use different type of
            % gradient binning. In the `BGMHard` that use `ASSIGN_HARD`
            % binning type the gradient is assigned to the nearest orientation
            % bin. In the `BGMBilinear` that use `ASSIGN_BILINEAR` binning
            % type the gradient is assigned to the two neighbouring bins. In
            % the `BGM` and all other modes that use `ASSIGN_SOFT` binning
            % type the gradient is assigned to 8 nearest bins according to the
            % cosine value between the gradient angle and the bin center.
            % `LBGM` (alias `FP-Boost`) is the floating point extension where
            % each dimension is computed as a linear combination of the weak
            % learner responses. `BinBoost` and subvariants are the binary
            % extensions of `LBGM` where each bit is computed as a thresholded
            % linear combination of a set of weak learners.
            %
            % See also: cv.BoostDesc.compute
            %
            this.id = BoostDesc_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.BoostDesc
            %
            if isempty(this.id), return; end
            BoostDesc_(this.id, 'delete');
        end

        function typename = typeid(this)
            %TYPEID  Name of the C++ type (RTTI)
            %
            %     typename = obj.typeid()
            %
            % ## Output
            % * __typename__ Name of C++ type
            %
            typename = BoostDesc_(this.id, 'typeid');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.BoostDesc.empty, cv.BoostDesc.load
            %
            BoostDesc_(this.id, 'clear');
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
            % See also: cv.BoostDesc.clear
            %
            b = BoostDesc_(this.id, 'empty');
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
            % See also: cv.BoostDesc.load
            %
            BoostDesc_(this.id, 'save', filename);
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
            % See also: cv.BoostDesc.save
            %
            BoostDesc_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.BoostDesc.save, cv.BoostDesc.load
            %
            name = BoostDesc_(this.id, 'getDefaultName');
        end
    end

    %% Features2D: DescriptorExtractor
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
            % See also: cv.BoostDesc.compute, cv.DescriptorMatcher
            %
            ntype = BoostDesc_(this.id, 'defaultNorm');
        end

        function sz = descriptorSize(this)
            %DESCRIPTORSIZE  Returns the descriptor size in bytes
            %
            %     sz = obj.descriptorSize()
            %
            % ## Output
            % * __sz__ Descriptor size.
            %
            % See also: cv.BoostDesc.descriptorType, cv.BoostDesc.compute
            %
            sz = BoostDesc_(this.id, 'descriptorSize');
        end

        function dtype = descriptorType(this)
            %DESCRIPTORTYPE  Returns the descriptor type
            %
            %     dtype = obj.descriptorType()
            %
            % ## Output
            % * __dtype__ Descriptor type, one of numeric MATLAB class names.
            %
            % See also: cv.BoostDesc.descriptorSize, cv.BoostDesc.compute
            %
            dtype = BoostDesc_(this.id, 'descriptorType');
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
            %   new keypoints can be added, for example: cv.SIFT duplicates
            %   keypoint with several dominant orientations (for each
            %   orientation). In the first variant, this is a struct-array of
            %   detected keypoints. In the second variant, it is a cell-array,
            %   where `keypoints{i}` is a set of keypoints detected in
            %   `imgs{i}` (a struct-array like before).
            %
            % ## Output
            % * __descriptors__ Computed descriptors. In the second variant of
            %   the method `descriptors{i}` are descriptors computed for a
            %   `keypoints{i}`. Row `j` in `descriptors` (or `descriptors{i}`)
            %   is the descriptor for `j`-th keypoint.
            % * __keypoints__ Optional output with possibly updated keypoints.
            %
            % See also: cv.BoostDesc.BoostDesc
            %
            [descriptors, keypoints] = BoostDesc_(this.id, 'compute', img, keypoints);
        end
    end

    %% Getters/Setters
    methods
        function value = get.UseScaleOrientation(this)
            value = BoostDesc_(this.id, 'get', 'UseScaleOrientation');
        end
        function set.UseScaleOrientation(this, value)
            BoostDesc_(this.id, 'set', 'UseScaleOrientation', value);
        end

        function value = get.ScaleFactor(this)
            value = BoostDesc_(this.id, 'get', 'ScaleFactor');
        end
        function set.ScaleFactor(this, value)
            BoostDesc_(this.id, 'set', 'ScaleFactor', value);
        end
    end

end
