%SEGMENTMOTION  Splits a motion history image into a few parts corresponding to separate independent motions (for example, left hand, right hand)
%
%    [segmask, boundingRects] = cv.segmentMotion(mhi, timestamp, segThresh)
%
% ## Input
% * __mhi__ Motion history image.
% * __timestamp__ Current time in milliseconds or other units.
% * __segThresh__ Segmentation threshold that is recommended to be equal to the
%         interval between motion history 'steps' or greater.
%
% ## Output
% * __segmask__ Image where the found mask should be stored, single-channel,
%         32-bit floating-point.
% * __boundingRects__ Vector containing ROIs of motion connected components.
%
% The function finds all of the motion segments and marks them in segmask with
% individual values (1,2,...). It also computes a vector with ROIs of motion
% connected components. After that the motion direction for every component can
% be calculated with cv.calcGlobalOrientation using the extracted mask of the
% particular component.
%
% See also cv.updateMotionHistory cv.calcMotionGradient cv.calcGlobalOrientation
%
