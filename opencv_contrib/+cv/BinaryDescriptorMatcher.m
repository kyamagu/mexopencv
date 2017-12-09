classdef BinaryDescriptorMatcher < handle
    %BINARYDESCRIPTORMATCHER  BinaryDescriptor matcher class
    %
    % Furnishes all functionalities for querying a dataset provided by user or
    % internal to class (that user must, anyway, populate) on the model of
    % Descriptor Matchers.
    %
    % Once descriptors have been extracted from an image (both they represent
    % lines and points), it becomes interesting to be able to match a
    % descriptor with another one extracted from a different image and
    % representing the same line or point, seen from a differente perspective
    % or on a different scale. In reaching such goal, the main headache is
    % designing an efficient search algorithm to associate a query descriptor
    % to one extracted from a dataset. In the following, a matching modality
    % based on *Multi-Index Hashing (MiHashing)* will be described.
    %
    % ### Multi-Index Hashing
    %
    % The theory described in this section is based on [MIH]. Given a dataset
    % populated with binary codes, each code is indexed `m` times into `m`
    % different hash tables, according to `m` substrings it has been divided
    % into. Thus, given a query code, all the entries close to it at least in
    % one substring are returned by search as *neighbor candidates*. Returned
    % entries are then checked for validity by verifying that their full codes
    % are not distant (in Hamming space) more than `r` bits from query code.
    % In details, each binary code `h` composed of `b` bits is divided into
    % `m` disjoint substrings `h^(1), ..., h^(m)`, each with length
    % `floor(b/m)` or `ceil(b/m)` bits. Formally, when two codes `h` and `g`
    % differ by at the most `r` bits, in at the least one of their `m`
    % substrings they differ by at the most `floor(r/m)` bits. In particular,
    % when `||h-g||_H <= r` (where `||.||_H` is the Hamming norm), there must
    % exist a substring `k` (with `1 <= k <= m`) such that:
    %
    %     || h^(k) - g^(k) ||_H <= floor(r/m)
    %
    % That means that if Hamming distance between each of the `m` substring is
    % strictly greater than `floor(r/m)`, then `||h-g||_H` must be larger that
    % `r` and that is a contradiction. If the codes in dataset are divided
    % into `m` substrings, then `m` tables will be built. Given a query `q`
    % with substrings `{q^(i)}_[i=1..m]`, `i`-th hash table is searched for
    % entries distant at the most `floor(r/m)` from `q^(i)` and a set of
    % candidates `N_i(q)` is obtained. The union of sets `N(q) = U_i {N_i(q)}`
    % is a superset of the `r`-neighbors of `q`. Then, last step of algorithm
    % is computing the Hamming distance between `q` and each element in `N(q)`,
    % deleting the codes that are distant more that `r` from `q`.
    %
    % ## References
    % [MIH]:
    % > Mohammad Norouzi, Ali Punjani, and David J Fleet. "Fast search in
    % > hamming space with Multi-Index Hashing". In Computer Vision and
    % > Pattern Recognition (CVPR), 2012 IEEE Conference on, pages 3108-3115.
    % > IEEE, 2012.
    %
    % See also: cv.BinaryDescriptor, cv.DescriptorMatcher, cv.drawLineMatches
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    methods
        function this = BinaryDescriptorMatcher()
            %BINARYDESCRIPTORMATCHER  Constructor
            %
            %     matcher = cv.BinaryDescriptorMatcher()
            %
            % The BinaryDescriptorMatcher constructed is able to store and
            % manage 256-bits long entries.
            %
            % See also: cv.BinaryDescriptorMatcher
            %
            this.id = BinaryDescriptorMatcher_(0, 'new');
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     matcher.delete()
            %
            % See also: cv.BinaryDescriptorMatcher
            %
            if isempty(this.id), return; end
            BinaryDescriptorMatcher_(this.id, 'delete');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clear dataset and internal data
            %
            %     matcher.clear()
            %
            % See also: cv.BinaryDescriptorMatcher.empty
            %
            BinaryDescriptorMatcher_(this.id, 'clear');
        end

        function status = empty(this)
            %EMPTY  Returns true if there are no train descriptors in the collection
            %
            %     status = matcher.empty()
            %
            % ## Output
            % * __status__ boolean status
            %
            % See also: cv.BinaryDescriptorMatcher.clear
            %
            status = BinaryDescriptorMatcher_(this.id, 'empty');
        end

        function save(this, filename)
            %SAVE  Saves the algorithm parameters to a file
            %
            %     matcher.save(filename)
            %
            % ## Input
            % * __filename__ Name of the file to save to.
            %
            % This method stores the algorithm parameters in the specified
            % XML or YAML file.
            %
            % See also: cv.BinaryDescriptorMatcher.load
            %
            BinaryDescriptorMatcher_(this.id, 'save', filename);
        end

        function load(this, fname_or_str, varargin)
            %LOAD  Loads algorithm from a file or a string
            %
            %     matcher.load(fname)
            %     matcher.load(str, 'FromString',true)
            %     matcher.load(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __fname__ Name of the file to read.
            % * __str__ String containing the serialized model you want to
            %   load.
            %
            % ## Options
            % * __ObjName__ The optional name of the node to read (if empty,
            %   the first top-level node will be used). default empty
            % * __FromString__ Logical flag to indicate whether the input is a
            %   filename or a string containing the serialized model.
            %   default false
            %
            % This method reads algorithm parameters from the specified XML or
            % YAML file (either from disk or serialized string). The previous
            % algorithm state is discarded.
            %
            % See also: cv.BinaryDescriptorMatcher.save
            %
            BinaryDescriptorMatcher_(this.id, 'load', fname_or_str, varargin{:});
        end

        function name = getDefaultName(this)
            %GETDEFAULTNAME  Returns the algorithm string identifier
            %
            %     name = matcher.getDefaultName()
            %
            % ## Output
            % * __name__ This string is used as top level XML/YML node tag
            %   when the object is saved to a file or string.
            %
            % See also: cv.BinaryDescriptorMatcher.save, cv.BinaryDescriptorMatcher.load
            %
            name = BinaryDescriptorMatcher_(this.id, 'getDefaultName');
        end
    end

    %% BinaryDescriptorMatcher
    methods
        function add(this, descriptors)
            %ADD  Store locally new descriptors to be inserted in dataset, without updating dataset
            %
            %     matcher.add(descriptors)
            %
            % ## Input
            % * __descriptors__ cell array of matrices containing descriptors
            %   to be inserted into dataset. Each matrix `descriptors{i}`
            %   should contain descriptors relative to lines extracted from
            %   i-th image.
            %
            % See also: cv.BinaryDescriptorMatcher.clear
            %
            BinaryDescriptorMatcher_(this.id, 'add', descriptors);
        end

        function train(this)
            %TRAIN  Update dataset by inserting into it all descriptors that were stored locally by add function
            %
            %     matcher.train()
            %
            % NOTE: Every time this function is invoked, current dataset is
            % deleted and locally stored descriptors are inserted into
            % dataset. The locally stored copy of just inserted descriptors is
            % then removed.
            %
            % See also: cv.BinaryDescriptorMatcher.add
            %
            BinaryDescriptorMatcher_(this.id, 'train');
        end

        function matches = match(this, queryDescriptors, varargin)
            %MATCH  For every input query descriptor, retrieve the best matching one from a dataset provided from user or from the one internal to class
            %
            %     matches = matcher.match(queryDescriptors, trainDescriptors)
            %     matches = matcher.match(queryDescriptors)
            %     [...] = matcher.match(..., 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __queryDescriptors__ query descriptors.
            % * __trainDescriptors__ dataset of descriptors furnished by user.
            %
            % ## Output
            % * __matches__ vector to host retrieved matches.
            %
            % ## Options
            % * __Mask__ mask to select which input descriptors must be
            %   matched to one in dataset. In the second variant, a vector of
            %   masks (the i-th mask in vector indicates whether each input
            %   query can be matched with descriptors in dataset relative to
            %   i-th image). Not set by default.
            %
            % For every input descriptor, find the best matching one:
            %
            % - in the first variant, for a pair of images
            % - in the second variant, from one image to a set
            %
            % See also: cv.BinaryDescriptorMatcher.knnMatch,
            %  cv.BinaryDescriptorMatcher.radiusMatch
            %
            matches = BinaryDescriptorMatcher_(this.id, 'match', queryDescriptors, varargin{:});
        end

        function matches = knnMatch(this, queryDescriptors, varargin)
            %KNNMATCH  For every input query descriptor, retrieve the best k matching ones from a dataset provided from user or from the one internal to class
            %
            %     matches = matcher.knnMatch(queryDescriptors, trainDescriptors, k)
            %     matches = matcher.knnMatch(queryDescriptors, k)
            %     [...] = matcher.knnMatch(..., 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __queryDescriptors__ query descriptors.
            % * __trainDescriptors__ dataset of descriptors furnished by user.
            % * __k__ number of the closest descriptors to be returned for
            %   every input query.
            %
            % ## Output
            % * __matches__ vector to host retrieved matches.
            %
            % ## Options
            % * __Mask__ mask to select which input descriptors must be
            %   matched to ones in dataset. A vector of masks in the second
            %   variant (the i-th mask in vector indicates whether each input
            %   query can be matched with descriptors in dataset relative to
            %   i-th image). Not set by default.
            % * __CompactResult__ flag to obtain a compact result (if true, a
            %   vector that doesn't contain any matches for a given query is
            %   not inserted in final result). default false
            %
            % For every input descriptor, find the best k matching descriptors:
            %
            % - in the first variant, for a pair of images
            % - in the second variant, from one image to a set
            %
            % See also: cv.BinaryDescriptorMatcher.match,
            %  cv.BinaryDescriptorMatcher.radiusMatch
            %
            matches = BinaryDescriptorMatcher_(this.id, 'knnMatch', ...
                queryDescriptors, varargin{:});
        end

        function matches = radiusMatch(this, queryDescriptors, varargin)
            %RADIUSMATCH  For every input query descriptor, retrieve, from a dataset provided from user or from the one internal to class, all the descriptors that are not further than maxDist from input query
            %
            %     matches = matcher.radiusMatch(queryDescriptors, trainDescriptors, maxDistance)
            %     matches = matcher.radiusMatch(queryDescriptors, maxDistance)
            %     [...] = matcher.radiusMatch(..., 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __queryDescriptors__ query descriptors.
            % * __trainDescriptors__ dataset of descriptors furnished by user.
            % * __maxDistance__ search radius.
            %
            % ## Output
            % * __matches__ vector to host retrieved matches.
            %
            % ## Options
            % * __Mask__ mask to select which input descriptors must be
            %   matched to ones in dataset. A vector of masks in the second
            %   variant (the i-th mask in vector indicates whether each input
            %   query can be matched with descriptors in dataset relative to
            %   i-th image). Not set by default.
            % * __CompactResult__ flag to obtain a compact result (if true, a
            %   vector that doesn't contain any matches for a given query is
            %   not inserted in final result). default false
            %
            % For every input desciptor, find all the ones falling in a
            % certaing matching radius:
            %
            % - in the first variant, for a pair of images
            % - in the second variant, from one image to a set
            %
            % See also: cv.BinaryDescriptorMatcher.match,
            %  cv.BinaryDescriptorMatcher.knnMatch
            %
            matches = BinaryDescriptorMatcher_(this.id, 'radiusMatch',...
                queryDescriptors, varargin{:});
        end
    end

end
