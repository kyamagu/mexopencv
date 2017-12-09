classdef ObjectnessBING < handle
    %OBJECTNESSBING  The Binarized normed gradients algorithm for Objectness
    %
    % Implementation of BING for Objectness.
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
    % ## Objectness Algorithms
    %
    % Objectness is usually represented as a value which reflects how likely
    % an image window covers an object of any category. Algorithms belonging
    % to this category, avoid making decisions early on, by proposing a small
    % number of category-independent proposals, that are expected to cover all
    % objects in an image. Being able to perceive objects before identifying
    % them is closely related to bottom up visual attention (saliency).
    %
    % Presently, the Binarized normed gradients algorithm [BING] has been
    % implemented.
    %
    % ## References
    % [BING]:
    % > Cheng, Ming-Ming, et al. "BING: Binarized normed gradients for
    % > objectness estimation at 300fps". In IEEE CVPR, 2014.
    %
    % See also: cv.StaticSaliencySpectralResidual,
    %  cv.MotionSaliencyBinWangApr2014
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % base for window size quantization. default 2
        Base
        % Size for non-maximal suppress. default 2
        NSS
        % As described in the paper: feature window size (W, W). default 8
        W
    end

    methods
        function this = ObjectnessBING()
            %OBJECTNESSBING  Constructor, creates a specialized saliency algorithm of this type
            %
            %     obj = cv.ObjectnessBING()
            %
            % See also: cv.ObjectnessBING.computeSaliency
            %
            this.id = ObjectnessBING_(0, 'new');
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.ObjectnessBING
            %
            if isempty(this.id), return; end
            ObjectnessBING_(this.id, 'delete');
        end

        function objectnessValues = getObjectnessValues(this)
            %GETOBJECTNESSVALUES  Return the list of the rectangles' objectness value
            %
            %     objectnessValues = obj.getObjectnessValues()
            %
            % ## Output
            % * __objectnessValues__ vector of floats in the same order as
            %   `objectnessBoundingBox` returned by the algorithm (in
            %   `computeSaliency` function). The bigger value these scores
            %   are, it is more likely to be an object window.
            %
            % See also: cv.ObjectnessBING.computeSaliency
            %
            objectnessValues = ObjectnessBING_(this.id, 'getobjectnessValues');
        end

        function setTrainingPath(this, trainingPath)
            %SETTRAININGPATH  This is a utility function that allows to set the correct path from which the algorithm will load the trained model
            %
            %     obj.setTrainingPath(trainingPath)
            %
            % ## Input
            % * __trainingPath__ trained model path.
            %
            % See also: cv.ObjectnessBING.setBBResDir
            %
            ObjectnessBING_(this.id, 'setTrainingPath', trainingPath);
        end

        function setBBResDir(this, resultsDir)
            %SETBBRESDIR  This is a utility function that allows to set an arbitrary path in which the algorithm will save the optional results
            %
            %     obj.setBBResDir(resultsDir)
            %
            % ## Input
            % * __resultsDir__ results' folder path.
            %
            % Writes on file the total number and the list of rectangles
            % returned by objectness, one for each row.
            %
            % See also: cv.ObjectnessBING.setTrainingPath
            %
            ObjectnessBING_(this.id, 'setBBResDir', resultsDir);
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.ObjectnessBING.empty, cv.ObjectnessBING.load
            %
            ObjectnessBING_(this.id, 'clear');
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
            % See also: cv.ObjectnessBING.clear, cv.ObjectnessBING.load
            %
            b = ObjectnessBING_(this.id, 'empty');
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
            % See also: cv.ObjectnessBING.load
            %
            ObjectnessBING_(this.id, 'save', filename);
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
            % See also: cv.ObjectnessBING.save
            %
            ObjectnessBING_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.ObjectnessBING.save, cv.ObjectnessBING.load
            %
            name = ObjectnessBING_(this.id, 'getDefaultName');
        end
    end

    %% Saliency, Objectness
    methods
        function objectnessBoundingBox = computeSaliency(this, img)
            %COMPUTESALIENCY  Compute the saliency
            %
            %     objectnessBoundingBox = obj.computeSaliency(img)
            %
            % ## Input
            % * __img__ The input image, 8-bit color.
            %
            % ## Output
            % * __objectnessBoundingBox__ objectness Bounding Box vector.
            %   According to the result given by this specialized algorithm,
            %   the `objectnessBoundingBox` is a cell array of 4-element
            %   vectors. Each bounding box is represented by
            %   `[minX, minY, maxX, maxY]`.
            %
            % Performs all the operations and calls all internal functions
            % necessary for the accomplishment of the Binarized normed
            % gradients algorithm.
            %
            % See also: cv.ObjectnessBING.ObjectnessBING
            %
            objectnessBoundingBox = ObjectnessBING_(this.id, 'computeSaliency', img);
        end
    end

    %% Getters/Setters
    methods
        function value = get.Base(this)
            value = ObjectnessBING_(this.id, 'get', 'Base');
        end
        function set.Base(this, value)
            ObjectnessBING_(this.id, 'set', 'Base', value);
        end

        function value = get.NSS(this)
            value = ObjectnessBING_(this.id, 'get', 'NSS');
        end
        function set.NSS(this, value)
            ObjectnessBING_(this.id, 'set', 'NSS', value);
        end

        function value = get.W(this)
            value = ObjectnessBING_(this.id, 'get', 'W');
        end
        function set.W(this, value)
            ObjectnessBING_(this.id, 'set', 'W', value);
        end
    end

end
