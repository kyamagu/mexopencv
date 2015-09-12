%FITLINE  Fits a line to a 2D or 3D point set
%
%    lin = cv.fitLine(points)
%    lin = cv.fitLine(points, 'OptionName',optionValue, ...)
%
% ## Input
% * __points__ Input vector of 2D or 3D points.
%       2D points stored in a cell array of 2-element vectors in the form
%       `{[x,y], [x,y], ...}` or a Nx2/Nx1x2/1xNx2 numeric array.
%       3D points stored in a cell array of 3-element vectors in the form
%       `{[x,y,z], [x,y,z], ...}` or a Nx3/Nx1x3/1xNx3 numeric array.
%
% ## Output
% * __lin__ Output line parameters. In case of 2D fitting, it is a vector of
%       4-elements vector `[vx,vy, x0,y0]`, where `[vx,vy]` is a normalized
%       vector collinear to the line and `[x0,y0]` is a point on the line. In
%       case of 3D fitting, it is a 6-elements vector `[vx,vy,vz, x0,y0,z0]`,
%       where `[vx,vy,vz]` is a normalized vector collinear to the line and
%       `[x0,y0,z0]` is a point on the line.
%
% ## Options
% * __DistType__ Distance used by the M-estimator (see explanation below).
%       One of: 'L2' (default), 'L1', 'L12', 'Fair', 'Welsch', 'Huber'.
% * __Param__ Numerical parameter (`C`) for some types of distances. If it is
%       0, an optimal value is chosen. default 0.
% * __RadiusEps__ Sufficient accuracy for the radius (distance between the
%       coordinate origin and the line). default 0.01
% * __AngleEps__ Sufficient accuracy for the angle. default 0.01
%
% The function fitLine fits a line to a 2D or 3D point set by minimizing
% `\sum_i rho(r_i)` where `r_i` is a distance between the i-th point and the
% line, and `rho(r)` is a distance function, one of the following:
%
% * __L2__
%
%        rho(r) = r^2/2 (the simplest and the fastest least-squares method)
%
% * __L1__
%
%        rho(r) = r
%
% * __L12__
%
%        rho(r) = 2 * (sqrt(1+r^2/2) - 1)
%
% * __Fair__
%
%        rho(r) = C^2 * (r/C - log(1 + r/c)), where C = 1.3998
%
% * __Welsch__
%
%        rho(r) = C^2/2 * (1 - exp(-(r/c)^2)), where C = 2.9846
%
% * __Huber__
%
%                 | r^2/2          if r<C
%        rho(r) = |                          , where C = 1.345
%                 | C * (r - C/2)  otherwise
%
%
% The algorithm is based on the M-estimator
% (http://en.wikipedia.org/wiki/M-estimator) technique that iteratively fits
% the line using the weighted least-squares algorithm. After each iteration
% the weights `w_i` are adjusted to be inversely proportional to `rho(r_i)`.
%
