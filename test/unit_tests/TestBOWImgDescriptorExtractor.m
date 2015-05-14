classdef TestBOWImgDescriptorExtractor
    %TestBOWImgDescriptorExtractor
    properties (Constant)
    end

    methods (Static)
        function test_1
            im = imread(fullfile(mexopencv.root(),'test','cat.jpg'));
            im = rgb2gray(im);
            detector = cv.FeatureDetector('FastFeatureDetector');
            kpts = detector.detect(im);
            extractor = cv.DescriptorExtractor('BRISK');
            descs = extractor.compute(im,kpts);
            trainer = cv.BOWKMeansTrainer(100);
            vocab = trainer.cluster(descs);

            bowextractor = cv.BOWImgDescriptorExtractor('BRISK');
            bowextractor.Vocabulary = uint8(vocab);

            [bow,idx] = bowextractor.compute(im,kpts);
        end

        function test_error_1
            try
                cv.BOWImgDescriptorExtractor('foo', 'bar');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

