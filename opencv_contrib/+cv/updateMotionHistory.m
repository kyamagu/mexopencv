%UPDATEMOTIONHISTORY  Updates the motion history image by a moving silhouette
%
%    mhi = cv.updateMotionHistory(silhouette, mhi, timestamp, duration)
%
% ## Input
% * __silhouette__ Silhouette mask that has non-zero pixels where the motion
%       occurs.
% * __mhi__ Input motion history image to be updated by the function
%       (single-channel, 32-bit floating-point).
% * __timestamp__ Current time in milliseconds or other units.
% * __duration__ Maximal duration of the motion track in the same units as
%       timestamp.
%
% ## Output
% * __mhi__ Updated motion history image (single-channel, 32-bit
%       floating-point).
%
% The function updates the motion history image as follows:
%
%                | timestamp  if silhouette(x,y) != 0
%     mhi(x,y) = | 0          if silhouette(x,y) == 0 and mhi < (timestamp < duration)
%                | mhi(x,y)   otherwise
%
% That is, `mhi` pixels where the motion occurs are set to the current
% timestamp, while the pixels where the motion happened last time a long time
% ago are cleared.
%
% The function, together with cv.calcMotionGradient and
% cv.calcGlobalOrientation, implements a motion templates technique described
% in [Davis97] and [Bradski00].
%
% ## References
% [Davis97]:
% > James W Davis and Aaron F Bobick. "The representation and recognition of
% > human movement using temporal templates". In Computer Vision and Pattern
% > Recognition, 1997. Proceedings., 1997 IEEE Computer Society Conference on,
% > pages 928-934. IEEE, 1997.
%
% [Bradski00]:
% > GR Bradski and J Davis. "Motion segmentation and pose recognition with
% > motion history gradients". In Applications of Computer Vision, 2000,
% > Fifth IEEE Workshop on., pages 238-244. IEEE, 2000.
%
% See also: cv.calcMotionGradient, cv.calcGlobalOrientation
%
