%FITELLIPSE  Fits an ellipse around a set of 2D points
%
%    rct = cv.fitEllipse(points)
%
% ## Input
% * __points__ Input 2D point set, stored in numeric array
%       (Nx2/Nx1x2/1xNx2) or cell array of 2-element vectors (`{[x,y], ...}`).
%
% ## Output
% * __rct__ Output rotated rectangle struct with the following fields:
%       * __center__ The rectangle mass center `[x,y]`.
%       * __size__ Width and height of the rectangle `[w,h]`.
%       * __angle__ The rotation angle in a clockwise direction.
%             When the angle is 0, 90, 180, 270 etc., the
%             rectangle becomes an up-right rectangle.
%
% The function calculates the ellipse that fits (in a least-squares sense) a
% set of 2D points best of all. It returns the rotated rectangle in which the
% ellipse is inscribed. The first algorithm described by [Fitzgibbon95] is
% used. Developer should keep in mind that it is possible that the returned
% ellipse/rotatedRect data contains negative indices, due to the data points
% being close to the border of the containing Mat element.
%
% ## References
% [Fitzgibbon95]:
% > Andrew W Fitzgibbon and Robert B Fisher.
% > "A buyer's guide to conic fitting". In Proceedings of the 6th British
% > conference on Machine vision (Vol. 2), pages 513-522. BMVA Press, 1995.
%
% See also: cv.minAreaRect
%
