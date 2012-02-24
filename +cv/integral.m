%INTEGRAL  Calculates the integral of an image
%
%    s = cv.integral(src)
%    [s, sqsum, tilted] = cv.integral(src)
%
% ## Input
% * __src__ Source image as W x H, 8-bit or floating-point (32f or 64f).
%
% ## Output
% * __s__ Integral image as (W+1) x (H+1), 32-bit integer or floating-point (32f
%        or 64f).
% * __sqsum__ Integral image for squared pixel values. It is (W+1) x (H+1),
%        double-precision floating-point (64f) array.
% * __tilted__ Integral for the image rotated by 45 degrees. It is (W+1) x (H+1)
%        array with the same data type as sum.
%
% The functions calculate one or more integral images for the source image as
% follows:
%
%     s(X,Y) = \sum_{x<X,y<Y} src(x,y)
%     sqsum(X,Y) = \sum_{x<X,y<Y} src(x,y)^2
%     tilted(X,Y) = \sum_{y<Y,\abs(x-X+1) \leq Y-y-1} src(x,y)
%
% Using these integral images, you can calculate sa um, mean, and standard
% deviation over a specific up-right or rotated rectangular region of the image
% in a constant time, for example:
%
%     \sum_{x_1 \leq x < x_2, y_1 \leq y < y_2} src(x,y)
%     = s(x_2, y_2) - s(x_1, y_2) - s(x_2, y_1) + s(x_1, y_1)
%
% It makes possible to do a fast blurring or fast block correlation with a
% variable window size, for example. In case of multi-channel images, sums for
% each channel are accumulated independently.
%
