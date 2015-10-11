%MATCHSHAPES  Compares two shapes
%
%    result = cv.matchShapes(contour1, contour2)
%    result = cv.matchShapes(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __contour1__ First contour or grayscale image. If it's contour, a cell
%       array of 2-element vectors (of `int32` or `single` type) of the form
%       `{[x,y], ...}`. In case of image, a single-channel 8-bit or
%       floating-point 2D matrix.
% * __contour2__ Second contour or grayscale image, with a similar type as the
%       first contour.
%
% ## Output
% * __result__ Output score.
%
% ## Options
% * __Method__ Comparison method, default 'I1'. One of:
%       * __I1__
%       * __I2__
%       * __I3__
% * __Parameter__ Method-specific parameter (not supported now). default 0
%
% The function compares two shapes. All three implemented methods use the
% Hu invariants (see cv.HuMoments).
%
% The following shape matching methods are available:
%
% * __I1__:
%
%        I_1(A,B) = \sum_{i=1,...,7} | 1/m_i^A - 1/m_i^B |
%
% * __I2__:
%
%        I_2(A,B) = \sum_{i=1,...,7} | m_i^A - m_i^B |
%
% * __I3__:
%
%        I_3(A,B) = \max_{i=1,...,7} | m_i^A - m_i^B | / | m_i^A |
%
% where `A` denotes `contour1`, `B` denotes `contour2`, and:
%
%    m_i^A = sign(h_i^A) * log(h_i^A)
%    m_i^B = sign(h_i^B) * log(h_i^B)
%
% and `h_i^A`, `h_i^B` are the Hu moments of `A` and `B`, respectively.
%
% See also: cv.moments, cv.HuMoments
%
