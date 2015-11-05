classdef MSER < handle
    %MSER  Maximally Stable Extremal Region extractor
    %
    % The class encapsulates all the parameters of the MSER extraction
    % algorithm
    % (see http://en.wikipedia.org/wiki/Maximally_stable_extremal_regions).
    % Also see http://code.opencv.org/projects/opencv/wiki/MSER for useful
    % comments and parameters description.
    %
    % * there are two different implementation of MSER, one for gray image,
    %   one for color image
    % * the gray image algorithm is taken from [Nister08]; the paper claims to
    %   be faster than union-find method.
    % * the color image algorithm is taken from [Forssen07]; it should be much
    %   slower than gray image method (3~4 times).
    % * though the name is *contours*, the result actually is a list of point
    %   set.
    %
    % ## References
    % [Nister08]:
    % > David Nister and Henrik Stewenius. "Linear Time Maximally Stable
    % > Extremal Regions". In Proceedings of the 10th ECCV '08, pp 183-196.
    % > doi: 10.1007/978-3-540-88688-4_14
    %
    % [Forssen07]:
    % > Per-Erik Forssen. "Maximally Stable Colour Regions for Recognition and
    % > Matching". in CVPR '07. IEEE Conference on , pp.1-8, 17-22 June 2007
    % > doi: 10.1109/CVPR.2007.383120
    % > http://www.cs.ubc.ca/~perfo/papers/forssen_cvpr07.pdf
    %
    % See also: cv.FeatureDetector, detectMSERFeatures
    %

    properties (SetAccess = private)
        id    % Object ID
    end

    properties (Dependent)
        % delta
        %
        % In the code, it compares `(size_{i}-size_{i-delta})/size_{i-delta}`.
        % default 5
        Delta
        % prune the area which smaller than MinArea.
        %
        % default 60
        MinArea
        % prune the area which bigger than MaxArea.
        %
        % default 14400
        MaxArea
        % default false
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
            % See also: cv.MSER.detectRegions, cv.MSER.detect
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
            %    typename = obj.typeid()
            %
            % ## Output
            % * __typename__ Name of C++ type
            %
            typename = MSER_(this.id, 'typeid');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %    obj.clear()
            %
            % See also: cv.MSER.empty, cv.MSER.load
            %
            MSER_(this.id, 'clear');
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
            % See also: cv.MSER.clear, cv.MSER.load
            %
            b = MSER_(this.id, 'empty');
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
            % See also: cv.MSER.load
            %
            MSER_(this.id, 'save', filename);
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
            % See also: cv.MSER.save
            %
            MSER_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.MSER.save, cv.MSER.load
            %
            name = MSER_(this.id, 'getDefaultName');
        end
    end

    %% Features2D: FeatureDetector
    methods
        function keypoints = detect(this, img, varargin)
            %DETECT  Detects keypoints in an image or image set.
            %
            %    keypoints = obj.detect(img)
            %    keypoints = obj.detect(imgs)
            %    [...] = obj.detect(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __img__ Image (first variant), 8-bit grayscale/color image.
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
            % See also: cv.MSER.detectRegions
            %
            keypoints = MSER_(this.id, 'detect', img, varargin{:});
        end
    end

    %% MSER
    methods
        function [msers, bboxes] = detectRegions(this, image)
            %DETECTREGIONS  Maximally stable extremal region extractor
            %
            % ## Input
            % * __image__ Input 8-bit grayscale or color image.
            %
            % ## Output
            % * __msers__ The output vector of connected points. Cell-array of
            %       cell-array of 2D points `{{[x,y],[x,y],..}, {[x,y],..}}`.
            % * __bboxes__ Output vector of rectangles. A cell-array of
            %       4-element vectors `{[x,y,width,height], ...}`.
            %
            % Runs the extractor on the specified image; returns the MSERs,
            % each encoded as a contour (see cv.findContours).
            %
            % See also: cv.MSER.detect
            %
            [msers, bboxes] = MSER_(this.id, 'detectRegions', image);
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
