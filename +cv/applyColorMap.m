%APPLYCOLORMAP  Applies a GNU Octave/MATLAB equivalent colormap on a given image
%
%     dst = cv.applyColorMap(src, colormap)
%     dst = cv.applyColorMap(src, userColor)
%     dst = cv.applyColorMap(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ The source image, grayscale or color of type `uint8`.
% * __colormap__ The colormap to apply. A string, one of:
%   * __Autumn__ Shades of red and yellow color map.
%   * __Bone__ Gray-scale with a tinge of blue color map.
%   * __Jet__ Variant of HSV.
%   * __Winter__ Shades of blue and green color map.
%   * __Rainbow__ Red-orange-yellow-green-blue-violet color map.
%   * __Ocean__ Black to white with shades of blue color map.
%   * __Summer__ Shades of green and yellow colormap.
%   * __Spring__ Shades of magenta and yellow color map.
%   * __Cool__ Shades of cyan and magenta color map.
%   * __HSV__ Hue-saturation-value color map.
%   * __Pink__ Pastel shades of pink color map.
%   * __Hot__ Black-red-yellow-white color map.
%   * __Parula__ Blue-green-orange-yellow color map.
% * __userColor__ The colormap to apply of type `uint8` (1 or 3 channels) and
%   length 256.
%
% ## Output
% * __dst__ The result is the colormapped source image. Same row/column size
%   and same type as `src`.
%
% ## Options
% * __FlipChannels__ whether to flip the order of color channels in output
%   `dst`, from OpenCV's BGR to between MATLAB's RGB. default true
%
% The human perception isn't built for observing fine changes in grayscale
% images. Human eyes are more sensitive to observing changes between colors,
% so you often need to recolor your grayscale images to get a clue about them.
% OpenCV now comes with various colormaps to enhance the visualization in your
% computer vision application.
%
% The second variant of the function applies a user-defined colormap on the
% given image.
%
% ## Example
%
% In OpenCV you only need cv.applyColorMap to apply a colormap on a given
% image. The following sample code takes an image and applies a Jet colormap
% on it and shows the result:
%
%     % We need an input image. (can be grayscale or color)
%     img_in = im2uint8(mat2gray(peaks(500)));
%
%     % Apply the colormap
%     %img_color2 = im2uint8(ind2rgb(img_in, jet(256)));
%     img_color = cv.applyColorMap(img_in, 'Jet');
%
%     % Show the result
%     imshow(img_color)
%
% ## Example
%
%     cmaps = {'Autumn', 'Bone', 'Jet', 'Winter', 'Rainbow', 'Ocean', ...
%         'Summer', 'Spring', 'Cool', 'HSV', 'Pink', 'Hot', 'Parula'};
%     img = cell2mat(cellfun(@(cmap) ...
%         cv.applyColorMap(repmat(uint8(0:255), 20, 1), cmap), cmaps(:), ...
%         'UniformOutput',false));
%     image(img)
%     set(gca, 'YTick', 10:20:20*numel(cmaps), 'YTickLabel',cmaps)
%     title('Colormaps')
%
% See also: cv.LUT, ind2rgb, colormap, autumn, bone, jet, winter, summer,
%  spring, cool, hsv, pink, hot, parula
%
