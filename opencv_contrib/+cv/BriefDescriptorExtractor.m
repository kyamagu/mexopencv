classdef BriefDescriptorExtractor < handle
    %BRIEFDESCRIPTOREXTRACTOR  Class for computing BRIEF descriptors.
    %
    % As described in [calon2010].
    %
    % ## References:
    % [calon2010]:
    % > Michael Calonder, Vincent Lepetit, Christoph Strecha, and Pascal Fua.
    % > "Brief: Binary robust independent elementary features".
    % > In Computer Vision-ECCV 2010, pages 778-792. Springer, 2010.
    %
    % See also: cv.BriefDescriptorExtractor.BriefDescriptorExtractor
    %

    properties (SetAccess = private)
        id    % Object ID
    end

    methods
        function this = BriefDescriptorExtractor(varargin)
            %BRIEFDESCRIPTOREXTRACTOR  Constructor
            %
            %    obj = cv.BriefDescriptorExtractor()
            %    obj = cv.BriefDescriptorExtractor(..., 'OptionName',optionValue, ...)
            %
            % ## Options
            % * __Bytes__ legth of the descriptor in bytes, valid values are:
            %       16, 32 (default) or 64.
            % * __UseOrientation__ sample patterns using keypoints orientation,
            %       disabled by default. default false.
            %
            % See also: cv.BriefDescriptorExtractor.compute
            %
            this.id = BriefDescriptorExtractor_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also: cv.BriefDescriptorExtractor
            %
            BriefDescriptorExtractor_(this.id, 'delete');
        end

        function typename = typeid(this)
            %TYPEID  Name of the C++ type (RTTI)
            %
            typename = BriefDescriptorExtractor_(this.id, 'typeid');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state.
            %
            %    obj.clear()
            %
            % See also: cv.BriefDescriptorExtractor.empty
            %
            BriefDescriptorExtractor_(this.id, 'clear');
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
            % See also: cv.BriefDescriptorExtractor.save, cv.BriefDescriptorExtractor.load
            %
            name = BriefDescriptorExtractor_(this.id, 'getDefaultName');
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
            % See also: cv.BriefDescriptorExtractor.load
            %
            BriefDescriptorExtractor_(this.id, 'save', filename);
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
            % See also: cv.BriefDescriptorExtractor.save
            %
            BriefDescriptorExtractor_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.BriefDescriptorExtractor.clear
            %
            b = BriefDescriptorExtractor_(this.id, 'empty');
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
            n = BriefDescriptorExtractor_(this.id, 'defaultNorm');
        end

        function sz = descriptorSize(this)
            %DESCRIPTORSIZE  Returns the descriptor size in bytes
            %
            %    sz = obj.descriptorSize()
            %
            % ## Output
            % * __sz__ Descriptor size
            %
            sz = BriefDescriptorExtractor_(this.id, 'descriptorSize');
        end

        function dtype = descriptorType(this)
            %DESCRIPTORTYPE  Returns the descriptor type
            %
            %    dtype = obj.descriptorType()
            %
            % ## Output
            % * __dtype__ Descriptor type, one of numeric MATLAB class names.
            %
            dtype = BriefDescriptorExtractor_(this.id, 'descriptorType');
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
            % See also: cv.BriefDescriptorExtractor.BriefDescriptorExtractor
            %
            [descriptors, keypoints] = BriefDescriptorExtractor_(this.id, 'compute', image, keypoints);
        end
    end

end
