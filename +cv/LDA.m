classdef LDA < handle
    %LDA  Linear Discriminant Analysis
    %
    % See also: cv.PCA
    %

    properties (SetAccess = private)
        id  % Object ID
    end
    
    methods
        function this = LDA(varargin)
            %LDA  Constructor, initializes a LDA object.
            %
            %    lda = cv.LDA()
            %    lda = cv.LDA('OptionName', optionValue, ...)
            %
            % ## Options
            % * __NumComponents number of components (default 0). If 0 (or less)
            %       number of components are given, they are automatically
            %       determined for given data in computation.
            %
            this.id = LDA_(0, 'new', varargin{:});
        end
        
        function delete(this)
            %DELETE  Destructor
            %
            LDA_(this.id, 'delete');
        end
        
        function load(this, filename)
            %LOAD  Deserializes this object from a given filename.
            %
            LDA_(this.id, 'load', filename);
        end
        
        function save(this, filename)
            %SAVE  Serializes this object to a given filename.
            %
            LDA_(this.id, 'save', filename);
        end
        
        function ev = eigenvalues(this)
            %EIGENVALUES  Returns the eigenvalues of this LDA.
            %
            ev = LDA_(this.id, 'eigenvalues');
        end
        
        function ev = eigenvectors(this)
            %EIGENVECTORS  Returns the eigenvectors of this LDA.
            %
            ev = LDA_(this.id, 'eigenvectors');
        end
        
        function compute(this, src, labels)
            %COMPUTE  Compute the discriminants for data in src and labels.
            %
            LDA_(this.id, 'compute', src, labels);
        end
        
        function m = project(this, src)
            %PROJECT  Projects samples into the LDA subspace.
            %
            m = LDA_(this.id, 'project', src);
        end
        
        function m = reconstruct(this, src)
            %RECONSTRUCT  Reconstructs projections from the LDA subspace.
            %
            m = LDA_(this.id, 'reconstruct', src);
        end
    end

end
