classdef BOWImgDescriptorExtractor < handle
    %BOWIMGDESCRIPTOREXTRACTOR  Class to compute an image descriptor using the bag of visual words
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
    %    % create bag of visual words
    %    trainer = cv.BOWKMeansTrainer(K);
    %    dictionary = trainer.cluster(train_descs);
    %
    %    % Compute histogram of visual word occurrences of an image
    %    extractor = cv.BOWImgDescriptorExtractor('SIFT','BruteForce');
    %    extractor.setVocabulary(dictionary);
    %    descs = extractor.compute(im, keypoints);
    %
    % See also: cv.BOWImgDescriptorExtractor.BOWImgDescriptorExtractor,
    %  cv.BOWKMeansTrainer, bagOfFeatures, trainImageCategoryClassifier,
    %  indexImages, retrieveImages
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % Visual vocabulary
        %
        % Vocabulary (can be trained using cv.BOWKMeansTrainer). Each row of
        % the vocabulary is a visual word (cluster center).
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
            %       cv.DescriptorExtractor.DescriptorExtractor for possible
            %       types.
            % * __dmatcher__ Descriptor matcher that is used to find the
            %       nearest word of the trained vocabulary for each keypoint
            %       descriptor of the image. It can be spacified by a string
            %       specifying the type of descriptor extractor, such as
            %       'BruteForce' or 'BruteForce-L1'. See
            %       cv.DescriptorMatcher.DescriptorMatcher for possible types.
            %       default 'BruteForce'
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
            % See also: cv.BOWImgDescriptorExtractor
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
            % This is basically `size(Vocabulary,1)` (i.e number of clusters).
            %
            % See also: cv.BOWImgDescriptorExtractor.descriptorType
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
            % Always `single` for BOWImgDescriptorExtractor.
            %
            % See also: cv.BOWImgDescriptorExtractor.descriptorSize,
            %  cv.DescriptorExtractor.descriptorType
            %
            dtype = BOWImgDescriptorExtractor_(this.id, 'descriptorType');
        end

        function [bow,idx,kptDescs] = compute(this, img, keypoints)
            %COMPUTE  Computes an image descriptor using the set visual vocabulary
            %
            %    [bow,idx,kptDescs] = extractor.compute(img, keypoints)
            %
            % ## Input
            % * __img__ Image, for which the descriptor is computed.
            % * __keypoints__ Keypoints detected in the input image. It is
            %       a struct array that is returned by
            %       cv.FeatureDetector.detect.
            %
            % ## Output
            % * __bow__ Computed output image descriptor. A vector of the same
            %       length as the vocabulary dimension.
            % * __idx__ Indices of keypoints that belong to the cluster. A
            %       cell array of integer vectors. This means that `idx{i}`
            %       are keypoint indices that belong to the i-th cluster
            %       (word of vocabulary).
            % * __kptDescs__ Descriptors of the image keypoints, as returned
            %       by cv.DescriptorExtractor.compute.
            %
            % See also: cv.BOWImgDescriptorExtractor.compute2,
            %  cv.BOWImgDescriptorExtractor.compute1
            %
            if nargout > 2
                [bow,idx,kptDescs] = BOWImgDescriptorExtractor_(this.id, 'compute', img, keypoints);
            elseif nargout > 1
                [bow,idx] = BOWImgDescriptorExtractor_(this.id, 'compute', img, keypoints);
            else
                bow = BOWImgDescriptorExtractor_(this.id, 'compute', img, keypoints);
            end
        end

        function [bow,idx] = compute1(this, kptDescs)
            %COMPUTE1  Computes an image descriptor using keypoint descriptors
            %
            %    [bow,idx] = extractor.compute1(kptDescs)
            %
            % ## Input
            % * __kptDescs__ Computed descriptors to match with vocabulary.
            %       It is a numeric matrix that is returned by
            %       cv.DescriptorExtractor.compute.
            %
            % ## Output
            % * __bow__ Computed output image descriptor. A vector of the same
            %       length as the vocabulary dimension.
            % * __idx__ Indices of keypoints that belong to the cluster. A
            %       cell array of integer vectors. This means that `idx{i}`
            %       are keypoint indices that belong to the i-th cluster
            %       (word of vocabulary).
            %
            % See also: cv.BOWImgDescriptorExtractor.compute
            %
            if nargout > 1
                [bow,idx] = BOWImgDescriptorExtractor_(this.id, 'compute1', kptDescs);
            else
                bow = BOWImgDescriptorExtractor_(this.id, 'compute1', kptDescs);
            end
        end

        function bow = compute2(this, img, keypoints)
            %COMPUTE2  Computes an image descriptor using the set visual vocabulary
            %
            %    bow = extrctor.compute2(img, keypoints)
            %
            % ## Input
            % * __img__ Image, for which the descriptor is computed.
            % * __keypoints__ Keypoints detected in the input image. It is
            %       a struct array that is returned by
            %       cv.FeatureDetector.detect.
            %
            % ## Output
            % * __bow__ Computed output image descriptor. A vector of the same
            %       length as the vocabulary dimension.
            %
            % See also: cv.BOWImgDescriptorExtractor.compute
            %
            bow = BOWImgDescriptorExtractor_(this.id, 'compute2', img, keypoints);
        end
    end

    %% Getters/Setters
    methods
        function value = get.Vocabulary(this)
            value = BOWImgDescriptorExtractor_(this.id, 'get', 'Vocabulary');
        end
        function set.Vocabulary(this, value)
            BOWImgDescriptorExtractor_(this.id, 'set', 'Vocabulary', value);
        end
    end

end
