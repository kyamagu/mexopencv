classdef ShapeContextDistanceExtractor < handle
    %SHAPECONTEXTDISTANCEEXTRACTOR  Implementation of the Shape Context descriptor and matching algorithm
    %
    % Proposed by [Belongie2002]. This implementation is packaged in a generic
    % scheme, in order to allow you the implementation of the common variations
    % of the original pipeline.
    %
    % ## References
    % [Belongie2002]:
    % > Belongie et al. "Shape Matching and Object Recognition using Shape
    % > Contexts" (PAMI 2002)
    %
    % See also: cv.ShapeContextDistanceExtractor.ShapeContextDistanceExtractor,
    %  cv.HausdorffDistanceExtractor, cv.matchShapes
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % The number of angular bins in the shape context descriptor.
        %
        % The number of angular bins for the Shape Context Descriptor used in
        % the shape matching pipeline. default 12
        AngularBins
        % The number of radial bins in the shape context descriptor.
        %
        % The number of radial bins for the Shape Context Descriptor used in
        % the shape matching pipeline. default 4
        RadialBins
        % The inner radius of the shape context descriptor.
        %
        % default 0.2
        InnerRadius
        % The outer radius of the shape context descriptor.
        %
        % default 2
        OuterRadius
        % default false
        RotationInvariant
        % The weight of the shape context distance in the final value of the
        % shape distance.
        %
        % The shape context distance between two shapes is defined as the
        % symmetric sum of shape context matching costs over best matching
        % points. The final value of the shape distance is a user-defined
        % linear combination of the shape context distance, an image
        % appearance distance, and a bending energy. default 1.0
        ShapeContextWeight
        % The weight of the image appearance cost in the final value of the
        % shape distance.
        %
        % The image appearance cost is defined as the sum of squared brightness
        % differences in Gaussian windows around corresponding image points.
        % The final value of the shape distance is a user-defined linear
        % combination of the shape context distance, an image appearance
        % distance, and a bending energy. If this value is set to a number
        % different from 0, is mandatory to set the images that correspond to
        % each shape. default 0.0
        ImageAppearanceWeight
        % The weight of the Bending Energy in the final distance value.
        %
        % The bending energy definition depends on what transformation is being
        % used to align the shapes. The final value of the shape distance is a
        % user-defined linear combination of the shape context distance, an
        % image appearance distance, and a bending energy. default 0.3
        BendingEnergyWeight
        % default 3
        Iterations
        % The standard deviation for the Gaussian window for the image
        % appearance cost.
        %
        % default 10.0
        StdDev
    end

    %% ShapeContextDistanceExtractor
    methods
        function this = ShapeContextDistanceExtractor(varargin)
            %SHAPECONTEXTDISTANCEEXTRACTOR  Constructor
            %
            %     obj = cv.ShapeContextDistanceExtractor()
            %     obj = cv.ShapeContextDistanceExtractor('OptionName',optionValue, ...)
            %
            % ## Options
            % * __AngularBins__ see
            %   cv.ShapeContextDistanceExtractor.AngularBins, default 12
            % * __RadialBins__ see
            %   cv.ShapeContextDistanceExtractor.RadialBins, default 4
            % * __InnerRadius__ see
            %   cv.ShapeContextDistanceExtractor.InnerRadius, default 0.2
            % * __OuterRadius__ see
            %   cv.ShapeContextDistanceExtractor.OuterRadius, default 2
            % * __Iterations__ see
            %   cv.ShapeContextDistanceExtractor.Iterations, default 3
            % * __CostExtractor__ an algorithm that defines the cost matrix
            %   between descriptors, specified as
            %   `{comparerType, 'OptionName',optionValue, ...}`. See
            %   cv.ShapeContextDistanceExtractor.setCostExtractor, where
            %   `comparerType` is one of:
            %   * __NormHistogramCostExtractor__
            %   * __EMDHistogramCostExtractor__
            %   * __ChiHistogramCostExtractor__ (default)
            %   * __EMDL1HistogramCostExtractor__
            % * __TransformAlgorithm__ an algorithm that defines the aligning
            %   transformation, specified as
            %   `{transformerType, 'OptionName',optionValue, ...}`. See
            %   cv.ShapeContextDistanceExtractor.setTransformAlgorithm, where
            %   `transformerType` is one of:
            %   * __ThinPlateSplineShapeTransformer__ (default)
            %   * __AffineTransformer__
            %
            % See also: cv.ShapeContextDistanceExtractor.computeDistance
            %
            this.id = ShapeContextDistanceExtractor_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.ShapeContextDistanceExtractor
            %
            if isempty(this.id), return; end
            ShapeContextDistanceExtractor_(this.id, 'delete');
        end

        function setImages(this, image1, image2)
            %SETIMAGES  Set the images that correspond to each shape, used in the calculation of the Image Appearance cost
            %
            %     obj.setImages(image1, image2)
            %
            % ## Input
            % * __image1__ Image corresponding to the shape defined by
            %   `contours1`.
            % * __image2__ Image corresponding to the shape defined by
            %   `contours2`.
            %
            % See also: cv.ShapeContextDistanceExtractor.getImages
            %
            ShapeContextDistanceExtractor_(this.id, 'setImages', image1, image2);
        end

        function setCostExtractor(this, comparerType, varargin)
            %SETCOSTEXTRACTOR  Set the algorithm used for building the shape context descriptor cost matrix
            %
            %     obj.setCostExtractor(comparerType)
            %     obj.setCostExtractor(comparerType, 'OptionName',optionValue,...)
            %
            % ## Input
            % * __comparerType__ an algorithm that defines the cost matrix
            %   between descriptors. One of:
            %   * __NormHistogramCostExtractor__ A norm based cost extraction.
            %     See cv.norm
            %   * __EMDHistogramCostExtractor__ An EMD based cost extraction.
            %     See cv.EMD
            %   * __ChiHistogramCostExtractor__ An Chi based cost extraction.
            %   * __EMDL1HistogramCostExtractor__ An EMD-L1 based cost
            %     extraction. See cv.EMDL1
            %
            % ## Options
            % The following are options accepted by all algorithms:
            %
            % * __NDummies__ default 25
            % * __DefaultCost__ default 0.2
            %
            % The following are options for the various algorithms:
            %
            % ### `NormHistogramCostExtractor`, `EMDHistogramCostExtractor`
            % * __NormFlag__ default 'L2'. This parameter matches the
            %   `NormType` and `DistType` flags of cv.norm and cv.EMD
            %   respectively.
            %
            % See also: cv.ShapeContextDistanceExtractor.getCostExtractor
            %
            ShapeContextDistanceExtractor_(this.id, 'setCostExtractor', comparerType, varargin{:});
        end

        function setTransformAlgorithm(this, transformerType, varargin)
            %SETTRANSFORMALGORITHM  Set the algorithm used for aligning the shapes
            %
            %     obj.setTransformAlgorithm(transformerType)
            %     obj.setTransformAlgorithm(transformerType, 'OptionName',optionValue,...)
            %
            % ## Input
            % * __transformerType__ an algorithm that defines the aligning
            %   transformation. One of:
            %   * __ThinPlateSplineShapeTransformer__ Definition of the
            %     transformation occupied in the paper [Bookstein89].
            %   * __AffineTransformer__ Wrapper class for the OpenCV Affine
            %     Transformation algorithm. See cv.estimateRigidTransform
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
            % See also: cv.ShapeContextDistanceExtractor.getTransformAlgorithm
            %
            ShapeContextDistanceExtractor_(this.id, 'setTransformAlgorithm', transformerType, varargin{:});
        end

        function [image1, image2] = getImages(this)
            %GETIMAGES  Get the images that correspond to each shape, used in the calculation of the Image Appearance cost
            %
            %     [image1, image2] = obj.getImages()
            %
            % ## Output
            % * __image1__ Image corresponding to the shape defined by
            %   `contours1`.
            % * __image2__ Image corresponding to the shape defined by
            %   `contours2`.
            %
            % See also: cv.ShapeContextDistanceExtractor.setImages
            %
            [image1, image2] = ShapeContextDistanceExtractor_(this.id, 'getImages');
        end

        function value = getCostExtractor(this)
            %GETCOSTEXTRACTOR  Get the current algorithm used for building the shape context descriptor cost matrix
            %
            %     value = obj.getCostExtractor()
            %
            % ## Output
            % * __value__ output scalar struct
            %
            % See also: cv.ShapeContextDistanceExtractor.setCostExtractor
            %
            value = ShapeContextDistanceExtractor_(this.id, 'getCostExtractor');
        end

        function value = getTransformAlgorithm(this)
            %GETTRANSFORMALGORITHM  Get the current algorithm used for aligning the shapes
            %
            %     value = obj.getTransformAlgorithm()
            %
            % ## Output
            % * __value__ output scalar struct
            %
            % See also: cv.ShapeContextDistanceExtractor.setTransformAlgorithm
            %
            value = ShapeContextDistanceExtractor_(this.id, 'getTransformAlgorithm');
        end
    end

    %% ShapeDistanceExtractor
    methods
        function dist = computeDistance(this, contour1, contour2)
            %COMPUTEDISTANCE  Compute the shape distance between two shapes defined by its contours
            %
            %     dist = obj.computeDistance(contour1, contour2)
            %
            % ## Options
            % * __contour1__ Contour defining first shape. A numeric
            %   Nx2/Nx1x2/1xNx2 array or a cell-array of 2D points
            %   `{[x,y], ...}`
            % * __contour2__ Contour defining second shape. Same format as
            %   `contours1`.
            %
            % ## Output
            % * __dist__ output distance.
            %
            % See also: cv.ShapeContextDistanceExtractor.ShapeContextDistanceExtractor
            %
            dist = ShapeContextDistanceExtractor_(this.id, 'computeDistance', contour1, contour2);
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.ShapeContextDistanceExtractor.empty,
            %  cv.ShapeContextDistanceExtractor.load
            %
            ShapeContextDistanceExtractor_(this.id, 'clear');
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
            % See also: cv.ShapeContextDistanceExtractor.clear,
            %  cv.ShapeContextDistanceExtractor.load
            %
            b = ShapeContextDistanceExtractor_(this.id, 'empty');
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
            % See also: cv.ShapeContextDistanceExtractor.load
            %
            ShapeContextDistanceExtractor_(this.id, 'save', filename);
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
            % See also: cv.ShapeContextDistanceExtractor.save
            %
            ShapeContextDistanceExtractor_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.ShapeContextDistanceExtractor.save,
            %  cv.ShapeContextDistanceExtractor.load
            %
            name = ShapeContextDistanceExtractor_(this.id, 'getDefaultName');
        end
    end

    %% Getters/Setters
    methods
        function value = get.AngularBins(this)
            value = ShapeContextDistanceExtractor_(this.id, 'get', 'AngularBins');
        end
        function set.AngularBins(this, value)
            ShapeContextDistanceExtractor_(this.id, 'set', 'AngularBins', value);
        end

        function value = get.RadialBins(this)
            value = ShapeContextDistanceExtractor_(this.id, 'get', 'RadialBins');
        end
        function set.RadialBins(this, value)
            ShapeContextDistanceExtractor_(this.id, 'set', 'RadialBins', value);
        end

        function value = get.InnerRadius(this)
            value = ShapeContextDistanceExtractor_(this.id, 'get', 'InnerRadius');
        end
        function set.InnerRadius(this, value)
            ShapeContextDistanceExtractor_(this.id, 'set', 'InnerRadius', value);
        end

        function value = get.OuterRadius(this)
            value = ShapeContextDistanceExtractor_(this.id, 'get', 'OuterRadius');
        end
        function set.OuterRadius(this, value)
            ShapeContextDistanceExtractor_(this.id, 'set', 'OuterRadius', value);
        end

        function value = get.RotationInvariant(this)
            value = ShapeContextDistanceExtractor_(this.id, 'get', 'RotationInvariant');
        end
        function set.RotationInvariant(this, value)
            ShapeContextDistanceExtractor_(this.id, 'set', 'RotationInvariant', value);
        end

        function value = get.ShapeContextWeight(this)
            value = ShapeContextDistanceExtractor_(this.id, 'get', 'ShapeContextWeight');
        end
        function set.ShapeContextWeight(this, value)
            ShapeContextDistanceExtractor_(this.id, 'set', 'ShapeContextWeight', value);
        end

        function value = get.ImageAppearanceWeight(this)
            value = ShapeContextDistanceExtractor_(this.id, 'get', 'ImageAppearanceWeight');
        end
        function set.ImageAppearanceWeight(this, value)
            ShapeContextDistanceExtractor_(this.id, 'set', 'ImageAppearanceWeight', value);
        end

        function value = get.BendingEnergyWeight(this)
            value = ShapeContextDistanceExtractor_(this.id, 'get', 'BendingEnergyWeight');
        end
        function set.BendingEnergyWeight(this, value)
            ShapeContextDistanceExtractor_(this.id, 'set', 'BendingEnergyWeight', value);
        end

        function value = get.Iterations(this)
            value = ShapeContextDistanceExtractor_(this.id, 'get', 'Iterations');
        end
        function set.Iterations(this, value)
            ShapeContextDistanceExtractor_(this.id, 'set', 'Iterations', value);
        end

        function value = get.StdDev(this)
            value = ShapeContextDistanceExtractor_(this.id, 'get', 'StdDev');
        end
        function set.StdDev(this, value)
            ShapeContextDistanceExtractor_(this.id, 'set', 'StdDev', value);
        end
    end

end
