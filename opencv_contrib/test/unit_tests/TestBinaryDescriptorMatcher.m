classdef TestBinaryDescriptorMatcher
    %TestBinaryDescriptorMatcher

    properties (Constant)
        fields = {'queryIdx', 'trainIdx', 'imgIdx', 'distance'};
    end

    methods (Static)
        function test_matcher
            %TODO: something in this test is causing memory corruption and
            %TODO: crashing MATLAB on repeated runs.. most likely an OpenCV bug!
            if true
                error('mexopencv:testskip', 'todo');
            end

            X = randi([0,255], [50,32], 'uint8');
            Y = randi([0,255], [10,32], 'uint8');
            matcher = cv.BinaryDescriptorMatcher();
            matcher.add(X);
            matcher.train();

            m = matcher.match(Y);
            validateattributes(m, {'struct'}, {'vector'});
            assert(all(ismember(TestBinaryDescriptorMatcher.fields, ...
                fieldnames(m))));

            k = 3;
            m = matcher.knnMatch(Y, k);
            validateattributes(m, {'cell'}, ...
                {'vector', 'numel',size(Y,1)});
            cellfun(@(mm) validateattributes(mm, {'struct'}, ...
                {'vector', 'numel',k}), m);
            cellfun(@(mm) assert(all(ismember(...
                TestBinaryDescriptorMatcher.fields, fieldnames(mm)))), m);

            maxDist = 125.0;
            m = matcher.radiusMatch(Y, maxDist);
            validateattributes(m, {'cell'}, ...
                {'vector', 'numel',size(Y,1)});
            cellfun(@(mm) validateattributes(mm, ...
                {'struct'}, {'vector'}), m);
            cellfun(@(mm) assert(all(ismember(...
                TestBinaryDescriptorMatcher.fields, fieldnames(mm)))), m);
            assert(all(cellfun(@(mm) all([mm.distance] <= maxDist), m)));
        end

        function test_matcher_mask
            X = randi([0,255], [50,32], 'uint8');
            Y = randi([0,255], [10,32], 'uint8');
            matcher = cv.BinaryDescriptorMatcher();
            mask = rand(size(Y,1), 1) > 0.5;

            m = matcher.match(Y, X, 'Mask',mask);
            validateattributes(m, {'struct'}, {'vector'});

            m = matcher.knnMatch(Y, X, 3, 'Mask',mask);
            validateattributes(m, {'cell'}, {'vector', 'numel',size(Y,1)});

            m = matcher.radiusMatch(Y, X, 2.0, 'Mask',mask);
            validateattributes(m, {'cell'}, {'vector', 'numel',size(Y,1)});
        end

        function test_closest_image
            %TODO: something in this test is causing memory corruption and
            %TODO: crashing MATLAB on repeated runs.. most likely an OpenCV bug!
            if true
                error('mexopencv:testskip', 'todo');
            end

            % compute descriptors for all training images
            obj = cv.BinaryDescriptor('NumOfOctave',1);
            matcher = cv.BinaryDescriptorMatcher();
            query = [];
            files = dir(fullfile(mexopencv.root(),'test','shape0*.png'));
            if isempty(files)
                error('mexopencv:testskip', 'missing data');
            end
            idxQuery = 1;
            idxTrain = 2:numel(files);
            for i=1:numel(files)
                img = cv.imread(fullfile(mexopencv.root(),'test',files(i).name), 'Flags',0);
                whos img
                [~,desc] = obj.detectAndCompute(img);
                assert(~isempty(desc));
                if i == idxQuery
                    query = desc;
                else
                    matcher.add(desc);
                end
            end

            % find matches between query and train set
            matcher.train();
            m = matcher.match(query);

            % naive approach to find nearest image
            [~,ord] = sort([m.distance]);         % retain best 100 (min dist)
            m = m(ord(1:min(10,end)));
            ii = idxTrain(mode([m.imgIdx]) + 1);  % most frequest image index
            query = files(idxQuery).name;
            closest = files(ii).name;
        end
    end

end
