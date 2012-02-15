%COMPUTECORRESPONDEPILINES  For points in an image of a stereo pair, computes the corresponding epilines in the other image
%
%    lines = cv.computeCorrespondEpilines(points, F)
%    [...] = cv.computeCorrespondEpilines(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __points__ Input points. Nx1x2 or 1xNx2 array, or cell array of 2 element
%        vectors.
% * __F__ Fundamental matrix that can be estimated using
%        cv.findFundamentalMat or cv.stereoRectify.
%
% ## Output
% * __lines__ Output vector of the epipolar lines corresponding to the points
%        in the other image. Each line ax+by+c=0 is encoded by 3 numbers
%        (a,b,c).
%
% ## Options
% * __WhichImage__ Index of the image (1 or 2) that contains the points.
%        default 1.
%
% For every point in one of the two images of a stereo pair, the function
% finds the equation of the corresponding epipolar line in the other image.
%
% From the fundamental matrix definition (see cv.findFundamentalMat), line
% l\_i^(2) in the second image for the point p\_i^(1) in the first image
% (when whichImage=1) is computed as:
%
%    l_i^(2) = F * p_i^(1)
%
% And vice versa, when whichImage=2, l\_i^(1) is computed from p\_i^(2) as:
%
%    l_i^(2) = F^T * p_i^(1)
%
% Line coefficients are defined up to a scale. They are normalized so that
% a^2+b^2=1.
%
% See also cv.findFundamentalMat cv.stereoRectify
%
