%% Interactive Mask demo
% Interactively create a polygon mask.
%
% This demo uses Image Processing Toolbox functions.
%
% See also: impoly, getline, roipoly
%
% Sources:
%
% * <https://github.com/opencv/opencv/blob/3.1.0/samples/cpp/create_mask.cpp>
%

% load an image, and display it
src = imread(fullfile(mexopencv.root(),'test','fruits.jpg'));
imshow(src);

% interactively create a polygon
hax = imgca;
h = impoly(hax, 'Closed',true);
api = iptgetapi(h);
fcn = makeConstrainToRectFcn('impoly', get(hax,'XLim'), get(hax,'YLim'));
api.setPositionConstraintFcn(fcn);

% get 2D points
pts = wait(h);
display(pts)

% create binary mask
mask = createMask(h);

% apply mask on image
out = bsxfun(@times, src, cast(mask,'like',src));

% show result
figure
subplot(121), imshow(mask), title('mask')
subplot(122), imshow(out), title('output')
