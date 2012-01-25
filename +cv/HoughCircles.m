%HOUGHCIRCLES  Finds circles in a grayscale image using the Hough transform
%
%   circles = cv.HoughCircles(image)
%
% Input:
%     image: 8-bit, single-channel, grayscale input image.
% Output:
%     circles: Output vector of found circles. Each vector is encoded as a
%         3-element floating-point vector (x, y, radius).
% Options:
%     'DP': Inverse ratio of the accumulator resolution to the image resolution.
%         For example, if dp=1 , the accumulator has the same resolution as the
%         input image. If dp=2 , the accumulator has half as big width and
%         height. default 1.
%     'MinDist': Minimum distance between the centers of the detected circles.
%         If the parameter is too small, multiple neighbor circles may be
%         falsely detected in addition to a true one. If it is too large, some
%         circles may be missed. default image.rows/8.
%     'Param1': First method-specific parameter. It is the higher threshold of
%         the two passed to the Canny() edge detector (the lower one is twice
%         smaller). default 100.
%     'Param2': Second method-specific parameter. It is the accumulator
%         threshold for the circle centers at the detection stage. The smaller
%         it is, the more false circles may be detected. Circles, corresponding
%         to the larger accumulator values, will be returned first. default 100.
%     'MinRadius': Minimum circle radius. default 0.
%     'MaxRadius': Maximum circle radius. default 0.
%
% The function finds circles in a grayscale image using a modification of the
% Hough transform
%
% See also cv.fitEllipse, cv.minEnclosingCircle
%