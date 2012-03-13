classdef BOWImgDescriptorExtractor < handle
    %BOWIMGDESCRIPTOREXTRACTOR Class to compute an image descriptor using the bag of visual words
    %
    % Class to compute an image descriptor using the bag of visual words.
    % Such a computation consists of the following steps:
    %
    %  1. Compute descriptors for a given image and its keypoints set.
    %  2. Find the nearest visual words from the vocabulary for each
    %     keypoint descriptor.
    %  3. Compute the bag-of-words image descriptor as is a normalized
    %     histogram of vocabulary words encountered in the image. The i-th
    %     bin of the histogram is a frequency of i-th word of the
    %     vocabulary in the given image.
    % 
    % The basic usage is the following:
    %
    %    trainer = cv.BOWKMeansTrainer();
    %    dictionary = trainer.cluster(train_descs);
    %    extractor = cv.BOWImgDescriptorExtractor('SIFT','BruteForce');
    %    extractor.setVocabulary(dictionary);
    %    descs = extractor.compute(im,keypoints);
    %
    % See also cv.BOWImgDescriptorExtractor.BOWImgDescriptorExtractor
    % cv.BOWKMeansTrainer
    %
    
    properties (SetAccess = private)
        % Object ID
        id
    end
    
    methods
        function this = BOWImgDescriptorExtractor(varargin)
            %BOWIMGDESCRIPTOREXTRACTOR Create a new BOWImgDescriptorExtractor
            %
            %    extractor = cv.BOWImgDescriptorExtractor(dextractor)
            %    extractor = cv.BOWImgDescriptorExtractor(dextractor,dmatcher)
            %
            % ## Input
            % * __dextractor__ Descriptor extractor that is used to compute
            %     descriptors for an input image and its keypoints. It can
            %     be spacified by a string specifying the type of
            %     descriptor extractor, such as 'SIFT' or 'SURF'. See
            %     cv.DescriptorExtractor for a possible type.
            % * __dmatcher__ Descriptor matcher that is used to find the
            %     nearest word of the trained vocabulary for each keypoint
            %     descriptor of the image. It can be spacified by a string
            %     specifying the type of descriptor extractor, such as
            %     'BruteForce' or 'BruteForce-L1'. See cv.DescriptorMatcher
            %     for a possible type. default 'BruteForce'
            %
            % ## Output
            % * __extractor__ Created BOWImgDescriptorExtractor object
            %
            % See also cv.BOWImgDescriptorExtractor
            %
            this.id = BOWImgDescriptorExtractor_(0, 'new', varargin{:});
        end
        
        function delete(this)
            %DELETE Destructor
            %
            % See also cv.BOWImgDescriptorExtractor
            %
            BOWImgDescriptorExtractor_(this.id, 'delete');
        end
        
        function setVocabulary(this, descs)
            %SETVOCABULARY Sets a visual vocabulary
            %
            %    extractor.setVocabulary(descs)
            %
            % ## Input
            % * __descs__ Vocabulary (can be trained using
            %     cv.BOWKMeansTrainer ). Each row of the vocabulary is a
            %     visual word (cluster center).
            %
            % See also cv.BOWImgDescriptorExtractor
            %
            BOWImgDescriptorExtractor_(this.id, 'setVocabulary', descs);
        end
        
        function s = getVocabulary(this)
            %GETVOCABULARY Returns the set vocabulary
            %
            %    s = extractor.getVocabulary()
            %
            % s is row vectors
            %
            % See also cv.BOWImgDescriptorExtractor
            %
            s = BOWImgDescriptorExtractor_(this.id, 'getVocabulary');
        end
        
        function s = descriptorSize(this)
            %DESCRIPTORSIZE Returns an image discriptor size if the vocabulary is set
            %
            %    s = extractor.descriptorSize()
            %
            % s is a numeric value.
            %
            % Returns an image discriptor size if the vocabulary is set.
            % Otherwise, it returns 0.
            %
            % See also cv.BOWImgDescriptorExtractor
            %
            s = BOWImgDescriptorExtractor_(this.id, 'descriptorSize');
        end
        
        function s = descriptorType(this)
            %DESCRIPTORTYPE Returns an image descriptor type
            %
            %    s = extractor.descriptorType()
            %
            % s is a numeric value.
            %
            % See also cv.BOWImgDescriptorExtractor
            %
            s = BOWImgDescriptorExtractor_(this.id, 'descriptorType');
        end
        
        function [bow,idx,descs] = compute(this, im, keypoints)
            %COMPUTE Computes an image descriptor using the set visual vocabulary
            %
            %    [bow,idx] = extractor.compute(im, keypoints)
            %
            % ## Input
            % * __im__ Image, for which the descriptor is computed.
            % * __keypoints__ Keypoints detected in the input image. It is
            %     a struct array that is returned by cv.FeatureDetector.
            %
            % ## Output
            % * __bow__ Computed output image descriptor.
            % * __idx__ Indices of keypoints that belong to the cluster.
            %     This means that idx(i) are keypoint indices that belong
            %     to the i-th cluster (word of vocabulary).
            %
            % See also cv.BOWImgDescriptorExtractor
            % cv.BOWImgDescriptorExtractor.setVocabulary
            %
            [bow,idx,descs] = BOWImgDescriptorExtractor_(this.id, 'compute', im, keypoints);
        end
    end
    
end

