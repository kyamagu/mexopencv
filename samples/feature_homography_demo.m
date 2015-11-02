%% Feature Matching + Homography to find a known object
% In this sample, you will use features2d and calib3d to detect an object in a
% scene.
%
% You will learn how to:
%
% * Use the function <matlab:doc('cv.findHomography') cv.findHomography> to
%   find the transform between matched keypoints.
% * Use the function <matlab:doc('cv.perspectiveTransform') cv.perspectiveTransform>
%   to map the points.
%
% <http://docs.opencv.org/3.0.0/d7/dff/tutorial_feature_homography.html>,
% <http://docs.opencv.org/3.0.0/d1/de0/tutorial_py_feature_homography.html>
%

%% Input images
imgObj = cv.imread(fullfile(mexopencv.root(),'test','box.png'), 'Grayscale',true);
imgScene = cv.imread(fullfile(mexopencv.root(),'test','box_in_scene.png'), 'Grayscale',true);
subplot(1,3,1), imshow(imgObj), title('object')
subplot(1,3,[2 3]), imshow(imgScene), title('scene')

%% Step 1: Detect the keypoints and extract descriptors using SURF
nonfree = false;  % requires xfeatures2d
if nonfree
    detector = cv.SURF('HessianThreshold',400);
else
    detector = cv.ORB();
end
[keyObj,featObj] = detector.detectAndCompute(imgObj);
[keyScene,featScene] = detector.detectAndCompute(imgScene);
display(keyObj); display(keyScene)
whos featObj featScene

%% Step 2: Matching descriptor vectors using FLANN matcher
if nonfree
    matcher = cv.DescriptorMatcher('FlannBased');
else
    matcher = cv.DescriptorMatcher('BruteForce-Hamming');
end
m = matcher.match(featObj, featScene);
display(m)

%%
% Keep only "good" matches (i.e. whose distance is less than k*min_dist)
dist = [m.distance];
cutoff = 3*min(dist);
m = m(dist <= cutoff);
fprintf('Min dist = %f\nMax dist = %f\nCutoff = %f\n', ...
    min(dist), max(dist), cutoff);
whos m

% show original and filtered distances
clf
hh = histogram(dist); hold on
histogram([m.distance], hh.BinEdges)
line([cutoff cutoff] + hh.BinWidth/2, ylim(), 'LineWidth',2, 'Color','r')
hold off
title('Distribution of match distances')
legend({'All', 'Good', 'cutoff'})

%%
% Get the keypoints from the good matches
% (Note: indices in C are zero-based while MATLAB are one-based)
ptsObj = cat(1, keyObj([m.queryIdx]+1).pt);
ptsScene = cat(1, keyScene([m.trainIdx]+1).pt);
whos ptsObj ptsScene

%% Step 3: Compute homography
[H,inliers] = cv.findHomography(ptsObj, ptsScene, 'Method','Ransac');
inliers = logical(inliers);
display(H)
fprintf('Num outliers reported by RANSAC = %d\n', nnz(~inliers));

%% Step 4: Localize the object
%

% get the corners from the first image (the object to be "detected")
[h,w,~] = size(imgObj);
corners = [0 0; w 0; w h; 0 h];
display(corners)

% apply the homography to the corner points of the box
p = cv.perspectiveTransform(corners, H);
display(p)

%% Show results
%

% draw the final good matches
imgMatches = cv.drawMatches(imgObj, keyObj, imgScene, keyScene, m, ...
    'NotDrawSinglePoints',true, 'MatchesMask',inliers);

% draw lines between the transformed corners (the mapped object in the scene)
p(:,1) = p(:,1) + w;  % shift points for the montage image
imgMatches = cv.polylines(imgMatches, {num2cell(p,2)}, 'Closed',true, ...
    'Color',[0 255 0], 'Thickness',4, 'LineType','AA');
imshow(imgMatches)
title('Good Matches & Object detection')
