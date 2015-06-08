classdef FREAK < handle
    %FREAK  Class implementing the FREAK (Fast Retina Keypoint) keypoint descriptor.
    %
    % As described in [AOV12].
    %
    % The algorithm propose a novel keypoint descriptor inspired by the human
    % visual system and more precisely the retina, coined Fast Retina Key-point
    % (FREAK). A cascade of binary strings is computed by efficiently comparing
    % image intensities over a retinal sampling pattern. FREAKs are in general
    % faster to compute with lower memory load and also more robust than
    % cv.SIFT, cv.SURF or cv.BRISK. They are competitive alternatives to
    % existing keypoints in particular for embedded applications.
    %
    % ## References
    % [AOV12]:
    % > Alexandre Alahi, Raphael Ortiz, and Pierre Vandergheynst.
    % > "Freak: Fast retina keypoint".
    % > In Computer Vision and Pattern Recognition (CVPR), 2012
    % > IEEE Conference on, pages 510-517. IEEE, 2012.
    %
    % See also: cv.FREAK.FREAK
    %

    properties (SetAccess = private)
        id    % Object ID
    end

    methods
        function this = FREAK(varargin)
            %FREAK  Constructor
            %
            %    obj = cv.FREAK()
            %    obj = cv.FREAK(..., 'OptionName',optionValue, ...)
            %
            % ## Options
            % * __PrientationNormalized__ Enable orientation normalization.
            %       default true
            % * __ScaleNormalized__ Enable scale normalization. default true
            % * __PatternScale__ Scaling of the description pattern.
            %       default 22.0
            % * __NOctaves__ Number of octaves covered by the detected
            %       keypoints. default 4
            % * __SelectedPairs__ (Optional) user defined selected pairs
            %       indexes. Not set by default
            %
            % See also: cv.FREAK.compute
            %
            this.id = FREAK_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also: cv.FREAK
            %
            FREAK_(this.id, 'delete');
        end

        function typename = typeid(this)
            %TYPEID  Name of the C++ type (RTTI)
            %
            typename = FREAK_(this.id, 'typeid');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state.
            %
            %    obj.clear()
            %
            % See also: cv.FREAK.empty
            %
            FREAK_(this.id, 'clear');
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
            % See also: cv.FREAK.save, cv.FREAK.load
            %
            name = FREAK_(this.id, 'getDefaultName');
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
            % See also: cv.FREAK.load
            %
            FREAK_(this.id, 'save', filename);
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
            % See also: cv.FREAK.save
            %
            FREAK_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.FREAK.clear
            %
            b = FREAK_(this.id, 'empty');
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
            n = FREAK_(this.id, 'defaultNorm');
        end

        function sz = descriptorSize(this)
            %DESCRIPTORSIZE  Returns the descriptor size in bytes
            %
            %    sz = obj.descriptorSize()
            %
            % ## Output
            % * __sz__ Descriptor size
            %
            sz = FREAK_(this.id, 'descriptorSize');
        end

        function dtype = descriptorType(this)
            %DESCRIPTORTYPE  Returns the descriptor type
            %
            %    dtype = obj.descriptorType()
            %
            % ## Output
            % * __dtype__ Descriptor type, one of numeric MATLAB class names.
            %
            dtype = FREAK_(this.id, 'descriptorType');
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
            % See also: cv.FREAK.FREAK
            %
            [descriptors, keypoints] = FREAK_(this.id, 'compute', image, keypoints);
        end
    end

end
