classdef TestBOWImgDescriptorExtractor
    %TestBOWImgDescriptorExtractor
    properties (Constant)
    end
    
    methods (Static)
        function test_1
            im = imread(fullfile(fileparts(fileparts(...
                mfilename('fullpath'))),'cat.jpg'));
            im = rgb2gray(im);
            kpts = cv.FAST(im);
            extractor = cv.DescriptorExtractor('SIFT');
            descs = extractor.compute(im,kpts);
            trainer = cv.BOWKMeansTrainer(100);
            vocab = trainer.cluster(descs);
            
            bowextractor = cv.BOWImgDescriptorExtractor('SIFT');
            bowextractor.setVocabulary(vocab);
            
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

