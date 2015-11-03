classdef TestDescriptorMatcher
    %TestDescriptorMatcher
    properties (Constant)
        fields = {'queryIdx', 'trainIdx', 'imgIdx', 'distance'};
    end

    methods (Static)
        function test_1
            X = randn(50,3);
            Y = randn(10,3);
            matchers = { ...
                cv.DescriptorMatcher('BruteForce'), ...
                cv.DescriptorMatcher('BruteForce-L1'), ...
                cv.DescriptorMatcher('BruteForce-SL2'), ...
                cv.DescriptorMatcher('FlannBased'), ...
                cv.DescriptorMatcher('BFMatcher', ...
                    'NormType','L2', 'CrossCheck',false), ...
                cv.DescriptorMatcher('FlannBasedMatcher', ...
                    'Index',  {'KDTree', 'Trees',4}, ...
                    'Search', {'Checks',32, 'EPS',0, 'Sorted',true})
            };
            for i = 1:numel(matchers)
                typename = matchers{i}.typeid();
                matchers{i}.add(X);
                matchers{i}.train();

                m = matchers{i}.match(Y);
                validateattributes(m, {'struct'}, {'vector'});
                assert(all(ismember(TestDescriptorMatcher.fields, ...
                    fieldnames(m))));

                k = 3;
                m = matchers{i}.knnMatch(Y, k);
                validateattributes(m, {'cell'}, {'vector', 'numel',size(Y,1)});
                cellfun(@(mm) validateattributes(mm, {'struct'}, ...
                    {'vector', 'numel',k}), m);
                cellfun(@(mm) assert(all(ismember(...
                    TestDescriptorMatcher.fields, fieldnames(mm)))), m);

                maxDist = 2.0;
                m = matchers{i}.radiusMatch(Y, maxDist);
                validateattributes(m, {'cell'}, {'vector', 'numel',size(Y,1)});
                cellfun(@(mm) validateattributes(mm, ...
                    {'struct'}, {'vector'}), m);
                cellfun(@(mm) assert(all(ismember(...
                    TestDescriptorMatcher.fields, fieldnames(mm)))), m);
                assert(all(cellfun(@(mm) all([mm.distance] <= maxDist), m)));
            end
        end

        function test_2
            X = randi([0,255], [50,3], 'uint8');
            Y = randi([0,255], [10,3], 'uint8');
            matchers = { ...
                cv.DescriptorMatcher('BruteForce-Hamming'), ...
                cv.DescriptorMatcher('BruteForce-HammingLUT'), ...
                ... cv.DescriptorMatcher('BruteForce-Hamming(2)')  %TODO
            };
            for i = 1:numel(matchers)
                typename = matchers{i}.typeid();
                matchers{i}.add(X);
                matchers{i}.train();

                m = matchers{i}.match(Y);
                validateattributes(m, {'struct'}, {'vector'});
                assert(all(ismember(TestDescriptorMatcher.fields, ...
                    fieldnames(m))));

                k = 3;
                m = matchers{i}.knnMatch(Y, k);
                validateattributes(m, {'cell'}, ...
                    {'vector', 'numel',size(Y,1)});
                cellfun(@(mm) validateattributes(mm, {'struct'}, ...
                    {'vector', 'numel',k}), m);
                cellfun(@(mm) assert(all(ismember(...
                    TestDescriptorMatcher.fields, fieldnames(mm)))), m);

                maxDist = 10.0;
                m = matchers{i}.radiusMatch(Y, maxDist);
                validateattributes(m, {'cell'}, ...
                    {'vector', 'numel',size(Y,1)});
                cellfun(@(mm) validateattributes(mm, ...
                    {'struct'}, {'vector'}), m);
                cellfun(@(mm) assert(all(ismember(...
                    TestDescriptorMatcher.fields, fieldnames(mm)))), m);
                assert(all(cellfun(@(mm) all([mm.distance] <= maxDist), m)));
            end
        end

        function test_3
            X = randn(50,3);
            Y = randn(10,3);
            matcher = cv.DescriptorMatcher('BruteForce');
            assert(matcher.isMaskSupported());
            mask = rand(size(Y,1), size(X,1)) > 0.5;
            m = matcher.match(Y, X, 'Mask',mask);
            validateattributes(m, {'struct'}, {'vector'});
            m = matcher.knnMatch(Y, X, 3, 'Mask',mask);
            validateattributes(m, {'cell'}, {'vector', 'numel',size(Y,1)});
            m = matcher.radiusMatch(Y, X, 2.0, 'Mask',mask);
            validateattributes(m, {'cell'}, {'vector', 'numel',size(Y,1)});
        end

        function test_4
            % compute descriptors for all training images
            obj = cv.KAZE();
            matcher = cv.DescriptorMatcher('BruteForce');
            query = [];
            files = dir(fullfile(mexopencv.root(),'test','shape0*.png'));
            if isempty(files)
                disp('SKIP');
                return;
            end
            idxQuery = 1;
            idxTrain = 2:numel(files);
            for i=1:numel(files)
                img = cv.imread(fullfile(mexopencv.root(),'test',files(i).name), 'Flags',0);
                [~,desc] = obj.detectAndCompute(img);
                assert(~isempty(desc));
                if i == idxQuery
                    query = desc;
                else
                    matcher.add(desc);
                end
            end

            D = matcher.getTrainDescriptors();
            validateattributes(D, {'cell'}, ...
                {'vector', 'numel',numel(idxTrain)});
            cellfun(@(desc) validateattributes(desc, ...
                {obj.descriptorType()}, ...
                {'size',[NaN obj.descriptorSize()]}), D);

            % find matches between query and train set
            matcher.train();
            m = matcher.match(query);

            % naive approach to find nearest image
            [~,ord] = sort([m.distance]);         % retain best 100 (min dist)
            m = m(ord(1:min(100,end)));
            ii = idxTrain(mode([m.imgIdx]) + 1);  % most frequest image index
            query = files(idxQuery).name;
            closest = files(ii).name;
        end
    end

end
