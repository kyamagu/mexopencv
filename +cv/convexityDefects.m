%CONVEXITYDEFECTS  Finds the convexity defects of a contour
%
%    defects = cv.convexityDefects(contour, convexhull);
%
% ## Input
% * __contour__ Input contour. 2D point set, stored in numeric array
%       (Nx2/Nx1x2/1xNx2) or cell array of 2-element vectors (`{[x,y], ...}`).
% * __convexhull__ Corresponding convex hull obtained using cv.convexHull that
%       should contain indices of the contour points that make the hull.
%       A numeric vector of 0-based indices.
%
% ## Output
% * __defects__ The output vector of convexity defects `{[v0,v1,v2,v3], ...}`.
%       Each convexity defect is represented as 4-element integer vector
%       `[start_index, end_index, farthest_pt_index, fixpt_depth]`, where
%       indices are 0-based indices in the original contour of the convexity
%       defect (beginning, end and the farthest point), and `fixpt_depth` is
%       fixed-point approximation (with 8 fractional bits) of the distance
%       between the farthest contour point and the hull. That is, to get the
%       floating-point value of the depth will be `fixpt_depth/256.0`.
%
% See also: cv.convexHull
%
