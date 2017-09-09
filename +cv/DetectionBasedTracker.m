classdef DetectionBasedTracker < handle
    %DETECTIONBASEDTRACKER  Detection-based tracker
    %
    % See also: cv.DetectionBasedTracker.DetectionBasedTracker
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    methods
        function this = DetectionBasedTracker(mainDetector, trackingDetector, varargin)
            %DETECTIONBASEDTRACKER  Creates a new tracker object
            %
            %     tracker = cv.DetectionBasedTracker(mainDetector, trackingDetector)
            %     tracker = cv.DetectionBasedTracker(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __mainDetector__, __trackingDetector__ detector of the form
            %   `{filename, 'key',val, ...}` where `filename` is the name of
            %   the file from which the classifier is loaded. See detection
            %   options below for valid key/value pairs. Currently only one
            %   detector based on cv.CascadeClassifier is supported.
            %
            % ## Options
            % * __MaxTrackLifetime__ must be non-negative. default 5
            % * __MinDetectionPeriod__ the minimal time between run of the big
            %   object detector (on the whole frame) in msec (1000 mean 1 sec).
            %   default 0
            %
            % ## CascadeClassifier detection options
            % * __ScaleFactor__ Parameter specifying how much the image size
            %   is reduced at each image scale. default 1.1
            % * __MinNeighbors__ Parameter specifying how many neighbors each
            %   candiate rectangle should have to retain it. default 2
            % * __MinSize__ Minimum possible object size. Objects smaller than
            %   that are ignored. default `[96,96]`.
            % * __MaxSize__ Maximum possible object size. Objects larger than
            %   that are ignored. default `[intmax,intmax]`.
            %
            % See also: cv.DetectionBasedTracker.process
            %
            this.id = DetectionBasedTracker_(0, 'new', mainDetector, trackingDetector, varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     tracker.delete()
            %
            % See also: cv.DetectionBasedTracker
            %
            if isempty(this.id), return; end
            DetectionBasedTracker_(this.id, 'delete');
        end

        function success = run(this)
            %RUN  Run tracker
            %
            %     success = tracker.run()
            %
            % ## Output
            % * __success__ success logical flag
            %
            % See also: cv.DetectionBasedTracker.stop
            %
            success = DetectionBasedTracker_(this.id, 'run');
        end

        function stop(this)
            %STOP  Stop tracker
            %
            %     tracker.stop()
            %
            % See also: cv.DetectionBasedTracker.run
            %
            DetectionBasedTracker_(this.id, 'stop');
        end

        function resetTracking(this)
            %RESETTRACKING  Reset tracker
            %
            %     tracker.resetTracking()
            %
            % See also: cv.DetectionBasedTracker.run
            %
            DetectionBasedTracker_(this.id, 'resetTracking');
        end

        function params = getParameters(this)
            %GETPARAMETERS  Get current tracker parameters
            %
            %     params = tracker.getParameters()
            %
            % ## Output
            % * __params__ a struct containing with the following fields:
            %   * __maxTrackLifetime__
            %   * __minDetectionPeriod__
            %
            % See also: cv.DetectionBasedTracker.setParameters
            %
            params = DetectionBasedTracker_(this.id, 'getParameters');
        end

        function success = setParameters(this, varargin)
            %SETPARAMETERS  Set current tracker parameters
            %
            %     success = tracker.setParameters('OptionName',optionValue, ...)
            %
            % ## Output
            % * __success__ success logical flag.
            %
            % ## Options
            % * __MaxTrackLifetime__ must be non-negative. default 5
            % * __MinDetectionPeriod__ the minimal time between run of the big
            %   object detector (on the whole frame) in msec (1000 mean 1 sec).
            %   default 0
            %
            % See also: cv.DetectionBasedTracker.getParameters
            %
            success = DetectionBasedTracker_(this.id, 'setParameters', varargin{:});
        end

        function process(this, imageGray)
            %PROCESS  Process new frame
            %
            %     tracker.process(imageGray)
            %
            % ## Input
            % * __imageGray__ 8-bit 1-channel gray image.
            %
            % See also: cv.DetectionBasedTracker.getObjects
            %
            DetectionBasedTracker_(this.id, 'process', imageGray);
        end

        function id = addObject(this, location)
            %ADDOBJECT  Track new object
            %
            %     tracker.addObject(location)
            %
            % ## Input
            % * __location__ rectangle containing object `[x,y,w,h]`.
            %
            % ## Output
            % * __id__ id of the new object.
            %
            % See also: cv.DetectionBasedTracker.getObjects
            %
            id = DetectionBasedTracker_(this.id, 'addObject', location);
        end

        function [boxes, ids] = getObjects(this)
            %GETOBJECTS  Return tracked objects
            %
            %     boxes = tracker.getObjects()
            %     [boxes, ids] = tracker.getObjects()
            %
            % ## Output
            % * __boxes__ Cell array of rectangles where each rectangle
            %   contains the detected object `{[x,y,w,h], ...}`.
            % * __ids__ optional vector of corresponding tracked object ID.
            %
            % See also: cv.DetectionBasedTracker.getObjectsExtended
            %
            if nargout > 1
                [boxes, ids] = DetectionBasedTracker_(this.id, 'getObjects');
            else
                boxes = DetectionBasedTracker_(this.id, 'getObjects');
            end
        end

        function objects = getObjectsExtended(this)
            %GETOBJECTSEXTENDED  Return tracked objects (extended)
            %
            %     objects = tracker.getObjectsExtended()
            %
            % ## Output
            % * __objects__ a struct-array of tracked objects with the
            %   following fields:
            %   * __id__ tracked object ID
            %   * __location__ rectangle contains the detected object
            %     `[x,y,w,h]`.
            %   * __status__ object status. One of the following strings:
            %     * __DetectedNotShownYet__
            %     * __Detected__
            %     * __DetectedTemporaryLost__
            %     * __WrongObject__
            %
            % See also: cv.DetectionBasedTracker.getObjects
            %
            objects = DetectionBasedTracker_(this.id, 'getObjectsExtended');
        end
    end

end
