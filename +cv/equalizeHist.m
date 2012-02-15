%EQUALIZEHIST  Equalizes the histogram of a grayscale image
%
%    dst = cv.equalizeHist(src)
%
% ## Input
% * __src__ Source 8-bit single channel image.
%
% ## Output
% * __dst__ Destination image of the same size and type as src.
%
% The function equalizes the histogram of the input image using the
% following algorithm:
% 
%   1. Calculate the histogram H for src.
% 
%   2. Normalize the histogram so that the sum of histogram bins is 255.
% 
%   3. Compute the integral of the histogram:
% 
%      `H_i' = \sum_{0 <= j < i} H(j)`
% 
%   4. Transform the image using H' as a look-up table:
% 
%      `dst(x,y) = H'(src(x,y))`
% 
% The algorithm normalizes the brightness and increases the contrast of
% the image.
%
