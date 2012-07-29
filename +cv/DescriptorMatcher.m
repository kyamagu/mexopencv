classdef DescriptorMatcher < handle
    %DESCRIPTORMATCHER  DescriptorMatcher class
    %
    % Descriptor matcher class. Basic usage is the following:
    %
    %    X = rand(100,10);
    %    Y = rand(100,10);
    %    matcher = cv.DescriptorMatcher('BruteForce');
    %    matcher.add(X);
    %    matcher.train(); % Optional for BruteForce matcher
    %    matches = matcher.match(Y);
    %
    % The following matcher types are supported:
    %
    %     'BruteForce'             L2 distance
    %     'BruteForce-L1'          L1 distance
    %     'BruteForce-Hamming'     Hamming distance
    %     'BruteForce-HammingLUT'  Hamming distance lookup table
    %     'FlannBased'             Flann-based indexing
    %
    % See the constructor help for a detail of how to specify types.
    %
    % See also cv.DescriptorMatcher.DescriptorMatcher cv.DescriptorExtractor
    %
    
    properties (SetAccess = private)
        % Object ID
        id
    end
    
    properties (SetAccess = private, Dependent)
        % Type of the detector
        type
    end
    
    methods
        function this = DescriptorMatcher(type, varargin)
            %DESCRIPTORMATCHER  DescriptorMatcher constructors
            %
            %    matcher = cv.DescriptorMatcher(type)
            %    matcher = cv.DescriptorMatcher('FlannBased', 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __type__ Type of the detector. see below. default 'BruteForce'
            %
            % ## Output
            % * __matcher__ New instance of the DescriptorMatcher
            %
            % The following matcher types are supported:
            %
            %     'BruteForce'             L2 distance
            %     'BruteForce-L1'          L1 distance
            %     'BruteForce-Hamming'     Hamming distance
            %     'BruteForce-HammingLUT'  Hamming distance lookup table
            %     'FlannBased'             Flann-based indexing
            %
            % The FlannBased matcher takes optional arguments
            %
            % * __Index__ Type of indexer. One of the below. 
            %     Each index type takes optional arguments. You can
            %     specify the indexer by a cell array that starts
            %     from the type name followed by option arguments:
            %     `{'Type', 'OptionName', optionValue,...}`
            %     * 'Linear'     Brute-force matching
            %     * 'KDTree'     Randomized kd-trees
            %     * 'KMeans'     Hierarchical k-means tree
            %     * 'Composite'  Combination of KDTree and KMeans
            %     * 'Autotuned'  Automatic tuning to one of the above
            %     * 'Saved'      Load saved index from a file
            % * __Search__ Option in matching operation. Takes a cell
            %     array of option pairs.
            %
            % For example, KDTree with tree size=4 is specified by:
            %
            %    matcher = cv.DescriptorMatcher('FlannBased',...
            %        'Index',  {'KDTree', 'Trees', 4},...
            %        'Search', {'Sorted', true})
            %
            % Options for FlannBased indexers are the following:
            %
            % ### KDTree and Composite
            % * __Trees__ The number of parallel kd-trees to use. Good
            %        values are in the range [1..16]. default 4
            %
            % ### KMeans and Composite
            % * __Branching__ The branching factor to use for the
            %        hierarchical k-means tree. default 32
            % * __Iterations__ The maximum number of iterations to use in
            %        the k-means clustering stage when building the k-means
            %        tree. A value of -1 used here means that the k-means
            %        clustering should be iterated until convergenceThe
            %        maximum number of iterations to use in the k-means
            %        clustering stage when building the k-means tree. A
            %        value of -1 used here means that the k-means
            %        clustering should be iterated until convergence.
            %        default 11
            % * __CentersInit__ The algorithm to use for selecting the
            %        initial centers when performing a k-means clustering
            %        step. The possible values are:
            %        `'Random'`    picks the initial cluster centers
            %                      randomly
            %        `'Gonzales'`  picks the initial centers using Gonzales
            %                      algorithm
            %        `'KMeansPP'`  picks the initial centers using the
            %                      algorithm suggested in arthur kmeanspp
            %                      2007
            %        default `'Random'`
            % * __CBIndex__ This parameter (cluster boundary index)
            %        influences the way exploration is performed in the
            %        hierarchical kmeans tree. When CBIndex is zero the
            %        next kmeans domain to be explored is choosen to be the
            %        one with the closest center. A value greater then zero
            %        also takes into account the size of the domain.
            %        default 0.2
            %
            % ### Autotuned
            % * __TargetPrecision__ Is a number between 0 and 1 specifying
            %        the percentage of the approximate nearest-neighbor
            %        searches that return the exact nearest-neighbor. Using
            %        a higher value for this parameter gives more accurate
            %        results, but the search takes longer. The optimum
            %        value usually depends on the application. default 0.9
            % * __BuildWeight__ Specifies the importance of the index build
            %        time raported to the nearest-neighbor search time. In
            %        some applications it?s acceptable for the index build
            %        step to take a long time if the subsequent searches in
            %        the index can be performed very fast. In other
            %        applications it?s required that the index be build as
            %        fast as possible even if that leads to slightly longer
            %        search times. default 0.01
            % * __MemoryWeight__ Is used to specify the tradeoff between
            %        time (index build time and search time) and memory
            %        used by the index. A value less than 1 gives more
            %        importance to the time spent and a value greater than
            %        1 gives more importance to the memory usage. default 0
            % * __SampleFraction__ Is a number between 0 and 1 indicating
            %        what fraction of the dataset to use in the automatic
            %        parameter configuration algorithm. Running the
            %        algorithm on the full dataset gives the most accurate
            %        results, but for very large datasets can take longer
            %        than desired. In such case using just a fraction of
            %        the data helps speeding up this algorithm while still
            %        giving good approximations of the optimum parameters.
            %        default 0.1
            %
            % ### Saved
            % Saved index takes only one argument specifing filename:
            %    
            %    cv.DescriptorMatcher('FlannBased',...
            %        'Index', {'Saved', '/path/to/saved/index.xml')}
            %
            % ### Search
            % * __Checks__ default 32
            % * __EPS__ default 0
            % * __Sorted__ default false
            %
            % See also cv.DescriptorMatcher
            %
            if nargin < 1, type = 'BruteForce'; end
            if ~ischar(type)
                error('DescriptorMatcher:error','Invalid type');
            end
            this.id = DescriptorMatcher_(0,'new',type,varargin{:});
        end
        
        function delete(this)
            %DELETE  DescriptorMatcher destructor
            %
            % See also cv.DescriptorMatcher
            %
            DescriptorMatcher_(this.id, 'delete');
        end
        
        function t = get.type(this)
            %TYPE  DescriptorMatcher type
            t = DescriptorMatcher_(this.id, 'type');
        end
        
        function add(this, descriptors)
            %ADD  Adds descriptors to train a descriptor collection
            %
            %    matcher.add(descriptors)
            %
            % If the collection trainDescCollectionis is not empty, the new
            % descriptors are added to existing train descriptors.
            %
            DescriptorMatcher_(this.id, 'add', descriptors);
        end
        
        function descriptors = getTrainDescriptors(this)
            %GETTRAINDESCRIPTORS  Returns a constant link to the train descriptor collection trainDescCollection
            %
            descriptors = DescriptorMatcher_(this.id, 'getTrainDescriptors');
        end
        
        function clear(this)
            %CLEAR  Clears the train descriptor collection
            %
            %    matcher.clear()
            %
            DescriptorMatcher_(this.id, 'clear');
        end
        
        function status = empty(this)
            %EMPTY  Returns true if there are no train descriptors in the collection
            %
            %    matcher.empty()
            %
            status = DescriptorMatcher_(this.id, 'empty');
        end
        
        function status = isMaskSupported(this)
            %ISMASKSUPPORTED  Returns true if the descriptor matcher supports masking permissible matches
            %
            status = DescriptorMatcher_(this.id, 'isMaskSupported');
        end
        
        function train(this)
            %TRAIN  Trains a descriptor matcher
            %
            %    matcher.train()
            %
            % Trains a descriptor matcher (for example, the flann index). In all
            % methods to match, the method train() is run every time before
            % matching. Some descriptor matchers (for example,
            % BruteForceMatcher) have an empty implementation of this method.
            % Other matchers really train their inner structures (for example,
            % FlannBasedMatcher trains flann::Index).
            %
            DescriptorMatcher_(this.id, 'train');
        end
        
        function matches = match(this, queryDescriptors, varargin)
            %MATCH  Finds the best match for each descriptor from a query set
            %
            %    matches = matcher.match(queryDescriptors)
            %    matches = matcher.match(queryDescriptors, trainDescriptors)
            %    [...] = matcher.match(..., 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __queryDescriptors__ Query set of descriptors.
            % * __trainDescriptors__ Train set of descriptors. This set is not
            %       added to the train descriptors collection stored in the
            %       class object.
            %
            % ## Output
            % * __matches__ Matches. If a query descriptor is masked out in mask,
            %       no match is added for this descriptor. So, matches size may
            %       be smaller than the query descriptors count.
            %
            % ## Options
            %   'Mask' Mask specifying permissible matches between an input
            %       query and train matrices of descriptors.
            %
            matches = DescriptorMatcher_(this.id, 'match', queryDescriptors, varargin{:});
        end
        
        function matches = knnMatch(this, queryDescriptors, varargin)
            %KNNMATCH  Finds the k best matches for each descriptor from a query set
            %
            %    matches = matcher.knnMatch(queryDescriptors, k)
            %    matches = matcher.knnMatch(queryDescriptors, trainDescriptors, k)
            %    [...] = matcher.knnMatch(..., 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __queryDescriptors__ Query set of descriptors.
            % * __trainDescriptors__ Train set of descriptors. This set is not
            %       added to the train descriptors collection stored in the
            %       class object.
            % * __k__ Count of best matches found per each query descriptor or less
            %       if a query descriptor has less than k possible matches in
            %       total
            %
            % ## Output
            % * __matches__ Matches. Each matches{i} is k or less matches for the
            %       same query descriptor.
            %
            % ## Options
            % * __Mask__ Mask specifying permissible matches between an input
            %       query and train matrices of descriptors.
            % * __CompactResult__ Parameter used when the mask (or masks) is not
            %       empty. If compactResult is false, the matches vector has the
            %       same size as queryDescriptors rows. If compactResult is
            %       true, the matches vector does not contain matches for fully
            %       masked-out query descriptors.
            %
            matches = DescriptorMatcher_(this.id, 'knnMatch', ...
                queryDescriptors, varargin{:});
        end
        
        function matches = radiusMatch(this, queryDescriptors, varargin)
            %RADIUSMATCH  For each query descriptor, finds the training descriptors not farther than the specified distance
            %
            %    matches = matcher.radiusMatch(queryDescriptors, k)
            %    matches = matcher.radiusMatch(queryDescriptors, trainDescriptors, k)
            %    [...] = matcher.radiusMatch(..., 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __queryDescriptors__ Query set of descriptors.
            % * __trainDescriptors__ Train set of descriptors. This set is not
            %       added to the train descriptors collection stored in the
            %       class object.
            % * __maxDistance__ Threshold for the distance between matched
            %       descriptors.
            %
            % ## Output
            % * __matches__ Found matches.
            %
            % ## Options
            % * __Mask__ Mask specifying permissible matches between an input
            %       query and train matrices of descriptors.
            % * __CompactResult__ Parameter used when the mask (or masks) is not
            %       empty. If compactResult is false, the matches vector has the
            %       same size as queryDescriptors rows. If compactResult is
            %       true, the matches vector does not contain matches for fully
            %       masked-out query descriptors.
            %
            matches = DescriptorMatcher_(this.id, 'radiusMatch',...
                queryDescriptors, varargin{:});
        end
        
        function read(this, filename)
            %READ  Reads a descriptor matcher object from a file
            %
            %    matcher.read(filename)
            %
            % ## Input
            % * __filename__ name of the xml/yaml file
            %
            % See also cv.DescriptorMatcher
            %
            DescriptorMatcher_(this.id, 'write', filename);
        end
        
        function write(this, filename)
            %WRITE  Writes a descriptor matcher object to a file
            %
            %    matcher.write(filename)
            %
            % ## Input
            % * __filename__ name of the xml/yaml file
            %
            % See also cv.DescriptorMatcher
            %
            DescriptorMatcher_(this.id, 'write', filename);
        end
    end
    
end
