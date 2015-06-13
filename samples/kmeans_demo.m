%% K-means demo
% An example on K-means clustering.
%
% This program demonstrates kmeans clustering.
% It generates an image with random points, then assigns a random number of
% cluster centers and uses kmeans to move those cluster centers to their
% representitive location.
%
% <https://github.com/Itseez/opencv/blob/master/samples/cpp/kmeans.cpp>

%% Initialization

% parameters
MAX_CLUSTERS = 5;
colorTab = [...
    0,   0, 255 ;
    0, 255,   0 ;
  255, 100, 100 ;
  255,   0, 255 ;
    0, 255, 255
];

% image on which to draw points
sz = [200 300];  % height/width, rows/cols
img = zeros([sz, 3], 'uint8');

% seed RNG for reproducible results
rng('default')

%% Data
% choose number of samples and clusters
sampleCount = randi([1 1000]);
clusterCount = min(randi([2 MAX_CLUSTERS]), sampleCount);

%%
% generate random samples from multigaussian distribution
points = zeros([sampleCount,2], 'single');
idx = fix(linspace(1, sampleCount+1, clusterCount+1));
for i=1:numel(idx)-1
    center = [randi([0, sz(2)]) randi([0, sz(1)])];
    sigma = [sz(2) sz(1)].*0.4;
    points(idx(i):idx(i+1)-1,:) = mvnrnd(center, sigma, idx(i+1)-idx(i));
end

%%
% show true labels
L = repelem(1:(numel(idx)-1), diff(idx));
gscatter(points(:,1), points(:,2), L)
axis square equal ij
axis([1 sz(2) 1 sz(1)])
snapnow

%% Clustering
% shuffle points
points = points(randperm(sampleCount),:);

%%
% cluster points
[labels,centers] = cv.kmeans(points, clusterCount, ...
    'Criteria',struct('type','Count+EPS', 'maxCount',10, 'epsilon',0.1), ...
    'Attempts',3, 'Initialization','PP');
display(centers)

%%
% show clusters
img(:) = 0;
for i=1:sampleCount
    clusterIdx = labels(i)+1;
    img = cv.circle(img, points(i,:), 2, ...
        'Color',colorTab(clusterIdx,:), ...
        'Thickness','Filled', 'LineType','AA');
end
imshow(img), title('clusters')
