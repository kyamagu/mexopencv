%ESTIMATERIGIDTRANSFORM  Computes an optimal affine transformation between two 2D point sets
%
%    M = cv.estimateRigidTransform(src, dst)
%    M = cv.estimateRigidTransform(src, dst, 'OptionName', optionValue)
%
% ## Input
% * __src__ First input 2D point set stored cell array of 2-element vectors, or
%         an image
% * __dst__ Second input 2D point set of the same size and the same type as A, or
%         another image.
%
% ## Output
% * __M__ Output matrix (see below).
%
% ## Options
% * __FullAffine__ If true, the function finds an optimal affine transformation
%         with no additional resrictions (6 degrees of freedom). Otherwise, the
%         class of transformations to choose from is limited to combinations of
%         translation, rotation, and uniform scaling (5 degrees of freedom).
%
% The function finds an optimal affine transform [A|b] (a 2 x 3 floating-point
% matrix) that approximates best the affine transformation between:
%
%   * Two point sets
%   * Two raster images. In this case, the function first finds some features in
%     the src image and finds the corresponding features in dst image. After
%     that, the problem is reduced to the first case.
%
% In case of point sets, the problem is formulated as follows: you need to find
% a 2x2 matrix A and 2x1 vector b so that:
%
%     [A*|b*] = argmin_{[A|b]} \sum_i || dst[i] - Asrc[i]^T - b ||^2
%
% where src[i] and dst[i] are the i-th points in src and dst, respectively.
% [A|b] can be either arbitrary (when fullAffine=true) or have a form of
%
%     [ a11, a12, b1;...
%      -a12, a22, b2 ]
%
% when fullAffine=false.
%
