%BUILDPYRAMID  Constructs the Gaussian pyramid for an image
%
%    dst = cv.buildPyramid(src)
%    dst = cv.buildPyramid(src, 'MaxLevel', 5)
%
% ## Input
% * __src__ Source image.
%
% ## Output
% * __dst__ Destination vector of maxlevel+1 images of the same type as src.
%          dst{1} will be the same as src . dst{2} is the next pyramid layer,
%          a smoothed and down-sized src , and so on.
%
% ## Options
% * __MaxLevel__ 0-based index of the last (the smallest) pyramid layer. It
%                 must be non-negative. default 5
%
% The function constructs a vector of images and builds the Gaussian pyramid by
% recursively applying pyrDown() to the previously built pyramid layers,
% starting from dst{1}==src.
%
