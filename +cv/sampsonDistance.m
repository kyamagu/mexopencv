%SAMPSONDISTANCE  Calculates the Sampson Distance between two points
%
%    sd = cv.sampsonDistance(pt1, pt2, F)
%
% ## Input
% * __pt1__ first homogeneous 2D point.
% * __pt2__ second homogeneous 2D point.
% * __F__ 3x3 fundamental matrix.
%
% ## Output
% * __sd__ calculated Sampson distance.
%
% The function cv.sampsonDistance calculates and returns the first order
% approximation of the geometric error as:
%
%                                     (pt2'*F*pt1)^2
%    sd(pt1,pt2) = -----------------------------------------------------
%                  ((F*pt1)(0) + (F*pt1)(1) + (F'*pt2)(0) + (F'*pt2)(1))
%
% The fundamental matrix may be calculated using the cv.findFundamentalMat
% function. See HZ 11.4.3 for details.
%
% All inputs are in double-precision floating-point type.
%
% See also: cv.findFundamentalMat
%
