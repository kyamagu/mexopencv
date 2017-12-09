classdef PCTSignatures < handle
    %PCTSIGNATURES  Class implementing PCT (Position-Color-Texture) signature extraction
    %
    % As described in [KrulisLS16].
    %
    % The algorithm is divided to a feature sampler and a clusterizer. Feature
    % sampler produces samples at given set of coordinates. Clusterizer then
    % produces clusters of these samples using k-means algorithm. Resulting
    % set of clusters is the signature of the input image.
    %
    % A signature is an array of 8-dimensional points. Used dimensions are:
    % weight, x/y position; Lab color L/a/b, contrast, entropy.
    %
    % ## References
    % [KrulisLS16]:
    % > Martin Krulis, Jakub Lokoc, and Tomas Skopal. "Efficient extraction of
    % > clustering-based feature signatures using GPU architectures".
    % > Multimedia Tools Appl., 75(13):8071-8103, 2016.
    %
    % [BeecksUS10]:
    % > Christian Beecks, Merih Seran Uysal, and Thomas Seidl.
    % > "Signature quadratic form distance". In CIVR, pages 438-445. ACM, 2010.
    %
    % See also: cv.PCTSignatures.computeSignature, cv.PCTSignaturesSQFD
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    % sampler (PCTSampler)
    properties (Dependent)
        % Color resolution of the greyscale bitmap represented in allocated
        % bits (i.e., value 4 means that 16 shades of grey are used). The
        % greyscale bitmap is used for computing contrast and entropy values.
        GrayscaleBits
        % Size of the texture sampling window used to compute contrast and
        % entropy (center of the window is always in the pixel selected by
        % x,y coordinates of the corresponding feature sample).
        WindowRadius
        % Weight (multiplicative constant) that linearly stretch individual
        % axis of the feature space (x position)
        WeightX
        % Weight (multiplicative constant) that linearly stretch individual
        % axis of the feature space (y position)
        WeightY
        % Weight (multiplicative constant) that linearly stretch individual
        % axis of the feature space (L color in CIE Lab space)
        WeightL
        % Weight (multiplicative constant) that linearly stretch individual
        % axis of the feature space (a color in CIE Lab space)
        WeightA
        % Weight (multiplicative constant) that linearly stretch individual
        % axis of the feature space (b color in CIE Lab space)
        WeightB
        % Weight (multiplicative constant) that linearly stretch individual
        % axis of the feature space (contrast)
        WeightContrast
        % Weight (multiplicative constant) that linearly stretch individual
        % axis of the feature space (entropy)
        WeightEntropy
    end

    % clusterizer (PCTClusterizer)
    properties (Dependent)
        % Number of iterations of the k-means clustering. We use fixed number
        % of iterations, since the modified clustering is pruning clusters
        % (not iteratively refining k clusters).
        IterationCount
        % Maximal number of generated clusters. If the number is exceeded, the
        % clusters are sorted by their weights and the smallest clusters are
        % cropped.
        MaxClustersCount
        % This parameter multiplied by the index of iteration gives lower
        % limit for cluster size. Clusters containing fewer points than
        % specified by the limit have their centroid dismissed and points are
        % reassigned.
        ClusterMinSize
        % Threshold euclidean distance between two centroids. If two cluster
        % centers are closer than this distance, one of the centroid is
        % dismissed and points are reassigned.
        JoiningDistance
        % Remove centroids in k-means whose weight is lesser or equal to given
        % threshold.
        DropThreshold
        % Distance function selector used for measuring distance between two
        % points in k-means.
        % Available: `L0_25`, `L0_5`, `L1`, `L2`, `L2Squared`, `L5`, `L_Inf`.
        DistanceFunction
    end

    %% Constructor/destructor
    methods
        function this = PCTSignatures(varargin)
            %PCTSIGNATURES  Creates PCTSignatures algorithm
            %
            %     obj = cv.PCTSignatures()
            %     obj = cv.PCTSignatures('OptionName',optionValue, ...)
            %
            %     obj = cv.PCTSignatures(initSamplingPoints, initSeedCount)
            %
            %     obj = cv.PCTSignatures(initSamplingPoints, initClusterSeedIndexes)
            %
            % ## Input
            % * __initSamplingPoints__ Sampling points used in image sampling.
            % * __initSeedCount__ Number of initial clusterization seeds. Must
            %   be lower or equal to `length(initSamplingPoints)`.
            % * __initClusterSeedIndexes__ Indexes of initial clusterization
            %   seeds. Its size must be lower or equal to
            %   `length(initSamplingPoints)`.
            %
            % ## Options (first variant)
            % * __InitSampleCount__ Number of points used for image sampling.
            %   default 2000
            % * __InitSeedCount__ Number of initial clusterization seeds. Must
            %   be lower or equal to `InitSampleCount`. default 400
            % * __PointDistribution__ Distribution of generated points.
            %   Available:
            %   * __Uniform__ (default) Generate numbers uniformly.
            %   * __Regular__ Generate points in a regular grid.
            %   * __Normal__ Generate points with normal (gaussian)
            %     distribution.
            %
            % In the first variant, it creates PCTSignatures algorithm using
            % sample and seed count. It generates its own sets of sampling
            % points and clusterization seed indexes.
            %
            % In the second variant, it creates PCTSignatures algorithm using
            % pre-generated sampling points and number of clusterization seeds.
            % It uses the provided sampling points and generates its own
            % clusterization seed indexes.
            %
            % In the third variant, it creates PCTSignatures algorithm using
            % pre-generated sampling points and clusterization seeds indexes.
            %
            % See also: cv.PCTSignatures.computeSignature
            %
            this.id = PCTSignatures_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.PCTSignatures
            %
            if isempty(this.id), return; end
            PCTSignatures_(this.id, 'delete');
        end
    end

    methods (Static)
        function initPoints = generateInitPoints(count, pointDistribution)
            %GENERATEINITPOINTS  Generates initial sampling points according to selected point distribution
            %
            %     initPoints = cv.PCTSignatures.generateInitPoints(count, pointDistribution)
            %
            % ## Input
            % * __count__ Number of points to generate.
            % * __pointDistribution__ Point distribution selector. Available:
            %   * __Uniform__ Generate numbers uniformly.
            %   * __Regular__ Generate points in a regular grid.
            %   * __Normal__ Generate points with normal (gaussian)
            %     distribution.
            %
            % ## Output
            % * __initPoints__ Output vector of generated points.
            %
            % Note: Generated coordinates are in range [0..1).
            %
            % See also: cv.PCTSignatures.PCTSignatures, rand, randn, meshgrid
            %
            initPoints = PCTSignatures_(0, 'generateInitPoints', count, pointDistribution);
        end

        function result = drawSignature(source, signature, varargin)
            %DRAWSIGNATURE  Draws signature in the source image and outputs the result
            %
            %     result = cv.PCTSignatures.drawSignature(source, signature)
            %     result = cv.PCTSignatures.drawSignature(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __source__ Source image.
            % * __signature__ Image signature (`single` matrix with 8 columns).
            %
            % ## Output
            % * __result__ Output result.
            %
            % ## Options
            % * __RadiusToShorterSideRatio__ Determines maximal radius of
            %   signature in the output image. default 1/8
            % * __BorderThickness__ Border thickness of the visualized
            %   signature. default 1
            %
            % Signatures are visualized as a circle with radius based on
            % signature weight and color based on signature color. Contrast
            % and entropy are not visualized.
            %
            % See also: cv.PCTSignatures.computeSignature
            %
            result = PCTSignatures_(0, 'drawSignature', source, signature, varargin{:});
        end
    end

    %% PCTSignatures
    methods
        function signature = computeSignature(this, img)
            %COMPUTESIGNATURE  Computes signature of given image
            %
            %     signature = obj.computeSignature(img)
            %
            % ## Input
            % * __img__ Input color image of `uint8` type.
            %
            % ## Output
            % * __signature__ Output computed signature.
            %
            % See also: cv.PCTSignatures.computeSignatures
            %
            signature = PCTSignatures_(this.id, 'computeSignature', img);
        end

        function signatures = computeSignatures(this, imgs)
            %COMPUTESIGNATURES  Computes signatures for multiple images in parallel
            %
            %     signatures = obj.computeSignatures(imgs)
            %
            % ## Input
            % * __imgs__ Vector of input images of `uint8` type.
            %
            % ## Output
            % * __signatures__ Vector of computed signatures.
            %
            % See also: cv.PCTSignatures.computeSignature
            %
            signatures = PCTSignatures_(this.id, 'computeSignatures', imgs);
        end
    end

    % sampler (PCTSampler)
    methods
        function sampleCount = getSampleCount(this)
            %GETSAMPLECOUNT  Number of initial samples taken from the image
            %
            %     sampleCount = obj.getSampleCount()
            %
            % ## Output
            % * __sampleCount__ Number of initial samples taken from the image.
            %
            % See also: cv.PCTSignatures.getSamplingPoints
            %
            sampleCount = PCTSignatures_(this.id, 'getSampleCount');
        end

        function samplingPoints = getSamplingPoints(this)
            %GETSAMPLINGPOINTS  Initial samples taken from the image
            %
            %     samplingPoints = obj.getSamplingPoints()
            %
            % ## Output
            % * __samplingPoints__ Initial samples taken from the image.
            %
            % These sampled features become the input for clustering.
            %
            % See also: cv.PCTSignatures.setSamplingPoints
            %
            samplingPoints = PCTSignatures_(this.id, 'getSamplingPoints');
        end

        function setSamplingPoints(this, samplingPoints)
            %SETSAMPLINGPOINTS  Sets sampling points used to sample the input image
            %
            %     obj.setSamplingPoints(samplingPoints)
            %
            % ## Input
            % * __samplingPoints__ Vector of sampling points in range [0..1).
            %
            % See also: cv.PCTSignatures.getSamplingPoints
            %
            PCTSignatures_(this.id, 'setSamplingPoints', samplingPoints);
        end

        function setWeight(this, idx, value)
            %SETWEIGHT  Sets weight (multiplicative constant) that linearly stretch individual axis of the feature space
            %
            %     obj.setWeight(idx, value)
            %
            % ## Input
            % * __idx__ ID of the weight (0-based index). One of:
            %   * __0__ weight.
            %   * __1__ X.
            %   * __2__ Y.
            %   * __3__ L.
            %   * __4__ A.
            %   * __5__ B.
            %   * __6__ Contrast.
            %   * __7__ Entropy.
            % * __value__ Value of the weight.
            %
            % See also: cv.PCTSignatures.setWeights
            %
            PCTSignatures_(this.id, 'setWeight', idx, value);
        end

        function setWeights(this, weights)
            %SETWEIGHTS  Sets weights (multiplicative constants) that linearly stretch individual axes of the feature space
            %
            %     obj.setWeights(weights)
            %
            % ## Input
            % * __weights__ Values of all weights. A float vector of the form
            %   `[weight, X, Y, L, A, B, Contrast, Entropy]`.
            %
            % See also: cv.PCTSignatures.setWeight
            %
            PCTSignatures_(this.id, 'setWeights', weights);
        end

        function setTranslation(this, idx, value)
            %SETRANSLATION  Sets translation of the individual axis of the feature space
            %
            %     obj.setTranslation(idx, value)
            %
            % ## Input
            % * __idx__ ID of the translation (0-based index). One of:
            %   * __0__ weight.
            %   * __1__ X.
            %   * __2__ Y.
            %   * __3__ L.
            %   * __4__ A.
            %   * __5__ B.
            %   * __6__ Contrast.
            %   * __7__ Entropy.
            % * __value__ Value of the translation.
            %
            % See also: cv.PCTSignatures.setTranslations
            %
            PCTSignatures_(this.id, 'setTranslation', idx, value);
        end

        function setTranslations(this, translations)
            %SETRANSLATIONS  Sets translations of the individual axes of the feature space
            %
            %     obj.setTranslations(translations)
            %
            % ## Input
            % * __translations__ Values of all translations. A float vector
            %   of the form `[weight, X, Y, L, A, B, Contrast, Entropy]`.
            %
            % See also: cv.PCTSignatures.setTranslation
            %
            PCTSignatures_(this.id, 'setTranslations', translations);
        end
    end

    % clusterizer (PCTClusterizer)
    methods
        function initSeedCount = getInitSeedCount(this)
            %GETINITSEEDCOUNT  Number of initial seeds for the k-means algorithm
            %
            %     initSeedCount = obj.getInitSeedCount()
            %
            % ## Output
            % * __initSeedCount__ Number of initial seeds (initial number of
            %   clusters) for the k-means algorithm.
            %
            % See also: cv.PCTSignatures.getInitSeedIndexes
            %
            initSeedCount = PCTSignatures_(this.id, 'getInitSeedCount');
        end

        function initSeedIndexes = getInitSeedIndexes(this)
            %GETINITSEEDINDEXES  Initial seeds for the k-means algorithm
            %
            %     initSeedIndexes = obj.getInitSeedIndexes()
            %
            % ## Output
            % * __initSeedIndexes__ Initial seeds (initial number of clusters)
            %   for the k-means algorithm (0-based indices).
            %
            % See also: cv.PCTSignatures.setInitSeedIndexes
            %
            initSeedIndexes = PCTSignatures_(this.id, 'getInitSeedIndexes');
        end

        function setInitSeedIndexes(this, initSeedIndexes)
            %SETINITSEEDINDEXES  Sets initial seed indexes for the k-means algorithm
            %
            %     obj.setInitSeedIndexes(initSeedIndexes)
            %
            % ## Input
            % * __initSeedIndexes__ Vector of initial seed indexes for the
            %   k-means algorithm (0-based indices).
            %
            % See also: cv.PCTSignatures.getInitSeedIndexes
            %
            PCTSignatures_(this.id, 'setInitSeedIndexes', initSeedIndexes);
        end
    end

    %% Algorithm
    methods (Hidden)
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.PCTSignatures.empty
            %
            PCTSignatures_(this.id, 'clear');
        end

        function b = empty(this)
            %EMPTY  Returns true if the algorithm is empty
            %
            %     b = obj.empty()
            %
            % ## Output
            % * __b__ Returns true if the algorithm is empty (e.g. in the very
            %   beginning or after unsuccessful read).
            %
            % See also: cv.PCTSignatures.clear
            %
            b = PCTSignatures_(this.id, 'empty');
        end

        function name = getDefaultName(this)
            %GETDEFAULTNAME  Returns the algorithm string identifier
            %
            %     name = obj.getDefaultName()
            %
            % ## Output
            % * __name__ This string is used as top level XML/YML node tag
            %   when the object is saved to a file or string.
            %
            % See also: cv.PCTSignatures.save, cv.PCTSignatures.load
            %
            name = PCTSignatures_(this.id, 'getDefaultName');
        end

        function save(this, filename)
            %SAVE  Saves the algorithm to a file
            %
            %     obj.save(filename)
            %
            % ## Input
            % * __filename__ Name of the file to save to.
            %
            % This method stores the algorithm parameters in a file storage.
            %
            % See also: cv.PCTSignatures.load
            %
            PCTSignatures_(this.id, 'save', filename);
        end

        function load(this, fname_or_str, varargin)
            %LOAD  Loads algorithm from a file or a string
            %
            %     obj.load(fname)
            %     obj.load(str, 'FromString',true)
            %     obj.load(..., 'OptionName',optionValue, ...)
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
            % This method reads algorithm parameters from a file storage.
            % The previous model state is discarded.
            %
            % See also: cv.PCTSignatures.save
            %
            PCTSignatures_(this.id, 'load', fname_or_str, varargin{:});
        end
    end

    %% Getters/Setters
    methods
        function value = get.GrayscaleBits(this)
            value = PCTSignatures_(this.id, 'get', 'GrayscaleBits');
        end
        function set.GrayscaleBits(this, value)
            PCTSignatures_(this.id, 'set', 'GrayscaleBits', value);
        end

        function value = get.WindowRadius(this)
            value = PCTSignatures_(this.id, 'get', 'WindowRadius');
        end
        function set.WindowRadius(this, value)
            PCTSignatures_(this.id, 'set', 'WindowRadius', value);
        end

        function value = get.WeightX(this)
            value = PCTSignatures_(this.id, 'get', 'WeightX');
        end
        function set.WeightX(this, value)
            PCTSignatures_(this.id, 'set', 'WeightX', value);
        end

        function value = get.WeightY(this)
            value = PCTSignatures_(this.id, 'get', 'WeightY');
        end
        function set.WeightY(this, value)
            PCTSignatures_(this.id, 'set', 'WeightY', value);
        end

        function value = get.WeightL(this)
            value = PCTSignatures_(this.id, 'get', 'WeightL');
        end
        function set.WeightL(this, value)
            PCTSignatures_(this.id, 'set', 'WeightL', value);
        end

        function value = get.WeightA(this)
            value = PCTSignatures_(this.id, 'get', 'WeightA');
        end
        function set.WeightA(this, value)
            PCTSignatures_(this.id, 'set', 'WeightA', value);
        end

        function value = get.WeightB(this)
            value = PCTSignatures_(this.id, 'get', 'WeightB');
        end
        function set.WeightB(this, value)
            PCTSignatures_(this.id, 'set', 'WeightB', value);
        end

        function value = get.WeightContrast(this)
            value = PCTSignatures_(this.id, 'get', 'WeightContrast');
        end
        function set.WeightContrast(this, value)
            PCTSignatures_(this.id, 'set', 'WeightContrast', value);
        end

        function value = get.WeightEntropy(this)
            value = PCTSignatures_(this.id, 'get', 'WeightEntropy');
        end
        function set.WeightEntropy(this, value)
            PCTSignatures_(this.id, 'set', 'WeightEntropy', value);
        end

        function value = get.IterationCount(this)
            value = PCTSignatures_(this.id, 'get', 'IterationCount');
        end
        function set.IterationCount(this, value)
            PCTSignatures_(this.id, 'set', 'IterationCount', value);
        end

        function value = get.MaxClustersCount(this)
            value = PCTSignatures_(this.id, 'get', 'MaxClustersCount');
        end
        function set.MaxClustersCount(this, value)
            PCTSignatures_(this.id, 'set', 'MaxClustersCount', value);
        end

        function value = get.ClusterMinSize(this)
            value = PCTSignatures_(this.id, 'get', 'ClusterMinSize');
        end
        function set.ClusterMinSize(this, value)
            PCTSignatures_(this.id, 'set', 'ClusterMinSize', value);
        end

        function value = get.JoiningDistance(this)
            value = PCTSignatures_(this.id, 'get', 'JoiningDistance');
        end
        function set.JoiningDistance(this, value)
            PCTSignatures_(this.id, 'set', 'JoiningDistance', value);
        end

        function value = get.DropThreshold(this)
            value = PCTSignatures_(this.id, 'get', 'DropThreshold');
        end
        function set.DropThreshold(this, value)
            PCTSignatures_(this.id, 'set', 'DropThreshold', value);
        end

        function value = get.DistanceFunction(this)
            value = PCTSignatures_(this.id, 'get', 'DistanceFunction');
        end
        function set.DistanceFunction(this, value)
            PCTSignatures_(this.id, 'set', 'DistanceFunction', value);
        end
    end

end
