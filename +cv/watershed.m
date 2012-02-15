%WATERSHED  Performs a marker-based image segmentation using the watershed algrorithm
%
%    marker = cv.watershed(image, marker)
%
% ## Input
% * __image__ Input 8-bit 3-channel image.
% * __marker__ Input 32-bit single-channel image (map) of markers. It
%     should have the same size as image.
%
% ## Output
% * __marker__ Output 32-bit single-channel image (map) of markers. It has
%     the same size as image.
%
% The function implements one of the variants of watershed, non-parametric
% marker-based segmentation algorithm, described in [Meyer92].
%
% Before passing the image to the function, you have to roughly outline the
% desired regions in the image markers with positive (>0) indices. So, every
% region is represented as one or more connected components with the pixel
% values 1, 2, 3, and so on. Such markers can be retrieved from a binary mask
% using findContours() and drawContours() (see the watershed.cpp demo). The
% markers are seeds of the future image regions. All the other pixels in
% markers , whose relation to the outlined regions is not known and should be
% defined by the algorithm, should be set to 0's. In the function output, each
% pixel in markers is set to a value of the seed components or to -1 at
% boundaries between the regions.
%
% ## Note
% Any two neighbor connected components are not necessarily separated by
% a watershed boundary (-1's pixels); for example, they can touch each other in
% the initial marker image passed to the function.
%
% See also cv.grabCut
%
