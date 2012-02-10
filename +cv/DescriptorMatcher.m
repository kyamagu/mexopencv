classdef DescriptorMatcher < handle
	%DESCRIPTORMATCHER  DescriptorMatcher class
	%
	% Descriptor matcher class. Here is how to use:
	%
	%   matcher = cv.DescriptorMatcher('BruteForce');
	%   matches = matcher.match();
    %
    % See also cv.DescriptorMatcher.DescriptorMatcher
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
        function this = DescriptorMatcher(type)
            %DESCRIPTORMATCHER  DescriptorMatcher constructors
            %
            %  matcher = cv.DescriptorMatcher(type)
            %
            % Input:
            %   type: Type of the detector. see below. default 'FAST'
            % Output:
            %   detector: New instance of the DescriptorMatcher
            %
            % The following matcher types are supported:
            %
            %     'BruteForce' (it uses L2)
            %     'BruteForce-L1'
            %     'BruteForce-Hamming'
            %     'BruteForce-HammingLUT'
            %     'FlannBased'
            %
            % See also cv.DescriptorMatcher cv.DescriptorMatcher.write
            %
            if nargin < 1, type = 'BruteForce'; end
            if ~ischar(type)
                error('DescriptorMatcher:error','Invalid type');
            end
            this.id = DescriptorMatcher_(type);
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
            %  matcher.add(descriptors)
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
            %  matcher.clear()
        	%
        	DescriptorMatcher_(this.id, 'clear');
        end
        
        function status = empty(this)
        	%EMPTY  Returns true if there are no train descriptors in the collection
            %
            %  matcher.empty()
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
            %  matcher.train()
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
            %   matches = matcher.match(queryDescriptors, trainDescriptors)
            %   [...] = matcher.match(..., 'OptionName', optionValue, ...)
            %
            % Input:
            %   queryDescriptors: Query set of descriptors.
            %   trainDescriptors: Train set of descriptors. This set is not
            %       added to the train descriptors collection stored in the
            %       class object.
            % Output:
            %   matches: Matches. If a query descriptor is masked out in mask,
            %       no match is added for this descriptor. So, matches size may
            %       be smaller than the query descriptors count.
            % Options:
            %   'Mask' Mask specifying permissible matches between an input
            %       query and train matrices of descriptors.
        	%
        	matches = DescriptorMatcher_(this.id, 'match', queryDescriptors, varargin{:});
        end
        
        function matches = knnMatch(this, queryDescriptors, trainDescriptors, k, varargin)
        	%KNNMATCH  Finds the k best matches for each descriptor from a query set
        	%
            %   matches = matcher.knnMatch(queryDescriptors, trainDescriptors, k)
            %   [...] = matcher.knnMatch(..., 'OptionName', optionValue, ...)
            %
            % Input:
            %   queryDescriptors: Query set of descriptors.
            %   trainDescriptors: Train set of descriptors. This set is not
            %       added to the train descriptors collection stored in the
            %       class object.
            %   k: Count of best matches found per each query descriptor or less
            %       if a query descriptor has less than k possible matches in
            %       total
            % Output:
            %   matches: Matches. Each matches{i} is k or less matches for the
            %       same query descriptor.
            % Options:
            %   'Mask': Mask specifying permissible matches between an input
            %       query and train matrices of descriptors.
            %   'CompactResult': Parameter used when the mask (or masks) is not
            %       empty. If compactResult is false, the matches vector has the
            %       same size as queryDescriptors rows. If compactResult is
            %       true, the matches vector does not contain matches for fully
            %       masked-out query descriptors.
        	%
        	matches = DescriptorMatcher_(this.id, 'knnMatch',queryDescriptors, varargin{:});
        end
        
        function matches = radiusMatch(this, queryDescriptors, trainDescriptors, maxDistance, varargin)
        	%RADIUSMATCH  For each query descriptor, finds the training descriptors not farther than the specified distance
        	%
            %   matches = matcher.radiusMatch(queryDescriptors, k)
            %   matches = matcher.radiusMatch(queryDescriptors, trainDescriptors, k)
            %   [...] = matcher.radiusMatch(..., 'OptionName', optionValue, ...)
            %
            % Input:
            %   queryDescriptors: Query set of descriptors.
            %   trainDescriptors: Train set of descriptors. This set is not
            %       added to the train descriptors collection stored in the
            %       class object.
            %   maxDistance: Threshold for the distance between matched
            %       descriptors.
            % Output:
            %   matches: Matches. Each matches{i} is k or less matches for the
            %       same query descriptor.
            % Options:
            %   'Mask': Mask specifying permissible matches between an input
            %       query and train matrices of descriptors.
            %   'CompactResult': Parameter used when the mask (or masks) is not
            %       empty. If compactResult is false, the matches vector has the
            %       same size as queryDescriptors rows. If compactResult is
            %       true, the matches vector does not contain matches for fully
            %       masked-out query descriptors.
        	%
        	matches = DescriptorMatcher_(this.id, 'radiusMatch',queryDescriptors, varargin{:});
        end
        
        function read(this, filename)
            %READ  Reads a descriptor matcher object from a file
            %
            %   matcher.read(filename)
            %
            % Input:
            %   filename: name of the xml/yaml file
            %
            % See also cv.DescriptorMatcher
            %
            DescriptorMatcher_(this.id, 'write', filename);
        end
        
        function write(this, filename)
            %WRITE  Writes a descriptor matcher object to a file
            %
            %   matcher.write(filename)
            %
            % Input:
            %   filename: name of the xml/yaml file
            %
            % See also cv.DescriptorMatcher
            %
            DescriptorMatcher_(this.id, 'write', filename);
        end
    end
    
end
