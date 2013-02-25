%PYRMEANSHIFTFILTERING  Performs initial step of meanshift segmentation of an image
%
%    dst = cv.pyrMeanShiftFiltering(src)
%    dst = cv.pyrMeanShiftFiltering(src, 'SP', 5, ...)
%
% ## Input
% * __src__ The source 8-bit, 3-channel image.
%
% ## Output
% * __dst__ The destination image of the same format and the same size as the
%         source.
%
% ## Options
% * __SP__ The spatial window radius. default 5
% * __SR__ The color window radius. default 10
% * __MaxLevel__ Maximum level of the pyramid for the segmentation
%
% The function implements the filtering stage of meanshift segmentation, that
% is, the output of the function is the filtered posterized image with color
% gradients and fine-grain texture flattened. At every pixel (X,Y) of the input
% image (or down-sized input image, see below) the function executes meanshift
% iterations, that is, the pixel (X,Y) neighborhood in the joint space-color
% hyperspace is considered:
% 
%    (x,y): X-sp <= x <= X+sp, Y-sp <= y <= Y+sp, ||(R,G,B) - (r,g,b)|| <= sr
%
% where (R,G,B) and (r,g,b) are the vectors of color components at (X,Y) and
% (x,y), respectively (though, the algorithm does not depend on the color space
% used, so any 3-component color space can be used instead). Over the
% neighborhood the average spatial value (X',Y') and average color vector
% (R',G',B') are found and they act as the neighborhood center on the next
% iteration
%
%    (X,Y) (X',Y'), (R,G,B) (R',G',B').
%
% After the iterations over, the color components of the initial pixel (that
% is, the pixel from where the iterations started) are set to the final value
% (average color at the last iteration):
%
%    I(X,Y) < -(R*,G*,B*)
%
% When maxLevel > 0, the gaussian pyramid of maxLevel+1 levels is built, and
% the above procedure is run on the smallest layer first. After that, the
% results are propagated to the larger layer and the iterations are run again
% only on those pixels where the layer colors differ by more than sr from the
% lower-resolution layer of the pyramid. That makes boundaries of color regions
% sharper. Note that the results will be actually different from the ones
% obtained by running the meanshift procedure on the whole original image (i.e.
% when maxLevel = 0)
%
