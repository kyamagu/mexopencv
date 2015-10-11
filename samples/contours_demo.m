%% Contours demo
% The example below shows how to retrieve connected components from a binary
% image and label them.

%% Input Image
% some binary (black-n-white) image, i.e class(src) = logical
src = imread(fullfile(mexopencv.root(),'test','bw.png'));
imshow(src), title('Source')
snapnow

%% Connected Components
[contours, hierarchy] = cv.findContours(src, ...
    'Mode','CComp', 'Method','Simple');

%%
% iterate through all the top-level contours,
% draw each connected component with its own random color
dst = zeros([size(src) 3], 'uint8');
idx = 0;
while idx >= 0
    clr = randi([0 255], [1 3], 'uint8');
    dst = cv.drawContours(dst, contours, ...
        'Hierarchy',hierarchy, 'ContourIdx',idx, ...
        'Color',clr, 'Thickness','Filled', 'LineType',8);
    idx = hierarchy{idx+1}(1);
end

%%
% show result
imshow(dst), title('Components')
snapnow
