%COMPUTERECALLPRECISIONCURVE  Evaluate a descriptor extractor by computing precision/recall curve
%
%    recallPrecisionCurve = cv.computeRecallPrecisionCurve(matches1to2, correctMatches1to2Mask)
%
% ## Input
% * __matches1to2__ Cell array of matches, each match is a structure array
%       with the following fields:
%       * __queryIdx__ query descriptor index (zero-based index)
%       * __trainIdx__ train descriptor index (zero-based index)
%       * __imgIdx__ train image index (zero-based index)
%       * __distance__ distance between descriptors (scalar)
% * __correctMatches1to2Mask__ Cell array of the same size as `matches1to2`.
%       A mask indicating correct matches.
%
% ## Output
% * __recallPrecisionCurve__ Recall/precision curve, Nx2 matrix.
%
% See also: cv.evaluateFeatureDetector, cv.DescriptorExtractor,
%  cv.DescriptorMatcher
%
