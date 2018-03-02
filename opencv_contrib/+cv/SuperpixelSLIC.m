classdef SuperpixelSLIC < handle
    %SUPERPIXELSLIC  Class implementing the SLIC (Simple Linear Iterative Clustering) superpixels algorithm
    %
    % As described in [Achanta2012].
    %
    % SLIC (Simple Linear Iterative Clustering) clusters pixels using pixel
    % channels and image plane space to efficiently generate compact, nearly
    % uniform superpixels. The simplicity of approach makes it extremely easy
    % to use a lone parameter specifies the number of superpixels and the
    % efficiency of the algorithm makes it very practical.
    %
    % Several optimizations are available for SLIC class:
    %
    % * SLICO stands for "Zero parameter SLIC" and it is an optimization of
    %   baseline SLIC described in [Achanta2012].
    % * MSLIC stands for "Manifold SLIC" and it is an optimization of baseline
    %   SLIC described in [Liu_2017_IEEE].
    %
    % ## References
    % [Achanta2012]:
    % > Radhakrishna Achanta, Appu Shaji, Kevin Smith, Aurelien Lucchi,
    % > Pascal Fua, and Sabine Susstrunk. "SLIC superpixels compared to
    % > state-of-the-art superpixel methods". IEEE Trans. Pattern Anal. Mach.
    % > Intell., 34(11):2274-2282, nov 2012.
    %
    % [epfl2010]:
    % > "SLIC Superpixels" Radhakrishna Achanta, Appu Shaji, Kevin Smith,
    % > Aurelien Lucchi, Pascal Fua, and Sabine Susstrunk. EPFL Technical
    % > Report no. 149300, June 2010.
    %
    % [Liu_2017_IEEE]:
    % > Yong-Jin Liu, Cheng-Chi Yu, Min-Jing Yu, and Ying He. "Intrinsic
    % > Manifold SLIC: A Simple and Efficient Method for Computing
    % > Content-Sensitive Superpixels". IEEE Transactions on Pattern Analysis
    % > and Machine Intelligence, Issue 99, March 2017.
    %
    % See also: cv.SuperpixelSLIC.SuperpixelSLIC, cv.SuperpixelLSC,
    %  cv.SuperpixelSEEDS, superpixels
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    methods
        function this = SuperpixelSLIC(img, varargin)
            %SUPERPIXELSLIC  Initialize a SuperpixelSLIC object
            %
            %     obj = cv.SuperpixelSLIC(img)
            %     obj = cv.SuperpixelSLIC(img, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __img__ Image to segment.
            %
            % ## Options
            % * __Algorithm__ Chooses the algorithm variant to use:
            %   * __SLIC__ segments image using a desired `RegionSize` and
            %     compactness factor `Ruler` (the same compactnes for all
            %     superpixels in the image).
            %   * __SLICO__ segments image using a desired `RegionSize`, and
            %     in addition will choose an adaptive compactness factor for
            %     each superpixel differently. This is the default.
            %   * __MSLIC__ optimize using manifold methods resulting in more
            %     content-sensitive superpixels.
            % * __RegionSize__ Chooses an average superpixel size measured in
            %   pixels. default 10
            % * __Ruler__ Chooses the enforcement of superpixel smoothness
            %   factor of superpixel. Only considered for SLIC, has no effect
            %   on SLICO. default 10.0
            %
            % The function initializes a SuperpixelSLIC object for the input
            % image. It sets the parameters of choosed superpixel algorithm,
            % which are: `RegionSize` and `Ruler`. It preallocate some buffers
            % for future computing iterations over the given image.
            %
            % For enanched results it is recommended for color images to
            % preprocess image with little gaussian blur using a small 3x3
            % kernel and additional conversion into CIELAB color space.
            %
            % An example of SLIC versus SLICO and MSLIC is ilustrated in the
            % following picture.
            %
            % ![image](https://github.com/opencv/opencv_contrib/raw/3.3.0/modules/ximgproc/doc/pics/superpixels_slic.png)
            %
            % See also: cv.SuperpixelSLIC.iterate
            %
            this.id = SuperpixelSLIC_(0, 'new', img, varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.SuperpixelSLIC
            %
            if isempty(this.id), return; end
            SuperpixelSLIC_(this.id, 'delete');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.SuperpixelSLIC.empty, cv.SuperpixelSLIC.load
            %
            SuperpixelSLIC_(this.id, 'clear');
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
            % See also: cv.SuperpixelSLIC.clear, cv.SuperpixelSLIC.load
            %
            b = SuperpixelSLIC_(this.id, 'empty');
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
            % See also: cv.SuperpixelSLIC.load
            %
            SuperpixelSLIC_(this.id, 'save', filename);
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
            % See also: cv.SuperpixelSLIC.save
            %
            SuperpixelSLIC_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.SuperpixelSLIC.save, cv.SuperpixelSLIC.load
            %
            name = SuperpixelSLIC_(this.id, 'getDefaultName');
        end
    end

    %% SuperpixelSLIC
    methods
        function num = getNumberOfSuperpixels(this)
            %GETNUMBEROFSUPERPIXELS  Calculates the actual amount of superpixels on a given segmentation computed and stored in object
            %
            %     num = obj.getNumberOfSuperpixels()
            %
            % ## Output
            % * __num__ actual amount of superpixels.
            %
            % See also: cv.SuperpixelSLIC.iterate
            %
            num = SuperpixelSLIC_(this.id, 'getNumberOfSuperpixels');
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
            % See also: cv.SuperpixelSLIC.getLabels
            %
            SuperpixelSLIC_(this.id, 'iterate', varargin{:});
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
            % See also: cv.SuperpixelSLIC.iterate
            %
            labels = SuperpixelSLIC_(this.id, 'getLabels');
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
            % See also: cv.SuperpixelSLIC.iterate, boundarymask
            %
            img = SuperpixelSLIC_(this.id, 'getLabelContourMask', varargin{:});
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
            %   absorbed, this is default. default 25
            %
            % The function merge component that is too small, assigning the
            % previously found adjacent label to this component. Calling this
            % function may change the final number of superpixels.
            %
            % See also: cv.SuperpixelSLIC.iterate
            %
            SuperpixelSLIC_(this.id, 'enforceLabelConnectivity', varargin{:});
        end
    end

end
