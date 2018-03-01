%% DNN for image classification
%
% An example of how to use the SqueezeNet model to classify an image.
%
% The SqueezeNet model was trained for Image Classification.
%
% * This model was trained for 1500000 iterations with a batch size of 16
% * Size of Model: 4.9MB
% * Top-1 Accuracy on ImageNet 2012 DataSet: 56.10%
% * Top-5 Accuracy on ImageNet 2012 DataSet: 79.54%
% * Trained weights can be found
%   <https://github.com/opencv/opencv_3rdparty/tree/dnn_objdetect_20170827 here>
%
% For details pertaining to the usage of the model, have a look at
% <https://github.com/kvmanohar22/caffe this repository>.
% You can infact train your own object detection models with the loss function
% which is implemented (in Caffe).
%
% The size of the model being *4.9MB*, just takes a time of 0.136401 seconds
% to classify an image.
%
% Use class labels file
% <https://github.com/opencv/opencv_contrib/raw/3.4.1/samples/data/dnn/synset_words.txt synset_words.txt>
% to map the prediction class index to class name.
%
% References:
%
% * <https://arxiv.org/abs/1602.07360 SqueezeNet>
%
% Sources:
%
% * <https://github.com/opencv/opencv_contrib/blob/3.4.1/modules/dnn_objdetect/samples/image_classification.cpp>
% * <https://docs.opencv.org/3.4.1/d2/da2/tutorial_dnn_objdetect.html>
%

%%
% load the network along with its trained weights
[net, blobOpts] = SqueezeNet();
assert(~net.empty(), 'Could not load model');

%%
% load test image
im = fullfile(mexopencv.root(), 'test', 'space_shuttle.jpg');
img = cv.imread(im, 'Color',true, 'FlipChannels',false);

%%
% convert the image into blob, and set the input blob
blob = cv.Net.blobFromImages(img, blobOpts{:});
net.setInput(blob);

%%
% get the output of the "predictions" layer
% probs is a 4D tensor of shape 1x1000x1x1, the output of softmax activation
tic
probs = net.forward('predictions');
toc

%%
% max prediction
probs = probs(:);  % 1000x1
[max_prob, class_idx] = max(probs);
fprintf('Best class Index: %d\n', class_idx);
fprintf('Probability: %f\n', max_prob*100);

%%
% Pretrained models

function dname = get_dnn_dir(dname)
    %GET_DNN_DIR  Path to model files, and show where to get them if missing

    dname = fullfile(mexopencv.root(), 'test', 'dnn', dname);
    b = isdir(dname);
    if ~b
        % display help of calling function
        % (assumed to be a local function in current file)
        st = dbstack(1);
        help([mfilename() filemarker() st(1).name])
    end
    assert(b, 'Missing model: %s', dname);
end

function [net, blobOpts] = SqueezeNet()
    %SQUEEZENET  SqueezeNet model trained on ImageNet 2012 Dataset [Caffe]
    %
    % homepage = https://github.com/kvmanohar22/caffe
    % homepage = https://kvmanohar22.github.io/GSoC/
    % homepage = https://github.com/opencv/opencv_3rdparty/tree/dnn_objdetect_20170827
    % homepage = https://github.com/opencv/opencv_contrib/tree/3.4.1/modules/dnn_objdetect/samples/data
    %
    % ## Model
    %
    % file = test/dnn/SqueezeDet/SqueezeNet_deploy.prototxt
    % url  = https://github.com/opencv/opencv_contrib/raw/3.4.1/modules/dnn_objdetect/samples/data/SqueezeNet_deploy.prototxt
    % hash = b518ef2a11a72aea6ef1d0170ac7cc239d8a4694
    %
    % ## Weights
    %
    % file = test/dnn/SqueezeDet/SqueezeNet.caffemodel
    % url  = https://github.com/opencv/opencv_3rdparty/raw/dnn_objdetect_20170827/SqueezeNet.caffemodel
    % hash = 507d7975c86591361a30efffb1b31270cf8fa650
    % size = 4.77 MB
    %

    dname = get_dnn_dir('SqueezeDet');
    net = cv.Net('Caffe', ...
        fullfile(dname, 'SqueezeNet_deploy.prototxt'), ...
        fullfile(dname, 'SqueezeNet.caffemodel'));
    blobOpts = {'SwapRB',false, 'Crop',false, 'Size',[416 416], 'Mean',[104 117 123]};
end
