classdef SuperpixelLSC < handle
    %SUPERPIXELLSC  Class implementing the LSC (Linear Spectral Clustering) superpixels algorithm
    %
    % As described in [LiCVPR2015LSC].
    %
    % LSC (Linear Spectral Clustering) produces compact and uniform
    % superpixels with low computational costs. Basically, a normalized cuts
    % formulation of the superpixel segmentation is adopted based on a
    % similarity metric that measures the color similarity and space proximity
    % between image pixels. LSC is of linear computational complexity and high
    % memory efficiency and is able to preserve global properties of images.
    %
    % ## References
    % [LiCVPR2015LSC]:
    % > Zhengqin Li and Jiansheng Chen. "Superpixel Segmentation using Linear
    % > Spectral Clustering". IEEE Conference on Computer Vision and Pattern
    % > Recognition (CVPR), June 2015.
    %
    % See also: cv.SuperpixelLSC.SuperpixelLSC, cv.SuperpixelSLIC,
    %  cv.SuperpixelSEEDS, superpixels
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    methods
        function this = SuperpixelLSC(img, varargin)
            %SUPERPIXELLSC  Class implementing the LSC (Linear Spectral Clustering) superpixels
            %
            %     obj = cv.SuperpixelLSC(img)
            %     obj = cv.SuperpixelLSC(img, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __img__ Image to segment.
            %
            % ## Options
            % * __RegionSize__ Chooses an average superpixel size measured in
            %   pixels. default 10
            % * __Ratio__ Chooses the enforcement of superpixel compactness
            %   factor of superpixel. default 0.075
            %
            % The function initializes a SuperpixelLSC object for the input
            % image. It sets the parameters of superpixel algorithm, which
            % are: `RegionSize` and `Ratio`. It preallocate some buffers for
            % future computing iterations over the given image. An example of
            % LSC is ilustrated in the following picture.
            % For enanched results it is recommended for color images to
            % preprocess image with little gaussian blur with a small 3x3
            % kernel and additional conversion into CieLAB color space.
            %
            % ![image](https://docs.opencv.org/3.3.1/superpixels_lsc.png)
            %
            % See also: cv.SuperpixelLSC.iterate
            %
            this.id = SuperpixelLSC_(0, 'new', img, varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.SuperpixelLSC
            %
            if isempty(this.id), return; end
            SuperpixelLSC_(this.id, 'delete');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.SuperpixelLSC.empty, cv.SuperpixelLSC.load
            %
            SuperpixelLSC_(this.id, 'clear');
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
            % See also: cv.SuperpixelLSC.clear, cv.SuperpixelLSC.load
            %
            b = SuperpixelLSC_(this.id, 'empty');
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
            % See also: cv.SuperpixelLSC.load
            %
            SuperpixelLSC_(this.id, 'save', filename);
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
            % See also: cv.SuperpixelLSC.save
            %
            SuperpixelLSC_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.SuperpixelLSC.save, cv.SuperpixelLSC.load
            %
            name = SuperpixelLSC_(this.id, 'getDefaultName');
        end
    end

    %% SuperpixelLSC
    methods
        function num = getNumberOfSuperpixels(this)
            %GETNUMBEROFSUPERPIXELS  Calculates the actual amount of superpixels on a given segmentation computed and stored in object
            %
            %     num = obj.getNumberOfSuperpixels()
            %
            % ## Output
            % * __num__ actual amount of superpixels.
            %
            % See also: cv.SuperpixelLSC.iterate
            %
            num = SuperpixelLSC_(this.id, 'getNumberOfSuperpixels');
        end

        function iterate(this, varargin)
            %ITERATE  Calculates the superpixel segmentation on a given image with the initialized parameters in the object
            %
            %     obj.iterate()
            %     obj.iterate('OptionName',optionValue, ...)
            %
            % ## Options
            % * __NumIterations__ Number of iterations. Higher number improves
            %   the result. default 10
            %
            % The function computes the superpixels segmentation of an image
            % with the parameters initialized with the constructor. The
            % algorithms starts from a grid of superpixels and then refines
            % the boundaries by proposing updates of edges boundaries.
            %
            % This function can be called again without the need of
            % initializing the algorithm with the constructor This save the
            % computational cost of allocating memory for all the structures
            % of the algorithm.
            %
            % See also: cv.SuperpixelLSC.getLabels
            %
            SuperpixelLSC_(this.id, 'iterate', varargin{:});
        end

        function labels = getLabels(this)
            %GETLABELS  Returns the segmentation labeling of the image
            %
            %     labels = obj.getLabels()
            %
            % ## Output
            % * __labels__ Return a `int32` integer array containing the
            %   labels of the superpixel segmentation. The labels are in the
            %   range `[0, obj.getNumberOfSuperpixels()]`.
            %
            % The function returns an image with the labels of the superpixel
            % segmentation. The labels are in the range
            % `[0, obj.getNumberOfSuperpixels()]`.
            %
            % Each label represents a superpixel, and each pixel is assigned
            % to one superpixel label.
            %
            % See also: cv.SuperpixelLSC.iterate
            %
            labels = SuperpixelLSC_(this.id, 'getLabels');
        end

        function img = getLabelContourMask(this, varargin)
            %GETLABELCONTOURMASK  Returns the mask of the superpixel segmentation stored in object
            %
            %     img = obj.getLabelContourMask()
            %     img = obj.getLabelContourMask('OptionName',optionValue, ...)
            %
            % ## Output
            % * __img__ Return `logical` image mask where 1 indicates that the
            %   pixel is a superpixel border, and 0 otherwise.
            %
            % ## Options
            % * __ThickLine__ If false, the border is only one pixel wide,
            %   otherwise all pixels at the border are masked. default true
            %
            % The function return the boundaries of the superpixel
            % segmentation.
            %
            % See also: cv.SuperpixelLSC.iterate, boundarymask
            %
            img = SuperpixelLSC_(this.id, 'getLabelContourMask', varargin{:});
            img = (img == 255);  % fg:uint8(255), bg:uint8(0)
        end

        function enforceLabelConnectivity(this, varargin)
            %ENFORCELABELCONNECTIVITY  Enforce label connectivity
            %
            %     obj.enforceLabelConnectivity()
            %     obj.enforceLabelConnectivity('OptionName',optionValue, ...)
            %
            % ## Options
            % * __MinElementSize__ The minimum element size in percents that
            %   should be absorbed into a bigger superpixel. Given resulted
            %   average superpixel size valid value should be in 0-100 range,
            %   25 means that less then a quarter sized superpixel should be
            %   absorbed, this is default. default 20
            %
            % The function merge component that is too small, assigning the
            % previously found adjacent label to this component. Calling this
            % function may change the final number of superpixels.
            %
            % See also: cv.SuperpixelLSC.iterate
            %
            SuperpixelLSC_(this.id, 'enforceLabelConnectivity', varargin{:});
        end
    end

end
