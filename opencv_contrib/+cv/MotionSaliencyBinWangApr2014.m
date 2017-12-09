classdef MotionSaliencyBinWangApr2014 < handle
    %MOTIONSALIENCYBINWANGAPR2014  A Fast Self-tuning Background Subtraction Algorithm for Motion Saliency
    %
    % Implementation of MotionSaliencyBinWangApr2014 for Motion Saliency.
    %
    % ## Saliency API
    %
    % Many computer vision applications may benefit from understanding where
    % humans focus given a scene. Other than cognitively understanding the way
    % human perceive images and scenes, finding salient regions and objects in
    % the images helps various tasks such as speeding up object detection,
    % object recognition, object tracking and content-aware image editing.
    %
    % About the saliency, there is a rich literature but the development is
    % very fragmented. The principal purpose of this API is to give a unique
    % interface, a unique framework for use and plug sever saliency
    % algorithms, also with very different nature and methodology, but they
    % share the same purpose, organizing algorithms into three main
    % categories:
    %
    % * Static Saliency
    % * Motion Saliency
    % * Objectness
    %
    % Saliency UML diagram:
    %
    % ![image](https://docs.opencv.org/3.3.1/saliency.png)
    %
    % To see how API works, try tracker demo: `computeSaliency_demo.m`.
    %
    % ## Motion Saliency Algorithms
    %
    % Algorithms belonging to this category, are particularly focused to
    % detect salient objects over time (hence also over frame), then there is
    % a temporal component sealing cosider that allows to detect "moving"
    % objects as salient, meaning therefore also the more general sense of
    % detection the changes in the scene.
    %
    % Presently, the Fast Self-tuning Background Subtraction Algorithm
    % [BinWangApr2014] has been implemented.
    %
    % ## References
    % [BinWangApr2014]:
    % > Bin Wang and Piotr Dudek. "A Fast Self-tuning Background Subtraction
    % > Algorithm". In Computer Vision and Pattern Recognition Workshops
    % > (CVPRW), 2014 IEEE Conference on, pages 401-404. IEEE, 2014.
    %
    % See also: cv.StaticSaliencySpectralResidual
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % Width of input image.
        ImageWidth
        % Height of input image.
        ImageHeight
    end

    methods
        function this = MotionSaliencyBinWangApr2014()
            %MOTIONSALIENCYBINWANGAPR2014  Constructor, creates a specialized saliency algorithm of this type
            %
            %     obj = cv.MotionSaliencyBinWangApr2014()
            %
            % See also: cv.MotionSaliencyBinWangApr2014.computeSaliency
            %
            this.id = MotionSaliencyBinWangApr2014_(0, 'new');
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.MotionSaliencyBinWangApr2014
            %
            if isempty(this.id), return; end
            MotionSaliencyBinWangApr2014_(this.id, 'delete');
        end

        function setImagesize(this, W, H)
            %SETIMAGESIZE  This is a utility function that allows to set the correct size (taken from the input image) in the corresponding variables that will be used to size the data structures of the algorithm
            %
            %     obj.setImagesize(W, H)
            %
            % ## Input
            % * __W__ width of input image.
            % * __H__ height of input image.
            %
            % See also: cv.MotionSaliencyBinWangApr2014.init
            %
            MotionSaliencyBinWangApr2014_(this.id, 'setImagesize', W, H);
        end

        function init(this)
            %INIT  This function allows the correct initialization of all data structures that will be used by the algorithm
            %
            %     obj.init()
            %
            % See also: cv.MotionSaliencyBinWangApr2014.setImagesize
            %
            MotionSaliencyBinWangApr2014_(this.id, 'init');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.MotionSaliencyBinWangApr2014.empty,
            %  cv.MotionSaliencyBinWangApr2014.load
            %
            MotionSaliencyBinWangApr2014_(this.id, 'clear');
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
            % See also: cv.MotionSaliencyBinWangApr2014.clear,
            %  cv.MotionSaliencyBinWangApr2014.load
            %
            b = MotionSaliencyBinWangApr2014_(this.id, 'empty');
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
            % See also: cv.MotionSaliencyBinWangApr2014.load
            %
            MotionSaliencyBinWangApr2014_(this.id, 'save', filename);
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
            % See also: cv.MotionSaliencyBinWangApr2014.save
            %
            MotionSaliencyBinWangApr2014_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.MotionSaliencyBinWangApr2014.save,
            %  cv.MotionSaliencyBinWangApr2014.load
            %
            name = MotionSaliencyBinWangApr2014_(this.id, 'getDefaultName');
        end
    end

    %% Saliency, MotionSaliency
    methods
        function saliencyMap = computeSaliency(this, img)
            %COMPUTESALIENCY  Compute the saliency
            %
            %     saliencyMap = obj.computeSaliency(img)
            %
            % ## Input
            % * __img__ The input image, 8-bit grayscale.
            %
            % ## Output
            % * __saliencyMap__ The computed saliency map
            %   (background-foreground mask). Is a binarized map that, in
            %   accordance with the nature of the algorithm, highlights the
            %   moving objects or areas of change in the scene. The saliency
            %   map is given by a matrix (one for each frame of an
            %   hypothetical video stream).
            %
            % Performs all the operations and calls all internal functions
            % necessary for the accomplishment of the Fast Self-tuning
            % Background Subtraction Algorithm algorithm.
            %
            % See also: cv.MotionSaliencyBinWangApr2014.MotionSaliencyBinWangApr2014
            %
            saliencyMap = MotionSaliencyBinWangApr2014_(this.id, 'computeSaliency', img);
        end
    end

    %% Getters/Setters
    methods
        function value = get.ImageWidth(this)
            value = MotionSaliencyBinWangApr2014_(this.id, 'get', 'ImageWidth');
        end
        function set.ImageWidth(this, value)
            MotionSaliencyBinWangApr2014_(this.id, 'set', 'ImageWidth', value);
        end

        function value = get.ImageHeight(this)
            value = MotionSaliencyBinWangApr2014_(this.id, 'get', 'ImageHeight');
        end
        function set.ImageHeight(this, value)
            MotionSaliencyBinWangApr2014_(this.id, 'set', 'ImageHeight', value);
        end
    end

end
