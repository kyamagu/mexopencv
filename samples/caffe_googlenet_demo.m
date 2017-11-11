%% Deep Neural Network Demo
% Load Caffe framework models.
%
% In this tutorial you will learn how to use DNN module for image
% classification by using GoogLeNet trained network from
% <http://caffe.berkeleyvision.org/model_zoo.html Caffe model zoo>.
%
% <https://github.com/opencv/opencv/blob/3.3.0/samples/dnn/caffe_googlenet.cpp>,
% <http://docs.opencv.org/3.3.0/d5/de7/tutorial_dnn_googlenet.html>
%

%% BVLC GoogLeNet
% First, we download GoogLeNet model files:
%
% * |bvlc_googlenet.prototxt| and |bvlc_googlenet.caffemodel|
% * Also we need file with names of
%   <http://image-net.org/challenges/LSVRC/2012/browse-synsets ILSVRC2012>
%   classes: |synset_words.txt|.
%
dirDNN = fullfile(mexopencv.root(), 'test', 'dnn', 'GoogLeNet');
modelLabels = fullfile(dirDNN, 'synset_words.txt');
modelTxt = fullfile(dirDNN, 'bvlc_googlenet.prototxt');
modelBin = fullfile(dirDNN, 'bvlc_googlenet.caffemodel');
if ~isdir(dirDNN)
    mkdir(dirDNN);
end
if exist(modelLabels, 'file') ~= 2
    disp('Downloading...')
    url = 'https://cdn.rawgit.com/opencv/opencv/3.3.0/samples/data/dnn/synset_words.txt';
    urlwrite(url, modelLabels);
end
if exist(modelTxt, 'file') ~= 2
    disp('Downloading...')
    url = 'https://cdn.rawgit.com/opencv/opencv/3.3.0/samples/data/dnn/bvlc_googlenet.prototxt';
    urlwrite(url, modelTxt);
end
if exist(modelBin, 'file') ~= 2
    disp('Downloading...')
    url = 'http://dl.caffe.berkeleyvision.org/bvlc_googlenet.caffemodel';
    urlwrite(url, modelBin);

    % verify checksum of downloaded file
    if ~mexopencv.isOctave()
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
if mexopencv.isOctave()
    %HACK: %[] format specifier not implemented in Octave
    C = textscan(fid, '%s', 'Delimiter','\n');
    labels = regexprep(C{1}, '^\w+\s*', '', 'once');
else
    C = textscan(fid, '%s %[^\n]');
    labels = C{2};
end
fclose(fid);

fprintf('%d classes\n', numel(labels));

%% Create and initialize network from Caffe model
net = cv.Net('Caffe', modelTxt, modelBin);
assert(~net.empty(), 'Cant load network');

%% Prepare blob from input image
% Read input image (BGR channel order)
img = cv.imread(fullfile(mexopencv.root(), 'test', 'cat.jpg'), ...
    'Color',true, 'FlipChannels',false);

%%
% we resize and convert the image to 4-dimensional blob (so-called batch)
% with 1x3x224x224 shape, because GoogLeNet accepts only 224x224 BGR-images.
% we also subtract the mean pixel value of the training dataset ILSVRC_2012
% (B: 104.0069879317889, G: 116.66876761696767, R: 122.6789143406786)
if true
    blob = cv.Net.blobFromImages(img, ...
        'Size',[224 224], 'Mean',[104 117 123], 'SwapRB',true);
else
    % NOTE: blobFromImages does crop/resize to maintain aspect ratio of image
    blob = cv.resize(img, [224 224]);                       % Size
    blob = bsxfun(@plus, blob, uint8(cat(3,123,117,104)));  % Mean (BGR)
    blob = permute(blob, [4 3 1 2]);                        % HWCN -> NCHW
    blob = single(blob);                                    % CV_32F
end

%% Set the network input
% In |bvlc_googlenet.prototxt| the network input blob named as "data".
% Other blobs labeled as "name_of_layer.name_of_layer_output".
net.setInput(blob, 'data');

%% Make forward pass and compute output
% During the forward pass output of each network layer is computed,
% but in this example we need output from "prob" layer only.
tic
p = net.forward('prob');  % vector of length 1000
toc

%% Gather output of "prob" layer
% We determine the best class by taking the output of "prob" layer, which
% contain probabilities for each of 1000 ILSVRC2012 image classes, and finding
% the index of element with maximal value in this one. This index correspond
% to the class of the image.
[~,ord] = sort(p, 'descend');  % ordered by maximum probability

%% Show predictions
if ~mexopencv.isOctave()
    %HACK: TABLE not implemented in Octave
    t = table(labels(:), p(:), 'VariableNames',{'Label','Probability'});
    t = sortrows(t, 'Probability', 'descend');
    disp('Top 5 predictions');
    disp(t(1:5,:));
end

subplot(3,1,1:2), imshow(flip(img,3)), title('cat.jpg')
subplot(3,1,3), barh(1:5, p(ord(1:5))*100)
set(gca, 'YTickLabel',labels(ord(1:5)), 'YDir','reverse')
axis([0 100 0 6]), grid on
title('Top-5 Predictions'), xlabel('Probability (%)')
