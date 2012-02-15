%CANNY  Finds edges in an image using the [Canny86] algorithm
%
%    edges = cv.Canny(image, thresh)
%
% ## Input
% * __image__ Single-channel 8-bit input image.
% * __thresh__ Threshold for the hysteresis procedure. Scalar or 2-element vector.
%
% ## Output
% * __edges__ Output edge map. It has the same size and type as image.
%
% ## Options
% * __ApertureSize__ Aperture size for the Sobel operator.
% * __L2Gradient__ Flag indicating whether a more accurate L2 norm  should be
%         used to compute the image gradient magnitude ( L2gradient=true ), or
%         a faster default L1 norm is enough ( L2gradient=false ).
%
% The function finds edges in the input image image and marks them in the output
% map edges using the Canny algorithm. When thresh is 2-element vector, the
% smallest value between them is used for edge linking. The largest value is
% used to find initial segments of strong edges. When thresh is a scalar, it is
% treated as a higher threshold value and 0.4*thresh is used for the lower
% threshold. See http://en.wikipedia.org/wiki/Canny_edge_detector
%
