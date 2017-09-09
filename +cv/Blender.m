classdef Blender < handle
    %BLENDER  Class for all image blenders
    %
    % See also: cv.Stitcher
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    methods
        function this = Blender(blenderType, varargin)
            %BLENDER  Constructor
            %
            %     obj = cv.Blender(blenderType)
            %     obj = cv.Blender(blenderType, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __blenderType__ image blender type. One of:
            %   * __NoBlender__ Simple blender which puts one image over
            %     another.
            %   * __FeatherBlender__ Simple blender which mixes images at its
            %     borders.
            %   * __MultiBandBlender__ Blender which uses multi-band blending
            %     algorithm (see [BA83]).
            %
            % ## Options
            % The following are options for the various algorithms:
            %
            % ### `FeatherBlender`
            % * __Sharpness__ default 0.02
            %
            % ### `MultiBandBlender`
            % * __TryGPU__ default false
            % * __NumBands__ default 5
            % * __WeightType__ One of:
            %   * __single__ (default)
            %   * __int16__
            %
            % ## References
            % [BA83]:
            % > Peter J Burt and Edward H Adelson.
            % > "A multiresolution spline with application to image mosaics".
            % > ACM Transactions on Graphics (TOG), 2(4):217-236, 1983.
            %
            % See also: cv.Blender.blend
            %
            this.id = Blender_(0, 'new', blenderType, varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.Blender
            %
            if isempty(this.id), return; end
            Blender_(this.id, 'delete');
        end

        function typename = typeid(this)
            %TYPEID  Name of the C++ type (RTTI)
            %
            %     typename = obj.typeid()
            %
            % ## Output
            % * __typename__ Name of C++ type
            %
            typename = Blender_(this.id, 'typeid');
        end
    end

    %% Blender
    methods
        function prepare(this, varargin)
            %PREPARE  Prepares the blender for blending
            %
            %     obj.prepare(corners, sizes)
            %     obj.prepare(dst_roi)
            %
            % ## Input
            % * __corners__ Source images top-left corners. Cell-array of 2D
            %   points `{[x,y],...}`.
            % * __sizes__ Source image sizes. Cell-array of sizes
            %   `{[w,h],...}`.
            % * **dst_roi** Destination ROI rectangle `[x,y,w,h]`, same as
            %   obtained by calling `cv.Blender.resultRoi(corners,sizes)`.
            %
            % See also: cv.Blender.feed
            %
            Blender_(this.id, 'prepare', varargin{:});
        end

        function feed(this, img, mask, tl)
            %FEED  Processes the image
            %
            %     obj.feed(img, mask, tl)
            %
            % ## Input
            % * __img__ Source image, 3-channel of type `int16`.
            % * __mask__ Source image mask, 1-channel of type `uint8`.
            % * __tl__ Source image top-left corners `[x,y]`.
            %
            % See also: cv.Blender.blend
            %
            Blender_(this.id, 'feed', img, mask, tl);
        end

        function [dst, dst_mask] = blend(this, varargin)
            %BLEND  Blends and returns the final pano
            %
            %     [dst, dst_mask] = obj.blend()
            %     [dst, dst_mask] = obj.blend('OptionName',optionValue, ...)
            %
            % ## Output
            % * __dst__ Final pano, of type `int16`.
            % * **dst_mask** Final pano mask, of type `uint8`.
            %
            % ## Options
            % * __Dst__
            % * __Mask__
            %
            % See also: cv.Blender.feed
            %
            [dst, dst_mask] = Blender_(this.id, 'blend', varargin{:});
        end
    end

    %% FeatherBlender
    methods
        function [weight_maps, dst_roi] = createWeightMaps(this, masks, corners)
            %CREATEWEIGHTMAPS  Creates weight maps for fixed set of source images by their masks and top-left corners
            %
            %     [weight_maps, dst_roi] = obj.createWeightMaps(masks, corners)
            %
            % ## Input
            % * __masks__ Cell-array of image masks.
            % * __corners__ Cell-array of top-left corners `{[x,y],...}`.
            %
            % ## Output
            % * **weight_maps** Cell-array of weight maps.
            % * **dst_roi** ROI rectangle `[x,y,w,h]`.
            %
            % Final image can be obtained by simple weighting of the source
            % images.
            %
            [weight_maps, dst_roi] = Blender_(this.id, 'createWeightMaps', masks, corners);
        end
    end

    %% Auxiliary methods
    methods (Static)
        function pyr = createLaplacePyr(img, num_levels, varargin)
            %CREATELAPLACEPYR  Create Laplace pyramid
            %
            %     pyr = cv.Blender.createLaplacePyr(img, num_levels)
            %     pyr = cv.Blender.createLaplacePyr(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __img__ Input image.
            % * **num_levels** Number of pyramid levels.
            %
            % ## Output
            % * __pyr__ Laplace pyramid, cell-array of matrices.
            %
            % ## Options
            % * __UseGPU__ (requires CUDA). default false
            %
            % See also: cv.Blender.restoreImageFromLaplacePyr, cv.buildPyramid
            %
            pyr = Blender_(0, 'createLaplacePyr', img, num_levels, varargin{:});
        end

        function img = restoreImageFromLaplacePyr(pyr, varargin)
            %RESTOREIMAGEFROMLAPLACEPYR  Restore source image from Laplace pyramid
            %
            %     img = cv.Blender.restoreImageFromLaplacePyr(pyr)
            %     img = cv.Blender.restoreImageFromLaplacePyr(pyr, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __pyr__ Laplace pyramid, cell-array of matrices.
            %
            % ## Output
            % * __img__ Output image.
            %
            % ## Options
            % * __UseGPU__ (requires CUDA). default false
            %
            % See also: cv.Blender.createLaplacePyr, cv.buildPyramid
            %
            img = Blender_(0, 'restoreImageFromLaplacePyr', pyr, varargin{:});
        end

        function [roi,success] = overlapRoi(tl1, tl2, sz1, sz2)
            %OVERLAPROI  Overlap ROI
            %
            %     [roi,success] = cv.Blender.overlapRoi(tl1, tl2, sz1, sz2)
            %
            % ## Input
            % * __tl1__ First top-left corner `[x1,y1]`.
            % * __tl2__ Second top-left corner `[x2,y2]`.
            % * __sz1__ First size `[w1,h1]`.
            % * __sz2__ Second size `[w2,h2]`.
            %
            % ## Output
            % * __roi__ Output rectangle `[x,y,w,h]`.
            % * __success__ Success flag.
            %
            % See also: cv.Blender.resultRoi
            %
            [roi,success] = Blender_(0, 'overlapRoi', tl1, tl2, sz1, sz2);
        end

        function roi = resultRoi(corners, sizes)
            %RESULTROI  Result ROI
            %
            %     roi = cv.Blender.resultRoi(corners, sizes)
            %
            % ## Input
            % * __corners__ Cell-array of top-left corners `{[x,y],...}`.
            % * __sizes__ Cell-array of corresponding sizes `{[w,h],...}`.
            %
            % ## Output
            % * __roi__ Output rectangle `[x,y,w,h]`.
            %
            % See also: cv.Blender.resultRoiIntersection
            %
            roi = Blender_(0, 'resultRoi', corners, sizes);
        end

        function roi = resultRoiIntersection(corners, sizes)
            %RESULTROIINTERSECTION  Result ROI intersection
            %
            %     roi = cv.Blender.resultRoiIntersection(corners, sizes)
            %
            % ## Input
            % * __corners__ Cell-array of top-left corners `{[x,y],...}`.
            % * __sizes__ Cell-array of corresponding sizes `{[w,h],...}`.
            %
            % ## Output
            % * __roi__ Output rectangle `[x,y,w,h]`.
            %
            % See also: cv.Blender.resultRoi
            %
            roi = Blender_(0, 'resultRoiIntersection', corners, sizes);
        end

        function tl = resultTl(corners)
            %RESULTTL  Result top-left corner
            %
            %     tl = cv.Blender.resultTl(corners)
            %
            % ## Input
            % * __corners__ Cell-array of top-left corners `{[x,y],...}`.
            %
            % ## Output
            % * __tl__ top-left corner `[x,y]`
            %
            % See also: cv.Blender.resultRoi
            %
            tl = Blender_(0, 'resultTl', corners);
        end
    end

end
