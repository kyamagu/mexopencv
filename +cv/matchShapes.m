%MATCHSHAPES  Compares two shapes
%
%   d = cv.matchShapes(object1, object2)
%   d = cv.matchShapes(object1, object2, 'OptionName', optionValue, ...)
%
% Input:
%     object1: First contour or grayscale image. If it's contour, a cell array
%         of 2-element vectors or 1-by-N-by-2 numeric array are accepted.
%     object2: Second contour or grayscale image. If it's contour, a cell array
%         of 2-element vectors or 1-by-N-by-2 numeric array are accepted.
% Output:
%     d: Output score.
% Options:
%     'Method': Comparison method. One of {'I1','I2','I3'}. default I1.
%     'Parameter': Parameter value used in comparison.
%
% The function compares two shapes. All three implemented methods use the Hu
% invariants (see HuMoments() ) as follows (A denotes object1,:math:B denotes
% object2):
%
%   'I1'    I_1(A,B) = \sum_{i=1,...,7} | 1/m_i^A - 1/m_i^B |
%   'I2'    I_2(A,B) = \sum_{i=1,...,7} | m_i^A - m_i^B |
%   'I3'    I_3(A,B) = \sum_{i=1,...,7} | m_i^A - m_i^B | / | m_i^A |
%
% where
%
%           m_i^A = sign(h_i^A) log h_i^A
%           m_i^B = sign(h_i^B) log h_i^B
%
% and h_i^A, h_i^B are the Hu moments of A and B, respectively.
%