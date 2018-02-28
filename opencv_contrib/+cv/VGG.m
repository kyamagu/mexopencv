classdef VGG < handle
    %VGG  Class implementing VGG (Oxford Visual Geometry Group) descriptor
    %
    % Trained end to end using "Descriptor Learning Using Convex Optimisation"
    % (DLCO) aparatus described in [Simonyan14].
    %
    % ## References
    % [Simonyan14]:
    % > K. Simonyan, A. Vedaldi, and A. Zisserman.
    % > "Learning local feature descriptors using convex optimisation".
    % > IEEE Transactions on Pattern Analysis and Machine Intelligence, 2014.
    %
    % See also: cv.VGG.VGG, cv.DescriptorExtractor
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % Gaussian kernel value for image blur.
        Sigma
        % Use image sample intensity normalization.
        UseNormalizeImage
        % Sample patterns using keypoints orientation.
        UseScaleOrientation
        % Adjust the sampling window of detected keypoints.
        ScaleFactor
        % Use 8-bit normalized descriptors.
        UseNormalizeDescriptor
    end

    methods
        function this = VGG(varargin)
            %VGG  Constructor
            %
            %     obj = cv.VGG()
            %     obj = cv.VGG('OptionName',optionValue, ...)
            %
            % ## Options
            % * __Desc__ Type of descriptor to use, '120' is default (120
            %   dimensions float). Available types are:
            %   * __120__
            %   * __80__
            %   * __64__
            %   * __48__
            % * __Sigma__ Gaussian kernel value for image blur. default is 1.4
            % * __ImgNormalize__ Use image sample intensity normalization.
            %   default true
            % * __UseScaleOrientation__ Sample patterns using keypoints
            %   orientation. default true
            % * __ScaleFactor__ Adjust the sampling window of detected
            %   keypoints to 64.0 (VGG sampling window).
            %   * 6.25 is default and fits for cv.KAZE, cv.SURF detected
            %     keypoints window ratio
            %   * 6.75 should be the scale for cv.SIFT detected keypoints
            %     window ratio
            %   * 5.00 should be the scale for cv.AKAZE, cv.MSDDetector,
            %     cv.AgastFeatureDetector, cv.FastFeatureDetector, cv.BRISK
            %     keypoints window ratio
            %   * 0.75 should be the scale for cv.ORB keypoints ratio
            % * __DescNormalize__ Clamp descriptors to 255 and convert to
            %   `uint8`. default false
            %
            % See also: cv.VGG.compute
            %
            this.id = VGG_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.VGG
            %
            if isempty(this.id), return; end
            VGG_(this.id, 'delete');
        end

        function typename = typeid(this)
            %TYPEID  Name of the C++ type (RTTI)
            %
            %     typename = obj.typeid()
            %
            % ## Output
            % * __typename__ Name of C++ type
            %
            typename = VGG_(this.id, 'typeid');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.VGG.empty, cv.VGG.load
            %
            VGG_(this.id, 'clear');
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
            % See also: cv.VGG.clear
            %
            b = VGG_(this.id, 'empty');
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
            % See also: cv.VGG.load
            %
            VGG_(this.id, 'save', filename);
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
            % See also: cv.VGG.save
            %
            VGG_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.VGG.save, cv.VGG.load
            %
            name = VGG_(this.id, 'getDefaultName');
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
            % Always `L2` for VGG.
            %
            % See also: cv.VGG.compute, cv.DescriptorMatcher
            %
            ntype = VGG_(this.id, 'defaultNorm');
        end

        function sz = descriptorSize(this)
            %DESCRIPTORSIZE  Returns the descriptor size in bytes
            %
            %     sz = obj.descriptorSize()
            %
            % ## Output
            % * __sz__ Descriptor size.
            %
            % See also: cv.VGG.descriptorType, cv.VGG.compute
            %
            sz = VGG_(this.id, 'descriptorSize');
        end

        function dtype = descriptorType(this)
            %DESCRIPTORTYPE  Returns the descriptor type
            %
            %     dtype = obj.descriptorType()
            %
            % ## Output
            % * __dtype__ Descriptor type, one of numeric MATLAB class names.
            %
            % Always `single` for VGG.
            %
            % See also: cv.VGG.descriptorSize, cv.VGG.compute
            %
            dtype = VGG_(this.id, 'descriptorType');
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
            % See also: cv.VGG.VGG
            %
            [descriptors, keypoints] = VGG_(this.id, 'compute', img, keypoints);
        end
    end

    %% Getters/Setters
    methods
        function value = get.Sigma(this)
            value = VGG_(this.id, 'get', 'Sigma');
        end
        function set.Sigma(this, value)
            VGG_(this.id, 'set', 'Sigma', value);
        end

        function value = get.UseNormalizeImage(this)
            value = VGG_(this.id, 'get', 'UseNormalizeImage');
        end
        function set.UseNormalizeImage(this, value)
            VGG_(this.id, 'set', 'UseNormalizeImage', value);
        end

        function value = get.UseScaleOrientation(this)
            value = VGG_(this.id, 'get', 'UseScaleOrientation');
        end
        function set.UseScaleOrientation(this, value)
            VGG_(this.id, 'set', 'UseScaleOrientation', value);
        end

        function value = get.ScaleFactor(this)
            value = VGG_(this.id, 'get', 'ScaleFactor');
        end
        function set.ScaleFactor(this, value)
            VGG_(this.id, 'set', 'ScaleFactor', value);
        end

        function value = get.UseNormalizeDescriptor(this)
            value = VGG_(this.id, 'get', 'UseNormalizeDescriptor');
        end
        function set.UseNormalizeDescriptor(this, value)
            VGG_(this.id, 'set', 'UseNormalizeDescriptor', value);
        end
    end

end
