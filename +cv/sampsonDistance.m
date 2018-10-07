%SAMPSONDISTANCE  Calculates the Sampson Distance between two points
%
%     sd = cv.sampsonDistance(pt1, pt2, F)
%
% ## Input
% * __pt1__ first homogeneous 2D point.
% * __pt2__ second homogeneous 2D point.
% * __F__ 3x3 fundamental matrix.
%
% ## Output
% * __sd__ The computed Sampson distance.
%
% The function cv.sampsonDistance calculates and returns the first order
% approximation of the geometric error as:
%
%                                      (pt2'*F*pt1)^2
%     sd(pt1,pt2) = -------------------------------------------------------------
%                   ((F*pt1)(0)^2 + (F*pt1)(1)^2 + (F'*pt2)(0)^2 + (F'*pt2)(1)^2)
%
% The fundamental matrix may be calculated using the cv.findFundamentalMat
% function. See [HartleyZ00] 11.4.3 for details.
%
% All inputs are in double-precision floating-point type.
%
% ## References
% [HartleyZ00]:
% > Richard Hartley and Andrew Zisserman. "Multiple View Geometry in Computer
% > Vision". Cambridge University Press, 2003.
%
% See also: cv.findFundamentalMat
%
