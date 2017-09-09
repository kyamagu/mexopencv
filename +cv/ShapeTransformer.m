classdef ShapeTransformer < handle
    %SHAPETRANSFORMER  Base class for shape transformation algorithms
    %
    % See also: cv.ShapeTransformer.ShapeTransformer,
    %  cv.ShapeContextDistanceExtractor, tpaps
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent, Hidden)
        % The regularization parameter for relaxing the exact interpolation
        % requirements of the TPS algorithm.
        % Beta value of the regularization parameter, default 0
        % (only applicable for ThinPlateSplineShapeTransformer)
        RegularizationParameter
        % default true
        % (only applicable for AffineTransformer)
        FullAffine
    end

    %% Constructor/destructor
    methods
        function this = ShapeTransformer(transformerType, varargin)
            %SHAPETRANSFORMER  Constructor
            %
            %     obj = cv.ShapeTransformer(transformerType)
            %     obj = cv.ShapeTransformer(transformerType, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __transformerType__ an algorithm that defines the aligning
            %   transformation. One of:
            %   * __ThinPlateSplineShapeTransformer__ Definition of the
            %     transformation occupied in the paper [Bookstein89].
            %   * __AffineTransformer__ Wrapper class for the OpenCV Affine
            %     Transformation algorithm. See cv.estimateRigidTransform,
            %     cv.warpAffine, and cv.transform
            %
            % ## Options
            % The following are options for the various algorithms:
            %
            % ### `ThinPlateSplineShapeTransformer`
            % * __RegularizationParameter__ The regularization parameter for
            %   relaxing the exact interpolation requirements of the TPS
            %   algorithm. default 0
            %
            % ### `AffineTransformer`
            % * __FullAffine__ see cv.estimateRigidTransform, default true
            %
            % ## References
            % [Bookstein89]:
            % > "Principal Warps: Thin-Plate Splines and Decomposition of
            % > Deformations", by F.L. Bookstein (PAMI 1989)
            %
            % See also: cv.ShapeTransformer.estimateTransformation
            %
            this.id = ShapeTransformer_(0, 'new', transformerType, varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.ShapeTransformer
            %
            if isempty(this.id), return; end
            ShapeTransformer_(this.id, 'delete');
        end
    end

    %% ShapeTransformer
    methods
        function estimateTransformation(this, transformingShape, targetShape, matches)
            %ESTIMATETRANSFORMATION  Estimate the transformation parameters of the current transformer algorithm, based on point matches
            %
            %     obj.estimateTransformation(transformingShape, targetShape, matches)
            %
            % ## Input
            % * __transformingShape__ Contour defining first shape. A numeric
            %   Nx2/Nx1x2/1xNx2 array or a cell-array of 2D points
            %   `{[x,y], ...}`
            % * __targetShape__ Contour defining second shape (target). Same
            %   format as `transformingShape`.
            % * __matches__ Standard vector of matches between points.
            %
            % See also: cv.ShapeTransformer.applyTransformation,
            %  cv.ShapeTransformer.warpImage
            %
            ShapeTransformer_(this.id, 'estimateTransformation', transformingShape, targetShape, matches);
        end

        function [cost, output] = applyTransformation(this, input)
            %APPLYTRANSFORMATION  Apply a transformation, given a pre-estimated transformation parameters
            %
            %     [cost, output] = obj.applyTransformation(input)
            %
            % ## Input
            % * __input__ Contour (set of points) to apply the transformation.
            %
            % ## Output
            % * __cost__ Transformation cost.
            % * __output__ Output contour.
            %
            % See also: cv.ShapeTransformer.estimateTransformation
            %
            [cost, output] = ShapeTransformer_(this.id, 'applyTransformation', input);
        end

        function output = warpImage(this, transformingImage, varargin)
            %WARPIMAGE  Apply a transformation, given a pre-estimated transformation parameters, to an Image
            %
            %     output = obj.warpImage(transformingImage)
            %     output = obj.warpImage(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __transformingImage__ Input image.
            %
            % ## Output
            % * __output__ Output image.
            %
            % ## Options
            % * __Interpolation__ Image interpolation method. default 'Linear'
            % * __BorderType__ border style. default 'Constant'
            % * __BorderValue__ border value. default 0
            %
            % See cv.remap or cv.warpAffine for options description.
            %
            % See also: cv.ShapeTransformer.estimateTransformation
            %
            output = ShapeTransformer_(this.id, 'warpImage', transformingImage, varargin{:});
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.ShapeTransformer.empty, cv.ShapeTransformer.load
            %
            ShapeTransformer_(this.id, 'clear');
        end

        function b = empty(this)
            %EMPTY  Returns true if the algorithm is empty
            %
            %     b = obj.empty()
            %
            % ## Output
            % * __b__ Returns true if the detector object is empty (e.g in the
            %   very beginning or after unsuccessful read).
            %
            % See also: cv.ShapeTransformer.clear, cv.ShapeTransformer.load
            %
            b = ShapeTransformer_(this.id, 'empty');
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
            % See also: cv.ShapeTransformer.load
            %
            ShapeTransformer_(this.id, 'save', filename);
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
            % See also: cv.ShapeTransformer.save
            %
            ShapeTransformer_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.ShapeTransformer.save, cv.ShapeTransformer.load
            %
            name = ShapeTransformer_(this.id, 'getDefaultName');
        end
    end

    %% Getters/Setters
    methods
        function value = get.RegularizationParameter(this)
            value = ShapeTransformer_(this.id, 'get', 'RegularizationParameter');
        end
        function set.RegularizationParameter(this, value)
            ShapeTransformer_(this.id, 'set', 'RegularizationParameter', value);
        end

        function value = get.FullAffine(this)
            value = ShapeTransformer_(this.id, 'get', 'FullAffine');
        end
        function set.FullAffine(this, value)
            ShapeTransformer_(this.id, 'set', 'FullAffine', value);
        end
    end

end
