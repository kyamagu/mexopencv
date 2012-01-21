%FITLINE  Fits a line to a 2D point set
%
%   lin = cv.fitLine(points)
%
% Input:
%     points: Input 2D point set, stored in a cell array of 2-element vectors or
%         1-by-N-by-2 numeric array.
% Output:
%     lin: Output line parameters. It should be a vector of 4 elements -
%         (vx, vy, x0, y0), where (vx, vy) is a normalized vector collinear to
%         the line and (x0, y0) is a point on the line.
% Options:
%     'DistType': Distance used by the M-estimator.
%         'L2'     (default)
%         'L1'
%         'L12'
%         'Fair'
%         'Welsch'
%         'Huber'
%     'Param': Numerical parameter ( C ) for some types of distances. If it is
%         0, an optimal value is chosen. default 0.
%     'REps': Sufficient accuracy for the radius (distance between the
%         coordinate origin and the line).
%     'AEps': Sufficient accuracy for the angle. 0.01 would be a good default
%         value for REps and AEps.
%
% The algorithm is based on the M-estimator (
% http://en.wikipedia.org/wiki/M-estimator ) technique that iteratively fits
% the line using the weighted least-squares algorithm. After each iteration the
% weights w_i are adjusted to be inversely proportional to rho(r_i).
%