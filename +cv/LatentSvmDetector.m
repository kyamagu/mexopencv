classdef LatentSvmDetector < handle
    %LATENTSVMDETECTOR Latent SVM detector
    %
    % See also cv.LatentSvmDetector.LatentSvmDetector
    % cv.LatentSvmDetector.detect
    %
    
    properties (SetAccess = private)
        % Object ID
        id
    end
    
    methods
        function this = LatentSvmDetector(varargin)
            %LATENTSVMDETECTOR Create or load a new detector
            %
            %    detector = cv.LatentSvmDetector()
            %    detector = cv.LatentSvmDetector(filenames)
            %    detector = cv.LatentSvmDetector(filenames, classnames)
            %
            % The constructor optionally takes the same argument to load
            % method.
            %
            % See also cv.LatentSvmDetector cv.LatentSvmDetector.load
            %
            this.id = LatentSvmDetector_(0, 'new');
            if nargin > 0, LatentSvmDetector_(this.id, 'load', varargin{:}); end
        end
        
        function delete(this)
            %DELETE Destructor
            %
            % See also cv.LatentSvmDetector
            %
            LatentSvmDetector_(this.id, 'delete');
        end
        
        function clear(this)
            %CLEAR Clear the detector
            %
            % See also cv.LatentSvmDetector
            %
            LatentSvmDetector_(this.id, 'clear');
        end
        
        function status = empty(this)
            %EMPTY Check if the detector is empty
            %
            % See also cv.LatentSvmDetector
            %
            status = LatentSvmDetector_(this.id, 'empty');
        end
        
        function names = getClassNames(this)
            %GETCLASSNAMES Get names of the object classes
            %
            %    names = detector.getClassNames()
            %
            % names is a cell array of strings
            %
            % See also cv.LatentSvmDetector
            %
            names = LatentSvmDetector_(this.id, 'getClassNames');
        end
        
        function s = getClassCount(this)
            %GETCLASSCOUNT Get size of the detector
            %
            %    s = detector.getClassCount()
            %
            % s is a numeric value
            %
            % See also cv.LatentSvmDetector
            %
            s = LatentSvmDetector_(this.id, 'getClassCount');
        end
        
        function status = load(this, filenames)
            %LOAD Loads a model from files
            %
            %    status = detector.load(filenames)
            %    status = detector.load(filenames, classnames)
            %
            % filenames is a string or a cell array of strings specifying
            % the location of model files. Optionally the method takes class
            % names as a cell array of strings that has the same size to
            % filenames. By default, class names are set to the name of the
            % file without xml extension. S is a logical value indicating
            % success of load when true.
            %
            % See also cv.LatentSvmDetector
            %
            status = LatentSvmDetector_(this.id, 'load', filenames);
        end
        
        function detections = detect(this, im, varargin)
            %DETECT Detects objects
            %
            %    detections = detector.detect(im, 'Option', optionValue, ...)
            %
            % ## Input
            % * __im__ Matrix of the type uint8 containing an image where
            %       objects are detected.
            %
            % ## Output
            % * __detections__ Struct array of detected objects. It has the
            %     following fields:
            %     * __rect__ rectangle [x,y,w,h] of the object
            %     * __score__ score of the detection
            %     * __class__ name of the object class
            % ## Options
            % * __OverlapThreshold__ Parameter to specify the threshold.
            %     default 0
            % * __NumThreads__ Number of parallel threads when OpenCV is
            %     built with TBB option. default -1
            %
            % See also cv.LatentSvmDetector
            %
            detections = LatentSvmDetector_(this.id, 'detect', im, varargin{:});
        end
        
    end
    
end

