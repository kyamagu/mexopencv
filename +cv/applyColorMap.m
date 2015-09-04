%APPLYCOLORMAP  Applies a GNU Octave/MATLAB equivalent colormap on a given image
%
%    dst = cv.applyColorMap(src, colormap)
%
% ## Input
% * __src__ The source image, grayscale or colored does not matter.
% * __colormap__ The colormap to apply. A string, one of:
%       * __Autumn__
%       * __Bone__
%       * __Jet__
%       * __Winter__
%       * __Rainbow__
%       * __Ocean__
%       * __Summer__
%       * __Spring__
%       * __Cool__
%       * __Hsv__
%       * __Pink__
%       * __Hot__
%       * __Parula__
%
% ## Output
% * __dst__ The result is the colormapped source image. Same row/column size
%       and same type as `src`.
%
% The human perception isn't built for observing fine changes in grayscale
% images. Human eyes are more sensitive to observing changes between colors,
% so you often need to recolor your grayscale images to get a clue about them.
% OpenCV now comes with various colormaps to enhance the visualization in your
% computer vision application.
%
% ## Example
%
% In OpenCV you only need cv.applyColorMap to apply a colormap on a given
% image. The following sample code takes an image and applies a Jet colormap
% on it and shows the result:
%
%    % We need an input image. (can be grayscale or color)
%    img_in = im2uint8(mat2gray(peaks(500)));
%
%    % Apply the colormap
%    %img_color2 = ind2rgb(img_in, jet(256));
%    img_color = cv.applyColorMap(img_in, 'Jet');
%
%    % Show the result
%    imshow(img_color)
%
% See also: cv.LUT, ind2rgb, colormap, autumn, bone, jet, winter, summer,
%  spring, cool, hsv, pink, hot, parula
%
