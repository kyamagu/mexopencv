classdef ContourFitting < handle
    %CONTOURFITTING  Contour Fitting algorithm using Fourier descriptors
    %
    % Contour fitting matches two contours `z_a` and `z_b` minimizing distance
    % `d(z_a, z_b) = sum_n (a_n - s * b_n * exp(j * (n * alpha + phi)))^2`
    % where `a_n` and `b_n` are Fourier descriptors of `z_a` and `z_b` and `s`
    % is a scaling factor and `phi` is angle rotation and `alpha` is starting
    % point factor adjustement.
    %
    % ## References:
    % [PersoonFu1977]:
    % > E Persoon and King-Sun Fu. "Shape discrimination using fourier
    % > descriptors". IEEE Transactions on Pattern Analysis and Machine
    % > Intelligence, 7(3):170-179, 1977.
    %
    % [BergerRaghunathan1998]:
    % > L Berger, V A Raghunathan, C Launay, D Ausserre, and Y Gallot.
    % > "Coalescence in 2 dimensions: experiments on thin copolymer films and
    % > numerical simulations". The European Physical Journal B - Condensed
    % > Matter and Complex Systems, 2(1):93-99, 1998.
    %
    % See also: cv.ContourFitting.ContourFitting, cv.matchShapes,
    %  cv.ShapeContextDistanceExtractor
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % number of Fourier descriptors used in
        % cv.ContourFitting.estimateTransformation equal to number of contour
        % points after resampling.
        CtrSize
        % number of Fourier descriptors used for optimal curve matching in
        % cv.ContourFitting.estimateTransformation when using vector of points
        FDSize
    end

    %% ContourFitting
    methods
        function this = ContourFitting(varargin)
            %CONTOURFITTING  Create ContourFitting object
            %
            %     obj = cv.ContourFitting()
            %     obj = cv.ContourFitting('OptionName',optionValue, ...)
            %
            % ## Options
            % * __CtrSize__ number of contour points after resampling.
            %   default 1024
            % * __FDSize__ number of Fourier descriptors. default 16
            %
            % See also: cv.ContourFitting.estimateTransformation
            %
            this.id = ContourFitting_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.ContourFitting
            %
            if isempty(this.id), return; end
            ContourFitting_(this.id, 'delete');
        end

        function [alphaPhiST, d] = estimateTransformation(this, src, ref, varargin)
            %ESTIMATETRANSFORMATION  Fits two closed curves using Fourier descriptors
            %
            %     [alphaPhiST, d] = obj.estimateTransformation(src, ref)
            %     [...] = obj.estimateTransformation(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __src__ Contour defining first shape (source), or Fourier
            %   descriptors if `FD` is true.
            % * __ref__ Contour defining second shape (target), or Fourier
            %   descriptors if `FD` is true.
            %
            % ## Output
            % * __alphaPhiST__ transformation as a 5-elements vector
            %   `[alpha, phi, s, Tx, Ty]`, where:
            %   * __alpha__ starting point factor adjustement
            %   * __phi__ angle rotation in radian
            %   * __s__ scaling factor
            %   * __Tx__, __Ty__ the translation
            % * __d__ distance between `src` and `ref` after matching.
            %
            % ## Options
            % * __FD__ If false then `src` and `ref` are contours, and
            %   if true `src` and `ref` are Fourier descriptors. default false
            %
            % When `FD` is false, it applies cv.ContourFitting.contourSampling
            % and cv.ContourFitting.fourierDescriptor to compute Fourier
            % descriptors.
            %
            % More details in [PersoonFu1977] and [BergerRaghunathan1998].
            %
            % See also: cv.ContourFitting.transformFD,
            %  cv.ContourFitting.contourSampling,
            %  cv.ContourFitting.fourierDescriptor
            %
            [alphaPhiST, d] = ContourFitting_(this.id, 'estimateTransformation', src, ref, varargin{:});
        end
    end

    %% Algorithm
    methods (Hidden)
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.ContourFitting.empty, cv.ContourFitting.load
            %
            ContourFitting_(this.id, 'clear');
        end

        function b = empty(this)
            %EMPTY  Checks if algorithm object is empty
            %
            %     b = obj.empty()
            %
            % ## Output
            % * __b__ Returns true if the algorithm object is empty
            %   (e.g. in the very beginning or after unsuccessful read).
            %
            % See also: cv.ContourFitting.clear, cv.ContourFitting.load
            %
            b = ContourFitting_(this.id, 'empty');
        end

        function save(this, filename)
            %SAVE  Saves the algorithm parameters to a file
            %
            %     obj.save(filename)
            %
            % ## Input
            % * __filename__ Name of the file to save to.
            %
            % This method stores the algorithm parameters in the specified
            % XML or YAML file.
            %
            % See also: cv.ContourFitting.load
            %
            ContourFitting_(this.id, 'save', filename);
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
            % This method reads algorithm parameters from the specified XML or
            % YAML file (either from disk or serialized string). The previous
            % algorithm state is discarded.
            %
            % See also: cv.ContourFitting.save
            %
            ContourFitting_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.ContourFitting.save, cv.ContourFitting.load
            %
            name = ContourFitting_(this.id, 'getDefaultName');
        end
    end

    %% Getters/Setters
    methods
        function value = get.CtrSize(this)
            value = ContourFitting_(this.id, 'get', 'CtrSize');
        end
        function set.CtrSize(this, value)
            ContourFitting_(this.id, 'set', 'CtrSize', value);
        end

        function value = get.FDSize(this)
            value = ContourFitting_(this.id, 'get', 'FDSize');
        end
        function set.FDSize(this, value)
            ContourFitting_(this.id, 'set', 'FDSize', value);
        end
    end

    %% Static functions
    methods (Static)
        function out = contourSampling(src, numElt)
            %CONTOURSAMPLING  Contour sampling
            %
            %     out = cv.ContourFitting.contourSampling(src, numElt)
            %
            % ## Input
            % * __src__ input contour, vector of 2D points stored in numeric
            %   array Nx2/Nx1x2/1xNx2 or cell array of 2-element vectors
            %   `{[x,y], ...}`.
            % * __NumElt__ number of points in `out` contour.
            %
            % ## Output
            % * __out__ output contour with `numElt` points.
            %
            % See also: cv.findContours, cv.approxPolyDP
            %
            out = ContourFitting_(0, 'contourSampling', src, numElt);
        end

        function dst = fourierDescriptor(src, varargin)
            %FOURIERDESCRIPTOR  Fourier descriptors for planed closed curves
            %
            %     dst = cv.ContourFitting.fourierDescriptor(src)
            %     dst = cv.ContourFitting.fourierDescriptor(src, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __src__ input contour, vector of 2D points stored in numeric
            %   array Nx2/Nx1x2/1xNx2 or cell array of 2-element vectors
            %   `{[x,y], ...}`.
            %
            % ## Output
            % * __dst__ 2-channel array of type `single` and length `NumElt`.
            %
            % ## Options
            % * __NumElt__ number of rows in `dst` or cv.getOptimalDFTSize
            %   rows if `NumElt=-1`. default -1
            % * __NumFD__ number of FD to return in `dst`,
            %   `dst = [FD(1...NumFD/2) FD(NumFD/2-NumElt+1...:NumElt)]`.
            %   default -1 (return all of FD as is).
            %
            % For more details about this implementation, please see
            % [PersoonFu1977].
            %
            % See also: cv.dft
            %
            dst = ContourFitting_(0, 'fourierDescriptor', src, varargin{:});
        end

        function dst = transformFD(src, t, varargin)
            %TRANSFORMFD  Transform a contour
            %
            %     dst = cv.ContourFitting.transformFD(src, t)
            %     dst = cv.ContourFitting.transformFD(src, t, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __src__ contour, or Fourier descriptors if `FD` is true.
            % * __t__ 1x5 transform matrix given by
            %   cv.ContourFitting.estimateTransformation method.
            %
            % ## Output
            % * __dst__ 2-channel matrix of type `double` and `NumElt` rows.
            %
            % ## Options
            % * __FD__ if true `src` are Fourier descriptors, if false `src`
            %   is a contour. default true
            %
            % See also: cv.ContourFitting.estimateTransformation,
            %  cv.ContourFitting.contourSampling,
            %  cv.ContourFitting.fourierDescriptor
            %
            dst = ContourFitting_(0, 'transformFD', src, t, varargin{:});
        end
    end

end
