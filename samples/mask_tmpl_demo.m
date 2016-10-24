%% Template Matching demo
% This program demonstrates template match with mask.
%
% <https://github.com/opencv/opencv/blob/3.1.0/samples/cpp/mask_tmpl.cpp>
%

%% Load Images
if false
    img = cv.imread(fullfile(mexopencv.root(),'test','lena_tmpl.jpg'));
    tmpl = cv.imread(fullfile(mexopencv.root(),'test','tmpl.png'));
    mask = cv.imread(fullfile(mexopencv.root(),'test','mask.png'), 'Color',true);
    assert(isequal(size(tmpl), size(mask)));
    opts = {'Mask',mask};
else
    img = imread(which('peppers.png'));
    tmpl = imread(which('onion.png'));
    opts = {};
end

%% Template Matching
method = 'CCorrNormed';  % 'SqDiff'
res = cv.matchTemplate(img, tmpl, 'Method',method, opts{:});
surf(res), shading flat
title('normalized cross correlation')

%% Find global optimum in result
switch method
    case {'SqDiff', 'SqDiffNormed'}
        val = min(res(:));
    otherwise
        val = max(res(:));
end
[y,x] = find(res == val);
[h,w,~] = size(tmpl);
rect = [x y w h];

%% Display matched area
out = cv.rectangle(img, rect, 'Color',[0 255 0], 'Thickness',2);

figure
subplot(221), imshow(img), title('image')
subplot(222), imshow(tmpl), title('template')
subplot(2,2,[3 4]), imshow(out), title('detected template')
