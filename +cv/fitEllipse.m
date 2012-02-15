%FITELLIPSE  Fits an ellipse around a set of 2D points
%
%    rct = cv.fitEllipse(points)
%
% ## Input
% * __points__ Input 2D point set, stored in a cell array of 2-element vectors or
%         1-by-N-by-2 numeric array.
%
% ## Output
% * __rct__ Output rotated rectangle struct.
%
% The function calculates the ellipse that fits (in a least-squares sense) a
% set of 2D points best of all. It returns the rotated rectangle in which the
% ellipse is inscribed. The algorithm [Fitzgibbon95] is used.
%
