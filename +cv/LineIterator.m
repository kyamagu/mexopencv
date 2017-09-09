%LINEITERATOR  Raster line iterator
%
%     [pos, count] = cv.LineIterator(img, pt1, pt2)
%     [...] = cv.LineIterator(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __img__ input image
% * __pt1__ first point `[x,y]`
% * __pt2__ second point `[x,y]`
%
% ## Output
% * __pos__ pixel position coordinates `[x,y]` as a `count-by-2` matrix
% * __count__ number of pixels along the line
%
% ## Options
% * __Connectivity__ 8-connected or 4-connected. default 8
% * __LeftToRight__ default false
%
% The function iterates over the line connecting `pt1` and `pt2`. The line
% will be clipped on the image boundaries. The line is 8-connected or
% 4-connected. If `LeftToRight=true`, then the iteration is always done from
% the left-most point to the right most, not to depend on the ordering of
% `pt1` and `pt2` parameters.
%
% The function is used to iterate over all the pixels on the raster line
% segment connecting two specified points.
%
% The function cv.LineIterator is used to get each pixel of a raster line. It
% can be treated as versatile implementation of the Bresenham algorithm where
% you can stop at each pixel and do some extra processing, for example, grab
% pixel values along the line or draw a line with an effect (for example, with
% XOR operation).
%
% The function cv.LineIterator returns the positions in the image, and the
% number of pixels along the line.
%
% ## Example
%
%     img = imread(fullfile(mexopencv.root(),'test','fruits.jpg'));
%     pt1 = [10 15];    % 0-based
%     pt2 = [200 100];  % 0-based
%
%     % grabs pixels along the line (pt1, pt2) from 8-bit 3-channel image
%     [xy,num] = cv.LineIterator(img, pt1, pt2, 'Connectivity',8);
%     xy = xy + 1;  % 1-based subscripts
%     c = zeros(num, size(img,3), class(img));
%     for i=1:num
%         c(i,:) = img(xy(i,2), xy(i,1), :);
%     end
%
% See also: improfile
%
