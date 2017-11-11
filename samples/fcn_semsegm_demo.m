%% Fully-Convolutional Networks Sematic Segmentation Demo
%
% "Fully Convolutional Models for Semantic Segmentation", Jonathan Long,
% Evan Shelhamer and Trevor Darrell, CVPR, 2015.
% <http://www.cv-foundation.org/openaccess/content_cvpr_2015/papers/Long_Fully_Convolutional_Networks_2015_CVPR_paper.pdf>
%
% <https://github.com/opencv/opencv/blob/3.3.0/samples/dnn/fcn_semsegm.cpp>
%

%% Model files
dirDNN = fullfile(mexopencv.root(), 'test', 'dnn', 'FCN');
modelLabels = fullfile(dirDNN, 'pascal-classes.txt');
modelTxt = fullfile(dirDNN, 'fcn8s-heavy-pascal.prototxt');
modelBin = fullfile(dirDNN, 'fcn8s-heavy-pascal.caffemodel');  % 513MB file

files = {modelLabels, modelTxt, modelBin};
urls = {
    'https://cdn.rawgit.com/opencv/opencv/3.3.0/samples/data/dnn/pascal-classes.txt';
    'https://cdn.rawgit.com/opencv/opencv/3.3.0/samples/data/dnn/fcn8s-heavy-pascal.prototxt';
    'http://dl.caffe.berkeleyvision.org/fcn8s-heavy-pascal.caffemodel';
};
if ~isdir(dirDNN), mkdir(dirDNN); end
for i=1:numel(files)
    if exist(files{i}, 'file') ~= 2
        disp('Downloading...')
        if i==3
            choice = questdlg({'Downloading a large Caffe model (>500MB).', ...
                'Continue?'}, 'Download', 'OK', 'Cancel', 'OK');
            assert(strcmp(choice, 'OK'), 'Download cancelled');
        end
        urlwrite(urls{i}, files{i});
    end
end

%% Load classes and their colors
fid = fopen(modelLabels, 'rt');
C = textscan(fid, '%s %d %d %d', 'CollectOutput',true);
fclose(fid);
labels = C{1};
colors = uint8(C{2});
fprintf('%d classes\n', numel(labels));

%% Create and initialize network from Caffe model
net = cv.Net('Caffe', modelTxt, modelBin);
assert(~net.empty(), 'Cant load network');

%% Prepare blob
% Set the network input (VOC-FCN8s was trained on 500x500 BGR-images)
img = cv.imread(fullfile(mexopencv.root(), 'test', 'rgb.jpg'), ...
    'Color',true, 'FlipChannels',false);
if true
    blob = cv.Net.blobFromImages(img, 'Size',[500 500]);
elseif true
    blob = cv.resize(img, [500 500]);
    blob = permute(blob, [4 3 1 2]);
    blob = single(blob);
else
    blob = img;
    blob = permute(blob, [4 3 1 2]);
    blob = single(blob);
end
net.setInput(blob, 'data');

%% Make forward pass
% computes output
tic
score = net.forward('score');
toc

%% Gather output
score = permute(score, [3 4 2 1]);  % num,cn,row,col -> row,col,cn,num

% max scores and corresponding labels
[S,L] = max(score, [], 3);

% free memory
%clear net

%% Result

% for display, recover image from blob as fed to network
if true
    rgb = permute(uint8(round(blob)), [3 4 2 1]);
elseif true
    rgb = flip(cv.resize(img, [500 500]), 3);
else
    rgb = flip(img, 3);
end

% colorize segmentations using label colors and overlay on top of image
out = reshape(colors(L(:),:), [size(L) 3]);
out = cv.addWeighted(rgb, 0.4, out, 0.6, 0.0);

% highlight segmented objects
for lbl=2:numel(labels)  % skip 1, background label
    % regionprops
    BW = (L == lbl);
    if nnz(BW) == 0, continue; end
    [~,~,stats,centroids] = cv.connectedComponents(BW);

    % ignore small areas
    idx = stats(:,5) < 200;
    stats(idx,:) = [];
    centroids(idx,:) = [];

    % show bounding box around objects + show name
    clr = colors(lbl,:);
    label = labels{lbl};
    for i=1:size(stats,1)
        boundingBox = double(stats(i,1:4));
        out = cv.rectangle(out, boundingBox, 'Color',clr, 'Thickness',1);
        out = cv.putText(out, label, boundingBox(1:2)-[0 6], ...
            'Color',clr, 'FontScale',0.5);
    end
end

% display
figure(1), imshow(out), title('segmentation')
figure(2), imshow(S,[]), title('score'), colorbar
