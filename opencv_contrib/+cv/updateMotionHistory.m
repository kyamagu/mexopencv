%UPDATEMOTIONHISTORY  Updates the motion history image by a moving silhouette
%
%    mhi = cv.updateMotionHistory(silhouette, mhi, timestamp, duration)
%
% ## Input
% * __silhouette__ Silhouette mask that has non-zero pixels where the motion
%         occurs.
% * __mhi__ Motion history image to be updated by the function (single-channel,
%         32-bit floating-point).
% * __timestamp__ Current time in milliseconds or other units.
% * __duration__ Maximal duration of the motion track in the same units as
%         timestamp.
%
% ## Output
% * __mhi__ Motion history image that is updated by the function (single-channel,
%         32-bit floating-point).
%
% The function updates the motion history image as follows:
%
%                | timestamp  if silhouette(x,y) != 0
%     mhi(x,y) = | 0          if silhouette(x,y) == 0 and mhi < (timestamp < duration)
%                | mhi(x,y)   otherwise
% 
% That is, MHI pixels where the motion occurs are set to the current timestamp,
% while the pixels where the motion happened last time a long time ago are
% cleared.
%
% The function, together with cv.calcMotionGradient and
% cv.calcGlobalOrientation, implements a motion templates technique described in
% [Davis97] and [Bradski00].
%
% See also cv.calcMotionGradient cv.calcGlobalOrientation
%
