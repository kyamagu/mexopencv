classdef PCA < handle
    %PCA  Principal Component Analysis class
    %
    % The class is used to compute a special basis for a set of vectors.
    % The basis will consist of eigenvectors of the covariance matrix
    % computed from the input set of vectors. The class PCA can also
    % transform vectors to/from the new coordinate space defined by the
    % basis. Usually, in this new coordinate system, each vector from the
    % original set (and any linear combination of such vectors) can be
    % quite accurately approximated by taking its first few components,
    % corresponding to the eigenvectors of the largest eigenvalues of the
    % covariance matrix. Geometrically it means that you compute a
    % projection of the vector to a subspace formed by a few eigenvectors
    % corresponding to the dominant eigenvalues of the covariance matrix.
    % And usually such a projection is very close to the original vector.
    % So, you can represent the original vector from a high-dimensional
    % space with a much shorter vector consisting of the projected vector's
    % coordinates in the subspace. Such a transformation is also known as
    % Karhunen-Loeve Transform, or KLT. See
    % http://en.wikipedia.org/wiki/Principal_component_analysis
    %
    % The following shows a quick example of how to reduce dimensionality
    % of samples from 10 to 3.
    %
    %    Xtrain = randn(100,10);
    %    Xtest  = randn(100,10);
    %    pca = cv.PCA(Xtrain, 'MaxComponents', 3);
    %    Y = pca.project(Xtest);
    %    Xapprox = pca.backProject(Y);
    %
    % See also cv.PCA.PCA
    %
    
    properties (SetAccess = protected)
        % Object ID
        id
        % Eigenvectors
        eigenvectors
        % Eigenvalues
        eigenvalues
        % Sample mean
        mean
    end
    
    methods
        function this = PCA(varargin)
            %PCA  PCA constructors
            %
            %    pca = cv.PCA()
            %    pca = cv.PCA(X, 'OptionName', optionValue, ...)
            %    pca = cv.PCA(S)
            %
            % ## Input
            % * __X__ Vectors to be analyzed
            % * __S__ A scalar struct to be imported
            %
            % ## Options
            % * __DataAs__ Data layout option. One of 'row' or 'col'.
            %       default 'row'.
            % * __MaxComponents__ Maximum number of components that PCA
            %       should retain. By default, all the components are
            %       retained.
            % * __Mean__ Optional mean value. By default, the mean is
            %       computed from the data.
            %
            % The constructor creates an empty pca object without an
            % argument. Use pca.compute to analyze data samples. The second
            % form accepts data samples with the same argument to
            % pca.compute. The third form create a new pca object from a
            % scalar struct with 'eigenvectors', 'eigenvalues', and 'mean'
            % fields.
            %
            % See also cv.PCA cv.PCA.compute
            %
            this.id = PCA_(0,'new');
            if nargin==1 && isscalar(varargin{1}) && isstruct(varargin{1})
                s = varargin{1};
                props = intersect(fieldnames(s),properties(this));
                props = setdiff(props,'id');
                for i = 1:numel(props)
                    this.(props{i}) = s.(props{i});
                end
            else
                this.compute(varargin{:});
            end
        end
        
        function delete(this)
            %DELETE  PCA destructor
            %
            % See also cv.PCA
            %
            PCA_(this.id, 'delete');
        end
        
        function S = struct(this)
            %STRUCT  Converts to a struct array
            %
            %    S = this.struct
            %    S = struct(this)
            %
            %
            % ## Output
            % * __S__ struct array
            %
            % See also cv.PCA
            %
            S = struct('eigenvectors',{this.eigenvectors},...
                       'eigenvalues', {this.eigenvalues},...
                       'mean',        {this.mean});
        end
        
        function obj = saveobj(this)
            %SAVEOBJ  Serialization before save
            %
            % See also cv.PCA
            %
            obj = this.struct;
        end
        
        function compute(this, X, varargin)
            %COMPUTE  Performs Principal Component Analysis of the supplied dataset
            %
            %    pca.compute(X)
            %
            % ## Input
            % * __X__ Vectors to be analyzed
            %
            % ## Options
            % * __DataAs__ Data layout option. One of 'row' or 'col'.
            %       default 'row'.
            % * __MaxComponents__ Maximum number of components that PCA
            %       should retain. By default, all the components are
            %       retained.
            % * __Mean__ Optional mean value. By default, the mean is
            %       computed from the data.
            %
            % The method performs PCA of the supplied dataset. It is safe
            % to reuse the same PCA structure for multiple datasets. That
            % is, if the structure has been previously used with another
            % dataset, the existing internal data is reclaimed and the new
            % eigenvalues, eigenvectors, and mean are allocated and
            % computed.
            %
            % The computed eigenvalues are sorted from the largest to the
            % smallest and the corresponding eigenvectors are stored as
            % pca.eigenvectors rows.
            %
            % See also cv.PCA cv.PCA.project cv.PCA.backProject
            %
            PCA_(this.id, 'compute', X, varargin{:});
            this.eigenvectors = [];
            this.eigenvalues = [];
            this.mean = [];
        end
        
        function Y = project(this, X)
            %PROJECT  Projects vector(s) to the principal component subspace
            %
            %    Y = pca.project(X)
            %
            % ## Input
            % * __X__ Vectors to be projected
            %
            % ## Output
            % * __Y__ PC coefficients
            %
            % The methods project one or more vectors to the principal
            % component subspace, where each vector projection is
            % represented by coefficients in the principal component basis.
            % The first form of the method returns the matrix that the
            % second form writes to the result. So the first form can be
            % used as a part of expression while the second form can be
            % more efficient in a processing loop.
            %
            % See also cv.PCA cv.PCA.backProject
            %
            Y = PCA_(this.id, 'project', X);
        end
        
        function X = backProject(this, Y)
            %BACKPROJECT  Reconstructs vectors from their PC projections
            %
            %    X = pca.backProject(Y)
            %
            % ## Input
            % * __Y__ PC coefficients
            %
            % ## Output
            % * __X__ Reconstructed vectors
            %
            % The methods are inverse operations to pca.project. They
            % take PC coordinates of projected vectors and reconstruct the
            % original vectors. Unless all the principal components have
            % been retained, the reconstructed vectors are different from
            % the originals. But typically, the difference is small if the
            % number of components is large enough (but still much smaller
            % than the original vector dimensionality). As a result, PCA is
            % used.
            %
            % See also cv.PCA cv.PCA.project
            %
            X = PCA_(this.id, 'backProject', Y);
        end
        
        function value = get.eigenvectors(this)
            %GET.EIGENVECTORS
            if isempty(this.eigenvectors)
                this.eigenvectors = PCA_(this.id, 'eigenvectors');
            end
            value = this.eigenvectors;
        end
        
        function value = get.eigenvalues(this)
            %GET.EIGENVALUES
            if isempty(this.eigenvalues)
                this.eigenvalues = PCA_(this.id, 'eigenvalues');
            end
            value = this.eigenvalues;
        end
        
        function value = get.mean(this)
            %GET.MEAN
            if isempty(this.mean)
                this.mean = PCA_(this.id, 'mean');
            end
            value = this.mean;
        end
    end
    
    methods (Static)
        function this = loadobj(obj)
            %LOADOBJ  Deserialization after load
            %
            % See also cv.PCA
            %
            this = cv.PCA(obj);
        end
    end
    
end
