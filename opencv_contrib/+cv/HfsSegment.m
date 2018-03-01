classdef HfsSegment < handle
    %HFSSEGMENT  Hierarchical Feature Selection for Efficient Image Segmentation
    %
    % This class contains an efficient algorithm to segment an image. The
    % implementation is based on the paper [cheng2016hfs],
    % [Project page](http://mmcheng.net/en/hfs/),
    % [Code](https://github.com/yun-liu/hfs)
    %
    % The HFS algorithm is executed in 3 stages:
    %
    % 1. In the first stage, the algorithm uses SLIC (simple linear iterative
    %    clustering) algorithm to obtain the superpixel of the input image.
    %
    % 2. In the second stage, the algorithm views each superpixel as a node in
    %    the graph. It will calculate a feature vector for each edge of the
    %    graph. It then calculates a weight for each edge based on the feature
    %    vector and trained SVM parameters. After obtaining weight for each
    %    edge, it will exploit EGB (Efficient Graph-based Image Segmentation)
    %    algorithm to merge some nodes in the graph thus obtaining a coarser
    %    segmentation. After these operations, a post process will be executed
    %    to merge regions that are smaller than a specific number of pixels
    %    into their nearby region.
    %
    % 3. In the third stage, the algorithm exploits the similar mechanism to
    %    further merge the small regions obtained in the second stage into
    %    even coarser segmentation.
    %
    % After these three stages, we can obtain the final segmentation of the
    % image. For further details about the algorithm, please refer to the
    % original paper [cheng2016hfs].
    %
    % ## Example
    %
    %     % read an image
    %     img = imread('image.jpg')
    %
    %     % create engine
    %     seg = cv.HfsSegment(size(img,1), size(img,2));
    %
    %     % perform segmentation
    %     % (res is an RGB image by default,
    %     % change the second parameter to "false" to get a matrix of indices)
    %     res = seg.performSegment(img, 'Draw',true);
    %
    % ## References
    % [cheng2016hfs]:
    % > M. Cheng, Y. Liu, Q. Hou, J. Bian, P. Torr, S. Hu, Z. Tu.
    % > "HFS: Hierarchical Feature Selection for Efficient Image Segmentation".
    % > European Conference on Computer Vision (ECCV) 2016, pp 867-882.
    % > [PDF](http://mftp.mmcheng.net/Papers/HFS.pdf)
    %
    % See also: cv.HfsSegment.HfsSegment
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % This parameter is used in the second stage mentioned above. It is a
        % constant used to threshold weights of the edge when merging adjacent
        % nodes when applying EGB algorithm. The segmentation result tends to
        % have more regions remained if this value is large and vice versa.
        SegEgbThresholdI
        % This parameter is used in the second stage mentioned above. After
        % the EGB segmentation, regions that have fewer pixels then this
        % parameter will be merged into its adjacent region.
        MinRegionSizeI
        % This parameter is used in the third stage mentioned above. It serves
        % the same purpose as `SegEgbThresholdI`. The segmentation result
        % tends to have more regions remained if this value is large and vice
        % versa.
        SegEgbThresholdII
        % This parameter is used in the third stage mentioned above. It serves
        % the same purpose as `MinRegionSizeI`.
        MinRegionSizeII
        % This parameter is used in the first stage mentioned above (the SLIC
        % stage). It describes how important is the role of position when
        % calculating the distance between each pixel and its center. The
        % exact formula to calculate the distance is
        % `colorDistance + spatialWeight * spatialDistance`. The segmentation
        % result tends to have more local consistency if this value is larger.
        SpatialWeight
        % This parameter is used in the first stage mentioned above (the SLIC
        % stage). It describes the size of each superpixel when initializing
        % SLIC. Every superpixel approximately has
        % `slicSpixelSize * slicSpixelSize` pixels in the begining.
        SlicSpixelSize
        % This parameter is used in the first stage. It describes how many
        % iteration to perform when executing SLIC.
        NumSlicIter
    end

    %% HfsSegment
    methods
        function this = HfsSegment(height, width, varargin)
            %HFSSEGMENT  Creates an HFS object
            %
            %     obj = cv.HfsSegment(height, width)
            %     obj = cv.HfsSegment(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __height__ the height of the input image.
            % * __width__ the width of the input image.
            %
            % ## Options
            % * __SegEgbThresholdI__ parameter cv.HfsSegment.SegEgbThresholdI,
            %   default 0.08
            % * __MinRegionSizeI__ parameter cv.HfsSegment.MinRegionSizeI,
            %   default 100
            % * __SegEgbThresholdII__ parameter cv.HfsSegment.SegEgbThresholdII,
            %   default 0.28
            % * __MinRegionSizeII__ parameter cv.HfsSegment.MinRegionSizeII,
            %   default 200
            % * __SpatialWeight__ parameter cv.HfsSegment.SpatialWeight,
            %   default 0.6
            % * __SlicSpixelSize__ parameter cv.HfsSegment.SlicSpixelSize,
            %   default 8
            % * __NumSlicIter__ parameter cv.HfsSegment.NumSlicIter,
            %   default 5
            %
            % See also: cv.HfsSegment.performSegment
            %
            this.id = HfsSegment_(0, 'new', height, width, varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.HfsSegment
            %
            if isempty(this.id), return; end
            HfsSegment_(this.id, 'delete');
        end

        function dst = performSegment(this, src, varargin)
            %PERFORMSEGMENT  Do segmentation
            %
            %     dst = obj.performSegment(src)
            %     dst = obj.performSegment(src, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __src__ the input image.
            %
            % ## Options
            % * __Draw__ whether to draw the image in the returned array. If
            %   this parameter is false, then the content of the output is a
            %   matrix of indices, describing the region each pixel belongs
            %   to, and its data type is `uint16`. If this parameter is true,
            %   then the returned array is a segmented picture, and color of
            %   each region is the average color of all pixels in that region,
            %   and it's data type is the same as the input image.
            %   default true
            % * __Backend__ back end to use:
            %   * __CPU__ default.
            %   * __GPU__ (requires CUDA).
            %
            % ## Output
            % __dst__ output, depends on `Draw` option.
            %
            % See also: cv.HfsSegment.HfsSegment
            %
            dst = HfsSegment_(this.id, 'performSegment', src, varargin{:});
        end
    end

    %% Algorithm
    methods (Hidden)
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.HfsSegment.empty, cv.HfsSegment.load
            %
            HfsSegment_(this.id, 'clear');
        end

        function b = empty(this)
            %EMPTY  Checks if algorithm object is empty
            %
            %     b = obj.empty()
            %
            % ## Output
            % * __b__ Returns true if the algorithm object is empty
            %   (e.g. in the very beginning or after unsuccessful read).
            %
            % See also: cv.HfsSegment.clear, cv.HfsSegment.load
            %
            b = HfsSegment_(this.id, 'empty');
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
            % See also: cv.HfsSegment.load
            %
            HfsSegment_(this.id, 'save', filename);
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
            % See also: cv.HfsSegment.save
            %
            HfsSegment_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.HfsSegment.save, cv.HfsSegment.load
            %
            name = HfsSegment_(this.id, 'getDefaultName');
        end
    end

    %% Getters/Setters
    methods
        function value = get.SegEgbThresholdI(this)
            value = HfsSegment_(this.id, 'get', 'SegEgbThresholdI');
        end
        function set.SegEgbThresholdI(this, value)
            HfsSegment_(this.id, 'set', 'SegEgbThresholdI', value);
        end

        function value = get.MinRegionSizeI(this)
            value = HfsSegment_(this.id, 'get', 'MinRegionSizeI');
        end
        function set.MinRegionSizeI(this, value)
            HfsSegment_(this.id, 'set', 'MinRegionSizeI', value);
        end

        function value = get.SegEgbThresholdII(this)
            value = HfsSegment_(this.id, 'get', 'SegEgbThresholdII');
        end
        function set.SegEgbThresholdII(this, value)
            HfsSegment_(this.id, 'set', 'SegEgbThresholdII', value);
        end

        function value = get.MinRegionSizeII(this)
            value = HfsSegment_(this.id, 'get', 'MinRegionSizeII');
        end
        function set.MinRegionSizeII(this, value)
            HfsSegment_(this.id, 'set', 'MinRegionSizeII', value);
        end

        function value = get.SpatialWeight(this)
            value = HfsSegment_(this.id, 'get', 'SpatialWeight');
        end
        function set.SpatialWeight(this, value)
            HfsSegment_(this.id, 'set', 'SpatialWeight', value);
        end

        function value = get.SlicSpixelSize(this)
            value = HfsSegment_(this.id, 'get', 'SlicSpixelSize');
        end
        function set.SlicSpixelSize(this, value)
            HfsSegment_(this.id, 'set', 'SlicSpixelSize', value);
        end

        function value = get.NumSlicIter(this)
            value = HfsSegment_(this.id, 'get', 'NumSlicIter');
        end
        function set.NumSlicIter(this, value)
            HfsSegment_(this.id, 'set', 'NumSlicIter', value);
        end
    end

end
