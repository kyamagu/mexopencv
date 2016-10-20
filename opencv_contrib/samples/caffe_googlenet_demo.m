%% Deep Neural Network Demo
% Load Caffe framework models.
%
% In this tutorial you will learn how to use DNN module for image
% classification by using GoogLeNet trained network from
% <http://caffe.berkeleyvision.org/model_zoo.html Caffe model zoo>.
%
% <https://github.com/opencv/opencv_contrib/blob/3.1.0/modules/dnn/samples/caffe_googlenet.cpp>
% <http://docs.opencv.org/3.1.0/d5/de7/tutorial_dnn_googlenet.html>
% <http://docs.opencv.org/3.1.0/de/d25/tutorial_dnn_build.html>
%

%% BVLC GoogLeNet
% First, we download GoogLeNet model files:
%
% * |bvlc_googlenet.prototxt| and |bvlc_googlenet.caffemodel|
% * Also we need file with names of
%   <http://image-net.org/challenges/LSVRC/2012/browse-synsets ILSVRC2012>
%   classes: |synset_words.txt|.
%
dirDNN = fullfile(mexopencv.root(), 'test', 'dnn');
modelLabels = fullfile(dirDNN, 'synset_words.txt');
modelTxt = fullfile(dirDNN, 'bvlc_googlenet.prototxt');
modelBin = fullfile(dirDNN, 'bvlc_googlenet.caffemodel');
if ~exist(dirDNN, 'dir')
    mkdir(dirDNN);
end
if ~exist(modelLabels, 'file')
    disp('Downloading...')
    url = 'https://cdn.rawgit.com/opencv/opencv_contrib/3.1.0/modules/dnn/samples/synset_words.txt';
    urlwrite(url, modelLabels);
end
if ~exist(modelTxt, 'file')
    disp('Downloading...')
    url = 'https://cdn.rawgit.com/opencv/opencv_contrib/3.1.0/modules/dnn/samples/bvlc_googlenet.prototxt';
    urlwrite(url, modelTxt);
end
if ~exist(modelBin, 'file')
    disp('Downloading...')
    url = 'http://dl.caffe.berkeleyvision.org/bvlc_googlenet.caffemodel';
    urlwrite(url, modelBin);

    % verify checksum of downloaded file
    if true
        sha1 = '405fc5acd08a3bb12de8ee5e23a96bec22f08204';
        md = java.security.MessageDigest.getInstance('SHA-1');
        fid = fopen(modelBin, 'rb');
        while true
            [b,n] = fread(fid, 1024*512, '*int8');  % 512KB
            if n <= 0, break; end
            md.update(b);
        end
        fclose(fid);
        hex = reshape(dec2hex(typecast(md.digest(),'uint8')).', 1, []);
        assert(isequal(hex, sha1), 'Checksum failed');
    end
end

%% Load class labels
fid = fopen(modelLabels, 'rt');
C = textscan(fid, '%s %[^\n]');
fclose(fid);

labels = C{2};
fprintf('%d classes\n', numel(labels));

%% Read input image
% we resize image and change its channel sequence order
% because GoogLeNet accepts only 224x224 BGR-images
img = cv.imread(fullfile(mexopencv.root(), 'test', 'cat.jpg'), 'FlipChannels',false);
img = cv.resize(img, [224 224]);

%% Create and initialize network from Caffe model
net = cv.Net();
net.importCaffe(modelTxt, modelBin);

%% Set the network input
% we convert the image to 4-dimensional blob (so-called batch)
% with 1x3x224x224 shape.
% In |bvlc_googlenet.prototxt| the network input blob named as "data",
% therefore this blob labeled as ".data" in OpenCV DNN API.
% Other blobs labeled as "name_of_layer.name_of_layer_output".
net.setBlob('.data', single(img));

if false
    % verify we get the same image/blob we set
    im = net.getBlob('.data');
    im = uint8(permute(im, [3 4 2 1]));  % num,cn,row,col -> row,col,cn,num
    assert(isequal(im,img));
    imshow(flip(im,3))                   % BGR to RGB
end

%% Make forward pass
% During the forward pass output of each network layer is computed,
% but in this example we need output from "prob" layer only.
tic
net.forward();  % computes output
toc

%% Gather output of "prob" layer
% We determine the best class by taking the output of "prob" layer, which
% contain probabilities for each of 1000 ILSVRC2012 image classes, and finding
% the index of element with maximal value in this one. This index correspond
% to the class of the image.
p = net.getBlob('prob');       % vector of length 1000
[~,ord] = sort(p, 'descend');  % ordered by maximum probability

%% Print results
t = table(labels(:), p(:), 'VariableNames',{'Class','Probability'});
t = sortrows(t, 'Probability', 'descend');
disp('Top 5 predictions')
disp(t(1:5,:))

subplot(3,1,1:2), imshow(flip(img,3)), title('cat.jpg')
subplot(3,1,3), barh(1:5, t.Probability(1:5)*100)
set(gca, 'YTickLabels',t.Class(1:5), 'YDir','reverse')
axis([0 100 0 6]), grid on
title('Top-5 Predictions'), xlabel('Probability (%)')
