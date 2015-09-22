%VALIDATEDISPARITY  Validates disparity using the left-right check
%
%    disparity = cv.validateDisparity(disparity, cost)
%    disparity = cv.validateDisparity(disparity, cost, 'OptionName',optionValue, ...)
%
% ## Input
% * __disparity__ disparity map, 1-channel 16-bit signed integer array.
% * __cost__ Cost matrix computed by the stereo correspondence algorithm. An
%       array of same size as `disparity` and 16-bit or 32-bit signed integer
%       type.
%
% ## Output
% * __disparity__ validated disparity map.
%
% ## Options
% * __MinDisparity__ Minimum possible disparity value. Normally, it is zero
%       but sometimes rectification algorithms can shift images, so this
%       parameter needs to be adjusted accordingly. default 0
% * __NumDisparities__ Maximum disparity minus minimum disparity. The value is
%       always greater than zero. default 64
% * __Disp12MaxDisp__ Maximum allowed difference (in integer pixel units) in
%       the left-right disparity check. default 1
%
% See also: cv.StereoBM, cv.StereoSGBM, cv.filterSpeckles,
%  cv.getValidDisparityROI,
%
