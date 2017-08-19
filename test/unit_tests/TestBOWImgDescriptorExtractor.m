classdef TestBOWImgDescriptorExtractor
    %TestBOWImgDescriptorExtractor

    methods (Static)
        function test_1
            im = cv.imread(fullfile(mexopencv.root(),'test','cat.jpg'), 'Flags',0);
            obj = cv.KAZE();
            [kpts, descs] = obj.detectAndCompute(im);

            K = 50;
            trainer = cv.BOWKMeansTrainer(K);
            vocab = trainer.cluster(descs);

            bowextractor = cv.BOWImgDescriptorExtractor('KAZE', 'BruteForce');
            bowextractor.Vocabulary = vocab;
            assert(isequal(bowextractor.Vocabulary, vocab));

            assert(bowextractor.descriptorSize() == K);

            [bow,idx,d] = bowextractor.compute(im, kpts);
            validateattributes(bow, {bowextractor.descriptorType()}, ...
                {'vector', 'numel',K, 'real', '>=',0, '<=',1});
            validateattributes(d, {class(descs)}, {'size',size(descs)});
            validateattributes(idx, {'cell'}, {'vector'});
            cellfun(@(ind) validateattributes(ind, {'numeric'}, ...
                {'vector', 'integer', 'nonnegative', '<',numel(kpts)}), idx);
            %assert(all(sort([idx{:}] + 1) == 1:numel(kpts)));
            v = cellfun(@numel,idx) ./ numel(kpts);
            %assert(norm(v-bow) < 1e-6);

            [bow,idx] = bowextractor.compute1(descs);
            validateattributes(bow, {bowextractor.descriptorType()}, ...
                {'vector', 'numel',K});
            validateattributes(idx, {'cell'}, {'vector'});

            bow = bowextractor.compute2(im, kpts);
            validateattributes(bow, {bowextractor.descriptorType()}, ...
                {'vector', 'numel',K});
        end

        function test_2
            im = cv.imread(fullfile(mexopencv.root(),'test','cat.jpg'), 'Flags',0);
            detector = cv.FeatureDetector('FastFeatureDetector');
            kpts = detector.detect(im);
            extractor = cv.DescriptorExtractor('BRISK');
            descs = extractor.compute(im,kpts);

            K = 100;
            trainer = cv.BOWKMeansTrainer(K);
            vocab = trainer.cluster(descs);

            bowextractor = cv.BOWImgDescriptorExtractor(...
                'BRISK', 'BruteForce-Hamming');
            bowextractor.Vocabulary = uint8(vocab);

            [bow,idx] = bowextractor.compute(im,kpts);
            validateattributes(bow, {bowextractor.descriptorType()}, ...
                {'vector', 'numel',K, 'real', '>=',0, '<=',1});
            validateattributes(idx, {'cell'}, {'vector'});
            cellfun(@(ind) validateattributes(ind, {'numeric'}, ...
                {'vector', 'integer', 'nonnegative', '<',numel(kpts)}), idx);
        end

        function test_bow_image_classification
            % we load images from CVST toolbox
            if mexopencv.isOctave() || ~mexopencv.require('vision')
                error('mexopencv:testskip', 'toolbox');
            end

            % we use SURF from opencv_contrib/xfeatures2d
            opts = {'HessianThreshold',500, 'Upright',true};
            try
                obj = cv.SURF(opts{:});
            catch ME
                error('mexopencv:testskip', 'contrib');
            end

            % two categories with 12 images total: 6 books and 6 cups
            fpath = fullfile(toolboxdir('vision'),'visiondata','imageSets');
            files = cv.glob(fpath, 'Recursive',true);
            labels = int32(cellfun(@isempty, strfind(files(:), 'books')));
            testIdx = [1 numel(files)];                  % 2 test samples
            trainIdx = setdiff(1:numel(files), testIdx); % 10 training samples

            % create Bag of Words from training images
            K = 100;
            trainer = cv.BOWKMeansTrainer(K);
            for i=1:numel(trainIdx)
                img = cv.imread(files{trainIdx(i)}, 'Grayscale',true, 'ReduceScale',4);
                [~, descs] = obj.detectAndCompute(img);
                trainer.add(descs);
            end
            vocab = trainer.cluster();

            % use BOW model to encode all images into feature vectors
            bowextractor = cv.BOWImgDescriptorExtractor(['SURF', opts], 'BruteForce');
            bowextractor.Vocabulary = vocab;
            data = zeros([numel(files), bowextractor.descriptorSize()], ...
                bowextractor.descriptorType());
            for i=1:numel(files)
                img = cv.imread(files{i}, 'Grayscale',true, 'ReduceScale',4);
                kpts = obj.detect(img);
                data(i,:) = bowextractor.compute2(img, kpts);
            end

            % train a supervised SVM classifier on training set
            model = cv.SVM();
            model.KernelType = 'Linear';
            model.train(data(trainIdx,:), labels(trainIdx));

            % use it to classify test images
            Yhat = model.predict(data(testIdx,:));
            acc = nnz(Yhat == labels(testIdx)) / numel(testIdx);
        end

        function test_error_argnum
            try
                cv.BOWImgDescriptorExtractor();
                throw('UnitTest:Fail');
            catch ME
                %TODO: MATLAB/Octave specific error id
                %assert(strcmp(ME.identifier, 'MATLAB:minrhs'));
            end
        end
    end

end
