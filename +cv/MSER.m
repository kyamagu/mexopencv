classdef MSER < handle
    %MSER  Maximally stable extremal region extractor.
    %
    % The class encapsulates all the parameters of the MSER extraction
    % algorithm
    % (see http://en.wikipedia.org/wiki/Maximally_stable_extremal_regions).
    % Also see http://code.opencv.org/projects/opencv/wiki/MSER for useful
    % comments and parameters description.
    %
    % See also: cv.FeatureDetector, cv.DescriptorExtractor
    %

    properties (SetAccess = private)
        id    % Object ID
    end

    properties (Dependent)
        Delta
        MinArea
        MaxArea
        Pass2Only
    end

    methods
        function this = MSER(varargin)
            %MSER  The full constructor
            %
            %    obj = cv.MSER()
            %    obj = cv.MSER(..., 'OptionName',optionValue, ...)
            %
            % ## Options
            % * __Delta__ delta, in the code, it compares
            %       `(size_{i}-size_{i-delta})/size_{i-delta}`. default 5.
            % * __MinArea__ prune the area which smaller than minArea.
            %       default 60.
            % * __MaxArea__ prune the area which bigger than maxArea.
            %       default 14400.
            % * __MaxVariation__ prune the area have simliar size to its
            %       children. default 0.25
            % * __MinDiversity__ trace back to cut off mser with diversity
            %       `< MinDiversity`. default 0.2.
            % * __MaxEvolution__ for color image, the evolution steps.
            %       default 200.
            % * __AreaThreshold__ the area threshold to cause re-initialize.
            %       default 1.01.
            % * __MinMargin__ ignore too small margin. default 0.003.
            % * __EdgeBlurSize__ the aperture size for edge blur. default 5.
            %
            % See also: cv.MSER.detectRegions
            %
            this.id = MSER_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also: cv.MSER
            %
            MSER_(this.id, 'delete');
        end

        function typename = typeid(this)
            %TYPEID  Name of the C++ type (RTTI)
            %
            typename = MSER_(this.id, 'typeid');
        end

        function [msers, bboxes] = detectRegions(this, image)
            %DETECTREGIONS  Maximally stable extremal region extractor
            %
            % ## Input
            % * __image__ Input 8-bit grayscale image.
            %
            % ## Output
            % * __msers__ The output vector of connected points. Cell-array of
            %       cell-array of points `{{[x,y],[x,y],..}, {[x,y],..}}`.
            % * __bboxes__ Output vector of rectangles. A cell-array of
            %       4-element vectors `{[x,y,width,height], ...}`.
            %
            [msers, bboxes] = MSER_(this.id, 'detectRegions', image);
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state.
            %
            %    obj.clear()
            %
            % See also: cv.MSER.empty
            %
            MSER_(this.id, 'clear');
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
            % See also: cv.MSER.save, cv.MSER.load
            %
            name = MSER_(this.id, 'getDefaultName');
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
            % See also: cv.MSER.load
            %
            MSER_(this.id, 'save', filename);
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
            % See also: cv.MSER.save
            %
            MSER_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.MSER.clear
            %
            b = MSER_(this.id, 'empty');
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
            n = MSER_(this.id, 'defaultNorm');
        end

        function sz = descriptorSize(this)
            %DESCRIPTORSIZE  Returns the descriptor size in bytes
            %
            %    sz = obj.descriptorSize()
            %
            % ## Output
            % * __sz__ Descriptor size
            %
            sz = MSER_(this.id, 'descriptorSize');
        end

        function dtype = descriptorType(this)
            %DESCRIPTORTYPE  Returns the descriptor type
            %
            %    dtype = obj.descriptorType()
            %
            % ## Output
            % * __dtype__ Descriptor type, one of numeric MATLAB class names.
            %
            dtype = MSER_(this.id, 'descriptorType');
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
            % See also: cv.MSER.detectRegions
            %
            keypoints = MSER_(this.id, 'detect', image, varargin{:});
        end
    end

    %% Getters/Setters
    methods
        function value = get.Delta(this)
            value = MSER_(this.id, 'get', 'Delta');
        end
        function set.Delta(this, value)
            MSER_(this.id, 'set', 'Delta', value);
        end

        function value = get.MinArea(this)
            value = MSER_(this.id, 'get', 'MinArea');
        end
        function set.MinArea(this, value)
            MSER_(this.id, 'set', 'MinArea', value);
        end

        function value = get.MaxArea(this)
            value = MSER_(this.id, 'get', 'MaxArea');
        end
        function set.MaxArea(this, value)
            MSER_(this.id, 'set', 'MaxArea', value);
        end

        function value = get.Pass2Only(this)
            value = MSER_(this.id, 'get', 'Pass2Only');
        end
        function set.Pass2Only(this, value)
            MSER_(this.id, 'set', 'Pass2Only', value);
        end
    end

end
