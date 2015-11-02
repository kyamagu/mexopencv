classdef DescriptorMatcher < handle
    %DESCRIPTORMATCHER  Common interface for matching keypoint descriptors.
    %
    % Class for matching keypoint descriptors.
    %
    % Matchers of keypoint descriptors in OpenCV have wrappers with a common
    % interface that enables you to easily switch between different algorithms
    % solving the same problem. This section is devoted to matching
    % descriptors that are represented as vectors in a multidimensional space.
    % All objects that implement vector descriptor matchers inherit the
    % DescriptorMatcher interface.
    %
    % It has two groups of match methods: for matching descriptors of an image
    % with another image or with an image set.
    %
    % ## Example
    %
    %    X = rand(100,10);
    %    Y = rand(100,10);
    %    matcher = cv.DescriptorMatcher('BruteForce');
    %    matcher.add(X);
    %    matcher.train();  % Optional for BruteForce matcher
    %    matches = matcher.match(Y);
    %
    % See also: cv.DescriptorExtractor, cv.FeatureDetector, cv.drawMatches,
    %  matchFeatures
    %

    properties (SetAccess = private)
        id    % Object ID
        Type  % Type of the matcher
    end

    methods
        function this = DescriptorMatcher(matcherType, varargin)
            %DESCRIPTORMATCHER  Creates a descriptor matcher by name.
            %
            %    matcher = cv.DescriptorMatcher(type)
            %    matcher = cv.DescriptorMatcher(type, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __type__ In the first variant, it creates a descriptor matcher
            %       of a given type with the default parameters (using default
            %       constructor). The following types are recognized:
            %
            %       * __'BruteForce'__ (default) L2 distance
            %       * __'BruteForce-SL2'__ L2SQR distance
            %       * __'BruteForce-L1'__ L1 distance
            %       * __'BruteForce-Hamming'__, __'BruteForce-HammingLUT'__
            %       * __'BruteForce-Hamming(2)'__
            %       * __'FlannBased'__ Flann-based indexing
            %
            %       In the second variant, it creates a matcher of the given
            %       type using the specified parameters. The following
            %       descriptor matcher types are supported:
            %
            %       * __'BFMatcher'__ Brute-force descriptor matcher. For each
            %             descriptor in the first set, this matcher finds the
            %             closest descriptor in the second set by trying each
            %             one. This descriptor matcher supports masking
            %             permissible matches of descriptor sets.
            %       * __'FlannBasedMatcher'__ Flann-based descriptor matcher.
            %             This matcher trains `flann::Index_` on a train
            %             descriptor collection and calls its nearest search
            %             methods to find the best matches. So, this matcher
            %             may be faster when matching a large train collection
            %             than the brute force matcher. `FlannBasedMatcher`
            %             does not support masking permissible matches of
            %             descriptor sets because `flann::Index` does not
            %             support this.
            %
            % ## Options
            % The Brute-force matcher constructor (`BFMatcher`) accepts the
            % following options:
            %
            % * __NormType__ One of 'L1', 'L2' (default), 'Hamming', or
            %       'Hamming2'. See cv.DescriptorExtractor.defaultNorm.
            %       * `L1` and `L2` norms are preferable choices for cv.SIFT
            %         and cv.SURF descriptors.
            %       * `Hamming` should be used with cv.ORB, cv.BRISK and
            %         cv.BRIEF.
            %       * `Hamming2` should be used with cv.ORB when `WTA_K`
            %         equals 3 or 4 (see cv.ORB.WTA_K description).
            % * __CrossCheck__ If it is false, this is will be default
            %       `BFMatcher` behaviour when it finds the `k` nearest
            %       neighbors for each query descriptor. If `CrossCheck==true`,
            %       then the cv.DescriptorMatcher.knnMatch() method with `k=1`
            %       will only return pairs `(i,j)` such that for i-th query
            %       descriptor the j-th descriptor in the matcher's collection
            %       is the nearest and vice versa, i.e. the `BFMatcher` will
            %       only return consistent pairs. Such technique usually
            %       produces best results with minimal number of outliers when
            %       there are enough matches. This is alternative to the ratio
            %       test, used by *D. Lowe* in SIFT paper. default false
            %
            % The Flann-based matcher constructor (`FlannBasedMatcher`) takes
            % the following optional arguments:
            %
            % * __Index__ Type of indexer, default 'KDTree'. One of the below.
            %       Each index type takes optional arguments (see IndexParams
            %       options below). You can specify the indexer by a cell
            %       array that starts from the type name followed by option
            %       arguments: `{'Type', 'OptionName',optionValue, ...}`.
            %       * __'Linear'__     Brute-force matching, linear search
            %       * __'KDTree'__     Randomized kd-trees, parallel search
            %       * __'KMeans'__     Hierarchical k-means tree
            %       * __'HierarchicalClustering'__ Hierarchical index
            %       * __'Composite'__  Combination of KDTree and KMeans
            %       * __'LSH'__        multi-probe LSH
            %       * __'Autotuned'__  Automatic tuning to one of the above
            %                          (`Linear`, `KDTree`, `KMeans`)
            %       * __'Saved'__      Load saved index from a file
            %
            % * __Search__ Option in matching operation. Takes a cell
            %       array of option pairs:
            %     * __Checks__ The number of times the tree(s) in the index
            %           should be recursively traversed. A higher value for
            %           this parameter would give better search precision, but
            %           also take more time. If automatic configuration was
            %           used when the index was created, the number of checks
            %           required to achieve the specified precision was also
            %           computed, in which case this parameter is ignored.
            %           -1 for unlimited. default 32
            %     * __EPS__ search for eps-approximate neighbours. default 0
            %     * __Sorted__ only for radius search, require neighbours
            %           sorted by distance. default true
            %
            % ## IndexParams Options for `FlannBasedMatcher`
            %
            % The following are the options for FLANN indexers
            % (Fast Library for Approximate Nearest Neighbors):
            %
            % ### `Linear`
            % Linear index takes no options.
            %
            % ### `Saved`
            % Saved index takes only one argument specifying the filename.
            %
            % ### `KDTree` and `Composite`
            % * __Trees__ The number of parallel kd-trees to use. Good values
            %       are in the range [1..16]. default 4
            %
            % ### `KMeans` and `Composite`
            % * __Branching__ The branching factor to use for the hierarchical
            %       k-means tree. default 32
            % * __Iterations__ The maximum number of iterations to use in the
            %       k-means clustering stage when building the k-means tree.
            %       A value of -1 used here means that the k-means clustering
            %       should be iterated until convergence. default 11
            % * __CentersInit__ The algorithm to use for selecting the initial
            %       centers when performing a k-means clustering step. The
            %       possible values are (default is 'Random'):
            %       * __'Random'__   picks the initial cluster centers randomly
            %       * __'Gonzales'__ picks the initial centers using Gonzales
            %             algorithm
            %       * __'KMeansPP'__  picks the initial centers using the
            %             algorithm suggested in [ArthurKmeansPP2007]
            %       * __'Groupwise'__ chooses the initial centers in a way
            %             inspired by Gonzales (by Pierre-Emmanuel Viel).
            % * __CBIndex__ This parameter (cluster boundary index) influences
            %       the way exploration is performed in the hierarchical
            %       kmeans tree. When `CBIndex` is zero the next kmeans domain
            %       to be explored is choosen to be the one with the closest
            %       center. A value greater then zero also takes into account
            %       the size of the domain. default 0.2
            %
            % ### `HierarchicalClustering`
            % * __Branching__ same as above.
            % * __CentersInit__ same as above.
            % * __Trees__ same as above.
            % * __LeafSize__ maximum leaf size. default 100
            %
            % ### `LSH`
            % * __TableNumber__ The number of hash tables to use (usually
            %       between 10 and 30). default 20
            % * __KeySize__ The length of the key in the hash tables (usually
            %       between 10 and 20). default 15
            % * __MultiProbeLevel__ Number of levels to use in multi-probe
            %       (0 is regular LSH, 2 is recommended). default 0
            %
            % ### `Autotuned`
            % * __TargetPrecision__ Is a number between 0 and 1 specifying the
            %       percentage of the approximate nearest-neighbor searches
            %       that return the exact nearest-neighbor. Using a higher
            %       value for this parameter gives more accurate results, but
            %       the search takes longer. The optimum value usually depends
            %       on the application. default 0.8
            % * __BuildWeight__ Specifies the importance of the index build
            %       time raported to the nearest-neighbor search time. In some
            %       applications it is acceptable for the index build step to
            %       take a long time if the subsequent searches in the index
            %       can be performed very fast. In other applications it is
            %       required that the index be build as fast as possible even
            %       if that leads to slightly longer search times. default 0.01
            % * __MemoryWeight__ Is used to specify the tradeoff between time
            %       (index build time and search time) and memory used by the
            %       index. A value less than 1 gives more importance to the
            %       time spent and a value greater than 1 gives more
            %       importance to the memory usage. default 0
            % * __SampleFraction__ Is a number between 0 and 1 indicating what
            %       fraction of the dataset to use in the automatic parameter
            %       configuration algorithm. Running the algorithm on the full
            %       dataset gives the most accurate results, but for very
            %       large datasets can take longer than desired. In such case
            %       using just a fraction of the data helps speeding up this
            %       algorithm while still giving good approximations of the
            %       optimum parameters. default 0.1
            %
            % ## Example
            % For example, `KDTree` with tree size = 4 is specified by:
            %
            %    matcher = cv.DescriptorMatcher('FlannBasedMatcher', ...
            %        'Index',  {'KDTree', 'Trees', 4}, ...
            %        'Search', {'Sorted', true})
            %
            % Here is an example for loading a saved index:
            %
            %    matcher = cv.DescriptorMatcher('FlannBasedMatcher', ...
            %        'Index', {'Saved', '/path/to/saved/index.xml'})
            %
            % ## References:
            %
            % [ArthurKmeansPP2007]:
            % > Arthur and S. Vassilvitskii
            % > *"k-means++: the advantages of careful seeding"*,
            % > Proceedings of the eighteenth annual ACM-SIAM symposium
            % > on Discrete algorithms, 2007
            %
            % [LSH]:
            % > *Multi-Probe LSH: Efficient Indexing for High-Dimensional Similarity Search*
            % > by Qin Lv, William Josephson, Zhe Wang, Moses Charikar, Kai Li.,
            % > Proceedings of the 33rd International Conference on
            % > Very Large Data Bases (VLDB). Vienna, Austria. September 2007
            %
            % See also cv.DescriptorMatcher
            %
            if nargin < 1, matcherType = 'BruteForce'; end
            this.Type = matcherType;
            this.id = DescriptorMatcher_(0, 'new', matcherType, varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also: cv.DescriptorMatcher
            %
            DescriptorMatcher_(this.id, 'delete');
        end

        function typename = typeid(this)
            %TYPEID  Name of the C++ type (RTTI)
            %
            %    typename = obj.typeid()
            %
            % ## Output
            % * __typename__ Name of C++ type
            %
            typename = DescriptorMatcher_(this.id, 'typeid');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the train descriptor collection
            %
            %    matcher.clear()
            %
            % See also: cv.DescriptorMatcher.empty
            %
            DescriptorMatcher_(this.id, 'clear');
        end

        function status = empty(this)
            %EMPTY  Returns true if there are no train descriptors in the collection
            %
            %    status = matcher.empty()
            %
            % ## Output
            % * __status__ boolean status
            %
            % See also: cv.DescriptorMatcher.clear
            %
            status = DescriptorMatcher_(this.id, 'empty');
        end

        function save(this, filename)
            %SAVE  Saves the algorithm parameters to a file
            %
            %    obj.save(filename)
            %
            % ## Input
            % * __filename__ Name of the file to save to.
            %
            % This method stores the algorithm parameters in the specified
            % XML or YAML file.
            %
            % See also: cv.DescriptorMatcher.load
            %
            DescriptorMatcher_(this.id, 'save', filename);
        end

        function load(this, fname_or_str, varargin)
            %LOAD  Loads algorithm from a file or a string
            %
            %    obj.load(fname)
            %    obj.load(str, 'FromString',true)
            %    obj.load(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __fname__ Name of the file to read.
            % * __str__ String containing the serialized model you want to
            %       load.
            %
            % ## Options
            % * __ObjName__ The optional name of the node to read (if empty,
            %       the first top-level node will be used). default empty
            % * __FromString__ Logical flag to indicate whether the input is
            %       a filename or a string containing the serialized model.
            %       default false
            %
            % This method reads algorithm parameters from the specified XML or
            % YAML file (either from disk or serialized string). The previous
            % algorithm state is discarded.
            %
            % See also: cv.DescriptorMatcher.save
            %
            DescriptorMatcher_(this.id, 'load', fname_or_str, varargin{:});
        end

        function name = getDefaultName(this)
            %GETDEFAULTNAME  Returns the algorithm string identifier
            %
            %    name = obj.getDefaultName()
            %
            % ## Output
            % * __name__ This string is used as top level XML/YML node tag
            %       when the object is saved to a file or string.
            %
            % See also: cv.DescriptorMatcher.save, cv.DescriptorMatcher.load
            %
            name = DescriptorMatcher_(this.id, 'getDefaultName');
        end
    end

    %% DescriptorMatcher
    methods
        function status = isMaskSupported(this)
            %ISMASKSUPPORTED  Returns true if the descriptor matcher supports masking permissible matches
            %
            %    status = matcher.isMaskSupported()
            %
            % ## Output
            % * __status__ boolean status.
            %
            % Brute-force matchers support masking, while Flann-based matchers
            % do no support masking.
            %
            % See also: cv.DescriptorMatcher.match
            %
            status = DescriptorMatcher_(this.id, 'isMaskSupported');
        end

        function descriptors = getTrainDescriptors(this)
            %GETTRAINDESCRIPTORS  Returns the train descriptor collection
            %
            %    descriptors = matcher.getTrainDescriptors();
            %
            % ## Outpt
            % * __descriptors__ Set of train descriptors. A cell array of
            %       matrices.
            %
            % See also: cv.DescriptorMatcher.add
            %
            descriptors = DescriptorMatcher_(this.id, 'getTrainDescriptors');
        end

        function add(this, descriptors)
            %ADD  Adds descriptors to train a descriptor collection
            %
            %    matcher.add(descriptors)
            %
            % If the collection is not empty, the new descriptors are added
            % to existing train descriptors.
            %
            % ## Input
            % * __descriptors__ Descriptors to add. Each `descriptors{i}` is
            %       a set of descriptors from the same train image.
            %       Can be either a matrix or a cell array of matrices
            %       (matrices of type `uint8` or `single`)
            %
            % See also: cv.DescriptorMatcher.getTrainDescriptors
            %
            DescriptorMatcher_(this.id, 'add', descriptors);
        end

        function train(this)
            %TRAIN  Trains a descriptor matcher
            %
            %    matcher.train()
            %
            % Trains a descriptor matcher (for example, the flann index). In all
            % methods to match, the method `train()` is run every time before
            % matching. Some descriptor matchers (for example,
            % `BruteForceMatcher`) have an empty implementation of this method.
            % Other matchers really train their inner structures (for example,
            % `FlannBasedMatcher` trains `flann::Index`).
            %
            DescriptorMatcher_(this.id, 'train');
        end

        function matches = match(this, queryDescriptors, varargin)
            %MATCH  Finds the best match for each descriptor from a query set
            %
            %    matches = matcher.match(queryDescriptors, trainDescriptors)
            %    matches = matcher.match(queryDescriptors)
            %    [...] = matcher.match(..., 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __queryDescriptors__ Query set of descriptors.
            % * __trainDescriptors__ Train set of descriptors. This set is not
            %       added to the train descriptors collection stored in the
            %       class object.
            %
            % ## Output
            % * __matches__ Matches. If a query descriptor is masked out in
            %       `Mask`, no match is added for this descriptor. So,
            %       `matches` size may be smaller than the query descriptors
            %       count. A 1-by-N structure array with the following fields:
            %       * __queryIdx__ query descriptor index (zero-based index)
            %       * __trainIdx__ train descriptor index (zero-based index)
            %       * __imgIdx__ train image index (zero-based index)
            %       * __distance__ distance between descriptors (scalar)
            %
            % ## Options
            % * __Mask__ default empty
            %       * In the first form, mask specifying permissible matches
            %       between an input query and train matrices of descriptors.
            %       Matrix of size
            %       `[size(queryDescriptors,1),size(trainDescriptors,1)]`.
            %       * In the second form, set of masks. Each `masks{i}`
            %       specifies permissible matches between the input query
            %       descriptors and stored train descriptors from the i-th
            %       image `trainDescCollection{i}`. Cell array of length
            %       `length(trainDescriptors)`, each a matrix of size
            %       `[size(queryDescriptors,1),size(trainDescriptors{i},1)]`.
            %
            % In the first variant of this method, the train descriptors are
            % passed as an input argument. In the second variant of the
            % method, train descriptors collection that was set by
            % cv.DescriptorMatcher.add() is used. Optional mask (or masks) can
            % be passed to specify which query and training descriptors can be
            % matched. Namely, `queryDescriptors(i,:)` can be matched with
            % `trainDescriptors(j,:)` only if `mask(i,j)` is non-zero.
            %
            % See also: cv.DescriptorMatcher.knnMatch,
            %  cv.DescriptorMatcher.radiusMatch
            %
            matches = DescriptorMatcher_(this.id, 'match', queryDescriptors, varargin{:});
        end

        function matches = knnMatch(this, queryDescriptors, varargin)
            %KNNMATCH  Finds the k best matches for each descriptor from a query set
            %
            %    matches = matcher.knnMatch(queryDescriptors, trainDescriptors, k)
            %    matches = matcher.knnMatch(queryDescriptors, k)
            %    [...] = matcher.knnMatch(..., 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __queryDescriptors__ Query set of descriptors.
            % * __trainDescriptors__ Train set of descriptors. This set is not
            %       added to the train descriptors collection stored in the
            %       class object.
            % * __k__ Count of best matches found per each query descriptor or
            %       less if a query descriptor has less than `k` possible
            %       matches in total.
            %
            % ## Output
            % * __matches__ Matches. Each `matches{i}` is `k` or less matches
            %       for the same query descriptor. A cell array of length
            %       `size(queryDescriptors,1)`, each cell is a 1-by-(k or less)
            %       structure array that has the following fields:
            %       * __queryIdx__ query descriptor index (zero-based index)
            %       * __trainIdx__ train descriptor index (zero-based index)
            %       * __imgIdx__ train image index (zero-based index)
            %       * __distance__ distance between descriptors (scalar)
            %
            % ## Options
            % * __Mask__ default empty
            %       * In the first form, mask specifying permissible matches
            %       between an input query and train matrices of descriptors.
            %       Matrix of size
            %       `[size(queryDescriptors,1),size(trainDescriptors,1)]`.
            %       * In the second form, set of masks. Each `masks{i}`
            %       specifies permissible matches between the input query
            %       descriptors and stored train descriptors from the i-th
            %       image `trainDescCollection{i}`. Cell array of length
            %       `length(trainDescriptors)`, each a matrix of size
            %       `[size(queryDescriptors,1),size(trainDescriptors{i},1)]`.
            % * __CompactResult__ Parameter used when the mask (or masks) is
            %       not empty. If `CompactResult` is false, the `matches`
            %       vector has the same size as `queryDescriptors` rows. If
            %       `CompactResult` is true, the matches vector does not
            %       contain matches for fully masked-out query descriptors.
            %       default false
            %
            % This extended variant of cv.DescriptorMatcher.match() method
            % finds several best matches for each query descriptor. The
            % matches are returned in the distance increasing order. See
            % cv.DescriptorMatcher.match() for the details about query and
            % train descriptors.
            %
            % See also: cv.DescriptorMatcher.match,
            %  cv.DescriptorMatcher.radiusMatch, cv.batchDistance
            %
            matches = DescriptorMatcher_(this.id, 'knnMatch', ...
                queryDescriptors, varargin{:});
        end

        function matches = radiusMatch(this, queryDescriptors, varargin)
            %RADIUSMATCH  For each query descriptor, finds the training descriptors not farther than the specified distance
            %
            %    matches = matcher.radiusMatch(queryDescriptors, trainDescriptors, maxDistance)
            %    matches = matcher.radiusMatch(queryDescriptors, maxDistance)
            %    [...] = matcher.radiusMatch(..., 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __queryDescriptors__ Query set of descriptors.
            % * __trainDescriptors__ Train set of descriptors. This set is not
            %       added to the train descriptors collection stored in the
            %       class object.
            % * __maxDistance__ Threshold for the distance between matched
            %       descriptors. Distance here means metric distance (e.g.
            %       Hamming distance), not the distance between coordinates
            %       (which is measured in Pixels)!
            %
            % ## Output
            % * __matches__ Found matches. A cell array of length
            %       `size(queryDescriptors,1)`, each cell is a structure array
            %       that has the following fields:
            %       * __queryIdx__ query descriptor index (zero-based index)
            %       * __trainIdx__ train descriptor index (zero-based index)
            %       * __imgIdx__ train image index (zero-based index)
            %       * __distance__ distance between descriptors (scalar)
            %
            % ## Options
            % * __Mask__ default empty
            %       * In the first form, mask specifying permissible matches
            %       between an input query and train matrices of descriptors.
            %       Matrix of size
            %       `[size(queryDescriptors,1),size(trainDescriptors,1)]`.
            %       * In the second form, set of masks. Each `masks{i}`
            %       specifies permissible matches between the input query
            %       descriptors and stored train descriptors from the i-th
            %       image `trainDescCollection{i}`. Cell array of length
            %       `length(trainDescriptors)`, each a matrix of size
            %       `[size(queryDescriptors,1),size(trainDescriptors{i},1)]`.
            % * __CompactResult__ Parameter used when the mask (or masks) is
            %       not empty. If `CompactResult` is false, the `matches`
            %       vector has the same size as `queryDescriptors` rows. If
            %       `CompactResult` is true, the matches vector does not
            %       contain matches for fully masked-out query descriptors.
            %       default false
            %
            % For each query descriptor, the methods find such training
            % descriptors that the distance between the query descriptor and
            % the training descriptor is equal or smaller than `maxDistance`.
            % Found matches are returned in the distance increasing order.
            %
            % See also: cv.DescriptorMatcher.match,
            %  cv.DescriptorMatcher.knnMatch, cv.batchDistance
            %
            matches = DescriptorMatcher_(this.id, 'radiusMatch',...
                queryDescriptors, varargin{:});
        end
    end

end
