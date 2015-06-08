classdef BOWImgDescriptorExtractor < handle
    %BOWIMGDESCRIPTOREXTRACTOR Class to compute an image descriptor using the bag of visual words
    %
    % Such a computation consists of the following steps:
    %
    %  1. Compute descriptors for a given image and its keypoints set.
    %  2. Find the nearest visual words from the vocabulary for each keypoint
    %     descriptor.
    %  3. Compute the bag-of-words image descriptor as is a normalized
    %     histogram of vocabulary words encountered in the image. The i-th bin
    %     of the histogram is a frequency of i-th word of the vocabulary in
    %     the given image.
    % 
    % ## Example
    %
    %    trainer = cv.BOWKMeansTrainer(K);
    %    dictionary = trainer.cluster(train_descs);
    %    extractor = cv.BOWImgDescriptorExtractor('SIFT','BruteForce');
    %    extractor.setVocabulary(dictionary);
    %    descs = extractor.compute(im,keypoints);
    %
    % See also: cv.BOWKMeansTrainer
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % Visual vocabulary (can be trained using cv.BOWKMeansTrainer).
        % Each row of the vocabulary is a visual word (cluster center).
        Vocabulary
    end

    methods
        function this = BOWImgDescriptorExtractor(dextractor, dmatcher)
            %BOWIMGDESCRIPTOREXTRACTOR  The constructor
            %
            %    extractor = cv.BOWImgDescriptorExtractor(dextractor, dmatcher)
            %    extractor = cv.BOWImgDescriptorExtractor({dextractor, 'key',val,...}, {dmatcher, 'key',val,...})
            %
            % ## Input
            % * __dextractor__ Descriptor extractor that is used to compute
            %       descriptors for an input image and its keypoints. It can
            %       be specified by a string containing the type of
            %       descriptor extractor, such as 'SIFT' or 'SURF'. See
            %       cv.DescriptorExtractor for possible types.
            % * __dmatcher__ Descriptor matcher that is used to find the
            %       nearest word of the trained vocabulary for each keypoint
            %       descriptor of the image. It can be spacified by a string
            %       specifying the type of descriptor extractor, such as
            %       'BruteForce' or 'BruteForce-L1'. See cv.DescriptorMatcher
            %       for possible types. default 'BruteForce'
            %
            % ## Output
            % * __extractor__ Created BOWImgDescriptorExtractor object
            %
            % In the first variant, it creates descriptor extractor/matcher
            % of the given types using default parameters (by calling the
            % default constructors).
            %
            % In the second variant, it creates descriptor extractor/matcher
            % of the given types using the specified options.
            % Each algorithm type takes optional arguments. Each of the
            % extractor/matcher are specified by a cell-array that starts
            % with the type name followed by option arguments, as in:
            % `{'Type', 'OptionName',optionValue, ...}`.
            % Refer to the individual extractor/matcher functions to see a
            % list of possible options of each algorithm.
            %
            % ## Examples
            %
            %    % first variant
            %    extractor = cv.BOWImgDescriptorExtractor('ORB', 'BruteForce');
            %
            %    % second variant
            %    extractor = cv.BOWImgDescriptorExtractor(...
            %        {'FastFeatureDetector', 'Threshold',10}, ...
            %        {'BFMatcher', 'NormType','L2'});
            %
            % See also: cv.DescriptorExtractor, cv.DescriptorMatcher
            %
            if nargin < 2, dmatcher = 'BruteForce'; end
            this.id = BOWImgDescriptorExtractor_(0, 'new', dextractor, dmatcher);
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also cv.BOWImgDescriptorExtractor
            %
            BOWImgDescriptorExtractor_(this.id, 'delete');
        end

        function sz = descriptorSize(this)
            %DESCRIPTORSIZE  Returns image discriptor size
            %
            %    sz = extractor.descriptorSize()
            %
            % ## Output
            % * __sz__ Returns an image discriptor size if the vocabulary
            %       is set. Otherwise, it returns 0.
            %
            % See also cv.BOWImgDescriptorExtractor.descriptorType
            %
            sz = BOWImgDescriptorExtractor_(this.id, 'descriptorSize');
        end

        function dtype = descriptorType(this)
            %DESCRIPTORTYPE  Returns image descriptor type
            %
            %    dtype = extractor.descriptorType()
            %
            % ## Output
            % * __dtype__ Returns an image descriptor type, one of
            %       numeric MATLAB class names.
            %
            % See also cv.BOWImgDescriptorExtractor.descriptorSize
            %
            dtype = BOWImgDescriptorExtractor_(this.id, 'descriptorType');
        end

        function [bow,idx,descs] = compute(this, im, keypoints)
            %COMPUTE  Computes an image descriptor using the set visual vocabulary
            %
            %    [bow,idx,descs] = extractor.compute(im, keypoints)
            %
            % ## Input
            % * __im__ Image, for which the descriptor is computed.
            % * __keypoints__ Keypoints detected in the input image. It is
            %     a struct array that is returned by cv.FeatureDetector.
            %
            % ## Output
            % * __bow__ Computed output image descriptor.
            % * __idx__ Indices of keypoints that belong to the cluster. This
            %       means that `idx(i)` are keypoint indices that belong to
            %       the i-th cluster (word of vocabulary) returned if it is
            %       non-zero.
            % * __descs__ Descriptors of the image keypoints that are returned
            %       if they are non-zero.
            %
            % See also: cv.BOWImgDescriptorExtractor.compute2
            %
            [bow,idx,descs] = BOWImgDescriptorExtractor_(this.id, 'compute', im, keypoints);
        end

        function [bow,idx] = compute_(this, keypointDescriptors)
            %COMPUTE_  Computes an image descriptor using keypoint descriptors
            %
            %    [bow,idx] = extractor.compute_(keypointDescriptors)
            %
            % ## Input
            % * __keypointDescriptors__ Computed descriptors to match with
            %       vocabulary.
            %
            % ## Output
            % * __bow__ Computed output image descriptor.
            % * __idx__ Indices of keypoints that belong to the cluster. This
            %       means that `idx(i)` are keypoint indices that belong to
            %       the i-th cluster (word of vocabulary) returned if it is
            %       non-zero.
            %
            % See also: cv.BOWImgDescriptorExtractor.compute
            %
            [bow,idx] = BOWImgDescriptorExtractor_(this.id, 'compute', keypointDescriptors);
        end

        function bow = compute2(this, im, keypoints)
            %COMPUTE2  Computes an image descriptor using the set visual vocabulary
            %
            %    bow = extrctor.compute2(im, keypoints)
            %
            % ## Input
            % * __im__ Image, for which the descriptor is computed.
            % * __keypoints__ Keypoints detected in the input image. It is
            %     a struct array that is returned by cv.FeatureDetector.
            %
            % ## Output
            % * __bow__ Computed output image descriptor.
            %
            % See also: cv.BOWImgDescriptorExtractor.compute
            %
            bow = BOWImgDescriptorExtractor_(this.id, 'compute2', im, keypoints);
        end
    end

    methods
        function value = get.Vocabulary(this)
            value = BOWImgDescriptorExtractor_(this.id, 'get', 'Vocabulary');
        end
        function set.Vocabulary(this, value)
            BOWImgDescriptorExtractor_(this.id, 'set', 'Vocabulary', value);
        end
    end

end
