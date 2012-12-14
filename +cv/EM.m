classdef EM < handle
    %EM Expectation Maximization Algorithm
    %
    % This is an algorithm to train Gaussian Mixture Models (GMM)
    %
    %  see also cv.EM/EM cv.EM/train cv.EM/predict

    properties (SetAccess = private)
        id % Object ID
    end

    properties (Dependent)
        Nclusters        % Number of clusters (mixture components)
        CovMatType       % Constraint of covariance matrix type
        MaxIters         % Maximum number of iterations
        Epsilon          % Epsilon
        Weights          % weights
        Means            % means
        Covs             % covariations
        IsTrained        % whether the model is trained or not
    end

    methods
        function this = EM(varargin)
            %EM  EM constructor
            %
            %    em = cv.EM()
            %    em = cv.EM('OptionName', optionValue, ...)
            %  
            %    em = cv.EM(filename)
            % 
            %    In the first form (without arguments, or with options), 
            %    the new object is created, which then needs training.
            %
            %    In the second form (with given file name as an input), 
            %    the new object is created, which then loads parameters (options, 
            %    trained weights, means and covariations) which were
            %    saved to this file by some earlier created object.
            %
            % ## Input
            % * __filename__  Name of XML or YML file, containing
            %                 previously saved model
            % 
            % ## Options
            % * __Nclusters__ Number of clusters (mixture components), 
            %                 default is cv::EM::DEFAULT_NCLUSTERS = 5
            %
            % * __CovMatType__ Constrain covariance matrix type:
            %        'Spherical' A scaled identity matrix mu_k * I. There is the only
            %                    parameter mu_k to be estimated for each matrix. 
            %                    The option may be used in special cases, when the constraint 
            %                    is relevant, or as a first step in the optimization 
            %                    (for example in case when the data is preprocessed with PCA). 
            %                    The results of such preliminary estimation may be passed again 
            %                    to the optimization procedure, this time with CovMatType='Diagonal'
            %
            %        'Diagonal'  A diagonal matrix with positive diagonal elements. The number of 
            %                    free parameters is d for each matrix. This is most commonly used option
            %                    yielding good estimation results.
            %
            %        'Generic'   A symmetric positively defined matrix. The number of free parameters 
            %                    in each matrix is about d^2 / 2. It is not recommended to use this option,
            %                    unless there is pretty accurate initial estimation of the parameters 
            %                    and/or a huge number of training samples.
            %
            %        Default is 'Diagonal'
            %
            % * __MaxIters__     Maximum number of iterations, 
            %                    default is EM::DEFAULT_MAX_ITERS=100
            %
            % * __Epsilon__      Minimum allowed change of likelihood logarithm, 
            %                    default is cv::FLT_EPSILON = 1.192092896e-07f
            %
            %  see also cv.EM cv.EM.train cv.EM.predict
            
            if (nargin == 1)
                fname = varargin{1};
                if ischar(fname) && exist(fname, 'file')
                    this.id = EM_(0, 'new');
                    this.load(fname);
                end
            else
                this.id = EM_(0, 'new', varargin{:});
            end
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also cv.EM
            %
            EM_(this.id, 'delete');
        end

        function [log_likelihoods labels probs] = train(this, samples)
            %TRAIN  Trains the GMM
            %
            %    [ log_likelihoods labels probs ] = em.train(samples)
            %
            % ## Input
            % * __samples__ Samples from which the Gaussian mixture model will be estimated. 
            %               It should be a one-channel matrix, each row of which is a sample. 
            %
            % ## Output
            % * __log_likelihoods__ The optional output matrix that contains a likelihood logarithm 
            %                        value for each sample. It has nsamples x 1 size.
            %
            % * __labels__          The optional output "class label" for each sample
            %                       (indices of the most probable mixture component for each sample):
            %                         labels_i = arg max k(p_i; k); i = 1::N 
            %                       It has nsamples x 1 size.
            %  
            % * __probs__           The optional output matrix that contains posterior probabilities 
            %                       of each Gaussian mixture component given the each sample. 
            %                       It has nsamples x nclusters size.

            [log_likelihoods, labels, probs] = EM_(this.id, 'train', samples);
        end

        function [log_likelihoods labels probs] = trainE(this, samples, means0, varargin)
            %TRAINE  Trains the GMM, starting from the Expectation step
            %
            %    [ log_likelihoods labels probs ] = em.trainE(samples, means0)
            %    [ log_likelihoods labels probs ] = em.trainE(samples, means0, 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __samples__ Samples from which the Gaussian mixture model will be estimated. 
            %               It should be a one-channel matrix, each row of which is a sample. 
            % 
            % * __means0__  Initial means ak of mixture components. It is a one-channel matrix of
            %               nclusters x dims size
            % 
            % ## Output
            %  see EM.train
            % 
            % ## Options
            % * __Covs0__       The vector of initial covariance matrices Sk of mixture components. 
            %                   Each of covariance matrices is a one-channel matrix of dims x dims size.
            % 
            % * __Weights0__    Initial weights pi_k of mixture components. It should be a one-channel 
            %                   matrix with 1 x nclusters or nclusters x 1 size.

            [log_likelihoods, labels, probs] = EM_(this.id, 'trainE', samples, means0, varargin{:});
        end

        function [log_likelihoods labels probs] = trainM(this, samples, probs0)
            %TRAINM  Trains the GMM, starting from the Maximization step
            %
            %    [ log_likelihoods labels probs ] = em.trainM(samples, probs0)
            %
            % ## Input
            % * __samples__ Samples from which the Gaussian mixture model will be estimated. 
            %               It should be a one-channel matrix, each row of which is a sample. 
            % 
            % * __probs0__  Initial probabilities p_i;k of sample i to belong to mixture component k. It is a
            %               one-channel floating-point matrix of nsamples x nclusters size
            % 
            % ## Output
            %  see EM.train

            [log_likelihoods, labels, probs] = EM_(this.id, 'trainM', samples, probs0);
        end

        function value = get.Nclusters(this)
            value = EM_(this.id, 'nclusters');
        end

        function set.Nclusters(this, value)
            EM_(this.id, 'nclusters', value);
        end

        function value = get.CovMatType(this)
            value = EM_(this.id, 'covMatType');
        end

        function set.CovMatType(this, value)
            EM_(this.id, 'covMatType', value);
        end

        function value = get.MaxIters(this)
            value = EM_(this.id, 'maxIters');
        end

        function set.MaxIters(this, value)
            EM_(this.id, 'maxIters', value);
        end

        function value = get.Epsilon(this)
            value = EM_(this.id, 'epsilon');
        end

        function set.Epsilon(this, value)
            EM_(this.id, 'epsilon', value);
        end
        
        function value = get.Weights(this)
            value = EM_(this.id, 'weights');
        end
        function value = get.Means(this)
            value = EM_(this.id, 'means');
        end
        function value = get.Covs(this)
            value = EM_(this.id, 'covs');
        end
        
        function value = get.IsTrained(this)
            value = logical(EM_(this.id, 'isTrained'));
        end

        function save(this, filename)
            %SAVE  Save object to a file
            %
            %    em.save(filename)
            %
            % ## Input
            % * __filename__ File name. 
            EM_(this.id, 'save', filename);
        end
        
        function load(this, filename)
            %LOAD  Load model parameters from a file
            %
            %    em.load(filename)
            %
            % ## Input
            % * __filename__ File name. 
            EM_(this.id, 'load', filename);
        end
        
        function [log_likelihood, cluster, probs] = predict(this, samples)
            %PREDICT Returns a likelihood logarithm value and an index 
            %        of the most probable mixture component for the given 
            %        sample.
            %
            %    [log_likelihood, cluster, probs] = em.predict(sample)
            %
            % ## Input
            % * __samples__ Samples for classification. It should be a
            %               matrix with each row representing separate
            %               sample.
            % 
            % ## Output
            % * __log_likelihood__ Likelihood logarithm values
            % 
            % * __cluster__        Indices of the most probable mixture
            %                      components for each sample
            % 
            % * __probs__          Matrix pf posterior probabilities of each
            %                      component given the sample. 
            %                      It has nsamples x nclusters size.
    
            nsamples = size(samples, 1);
            if  nsamples > 1
                log_likelihood = zeros(nsamples, 1);
                cluster = zeros(nsamples, 1);
                probs = zeros(nsamples, this.Nclusters);
                for i = 1:nsamples
                    [log_likelihood(i), cluster(i), probs(i, :)] = EM_(this.id, 'predict', samples(i, :));
                end
            else
                [log_likelihood, cluster, probs] = EM_(this.id, 'predict', samples);
            end
        end
    end     
end
