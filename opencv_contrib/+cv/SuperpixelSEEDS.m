classdef SuperpixelSEEDS < handle
    %SUPERPIXELSEEDS  Class implementing the SEEDS (Superpixels Extracted via Energy-Driven Sampling) superpixels algorithm
    %
    % As described in [VBRV14].
    %
    % The algorithm uses an efficient hill-climbing algorithm to optimize the
    % superpixels' energy function that is based on color histograms and a
    % boundary term, which is optional. The energy function encourages
    % superpixels to be of the same color, and if the boundary term is
    % activated, the superpixels have smooth boundaries and are of similar
    % shape. In practice it starts from a regular grid of superpixels and
    % moves the pixels or blocks of pixels at the boundaries to refine the
    % solution. The algorithm runs in real-time using a single CPU.
    %
    % ## References
    % [VBRV14]:
    % > Michael Van den Bergh, Xavier Boix, Gemma Roig, Benjamin de Capitani,
    % > and Luc Van Gool. "SEEDS: Superpixels Extracted via Energy-Driven
    % > Sampling". In Computer Vision-ECCV 2012, pages 13-26. Springer, 2012.
    %
    % See also: cv.SuperpixelSEEDS.SuperpixelSEEDS, cv.SuperpixelSLIC,
    %  cv.SuperpixelLSC, superpixels
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    methods
        function this = SuperpixelSEEDS(image_size, num_superpixels, num_levels, varargin)
            %SUPERPIXELSEEDS  Initializes a SuperpixelSEEDS object
            %
            %     obj = cv.SuperpixelSEEDS(image_size, num_superpixels, num_levels)
            %     obj = cv.SuperpixelSEEDS(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * **image_size** Image size specified as `[height,width]` or
            %   `[height,width,number_of_channels]`.
            % * **num_superpixels** Desired number of superpixels. Note that
            %   the actual number may be smaller due to restrictions
            %   (depending on the image size and `num_levels`). Use
            %   cv.SuperpixelSEEDS.getNumberOfSuperpixels to get the actual
            %   number.
            % * **num_levels** Number of block levels. The more levels, the
            %   more accurate is the segmentation, but needs more memory and
            %   CPU time. Minimum is 2.
            %
            % ## Options
            % * __Prior__ enable 3x3 shape smoothing term if `> 0`. A larger
            %   value leads to smoother shapes. Prior must be in the range
            %   [0, 5]. default 2
            % * __HistogramBins__ Number of histogram bins. default 5
            % * __DoubleStep__ If true, iterate each block level twice for
            %   higher accuracy. default false
            %
            % The function initializes a SuperpixelSEEDS object for the input
            % image. It stores the parameters of the image: `image_width`,
            % `image_height` and `image_channels`. It also sets the parameters
            % of the SEEDS superpixel algorithm, which are: `num_superpixels`,
            % `num_levels`, `Prior`, `HistogramBins` and `DoubleStep`.
            %
            % The number of levels in `num_levels` defines the amount of block
            % levels that the algorithm use in the optimization. The
            % initialization is a grid, in which the superpixels are equally
            % distributed through the width and the height of the image. The
            % larger blocks correspond to the superpixel size, and the levels
            % with smaller blocks are formed by dividing the larger blocks
            % into 2x2 blocks of pixels, recursively until the smaller block
            % level. An example of initialization of 4 block levels is
            % illustrated in the following figure.
            %
            % ![image](https://docs.opencv.org/3.3.1/superpixels_blocks.png)
            %
            % See also: cv.SuperpixelSEEDS.iterate
            %
            this.id = SuperpixelSEEDS_(0, 'new', ...
                image_size, num_superpixels, num_levels, varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.SuperpixelSEEDS
            %
            if isempty(this.id), return; end
            SuperpixelSEEDS_(this.id, 'delete');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.SuperpixelSEEDS.empty, cv.SuperpixelSEEDS.load
            %
            SuperpixelSEEDS_(this.id, 'clear');
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
            % See also: cv.SuperpixelSEEDS.clear, cv.SuperpixelSEEDS.load
            %
            b = SuperpixelSEEDS_(this.id, 'empty');
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
            % See also: cv.SuperpixelSEEDS.load
            %
            SuperpixelSEEDS_(this.id, 'save', filename);
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
            % See also: cv.SuperpixelSEEDS.save
            %
            SuperpixelSEEDS_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.SuperpixelSEEDS.save, cv.SuperpixelSEEDS.load
            %
            name = SuperpixelSEEDS_(this.id, 'getDefaultName');
        end
    end

    %% SuperpixelSEEDS
    methods
        function num = getNumberOfSuperpixels(this)
            %GETNUMBEROFSUPERPIXELS  Calculates the superpixel segmentation on a given image stored in object
            %
            %     num = obj.getNumberOfSuperpixels()
            %
            % ## Output
            % * __num__ actual amount of superpixels.
            %
            % The function computes the superpixels segmentation of an image
            % with the parameters initialized with the constructor.
            %
            % See also: cv.SuperpixelSEEDS.iterate
            %
            num = SuperpixelSEEDS_(this.id, 'getNumberOfSuperpixels');
        end

        function iterate(this, img, varargin)
            %ITERATE  Calculates the superpixel segmentation on a given image with the initialized parameters in the object
            %
            %     obj.iterate(img)
            %     obj.iterate(img, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __img__ Input image. Supported formats: `uint8`, `uint16`,
            %   `single`. Image size & number of channels must match with the
            %   initialized image size & channels with the constructor. It
            %   should be in HSV or Lab color space. Lab is a bit better, but
            %   also slower.
            %
            % ## Options
            % * __NumIterations__ Number of iterations. Higher number improves
            %   the result. default 4
            %
            % The function computes the superpixels segmentation of an image
            % with the parameters initialized with the constructor. The
            % algorithms starts from a grid of superpixels and then refines
            % the boundaries by proposing updates of blocks of pixels that lie
            % at the boundaries from large to smaller size, finalizing with
            % proposing pixel updates. An illustrative example can be seen
            % below.
            %
            % ![image](https://docs.opencv.org/3.3.1/superpixels_blocks2.png)
            %
            % This function can be called again for other images without the
            % need of initializing the algorithm with constructor. This save
            % the computational cost of allocating memory for all the
            % structures of the algorithm.
            %
            % See also: cv.SuperpixelSEEDS.getLabels
            %
            SuperpixelSEEDS_(this.id, 'iterate', img, varargin{:});
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
            % See also: cv.SuperpixelSEEDS.iterate
            %
            labels = SuperpixelSEEDS_(this.id, 'getLabels');
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
            %   otherwise all pixels at the border are masked. default false
            %
            % The function return the boundaries of the superpixel
            % segmentation.
            %
            % ![image](https://docs.opencv.org/3.3.1/superpixels_demo.png)
            %
            % See also: cv.SuperpixelSEEDS.iterate, boundarymask
            %
            img = SuperpixelSEEDS_(this.id, 'getLabelContourMask', varargin{:});
            img = (img == 255);  % fg:uint8(255), bg:uint8(0)
        end
    end

end
