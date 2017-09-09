classdef SelectiveSearchSegmentation < handle
    %SELECTIVESEARCHSEGMENTATION  Selective search segmentation algorithm
    %
    % The class implements the algorithm described in [uijlings2013selective].
    %
    % ## References
    % [uijlings2013selective]:
    % > Jasper RR Uijlings, Koen EA van de Sande, Theo Gevers, and Arnold WM
    % > Smeulders. "Selective search for object recognition". International
    % > journal of computer vision, 104(2):154-171, 2013.
    %
    % See also: cv.SelectiveSearchSegmentation.process
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    %% Constructor/destructor
    methods
        function this = SelectiveSearchSegmentation()
            %SELECTIVESEARCHSEGMENTATION  Constructor
            %
            %     obj = cv.SelectiveSearchSegmentation()
            %
            % See also: cv.SelectiveSearchSegmentation.process
            %
            this.id = SelectiveSearchSegmentation_(0, 'new');
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.SelectiveSearchSegmentation
            %
            if isempty(this.id), return; end
            SelectiveSearchSegmentation_(this.id, 'delete');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.SelectiveSearchSegmentation.empty,
            %  cv.SelectiveSearchSegmentation.load
            %
            SelectiveSearchSegmentation_(this.id, 'clear');
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
            % See also: cv.SelectiveSearchSegmentation.clear,
            %  cv.SelectiveSearchSegmentation.load
            %
            b = SelectiveSearchSegmentation_(this.id, 'empty');
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
            % See also: cv.SelectiveSearchSegmentation.load
            %
            SelectiveSearchSegmentation_(this.id, 'save', filename);
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
            % See also: cv.SelectiveSearchSegmentation.save
            %
            SelectiveSearchSegmentation_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.SelectiveSearchSegmentation.save,
            %  cv.SelectiveSearchSegmentation.load
            %
            name = SelectiveSearchSegmentation_(this.id, 'getDefaultName');
        end
    end

    %% SelectiveSearchSegmentation
    methods
        function setBaseImage(this, img)
            %SETBASEIMAGE  Set a image used by switch functions to initialize the class
            %
            %     obj.setBaseImage(img)
            %
            % ## Input
            % * __img__ The image.
            %
            % See also: cv.SelectiveSearchSegmentation.process
            %
            SelectiveSearchSegmentation_(this.id, 'setBaseImage', img);
        end

        function switchToSingleStrategy(this, varargin)
            %SWITCHTOSINGLESTRATEGY  Initialize the class with the 'Single strategy' parameters
            %
            %     obj.switchToSingleStrategy()
            %     obj.switchToSingleStrategy('OptionName',optionValue, ...)
            %
            % ## Options
            % * __K__ The k parameter for the graph segmentation. default 200
            % * __Sigma__ The sigma parameter for the graph segmentation.
            %   default 0.8
            %
            % As described in [uijlings2013selective].
            %
            % See also: cv.SelectiveSearchSegmentation.switchToSelectiveSearchFast
            %
            SelectiveSearchSegmentation_(this.id, 'switchToSingleStrategy', varargin{:});
        end

        function switchToSelectiveSearchFast(this, varargin)
            %SWITCHTOSELECTIVESEARCHFAST  Initialize the class with the 'Selective search fast' parameters
            %
            %     obj.switchToSelectiveSearchFast()
            %     obj.switchToSelectiveSearchFast('OptionName',optionValue, ...)
            %
            % ## Options
            % * __BaseK__ The k parameter for the first graph segmentation.
            %   default 150
            % * __IncK__ The increment of the k parameter for all graph
            %   segmentations. default 150
            % * __Sigma__ The sigma parameter for the graph segmentation.
            %   default 0.8
            %
            % As described in [uijlings2013selective].
            %
            % See also: cv.SelectiveSearchSegmentation.switchToSelectiveSearchQuality
            %
            SelectiveSearchSegmentation_(this.id, 'switchToSelectiveSearchFast', varargin{:});
        end

        function switchToSelectiveSearchQuality(this, varargin)
            %SWITCHTOSELECTIVESEARCHQUALITY  Initialize the class with the 'Selective search fast' parameters
            %
            %     obj.switchToSelectiveSearchQuality()
            %     obj.switchToSelectiveSearchQuality('OptionName',optionValue, ...)
            %
            % ## Options
            % * __BaseK__ The k parameter for the first graph segmentation.
            %   default 150
            % * __IncK__ The increment of the k parameter for all graph
            %   segmentations. default 150
            % * __Sigma__ The sigma parameter for the graph segmentation.
            %   default 0.8
            %
            % As described in [uijlings2013selective].
            %
            % See also: cv.SelectiveSearchSegmentation.switchToSingleStrategy
            %
            SelectiveSearchSegmentation_(this.id, 'switchToSelectiveSearchQuality', varargin{:});
        end

        function addImage(this, img)
            %ADDIMAGE  Add a new image in the list of images to process
            %
            %     obj.addImage(img)
            %
            % ## Input
            % * __img__ The image.
            %
            % See also: cv.SelectiveSearchSegmentation.clearImages
            %
            SelectiveSearchSegmentation_(this.id, 'addImage', img);
        end

        function clearImages(this)
            %CLEARIMAGES  Clear the list of images to process
            %
            %     obj.clearImages()
            %
            % See also: cv.SelectiveSearchSegmentation.addImage
            %
            SelectiveSearchSegmentation_(this.id, 'clearImages');
        end

        function addGraphSegmentation(this, varargin)
            %ADDGRAPHSEGMENTATION  Add a new graph segmentation in the list of graph segementations to process
            %
            %     obj.addGraphSegmentation()
            %     obj.addGraphSegmentation('OptionName',optionValue, ...)
            %
            % ## Options
            % * __Sigma__ The sigma parameter, used to smooth image.
            %   default 0.5
            % * __K__ The k parameter of the algorithm. default 300
            % * __MinSize__ The minimum size of segments. default 100
            %
            % See also: cv.SelectiveSearchSegmentation.clearGraphSegmentations,
            %  cv.GraphSegmentation
            %
            SelectiveSearchSegmentation_(this.id, 'addGraphSegmentation', varargin{:});
        end

        function clearGraphSegmentations(this)
            %CLEARGRAPHSEGMENTATIONS  Clear the list of graph segmentations to process
            %
            %     obj.clearGraphSegmentations()
            %
            % See also: cv.SelectiveSearchSegmentation.addGraphSegmentation,
            %  cv.GraphSegmentation
            %
            SelectiveSearchSegmentation_(this.id, 'clearGraphSegmentations');
        end

        function addStrategy(this, stype, varargin)
            %ADDSTRATEGY  Add a new strategy in the list of strategy to process
            %
            %     obj.addStrategy(stype)
            %     obj.addStrategy('Multiple', stype, stype, ...)
            %
            % ## Input
            % * __stype__ The strategy type for the selective search
            %   segmentation algorithm, one of:
            %   * __Color__ Color-based strategy.
            %   * __Size__ Size-based strategy.
            %   * __Texture__ Texture-based strategy.
            %   * __Fill__ Fill-based strategy.
            %   * __Multiple__ Regroup multiple strategies, where all
            %     sub-strategies have equal weights.
            %
            % The classes are implemented from the algorithm described in
            % [uijlings2013selective].
            %
            % See also: cv.SelectiveSearchSegmentation.clearStrategies
            %
            SelectiveSearchSegmentation_(this.id, 'addStrategy', stype, varargin{:});
        end

        function clearStrategies(this)
            %CLEARSTRATEGIES  Clear the list of strategy to process
            %
            %     obj.clearStrategies()
            %
            % See also: cv.SelectiveSearchSegmentation.addStrategy
            %
            SelectiveSearchSegmentation_(this.id, 'clearStrategies');
        end

        function rects = process(this)
            %PROCESSIMAGE  Based on all images, graph segmentations and stragies, computes all possible rects and return them
            %
            %     rects = obj.process()
            %
            % ## Output
            % * __rects__ The list of rects as a Nx4 numeric matrix
            %   `[x,y,w,h; ...]`. The first ones are more relevents than the
            %   lasts ones.
            %
            % See also: cv.SelectiveSearchSegmentation.setBaseImage
            %
            rects = SelectiveSearchSegmentation_(this.id, 'process');
        end
    end

end
