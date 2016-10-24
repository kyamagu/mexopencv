classdef StructuredEdgeDetection < handle
    %STRUCTUREDEDGEDETECTION  Class implementing edge detection algorithm
    %
    % As described in [Dollar2013].
    %
    % ### Structured forests for fast edge detection
    %
    % This module contains implementations of modern structured edge detection
    % algorithms, i.e. algorithms which somehow takes into account pixel
    % affinities in natural images.
    %
    % <<http://docs.opencv.org/3.1.0/01.jpg>>
    % <<http://docs.opencv.org/3.1.0/02.jpg>>
    % <<http://docs.opencv.org/3.1.0/03.jpg>>
    % <<http://docs.opencv.org/3.1.0/04.jpg>>
    % <<http://docs.opencv.org/3.1.0/05.jpg>>
    % <<http://docs.opencv.org/3.1.0/06.jpg>>
    % <<http://docs.opencv.org/3.1.0/07.jpg>>
    % <<http://docs.opencv.org/3.1.0/08.jpg>>
    % <<http://docs.opencv.org/3.1.0/09.jpg>>
    % <<http://docs.opencv.org/3.1.0/10.jpg>>
    % <<http://docs.opencv.org/3.1.0/11.jpg>>
    % <<http://docs.opencv.org/3.1.0/12.jpg>>
    %
    % ## References
    % [Dollar2013]:
    % > Piotr Dollar and C Lawrence Zitnick. "Structured forests for fast edge
    % > detection". In IEEE International Conference on Computer Vision (ICCV)
    % > 2013, pages 1841-1848.
    %
    % [Lim2013]:
    % > Joseph J Lim, C Lawrence Zitnick, and Piotr DollAr. "Sketch tokens: A
    % > learned mid-level representation for contour and object detection".
    % > In IEEE Conference on Computer Vision and Pattern Recognition (CVPR),
    % > 2013, pages 3158-3165.
    %
    % See also: cv.StructuredEdgeDetection.StructuredEdgeDetection
    %

    properties (SetAccess = private)
        id    % Object ID
    end

    methods
        function this = StructuredEdgeDetection(model, varargin)
            %STRUCTUREDEDGEDETECTION  The only constructor
            %
            %    obj = cv.StructuredEdgeDetection(model)
            %    obj = cv.StructuredEdgeDetection(model, howToGetFeatures)
            %
            % ## Input
            % * __model__ name of the file where the model is stored.
            % * __howToGetFeatures__ optional name of MATLAB M-function that
            %       implements custom feature extractor. A helper function for
            %       training part of: "P. Dollar and C. L. Zitnick. Structured
            %       Forests for Fast Edge Detection, 2013". You need it only
            %       if you would like to train your own forest, otherwise
            %       leave it unspecified for the default implementation. See
            %       example below.
            %
            % ## Example
            % The following is an example of a custom feature extractor
            % MATLAB function:
            %
            %    % This function extracts feature channels from src. The
            %    % StructureEdgeDetection uses this feature space to detect
            %    % edges.
            %    function features = myRFFeatureGetter(src, opts)
            %        % src: source image to extract features
            %        % features: output n-channel floating-point feature matrix
            %        % opts: struct of options
            %        gnrmRad = opts.gradientNormalizationRadius;
            %        gsmthRad = opts.gradientSmoothingRadius;
            %        shrink = opts.shrinkNumber;
            %        outNum = opts.numberOfOutputChannels;
            %        gradNum = opts.numberOfGradientOrientations;
            %
            %        nsize = [size(src,1) size(src,2)] ./ shrink;
            %        features = zeros([nsize outNum], 'single');
            %        % ... here your feature extraction code
            %    end
            %
            % TODO: Custom extractor is not internally used in the current
            % cv.StructuredEdgeDetection implementation. See
            % http://docs.opencv.org/3.1.0/d2/d59/tutorial_ximgproc_training.html
            % for more information about training your own structured forest
            % (it uses an external MATLAB toolbox for the training part).
            %
            % See also: cv.StructuredEdgeDetection.detectEdges
            %
            this.id = StructuredEdgeDetection_(0, 'new', model, varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also: cv.StructuredEdgeDetection
            %
            if isempty(this.id), return; end
            StructuredEdgeDetection_(this.id, 'delete');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %    obj.clear()
            %
            % See also: cv.StructuredEdgeDetection.empty,
            %  cv.StructuredEdgeDetection.load
            %
            StructuredEdgeDetection_(this.id, 'clear');
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
            % See also: cv.StructuredEdgeDetection.clear,
            %  cv.StructuredEdgeDetection.load
            %
            b = StructuredEdgeDetection_(this.id, 'empty');
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
            % See also: cv.StructuredEdgeDetection.load
            %
            StructuredEdgeDetection_(this.id, 'save', filename);
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
            % See also: cv.StructuredEdgeDetection.save
            %
            StructuredEdgeDetection_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.StructuredEdgeDetection.save,
            %  cv.StructuredEdgeDetection.load
            %
            name = StructuredEdgeDetection_(this.id, 'getDefaultName');
        end
    end

    %% StructuredEdgeDetection
    methods
        function dst = detectEdges(this, src)
            %DETECTEDGES  The function detects edges in src and draw them to dst
            %
            %    dst = obj.detectEdges(src)
            %
            % ## Input
            % * __src__ source image (RGB, float, in [0;1]) to detect edges.
            %
            % ## Output
            % * __dst__ destination image (grayscale, float, in [0;1]) where
            %       edges are drawn.
            %
            % The algorithm underlies this function is much more robust to
            % texture presence, than common approaches, e.g. cv.Sobel.
            %
            % See also: cv.Sobel, cv.Canny
            %
            dst = StructuredEdgeDetection_(this.id, 'detectEdges', src);
        end
    end

end
