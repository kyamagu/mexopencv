classdef StaticSaliencySpectralResidual < handle
    %STATICSALIENCYSPECTRALRESIDUAL  The Spectral Residual approach for Static Saliency
    %
    % Implementation of SpectralResidual for Static Saliency.
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
    % ## Static Saliency algorithms
    %
    % Algorithms belonging to this category, exploit different image features
    % that allow to detect salient objects in a non dynamic scenarios.
    %
    % Presently, the Spectral Residual approach [SR] has been implemented.
    %
    % ### Spectral Residual
    %
    % Starting from the principle of natural image statistics, this method
    % simulate the behavior of pre-attentive visual search. The algorithm
    % analyze the log spectrum of each image and obtain the spectral residual.
    % Then transform the spectral residual to spatial domain to obtain the
    % saliency map, which suggests the positions of proto-objects.
    %
    % ## References
    % [SR]:
    % > Xiaodi Hou and Liqing Zhang. "Saliency detection: A spectral residual
    % > approach". In Computer Vision and Pattern Recognition, 2007. CVPR'07.
    % > IEEE Conference on, pages 1-8. IEEE, 2007.
    %
    % See also: cv.MotionSaliencyBinWangApr2014, cv.StaticSaliencyFineGrained
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % The dimension to which the image should be resized
        % (resized image width).
        %
        % Default 64
        ImageWidth
        % The dimension to which the image should be resized
        % (resized image height).
        %
        % Default 64
        ImageHeight
    end

    methods
        function this = StaticSaliencySpectralResidual()
            %STATICSALIENCYSPECTRALRESIDUAL  Constructor, creates a specialized saliency algorithm of this type
            %
            %     obj = cv.StaticSaliencySpectralResidual()
            %
            % See also: cv.StaticSaliencySpectralResidual.computeSaliency
            %
            this.id = StaticSaliencySpectralResidual_(0, 'new');
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.StaticSaliencySpectralResidual
            %
            if isempty(this.id), return; end
            StaticSaliencySpectralResidual_(this.id, 'delete');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.StaticSaliencySpectralResidual.empty,
            %  cv.StaticSaliencySpectralResidual.load
            %
            StaticSaliencySpectralResidual_(this.id, 'clear');
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
            % See also: cv.StaticSaliencySpectralResidual.clear,
            %  cv.StaticSaliencySpectralResidual.load
            %
            b = StaticSaliencySpectralResidual_(this.id, 'empty');
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
            % See also: cv.StaticSaliencySpectralResidual.load
            %
            StaticSaliencySpectralResidual_(this.id, 'save', filename);
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
            % See also: cv.StaticSaliencySpectralResidual.save
            %
            StaticSaliencySpectralResidual_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.StaticSaliencySpectralResidual.save,
            %  cv.StaticSaliencySpectralResidual.load
            %
            name = StaticSaliencySpectralResidual_(this.id, 'getDefaultName');
        end
    end

    %% Saliency
    methods
        function saliencyMap = computeSaliency(this, img)
            %COMPUTESALIENCY  Compute the saliency
            %
            %     saliencyMap = obj.computeSaliency(img)
            %
            % ## Input
            % * __img__ The input image, 1 or 3-channel (internally converted
            %   to grayscale).
            %
            % ## Output
            % * __saliencyMap__ The computed saliency map, `single` matrix.
            %
            % Performs all the operations and calls all internal functions
            % necessary for the accomplishment of spectral residual saliency
            % map.
            %
            % See also: cv.StaticSaliencySpectralResidual.computeBinaryMap
            %
            saliencyMap = StaticSaliencySpectralResidual_(this.id, 'computeSaliency', img);
        end
    end

    %% StaticSaliency
    methods
        function binaryMap = computeBinaryMap(this, saliencyMap)
            %COMPUTEBINARYMAP  This function perform a binary map of given saliency map
            %
            %     binaryMap = obj.computeBinaryMap(saliencyMap)
            %
            % ## Input
            % * __saliencyMap__ the saliency map obtained through one of the
            %   specialized algorithms, `single` matrix.
            %
            % ## Output
            % * __binaryMap__ the binary map, `uint8` matrix with either 0 or
            %   255 values.
            %
            % This is obtained in this way:
            % In a first step, to improve the definition of interest areas and
            % facilitate identification of targets, a segmentation by
            % clustering is performed, using *K-means algorithm*. Then, to
            % gain a binary representation of clustered saliency map, since
            % values of the map can vary according to the characteristics of
            % frame under analysis, it is not convenient to use a fixed
            % threshold. So, *Otsu's algorithm* is used, which assumes that
            % the image to be thresholded contains two classes of pixels or
            % bi-modal histograms (e.g. foreground and back-ground pixels);
            % later on, the algorithm calculates the optimal threshold
            % separating those two classes, so that their intra-class variance
            % is minimal.
            %
            % See also: cv.StaticSaliencySpectralResidual.computeSaliency
            %
            binaryMap = StaticSaliencySpectralResidual_(this.id, 'computeBinaryMap', saliencyMap);
        end
    end

    %% Getters/Setters
    methods
        function value = get.ImageWidth(this)
            value = StaticSaliencySpectralResidual_(this.id, 'get', 'ImageWidth');
        end
        function set.ImageWidth(this, value)
            StaticSaliencySpectralResidual_(this.id, 'set', 'ImageWidth', value);
        end

        function value = get.ImageHeight(this)
            value = StaticSaliencySpectralResidual_(this.id, 'get', 'ImageHeight');
        end
        function set.ImageHeight(this, value)
            StaticSaliencySpectralResidual_(this.id, 'set', 'ImageHeight', value);
        end
    end

end
