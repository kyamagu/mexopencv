classdef BOWKMeansTrainer < handle
    %BOWKMEANSTRAINER  kmeans-based class to train visual vocabulary using the bag of visual words approach
    %
    % kmeans-based class for training the *bag of visual words* vocabulary
    % from a set of descriptors.
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
    % ## References
    % > "Visual Categorization with Bags of Keypoints" by
    % > Gabriella Csurka, Christopher R. Dance, Lixin Fan, Jutta Willamowski,
    % > Cedric Bray, 2004.
    %
    % See also: cv.BOWKMeansTrainer.BOWKMeansTrainer,
    %  cv.BOWImgDescriptorExtractor, bagOfFeatures
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    methods
        function this = BOWKMeansTrainer(dictionarySize, varargin)
            %BOWKMEANSTRAINER  The constructor
            %
            %    trainer = cv.BOWKMeansTrainer(dictionarySize)
            %    [...] = cv.BOWKMeansTrainer(...,'OptionName', optionValue, ...)
            %
            % ## Input
            % * __dictionarySize__ Number of clusters.
            %
            % ## Options
            % * __Criteria__ The algorithm termination criteria, that is, the
            %       maximum number of iterations and/or the desired accuracy.
            %       The accuracy is specified as `Criteria.epsilon`. As soon
            %       as each of the cluster centers moves by less than
            %       `Criteria.epsilon` on some iteration, the algorithm stops.
            %       default `struct('type','Count+EPS', 'maxCount',100, 'epsilon',eps('float'))`
            % * __Attempts__ The number of times the algorithm is executed
            %       using different initial labelings. The algorithm returns
            %       the labels that yield the best compactness. default 3.
            % * __Initialization__ Method to initialize seeds, default 'PP'.
            %       One of the followings:
            %       * __'Random'__ Select random initial centers in each
            %             attempt.
            %       * __'PP'__  Use kmeans++ center initialization by
            %             Arthur and Vassilvitskii [Arthur2007].
            %
            % See also: cv.BOWKMeansTrainer, cv.kmeans
            %
            this.id = BOWKMeansTrainer_(0, 'new', dictionarySize, varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also: cv.BOWKMeansTrainer
            %
            BOWKMeansTrainer_(this.id, 'delete');
        end

        function descs = getDescriptors(this)
            %GETDESCRIPTORS  Returns a training set of descriptors
            %
            %    descs = trainer.getDescriptors()
            %
            % ## Output
            % * __descs__ a cell array of descriptors
            %
            % See also: cv.BOWKMeansTrainer.descriptorsCount
            %
            descs = BOWKMeansTrainer_(this.id, 'getDescriptors');
        end

        function count = descriptorsCount(this)
            %DESCRIPTORSCOUNT Returns the count of all descriptors stored in the training set
            %
            %    count = trainer.descriptorsCount()
            %
            % ## Output
            % * __count__ is a numeric value
            %
            % See also: cv.BOWKMeansTrainer.add
            %
            count = BOWKMeansTrainer_(this.id, 'descriptorsCount');
        end

        function add(this, descs)
            %ADD  Adds descriptors to a training set
            %
            %    trainer.add(descs)
            %
            % ## Input
            % * __descs__ Descriptors to add to a training set. Each row of
            %       the descriptors matrix is a descriptor.
            %
            % The training set is clustered using cluster method to construct
            % the vocabulary.
            %
            % See also: cv.BOWKMeansTrainer.cluster
            %
            BOWKMeansTrainer_(this.id, 'add', descs);
        end

        function clear(this)
            %CLEAR  Clear training descriptors
            %
            %    trainer.clear()
            %
            % See also: cv.BOWKMeansTrainer.add
            %
            BOWKMeansTrainer_(this.id, 'clear');
        end

        function centers = cluster(this, descs)
            %CLUSTER  Clusters train descriptors
            %
            %    centers = trainer.cluster()
            %    centers = trainer.cluster(descs)
            %
            % ## Input
            % * __descs__ Descriptors to cluster. Each row of the
            %     descriptors matrix is a descriptor. Descriptors are not
            %     added to the inner train descriptor set.
            %
            % ## Output
            % * __centers__ Row vectors of vocabulary descriptors.
            %
            % The vocabulary consists of cluster centers. So, this method
            % returns the vocabulary. In the first variant of the method,
            % train descriptors stored in the object are clustered. In the
            % second variant, input descriptors are clustered.
            %
            % See also: cv.BOWKMeansTrainer.add, cv.kmeans
            %
            if (nargin > 1)
                centers = BOWKMeansTrainer_(this.id, 'cluster', descs);
            else
                centers = BOWKMeansTrainer_(this.id, 'cluster');
            end
        end
    end

end

