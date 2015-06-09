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
    % ## Example
    % The following shows a quick example of how to reduce dimensionality
    % of samples from 10 to 3.
    %
    %    Xtrain = randn(100,10);
    %    Xtest  = randn(100,10);
    %    pca = cv.PCA(Xtrain, 'MaxComponents',3);
    %    Y = pca.project(Xtest);
    %    Xapprox = pca.backProject(Y);
    %
    % The class also implements the save/load pattern to regular MAT-files,
    % so we can do the following:
    %
    %    pca = cv.PCA(randn(100,5));
    %    save out.mat pca
    %    clear pca
    %
    %    load out.mat
    %    disp(pca)
    %
    % See also cv.PCA.PCA
    %

    properties (SetAccess = private)
        id    % Object ID
    end

    % cached properties of their C++ couterpart
    properties (Access = private, Hidden)
        p_eigenvectors
        p_eigenvalues
        p_mean
    end

    % publicly exposed properties (backed by the cached ones)
    properties (Dependent)
        % Eigenvectors of the covariation matrix.
        eigenvectors
        % Eigenvalues of the covariation matrix.
        eigenvalues
        % Mean value subtracted before the projection and added after
        % the back projection.
        mean
    end

    methods
        function this = PCA(varargin)
            %PCA  PCA constructors
            %
            %    pca = cv.PCA()
            %    pca = cv.PCA(data, 'OptionName', optionValue, ...)
            %    pca = cv.PCA(S)
            %
            % ## Input
            % * __data__ input samples stored as matrix rows or matrix columns
            % * __S__ A scalar struct to be imported
            %
            % ## Options
            % Same set of options as the cv.PCA.compute method.
            %
            % The constructor creates an empty PCA object without an argument.
            % Use cv.PCA.compute to analyze data samples. The second form
            % accepts data samples with the same arguments as cv.PCA.compute.
            % The third form create a new PCA object from a scalar struct with
            % 'eigenvectors', 'eigenvalues', and 'mean' fields.
            %
            % See also: cv.PCA, cv.PCA.compute
            %
            this.id = PCA_(0,'new');
            if nargin > 0
                if nargin==1 && isstruct(varargin{1}) && isscalar(varargin{1})
                    S = varargin{1};
                    this.eigenvectors = S.eigenvectors;
                    this.eigenvalues = S.eigenvalues;
                    this.mean = S.mean;
                else
                    this.compute(varargin{:});
                end
            end
        end

        function delete(this)
            %DELETE  PCA destructor
            %
            % See also cv.PCA
            %
            PCA_(this.id, 'delete');
        end

        function read(this, filename, varargin)
            %READ  Read PCA from file
            %
            %    obj.read(filename)
            %    obj.read(str, 'FromString',true)
            %    obj.read(..., 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __filename__ Name of the file to read.
            % * __str__ String containing serialized object you want to load.
            %
            % ## Options
            % * __FromString__ Logical flag to indicate whether the input is
            %       a filename or a string containing the serialized object.
            %       default false
            %
            % See also: cv.PCA.write
            %
            PCA_(this.id, 'read', filename, varargin{:});
        end

        function write(this, filename)
            %WRITE  Write PCA to file
            %
            %    obj.write(filename)
            %
            % ## Input
            % * __filename__ Name of the file to write to.
            %
            % See also: cv.PCA.read
            %
            PCA_(this.id, 'write', filename);
        end

        function compute(this, data, varargin)
            %COMPUTE  Performs Principal Component Analysis on the supplied dataset
            %
            %    pca.compute(data)
            %    pca.compute(..., 'OptionName', optionValue, ...)
            %
            % ## Input
            % * __data__ input samples stored as the matrix rows or as the
            %       matrix columns
            %
            % ## Options
            % * __DataAs__ Data layout option. One of 'Row' or 'Col'.
            %       default 'Row':
            %       * __Row__ indicates that the input samples are stored as
            %             matrix rows.
            %       * __Col__ indicates that the input samples are stored as
            %             matrix columns.
            % * __MaxComponents__ Maximum number of components that PCA should
            %       retain. default 0 (all the components are retained).
            % * __RetainedVariance__ Percentage of variance that PCA should
            %       retain. Using this parameter will let the PCA decided how
            %       many components to retain but it will always keep at
            %       least 2. default 1.0 (all the components are retained).
            % * __Mean__ Optional mean value. By default, the mean is computed
            %       from the data. Not set by default.
            %
            % **Note**: `RetainedVariance` and `MaxComponents` are mutually
            % exclusive options, and shoudn't be used together.
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
            % cv.PCA.eigenvectors rows.
            %
            % See also: cv.PCA.PCA, cv.PCA.project, cv.PCA.backProject
            %
            PCA_(this.id, 'compute', data, varargin{:});

            % invalidate cached properties
            this.p_eigenvectors = [];
            this.p_eigenvalues = [];
            this.p_mean = [];
        end

        function Y = project(this, X)
            %PROJECT  Projects vector(s) to the principal component subspace
            %
            %    Y = pca.project(X)
            %
            % ## Input
            % * __X__ input vector(s); must have the same dimensionality and
            %       the same layout as the input data used at PCA phase, that
            %       is, if 'Row' was specified, then `size(X,2)==size(data,2)`
            %       (vector dimensionality) and `size(X,1)` is the number of
            %       vectors to project, and the same is true for the 'Col'
            %       case.
            %
            % ## Output
            % * __Y__ output vectors (PC coefficients); in case of 'Col', the
            %       output matrix has as many columns as the number of input
            %       vectors, this means that `size(Y,2)==size(X,2)` and the
            %       number of rows match the number of principal components
            %       (for example, `MaxComponents` parameter passed to the
            %       constructor).
            %
            % The method project one or more vectors to the principal
            % component subspace, where each vector projection is
            % represented by coefficients in the principal component basis.
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
            % * __Y__ coordinates of the vectors in the principal component
            %       subspace, the layout and size are the same as of
            %       cv.PCA.project output vectors.
            %
            % ## Output
            % * __X__ reconstructed vectors; the layout and size are the same
            %       as of cv.PCA.project input vectors.
            %
            % The method is the inverse operation to cv.PCA.project. It
            % takes PC coordinates of projected vectors and reconstruct the
            % original vectors. Unless all the principal components have
            % been retained, the reconstructed vectors are different from
            % the originals. But typically, the difference is small if the
            % number of components is large enough (but still much smaller
            % than the original vector dimensionality). As a result, PCA is
            % used.
            %
            % See also: cv.PCA.compute, cv.PCA.project
            %
            X = PCA_(this.id, 'backProject', Y);
        end
    end

    %% Getters/Setters for dependent properties
    methods
        function value = get.eigenvectors(this)
            if isempty(this.p_eigenvectors)
                this.p_eigenvectors = PCA_(this.id, 'get', 'eigenvectors');
            end
            value = this.p_eigenvectors;
        end
        function set.eigenvectors(this, value)
            PCA_(this.id, 'set', 'eigenvectors', value);
            this.p_eigenvectors = value;
        end

        function value = get.eigenvalues(this)
            if isempty(this.p_eigenvalues)
                this.p_eigenvalues = PCA_(this.id, 'get', 'eigenvalues');
            end
            value = this.p_eigenvalues;
        end
        function set.eigenvalues(this, value)
            PCA_(this.id, 'set', 'eigenvalues', value);
            this.p_eigenvalues = value;
        end

        function value = get.mean(this)
            if isempty(this.p_mean)
                this.p_mean = PCA_(this.id, 'get', 'mean');
            end
            value = this.p_mean;
        end
        function set.mean(this, value)
            PCA_(this.id, 'set', 'mean', value);
            this.p_mean = value;
        end
    end

    methods (Hidden)
        function S = struct(this)
            %STRUCT  Converts to a struct array
            %
            %    S = struct(obj)
            %
            % ## Output
            % * __S__ output struct array
            %
            % See also cv.PCA
            %
            S = struct('eigenvectors',{this.eigenvectors},...
                       'eigenvalues', {this.eigenvalues},...
                       'mean',        {this.mean});
        end

        function S = saveobj(this)
            %SAVEOBJ  Serialization before save
            %
            % See also cv.PCA.loadobj
            %
            S = struct(this);
        end
    end

    methods (Static, Hidden)
        function this = loadobj(S)
            %LOADOBJ  Deserialization after load
            %
            % See also: cv.PCA.PCA, cv.PCA.saveobj
            %
            this = cv.PCA(S);
        end
    end

end
