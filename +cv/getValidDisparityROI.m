%GETVALIDDISPARITYROI  Computes valid disparity ROI from the valid ROIs of the rectified images
%
%    r = cv.getValidDisparityROI(roi1, roi2)
%    r = cv.getValidDisparityROI(roi1, roi2, 'OptionName',optionValue, ...)
%
% ## Input
% * __roi1__, __roi2__ rectangles inside the rectified images where all the
%       the pixels are valid `[x,y,w,h]` (as returned by cv.stereoRectify).
%
% ## Output
% * __r__ computed rectangle inside the disparity of valid ROI `[x,y,w,h]`.
%
% ## Options
% * __MinDisparity__ Minimum possible disparity value. Normally, it is zero
%       but sometimes rectification algorithms can shift images, so this
%       parameter needs to be adjusted accordingly. default 0
% * __NumDisparities__ Maximum disparity minus minimum disparity. The value is
%       always greater than zero. default 64
% * __BlockSize__ the linear size of the matched block size. The size should
%       be odd (as the block is centered at the current pixel). Larger block
%       size implies smoother, though less accurate disparity map. Smaller
%       block size gives more detailed disparity map, but there is is higher
%       chance for algorithm to find a wrong correspondence. default 21.
%
% See also: cv.stereoRectify, cv.StereoBM, cv.StereoSGBM, cv.filterSpeckles,
%  cv.validateDisparity
%
