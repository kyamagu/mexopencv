classdef RotationWarper < handle
    %ROTATIONWARPER  Rotation-only model image warper
    %
    % See also: cv.Stitcher, cv.remap
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % Projected image scale multiplier
        Scale
    end

    methods
        function this = RotationWarper(warperType, scale, varargin)
            %ROTATIONWARPER  Constructor
            %
            %     obj = cv.RotationWarper(warperType, scale)
            %     obj = cv.RotationWarper(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __warperType__ image warper factory class type, used to create
            %   the rotation-based warper. One of:
            %   * __PlaneWarper__ Plane warper factory class. Warper that maps
            %     an image onto the `z = 1` plane.
            %   * __AffineWarper__ Affine warper factory class. Affine warper
            %     that uses rotations and translations. Uses affine
            %     transformation in homogeneous coordinates to represent both
            %     rotation and translation in camera rotation matrix.
            %   * __CylindricalWarper__ Cylindrical warper factory class.
            %     Warper that maps an image onto the `x*x + z*z = 1` cylinder.
            %   * __SphericalWarper__ Spherical warper factory class. Warper
            %     that maps an image onto the unit sphere located at the
            %     origin. Projects image onto unit sphere with origin at
            %     [0,0,0] and radius `scale`, measured in pixels. A 360
            %     panorama would therefore have a resulting width of
            %     `2*scale*pi` pixels. Poles are located at [0,-1,0] and
            %     [0,1,0] points.
            %   * __PlaneWarperGpu__ (requires CUDA)
            %   * __CylindricalWarperGpu__ (requires CUDA)
            %   * __SphericalWarperGpu__ (requires CUDA)
            %   * __FisheyeWarper__
            %   * __StereographicWarper__
            %   * __CompressedRectilinearWarper__
            %   * __CompressedRectilinearPortraitWarper__
            %   * __PaniniWarper__
            %   * __PaniniPortraitWarper__
            %   * __MercatorWarper__
            %   * __TransverseMercatorWarper__
            % * __scale__ Projected image scale multiplier, e.g. 1.0
            %
            % ## Options
            % The following are options for the various warpers:
            %
            % ### `CompressedRectilinearWarper`, `CompressedRectilinearPortraitWarper`, `PaniniWarper`, `PaniniPortraitWarper`
            % * __A__ default 1
            % * __B__ default 1
            %
            % See also: cv.RotationWarper.warp
            %
            this.id = RotationWarper_(0, 'new', warperType, scale, varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.RotationWarper
            %
            if isempty(this.id), return; end
            RotationWarper_(this.id, 'delete');
        end

        function typename = typeid(this)
            %TYPEID  Name of the C++ type (RTTI)
            %
            %     typename = obj.typeid()
            %
            % ## Output
            % * __typename__ Name of C++ type
            %
            typename = RotationWarper_(this.id, 'typeid');
        end
    end

    %% RotationWarper
    methods
        function uv = warpPoint(this, pt, K, R)
            %WARPPOINT  Projects the image point
            %
            %     uv = obj.warpPoint(pt, K, R)
            %
            % ## Input
            % * __pt__ Source point `[x,y]`.
            % * __K__ Camera intrinsic parameters, 3x3 single matrix.
            % * __R__ Camera rotation matrix, 3x3 single matrix..
            %
            % ## Output
            % * __uv__ Projected point `[xx,yy]`.
            %
            % See also: cv.RotationWarper.warp
            %
            uv = RotationWarper_(this.id, 'warpPoint', pt, K, R);
        end

        function [xmap,ymap,bbox] = buildMaps(this, src_size, K, R)
            %BUILDMAPS  Builds the projection maps according to the given camera data
            %
            %     [xmap,ymap,bbox] = obj.buildMaps(src_size, K, R)
            %
            % ## Input
            % * **src_size** Source image size `[w,h]`.
            % * __K__ Camera intrinsic parameters, 3x3 single matrix.
            % * __R__ Camera rotation matrix, 3x3 single matrix.
            %
            % ## Output
            % * __xmap__ Projection map for the x-axis, `single` matrix.
            % * __ymap__ Projection map for the y-axis, `single` matrix.
            % * __bbox__ Projected image minimum bounding box `[x,y,w,h].
            %
            % See also: cv.RotationWarper.warp
            %
            [xmap,ymap,bbox] = RotationWarper_(this.id, 'buildMaps', src_size, K, R);
        end

        function [dst,tl] = warp(this, src, K, R, varargin)
            %WARP  Projects the image
            %
            %     [dst,tl] = obj.warp(src, K, R)
            %     [dst,tl] = obj.warp(src, K, R, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __src__ Source image.
            % * __K__ Camera intrinsic parameters, 3x3 single matrix.
            % * __R__ Camera rotation matrix, 3x3 single matrix.
            %
            % ## Output
            % * __dst__ Projected image.
            % * __tl__ Project image top-left corner point `[x,y]`.
            %
            % ## Options
            % * __InterpMode__ Interpolation mode, see cv.remap.
            %   default 'Linear'
            % * __BorderMode__ Border extrapolation mode, see cv.remap.
            %   default 'Constant'
            %
            % See also: cv.RotationWarper.RotationWarper
            %
            [dst,tl] = RotationWarper_(this.id, 'warp', src, K, R, varargin{:});
        end

        function dst = warpBackward(this, src, K, R, dst_size, varargin)
            %WARPBACKWARD  Projects the image backward
            %
            %     dst = obj.warpBackward(src, K, R, dst_size)
            %     dst = obj.warpBackward(src, K, R, dst_size, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __src__ Projected image.
            % * __K__ Camera intrinsic parameters, 3x3 single matrix.
            % * __R__ Camera rotation matrix, 3x3 single matrix.
            % * **dst_size** Backward-projected image size `[w,h]`.
            %
            % ## Output
            % * __dst__ Backward-projected image.
            %
            % ## Options
            % * __InterpMode__ Interpolation mode, see cv.remap.
            %   default 'Linear'
            % * __BorderMode__ Border extrapolation mode, see cv.remap.
            %   default 'Constant'
            %
            % See also: cv.RotationWarper.warp
            %
            dst = RotationWarper_(this.id, 'warpBackward', src, K, R, dst_size, varargin{:});
        end

        function bbox = warpRoi(this, src_size, K, R)
            %WARPROI  Projects image ROI
            %
            %     bbox = obj.warpRoi(src_size, K, R)
            %
            % ## Input
            % * **src_size** Source image bounding box, `[x,y,w,h].
            % * __K__ Camera intrinsic parameters, 3x3 single matrix.
            % * __R__ Camera rotation matrix, 3x3 single matrix.
            %
            % ## Output
            % * __bbox__ Projected image minimum bounding box `[x,y,w,h].
            %
            % See also: cv.RotationWarper.warp
            %
            bbox = RotationWarper_(this.id, 'warpRoi', src_size, K, R);
        end
    end

    %% Getters/Setters
    methods
        function value = get.Scale(this)
            value = RotationWarper_(this.id, 'get', 'Scale');
        end
        function set.Scale(this, value)
            RotationWarper_(this.id, 'set', 'Scale', value);
        end
    end

end
