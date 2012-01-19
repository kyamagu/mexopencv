%GETRECTSUBPIX  Retrieves a pixel rectangle from an image with sub-pixel accuracy
%
%   dst = cv.getRectSubPix(src, siz, center)
%
% Input:
%     src: Source image.
%     siz: Size of the extracted patch.
%     center: Floating point coordinates of the center of the extracted
%             rectangle within the source image. The center must be inside the
%             image.
% Output:
%     dst: Extracted patch that has the size patchSize and the same number of
%          channels as src.
%
% The function getRectSubPix extracts pixels from src:
% 
%   dst(x,y) = src(x+center.x-(dst.cols-1)*0.5, y+center.y-(dst.rows-1)*0.5))
%
% where the values of the pixels at non-integer coordinates are retrieved using
% bilinear interpolation. Every channel of multi-channel images is processed
% independently. While the center of the rectangle must be inside the image,
% parts of the rectangle may be outside. In this case, the replication border
% mode is used to extrapolate the pixel values outside of the image.
%