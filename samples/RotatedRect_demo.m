%% Rotated Rectangle demo
% The sample below demonstrates how to use cv.RotatedRect
%

%%
img = zeros([200 200 3], 'uint8');
rRect = struct('center',[100 100], 'size',[100 50], 'angle',30);

%%
vertices = cv.RotatedRect.points(rRect);
for i=1:4
  img = cv.line(img, vertices(i,:), vertices(mod(i,4)+1,:), ...
      'Color',[0 255 0]);
end

%%
brect = cv.RotatedRect.boundingRect(rRect);
img = cv.rectangle(img, brect, 'Color',[255 0 0]);

%%
imshow(img); title('rectangles')
