%CALCOPTICALFLOWPYRLK  Calculates an optical flow for a sparse feature set using the iterative Lucas-Kanade method with pyramids
%
%    nextPts = cv.calcOpticalFlowPyrLK(prevImg, nextImg, prevPts)
%    [nextPts, status, err] = cv.calcOpticalFlowPyrLK(...)
%
% ## Input
% * __prevImg__ First 8-bit single-channel or 3-channel input image.
% * __nextImg__ Second input image of the same size and the same type as prevImg.
% * __prevPts__ Vector of 2D points for which the flow needs to be found. Cell
%         array of 2-element vectors is accepted.
%
% ## Output
% * __nextPts__ Output vector of 2D points (with single-precision floating-point
%         coordinates) containing the calculated new positions of input features
%         in the second image.
% * __status__ Output status vector. Each element of the vector is set to 1 if
%         the flow for the corresponding features has been found. Otherwise, it
%         is set to 0.
% * __err__ Output vector that contains the difference between patches around the
%         original and moved points.
%
% ## Options
% * __InitialFlow__ Vector of 2D points to be used for the initial estimate of
%         nextPts. If not specified, prevPts will be used as an initial value.
% * __WinSize__ Size of the search window at each pyramid level.
% * __MaxLevel__ 0-based maximal pyramid level number. If set to 0, pyramids are
%         not used (single level). If set to 1, two levels are used, and so on.
% * __Criteria__ Parameter specifying the termination criteria of the iterative
%         search algorithm (after the specified maximum number of iterations
%         criteria.maxCount or when the search window moves by less than
%         criteria.epsilon. Struct with {'type','maxCount','epsilon'} fields is
%         accepted. The type field should have one of 'Count', 'EPS', or
%         'Count+EPS' to indicate which criteria to use.
%
% The function implements a sparse iterative version of the Lucas-Kanade optical
% flow in pyramids. See [Bouguet00].
%
% ## Example
%
%    prevIm = rgb2gray(imread('prev.jpg'));
%    nextIm = rgb2gray(imread('next.jpg'));
%    prevPts = cv.goodFeaturesToTrack(prevIm);
%    nextPts = cv.calcOpticalFlowPyrLK(prevIm, nextIm, prevPts);
%
% See also cv.goodFeaturesToTrack cv.calcOpticalFlowFarneback
%
