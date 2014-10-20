classdef TestBOWImgDescriptorExtractor
    %TestBOWImgDescriptorExtractor
    properties (Constant)
    end

    methods (Static)
        function test_1
            im = imread(fullfile(mexopencv.root(),'test','cat.jpg'));
            im = rgb2gray(im);
            detector = cv.FeatureDetector('FAST');
            kpts = detector.detect(im);
            extractor = cv.DescriptorExtractor('BRIEF');
            descs = extractor.compute(im,kpts);
            trainer = cv.BOWKMeansTrainer(100);
            vocab = trainer.cluster(descs);

            bowextractor = cv.BOWImgDescriptorExtractor('BRIEF');
            bowextractor.setVocabulary(uint8(vocab));

            [bow,idx] = bowextractor.compute(im,kpts);
        end

        function test_error_1
            try
                cv.BOWImgDescriptorExtractor();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

