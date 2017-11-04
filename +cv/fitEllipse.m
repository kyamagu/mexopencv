%FITELLIPSE  Fits an ellipse around a set of 2D points
%
%     rct = cv.fitEllipse(points)
%     rct = cv.fitEllipse(points, 'OptionName',optionValue, ...)
%
% ## Input
% * __points__ Input 2D point set, stored in numeric array
%   (Nx2/Nx1x2/1xNx2) or cell array of 2-element vectors (`{[x,y], ...}`).
%   There should be at least 5 points to fit the ellipse.
%
% ## Output
% * __rct__ Output rotated rectangle struct with the following fields:
%   * __center__ The rectangle mass center `[x,y]`.
%   * __size__ Width and height of the rectangle `[w,h]`.
%   * __angle__ The rotation angle in a clockwise direction. When the angle is
%     0, 90, 180, 270 etc., the rectangle becomes an up-right rectangle.
%
% ## Options
% * __Method__ One of:
%   * __Linear__ Linear (LIN) conic fitting method. This is the default.
%   * __Direct__ Direct least square (DLS) method.
%   * __AMS__ Approximate mean square (AMS) method.
%
% ### Method = Linear
%
% The function calculates the ellipse that fits (in a least-squares sense) a
% set of 2D points best of all. It returns the rotated rectangle in which the
% ellipse is inscribed. The first algorithm described by [Fitzgibbon95] is
% used. Developer should keep in mind that it is possible that the returned
% ellipse/rotatedRect data contains negative indices, due to the data points
% being close to the border of the containing Mat element.
%
% ### Method = Direct
%
% The function calculates the ellipse that fits a set of 2D points.
% It returns the rotated rectangle in which the ellipse is inscribed.
% The Direct least square (Direct) method by [Fitzgibbon1999] is used.
%
% For an ellipse, this basis set is `chi = (x^2, x*y, y^2, x, y, 1)`, which is
% a set of six free coefficients `A^T = {A_xx, A_xy, A_yy, A_x, A_y, A_0}`.
% However, to specify an ellipse, all that is needed is five numbers; the
% major and minor axes lengths `(a,b)`, the position `(x_0,y_0)`, and the
% orientation `theta`. This is because the basis set includes lines,
% quadratics, parabolic and hyperbolic functions as well as elliptical
% functions as possible fits.
%
% The Direct method confines the fit to ellipses by ensuring that
% `4*A_xx*A_yy - A_xy^2 > 0`. The condition imposed is that
% `4*A_xx*A_yy - A_xy^2 = 1` which satisfies the inequality and as the
% coefficients can be arbitrarily scaled is not overly restrictive.
%
%     epsilon^2 = A^T * D^T * D * A
%     with A^T * C * A = 1
%     and C = [0 0 2 0 0 0; 0 -1 0 0 0 0; 2 0 0 0 0 0; 0 0 0 0 0 0; 0 0 0 0 0 0; 0 0 0 0 0 0]
%
% The minimum cost is found by solving the generalized eigenvalue problem.
%
%     D^T * D * A = lambda * (C) * A
%
% The system produces only one positive eigenvalue `lambda` which is chosen as
% the solution with its eigenvector `u`. These are used to find the
% coefficients:
%
%     A = sqrt(1 / (u^T * C * u)) * u
%
% The scaling factor guarantees that  `A^T * C * A = 1`.
%
% Note: If the determinant of `A` is too small, the method fallsback to
% 'Linear'.
%
% ### Method = AMS
%
% The function calculates the ellipse that fits a set of 2D points.
% It returns the rotated rectangle in which the ellipse is inscribed.
% The Approximate Mean Square (AMS) proposed by [Taubin1991] is used.
%
% For an ellipse, this basis set is `chi = (x^2, x*y, y^2, x, y, 1)`, which is
% a set of six free coefficients `A^T = {A_xx, A_xy, A_yy, A_x, A_y, A_0}`.
% However, to specify an ellipse, all that is needed is five numbers; the
% major and minor axes lengths `(a,b)`, the position `(x_0,y_0)`, and the
% orientation `theta`. This is because the basis set includes lines,
% quadratics, parabolic and hyperbolic functions as well as elliptical
% functions as possible fits.
%
% If the fit is found to be a parabolic or hyperbolic function then the
% 'Direct' method is used. The AMS method restricts the fit to parabolic,
% hyperbolic and elliptical curves by imposing the condition that
% `A^T * (D_x^T * D_x + D_y^T * D_y) * A = 1` where the matrices `Dx` and `Dy`
% are the partial derivatives of the design matrix `D` with respect to x and y.
% The matrices are formed row by row applying the following to each of the
% points in the set:
%
%     D(i,:)   = {x_i^2, x_i y_i, y_i^2, x_i, y_i, 1}
%     D_x(i,:) = {2*x_i, y_i, 0, 1, 0, 0}
%     D_y(i,:) = {0, x_i, 2*y_i, 0, 1, 0}
%
% The AMS method minimizes the cost function
%
%     epsilon^2 = (A^T * D^T * D * A) / (A^T * (D_x^T * D_x + D_y^T * D_y) * A^T)
%
% The minimum cost is found by solving the generalized eigenvalue problem.
%
%     D^T * D * A = lambda * (D_x^T * D_x + D_y^T * D_y) * A
%
% Note: If the determinant of `A` is too small, the method fallsback to
% 'Linear'.
%
% ## References
% [Fitzgibbon95]:
% > Andrew W Fitzgibbon and Robert B Fisher.
% > "A buyer's guide to conic fitting". In Proceedings of the 6th British
% > conference on Machine vision (Vol. 2), pages 513-522. BMVA Press, 1995.
% > [PDF](http://www.bmva.org/bmvc/1995/bmvc-95-050.pdf)
%
% [Fitzgibbon1999]:
% > Andrew Fitzgibbon, Maurizio Pilu, and Robert B. Fisher.
% > "Direct least square fitting of ellipses". IEEE Transactions on Pattern
% > Analysis and Machine Intelligence, 21(5):476-480, 1999.
% > [PDF](https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/ellipse-pami.pdf)
%
% [Taubin1991]:
% > Gabriel Taubin. "Estimation of planar curves, surfaces, and nonplanar
% > space curves defined by implicit equations with applications to edge and
% > range image segmentation". IEEE Transactions on Pattern Analysis and
% > Machine Intelligence, 13(11):1115-1138, 1991.
%
% See also: cv.minAreaRect
%
