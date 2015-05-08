%CALCMOTIONGRADIENT  Updates the motion history image by a moving silhouette
%
%    [mask,orientation] = cv.calcMotionGradient(mhi, delta1, delta2)
%    [...] = cv.calcMotionGradient(mhi, delta1, delta2, 'OptionName', optionValue, ...)
%
% ## Input
% * __mhi__ Motion history single-channel floating-point image.
% * __delta1__ Minimal (or maximal) allowed difference between mhi values
%     within a pixel neighorhood.
% * __delta2__ Maximal (or minimal) allowed difference between mhi values within
%          a pixel neighorhood. That is, the function finds the minimum
%          ( m(x,y) ) and maximum ( M(x,y) ) mhi values over 3 x 3 neighborhood
%          of each pixel and marks the motion orientation at (x,y) as valid only
%          if
%              min(delta1,delta2) <= M(x,y) - m(x,y) <= max(delta1,delta2)
%
% ## Output
% * __mask__ Output mask image that has the type uint8 and the same size a
%     mhi. Its non-zero elements mark pixels where the motion gradient data
%     is correct.
% * __orientation__ Output motion gradient orientation image that has the same
%     type and the same size as mhi . Each pixel of the image is a motion
%     orientation, from 0 to 360 degrees.
%
% ## Options
% * __ApertureSize__ Aperture size of the cv.Sobel operator.
%
% The function calculates a gradient orientation at each pixel (x,y) as:
%
%     orientation(x,y) = arctan (dmhi / dy) / (dmhi / dx)
%
% In fact, fastAtan2() and phase() are used so that the computed angle is
% measured in degrees and covers the full range 0..360. Also, the mask is filled
% to indicate pixels where the computed angle is valid.
%
% See also cv.updateMotionHistory cv.calcGlobalOrientation
%
