classdef CascadeClassifier < handle
    %CASCADECLASSIFIER  Haar Feature-based Cascade Classifier for Object Detection
    %
    % The object detector described below has been initially proposed by
    % Paul Viola [Viola01] and improved by Rainer Lienhart [Lienhart02].
    % 
    % The usage example is shown in the following:
    %
    %    filename = 'haarcascades/haarcascade_frontalface_alt.xml';
    %    cls = cv.CascadeClassifier(filename);
    %    boxes = cls.detect(im);
    %
    % See also cv.CascadeClassifier.CascadeClassifier
    % cv.CascadeClassifier.empty cv.CascadeClassifier.load
    % cv.CascadeClassifier.detect
    %
    
    properties (SetAccess = private)
        % Object ID
        id
    end
    
    methods
        function this = CascadeClassifier(filename)
            %CASCADECLASSIFIER  Loads a classifier from a file
            %
            %    classifier = cv.CascadeClassifier(filename)
            %
            % filename specifies an XML file containing trained classifier.
            %
            % See also cv.CascadeClassifier
            %
            this.id = CascadeClassifier_(filename);
        end
        
        function delete(this)
            %DELETE  Destructor
            %
            % See also cv.CascadeClassifier
            %
            CascadeClassifier_(this.id, 'delete');
        end
        
        function status = empty(this)
            %EMPTY  Checks whether the classifier has been loaded
            %
            %    S = classifier.load(filename)
            %
            % S is a logical value indicating empty object when true
            %
            % See also cv.CascadeClassifier
            %
            status = CascadeClassifier_(this.id, 'empty');
        end
        
        function status = load(this, filename)
            %LOAD  Loads a classifier from a file
            %
            %    S = classifier.load(filename)
            %
            % S is a logical value indicating success of load when true
            %
            % See also cv.CascadeClassifier
            %
            status = CascadeClassifier_(this.id, 'load', filename);
        end
        
        function boxes = detect(this, im, varargin)
            %DETECT Detects objects of different sizes in the input image.
            %
            %    boxes = classifier.detect(im, 'Option', optionValue, ...)
            %
            % The detected objects are returned as a cell array of rectangles.
            %
            % ## Input
            % * __im__ Matrix of the type uint8 containing an image where
            %       objects are detected.
            %
            % ## Output
            % * __boxes__ Cell array of rectangles where each rectangle
            %       contains the detected object.
            %
            % ## Options
            % * __ScaleFactor__ Parameter specifying how much the image size
            %       is reduced at each image scale.
            % * __MinNeighbors__ Parameter specifying how many neighbors
            %       each candiate rectangle should have to retain it.
            % * __MinSize__ Minimum possible object size. Objects smaller
            %       than that are ignored.
            % * __MaxSize__ Maximum possible object size. Objects larger
            %       than that are ignored.
            %
            % See also cv.CascadeClassifier
            %
            boxes = CascadeClassifier_(this.id, 'detectMultiScale', im, varargin{:});
        end
    end
    
end

