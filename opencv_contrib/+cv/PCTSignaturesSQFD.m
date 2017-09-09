classdef PCTSignaturesSQFD < handle
    %PCTSIGNATURESSQFD  Class implementing Signature Quadratic Form Distance (SQFD)
    %
    % ## References
    % [BeecksUS10]:
    % > Christian Beecks, Merih Seran Uysal, Thomas Seidl.
    % > "Signature quadratic form distance". In Proceedings of the ACM
    % > International Conference on Image and Video Retrieval, pages 438-445.
    % > ACM, 2010.
    %
    % See also: cv.PCTSignaturesSQFD.computeQuadraticFormDistance,
    %  cv.PCTSignatures
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    %% Constructor/destructor
    methods
        function this = PCTSignaturesSQFD(varargin)
            %PCTSIGNATURESSQFD  Creates the algorithm instance using selected distance function, similarity function and similarity function parameter
            %
            %     obj = cv.PCTSignaturesSQFD()
            %     obj = cv.PCTSignaturesSQFD('OptionName',optionValue, ...)
            %
            % ## Options
            % * __DistanceFunction__ Lp Distance function selector. Available:
            %   * **L0_25**
            %   * **L0_5**
            %   * __L1__
            %   * __L2__ (default)
            %   * __L2Squared__
            %   * __L5__
            %   * **L_Inf**
            % * __SimilarityFunction__ Similarity function selector, for
            %   selected distance function `d(c_i, c_j)` and parameter
            %   `alpha`. Available:
            %   * __Minus__ `-d(c_i, c_j)`
            %   * __Gaussian__ `exp(-alpha * d^2(c_i, c_j))`
            %   * __Heuristic__ (default) `1/(alpha + d(c_i, c_j))`
            % * __SimilarityParameter__ Parameter of the similarity function.
            %   default 1.0
            %
            % See also: cv.PCTSignaturesSQFD.computeQuadraticFormDistance
            %
            this.id = PCTSignaturesSQFD_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.PCTSignaturesSQFD
            %
            if isempty(this.id), return; end
            PCTSignaturesSQFD_(this.id, 'delete');
        end
    end

    %% PCTSignaturesSQFD
    methods
        function dist = computeQuadraticFormDistance(this, signature0, signature1)
            %COMPUTEQUADRATICFORMDISTANCE  Computes Signature Quadratic Form Distance of two signatures
            %
            %     dist = obj.computeQuadraticFormDistance(signature0, signature1)
            %
            % ## Input
            % * __signature0__ The first signature.
            % * __signature1__ The second signature.
            %
            % ## Output
            % * __dist__ measured distance.
            %
            % See also: cv.PCTSignaturesSQFD.computeQuadraticFormDistances,
            %  cv.PCTSignatures.computeSignature
            %
            dist = PCTSignaturesSQFD_(this.id, 'computeQuadraticFormDistance', signature0, signature1);
        end

        function distances = computeQuadraticFormDistances(this, sourceSignature, imageSignatures)
            %COMPUTEQUADRATICFORMDISTANCES  Computes Signature Quadratic Form Distance between the reference signature and each of the other image signatures
            %
            %     distances = obj.computeQuadraticFormDistances(sourceSignature, imageSignatures)
            %
            % ## Input
            % * __sourceSignature__ The signature to measure distance of other
            %   signatures from.
            % * __imageSignatures__ Vector of signatures to measure distance
            %   from the source signature.
            %
            % ## Output
            % * __distances__ Output vector of measured distances.
            %
            % See also: cv.PCTSignaturesSQFD.computeQuadraticFormDistance,
            %  cv.PCTSignatures.computeSignatures
            %
            distances = PCTSignaturesSQFD_(this.id, 'computeQuadraticFormDistances', sourceSignature, imageSignatures);
        end
    end

    %% Algorithm
    methods (Hidden)
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.PCTSignaturesSQFD.empty
            %
            PCTSignaturesSQFD_(this.id, 'clear');
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
            % See also: cv.PCTSignaturesSQFD.clear
            %
            b = PCTSignaturesSQFD_(this.id, 'empty');
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
            % See also: cv.PCTSignaturesSQFD.save, cv.PCTSignaturesSQFD.load
            %
            name = PCTSignaturesSQFD_(this.id, 'getDefaultName');
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
            % See also: cv.PCTSignaturesSQFD.load
            %
            PCTSignaturesSQFD_(this.id, 'save', filename);
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
            % See also: cv.PCTSignaturesSQFD.save
            %
            PCTSignaturesSQFD_(this.id, 'load', fname_or_str, varargin{:});
        end
    end

end
