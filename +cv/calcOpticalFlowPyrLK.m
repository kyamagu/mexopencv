%CALCOPTICALFLOWPYRLK  Calculates an optical flow for a sparse feature set using the iterative Lucas-Kanade method with pyramids
%
%    nextPts = cv.calcOpticalFlowPyrLK(prevImg, nextImg, prevPts)
%    [nextPts, status, err] = cv.calcOpticalFlowPyrLK(...)
%    [...] = cv.calcOpticalFlowPyrLK(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __prevImg__ First 8-bit single-channel or 3-channel input image.
% * __nextImg__ Second input image of the same size and the same type as `prevImg`.
% * __prevPts__ Vector of 2D points for which the flow needs to be found. Cell
%         array of 2-element vectors is accepted: `{[x,y], ...}`
%
% ## Output
% * __nextPts__ Output vector of 2D points (with single-precision floating-point
%         coordinates) containing the calculated new positions of input features
%         in the second image. A cell array of 2-elements vectors of the same
%         size as `prevPts`.
% * __status__ Output status vector. Each element of the vector is set to 1 if
%         the flow for the corresponding features has been found. Otherwise, it
%         is set to 0.
% * __err__ Output vector of errors; each element of the vector is set to an
%         error for the corresponding feature, type of the error measure is
%         determined by `GetMinEigenvals` option; if the flow wasn't found then
%         the error is not defined (use `status` to find such cases).
%
% ## Options
% * __InitialFlow__ Vector of 2D points to be used for the initial estimate of
%         `nextPts`. If not specified, `prevPts` will be used as an initial value.
%         The vector must have the same size as in the input.
% * __WinSize__ Size of the search window at each pyramid level. Default to
%         [21, 21].
% * __MaxLevel__ 0-based maximal pyramid level number. If set to 0, pyramids are
%         not used (single level). If set to 1, two levels are used, and so on.
%         Default to 3.
% * __Criteria__ Parameter specifying the termination criteria of the iterative
%         search algorithm (after the specified maximum number of iterations
%         `criteria.maxCount` or when the search window moves by less than
%         `criteria.epsilon`. Struct with `{'type','maxCount','epsilon'}` fields is
%         accepted. The type field should have one of 'Count', 'EPS', or
%         'Count+EPS' to indicate which criteria to use. Default to
%         `struct('type', 'Count+EPS', 'maxCount', 30, 'epsilon', 0.01)`.
% * __GetMinEigenvals__ Use minimum eigen values as an error measure
%         (see `MinEigThreshold` description); if the flag is not set, then L1
%         distance between patches around the original and a moved point,
%         divided by number of pixels in a window, is used as a error measure.
%         Default to false.
% * __MinEigThreshold__ The algorithm calculates the minimum eigen value of a
%         2x2 normal matrix of optical flow equations (this matrix is called a
%         spatial gradient matrix in [Bouguet00]), divided by number of pixels
%         in a window; if this value is less than `MinEigThreshold`, then a
%         corresponding feature is filtered out and its flow is not processed,
%         so it allows to remove bad points and get a performance boost.
%         Default to 1e-4.
%
% The function implements a sparse iterative version of the Lucas-Kanade optical
% flow in pyramids. See [Bouguet00].
%
% ## References
% [Bouguet00]:
% > Jean-Yves Bouguet. "Pyramidal Implementation of the Lucas Kanade Feature
% > Tracker", 2000
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
