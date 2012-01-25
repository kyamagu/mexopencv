%CALCGLOBALORIENTATION  Calculates a global motion orientation in a selected region
%
%   o = cv.calcMotionGradient(orientation, mask, mhi, timestamp, duration)
%
% Input:
%     orientation: Motion gradient orientation image calculated by the function
%         cv.calcMotionGradient
%     mask: Mask image. It may be a conjunction of a valid gradient mask, also
%         calculated by cv.calcMotionGradient, and the mask of a region whose
%         direction needs to be calculated.
%     mhi: Motion history image calculated by cv.updateMotionHistory.
%     timestamp: Timestamp passed to cv.updateMotionHistory.
%     duration: Maximum duration of a motion track in milliseconds, passed to
%         cv.updateMotionHistory.
% Output:
%     o: Output global orientation.
%
% The function calculates an average motion direction in the selected region
% and returns the angle between 0 degrees and 360 degrees. The average direction
% is computed from the weighted orientation histogram, where a recent motion has
% a larger weight and the motion occurred in the past has a smaller weight, as
% recorded in mhi.
%
% See also cv.updateMotionHistory cv.calcMotionGradient
%