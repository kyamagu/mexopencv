classdef TestDetectionBasedTracker
    %TestDetectionBasedTracker

    methods (Static)
        function test_1
            %TODO: untested
            if true
                disp('SKIP');
                return;
            end

            cascadeFile = fullfile(mexopencv.root(),'test','lbpcascade_frontalface.xml');
            tracker = cv.DetectionBasedTracker(cascadeFile, ...
                {cascadeFile, 'ScaleFactor',1.1}, 'MaxTrackLifetime',5);
            tracker.setParameters('MaxTrackLifetime',5);
            params = tracker.getParameters();
            validateattributes(params, {'struct'}, {'scalar'});
            assert(isequal(params.maxTrackLifetime, 5));

            success = tracker.run();
            validateattributes(success, {'logical'}, {'scalar'});
            assert(success);

            im = cv.imread(fullfile(mexopencv.root(),'test','lena.jpg'), ...
                'Grayscale',true);
            tracker.process(im);

            %TODO: hangs
            if false
                [rects,ids] = tracker.getObjects();
                if ~isempty(rects)
                    validateattributes(rects, {'cell'}, {'vector'});
                    cellfun(@(r) validateattributes(r, {'numeric'}, ...
                        {'vector', 'numel',4, 'integer'}), rects);
                    validateattributes(ids, {'numeric'}, ...
                        {'vector', 'numel',numel(rects), 'integer'});
                end
            end

            objs = tracker.getObjectsExtended();
            if ~isempty(objs)
                validateattributes(objs, {'struct'}, {'vector'});
                arrayfun(@(obj) validateattributes(obj.id, ...
                    {'numeric'}, {'scalar', 'integer'}), objs);
                arrayfun(@(obj) validateattributes(obj.location, ...
                    {'numeric'}, {'vector', 'numel',4, 'integer'}), objs);
                arrayfun(@(obj) validateattributes(obj.status, ...
                    {'char'}, {'row'}), objs);
            end

            %tracker.resetTracking();
            tracker.stop();
        end
    end

end
