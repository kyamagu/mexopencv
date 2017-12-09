classdef Rect
    %RECT  Class for 2D rectangles
    %
    % A rectangle `[x,y,w,h]` is described by the following parameters:
    %
    % * Coordinates of the top-left corner. This is a default interpretation
    %   of `[x,y]` in OpenCV. Though, in your algorithms you may count `x` and
    %   `y` from the bottom-left corner.
    % * Rectangle width and height `[w h]`.
    %
    % OpenCV typically assumes that the top and left boundary of the rectangle
    % are inclusive, while the right and bottom boundaries are not. For
    % example, the method cv.Rect.contains returns true if:
    %
    %     x <= pt.x < x + width , y <= pt.y < y + height
    %
    % Virtually every loop over an image ROI in OpenCV (where ROI is specified
    % by an integer rectangle) is implemented as:
    %
    %     roi = [x,y,w,h];
    %     for y=roi(2):(roi(2)+roi(4)-1)
    %         for x=roi(1):(roi(1)+roi(3)-1)
    %             %...
    %         end
    %     end
    %
    % In addition, the following operations on rectangles are implemented:
    %
    % * __adjustPosition__ (`rect += point`): shifting a rectangle by a
    %   certain offset.
    % * __adjustSize__ (`rect += size`): expanding or shrinking a rectangle by
    %   a certain amount.
    % * __intersect__ (`rect1 & rect2`): rectangle intersection.
    % * __union__ (`rect1 | rect2`): minimum area rectangle containing `rect1`
    %   and `rect2`.
    %
    % This is an example how the partial ordering on rectangles can be
    % established (`rect1 \subseteq rect2`):
    %
    %     function b = rect_le(r1, r2)
    %         b = all(cv.Rect.intersect(r1,r2) == r1);
    %     end
    %
    % See also: cv.RotatedRect
    %

    methods (Static)
        function r = from2points(pt1, pt2)
            %FROM2POINTS  Create a rectangle from 2 points
            %
            %     r = cv.Rect.from2points(pt1, pt2)
            %
            % ## Input
            % * __pt1__ First point `[x1,y1]`.
            % * __pt1__ Second point `[x2,y2]`.
            %
            % ## Output
            % * __r__ output rectangle `[x,y,w,h]`.
            %
            r = Rect_('from2points', pt1, pt2);
        end

        function pt = tl(r)
            %TL  The top-left corner
            %
            %     pt = cv.Rect.tl(r)
            %
            % ## Input
            % * __r__ rectangle `[x,y,w,h]`.
            %
            % ## Output
            % * __pt__ top-left corner `[x,y]`.
            %
            % See also: cv.Rect.br
            %
            pt = Rect_('tl', r);
        end

        function pt = br(r)
            %BR  The bottom-right corner
            %
            %     pt = cv.Rect.br(r)
            %
            % ## Input
            % * __r__ rectangle `[x,y,w,h]`.
            %
            % ## Output
            % * __pt__ bottom-right corner `[x+w,y+h]`.
            %
            % See also: cv.Rect.tl
            %
            pt = Rect_('br', r);
        end

        function sz = size(r)
            %SIZE  Size (width, height) of the rectangle
            %
            %     sz = cv.Rect.size(r)
            %
            % ## Input
            % * __r__ rectangle `[x,y,w,h]`.
            %
            % ## Output
            % * __sz__ size of the rectangle `[w,h]`.
            %
            % See also: cv.Rect.area
            %
            sz = Rect_('size', r);
        end

        function a = area(r)
            %AREA  Area (width*height) of the rectangle
            %
            %     out = cv.Rect.area(r)
            %
            % ## Input
            % * __r__ rectangle `[x,y,w,h]`.
            %
            % ## Output
            % * __a__ area of the rectangle `w*h`.
            %
            % See also: cv.Rect.size
            %
            a = Rect_('area', r);
        end

        function b = contains(r, pt)
            %CONTAINS  Checks whether the rectangle contains the point
            %
            %     b = cv.Rect.contains(r, pt)
            %
            % ## Input
            % * __r__ rectangle `[x,y,w,h]`
            % * __pt__ point `[x,y]`
            %
            % ## Output
            % * __b__ true or false.
            %
            % See also: cv.Point.inside
            %
            b = Rect_('contains', r, pt);
        end

        function r = adjustPosition(r, pt)
            %ADJUSTPOSITION  Shift a rectangle by a certain offset
            %
            %     r = cv.Rect.adjustPosition(r, pt)
            %
            % ## Input
            % * __r__ input rectangle `[x,y,w,h]`.
            % * __pt__ point `[ptx,pty]`.
            %
            % ## Output
            % * __r__ output rectangle `[x+ptx,y+pty,w,h]`.
            %
            % See also: cv.Rect.adjustSize
            %
            r = Rect_('adjustPosition', r, pt);
        end

        function r = adjustSize(r, sz)
            %ADJUSTSIZE  Expand or shrink a rectangle by a certain amount
            %
            %     r = cv.Rect.adjustSize(r, sz)
            %
            % ## Input
            % * __r__ input rectangle `[x,y,w,h]`.
            % * __sz__ size `[szw,szh]`.
            %
            % ## Output
            % * __r__ output rectangle `[x,y,w+szw,h+szh]`.
            %
            % See also: cv.Rect.adjustPosition
            %
            r = Rect_('adjustSize', r, sz);
        end

        function r = intersect(r1, r2)
            %INTERSECT  Rectangle intersection
            %
            %     r = cv.Rect.intersect(r1, r2)
            %
            % ## Input
            % * __r1__ first rectangle `[x1,y1,w1,h1]`.
            % * __r2__ second rectangle `[x2,y2,w2,h2]`.
            %
            % ## Output
            % * __r__ output rectangle `[x,y,w,h]`.
            %
            % See also: cv.Rect.union, bboxOverlapRatio, rectint
            %
            r = Rect_('intersect', r1, r2);
        end

        function r = union(r1, r2)
            %UNION  Minimum area rectangle
            %
            %     r = cv.Rect.union(r1, r2)
            %
            % ## Input
            % * __r1__ first rectangle `[x1,y1,w1,h1]`.
            % * __r2__ second rectangle `[x2,y2,w2,h2]`.
            %
            % ## Output
            % * __r__ output rectangle `[x,y,w,h]`.
            %
            % See also: cv.Rect.intersect, bboxOverlapRatio
            %
            r = Rect_('union', r1, r2);
        end

        function out = crop(img, r, roi)
            %CROP  Extract region-of-interest from image
            %
            %     roi = cv.Rect.crop(img, r)
            %     img = cv.Rect.crop(img, r, roi)
            %
            % ## Input
            % * __img__ input image.
            % * __r__ ROI rectangle `[x,y,w,h]`.
            % * __roi__ input cropped image, of size `[h,w]`, and same type
            %   and channels as input image `img`.
            %
            % ## Output
            % * __roi__ output cropped image.
            % * __img__ output image with updated ROI region.
            %
            % In the first variant, the function gets ROI region from image,
            % i.e: `roi = img(r(2)+1:r(2)+r(4), r(1)+1:r(1)+r(3), :)`.
            %
            % In the second variant, the function sets ROI region inside image,
            % i.e: `img(r(2)+1:r(2)+r(4), r(1)+1:r(1)+r(3), :) = roi`
            %
            % See also: cv.getRectSubPix, imcrop
            %
            if nargin < 3
                out = Rect_('crop', img, r);
            else
                out = Rect_('crop', img, r, roi);
            end
        end
    end

end
