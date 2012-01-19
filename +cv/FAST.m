%FAST  Detects corners using the FAST algorithm
%
%    keypoints = cv.FAST(im)
%    keypoints = cv.FAST(im, 'OptionName', optionValue)
%
% Input:
%   im: Image where keypoints (corners) are detected.
% Output:
%   keypoints: Keypoints detected on the image.
% Options:
%   'Threshold': Threshold on difference between intensity of the central
%        pixel and pixels on a circle around this pixel. See the algorithm
%        description [E. Rosten, 2006]. default 20.
%   'NonMaxSupression': If it is true, non-maximum supression is applied
%        to detected corners (keypoints). default true.
%
% Detects corners using the FAST algorithm by E. Rosten (Machine Learning
% for High-speed Corner Detection, 2006).
%