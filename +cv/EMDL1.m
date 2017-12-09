%EMDL1  Computes the "minimal work" distance between two weighted point configurations
%
%     dist = cv.EMDL1(signature1, signature2)
%
% ## Input
% * __signature1__ First signature, a single column floating-point matrix.
%   Each row is the value of the histogram in each bin.
% * __signature2__ Second signature of the same format and size as
%   `signature1`.
%
% ## Output
% * __dist__ output distance.
%
% Base on the papers [1] and [2].
%
% ## References
% [1]:
% > "EMD-L1: An efficient and Robust Algorithm for comparing histogram-based
% > descriptors", by Haibin Ling and Kazunori Okuda
%
% [2]:
% > "The Earth Mover's Distance is the Mallows Distance: Some Insights from
% > Statistics", by Elizaveta Levina and Peter Bickel.
%
% See also: cv.EMD, cv.compareHist
%
