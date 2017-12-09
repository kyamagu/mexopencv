classdef StaticSaliencyFineGrained < handle
    %STATICSALIENCYFINEGRAINED  The Fine Grained Saliency approach for Static Saliency
    %
    % The Fine Grained Saliency approach from [FGS].
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
    % ### Fine Grained Saliency
    %
    % This method calculates saliency based on center-surround differences.
    % High resolution saliency maps are generated in real time by using
    % integral images.
    %
    % ## References
    % [FGS]:
    % > Sebastian Montabone and Alvaro Soto. "Human detection using a mobile
    % > platform and novel features derived from a visual saliency mechanism".
    % > In Image and Vision Computing, Vol. 28 Issue 3, pages 391-402.
    % > Elsevier, 2010.
    %
    % See also: cv.StaticSaliencySpectralResidual
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    methods
        function this = StaticSaliencyFineGrained()
            %STATICSALIENCYFINEGRAINED  Constructor, creates a specialized saliency algorithm of this type
            %
            %     obj = cv.StaticSaliencyFineGrained()
            %
            % See also: cv.StaticSaliencyFineGrained.computeSaliency
            %
            this.id = StaticSaliencyFineGrained_(0, 'new');
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.StaticSaliencyFineGrained
            %
            if isempty(this.id), return; end
            StaticSaliencyFineGrained_(this.id, 'delete');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.StaticSaliencyFineGrained.empty,
            %  cv.StaticSaliencyFineGrained.load
            %
            StaticSaliencyFineGrained_(this.id, 'clear');
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
            % See also: cv.StaticSaliencyFineGrained.clear,
            %  cv.StaticSaliencyFineGrained.load
            %
            b = StaticSaliencyFineGrained_(this.id, 'empty');
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
            % See also: cv.StaticSaliencyFineGrained.load
            %
            StaticSaliencyFineGrained_(this.id, 'save', filename);
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
            % See also: cv.StaticSaliencyFineGrained.save
            %
            StaticSaliencyFineGrained_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.StaticSaliencyFineGrained.save,
            %  cv.StaticSaliencyFineGrained.load
            %
            name = StaticSaliencyFineGrained_(this.id, 'getDefaultName');
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
            % * __img__ The input image, 8-bit 1 or 3-channel (internally
            %   converted to grayscale).
            %
            % ## Output
            % * __saliencyMap__ The computed saliency map, `uint8` matrix.
            %
            % See also: cv.StaticSaliencyFineGrained.computeBinaryMap
            %
            saliencyMap = StaticSaliencyFineGrained_(this.id, 'computeSaliency', img);
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
            % See also: cv.StaticSaliencyFineGrained.computeSaliency
            %
            if isa(saliencyMap, 'uint8')
                % saliency map expected to be floating point in [0,1] range
                saliencyMap = single(saliencyMap) / 255;
            end
            binaryMap = StaticSaliencyFineGrained_(this.id, 'computeBinaryMap', saliencyMap);
        end
    end

end
