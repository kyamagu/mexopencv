%% Structured Edge Detection demo
% This sample demonstrates structured forests for fast edge detection.
%
% The structered edge demo requires you to provide a model.
% This demo downloads a model from the opencv_extra repository on Github.
%
% Sources:
%
% * <https://github.com/opencv/opencv_contrib/blob/3.3.0/modules/ximgproc/samples/structured_edge_detection.cpp>
%

%% Load image
% read RGB image
img = cv.imread(fullfile(mexopencv.root(),'test','balloon.jpg'), 'Color',true);
assert(~isempty(img), 'Cannot read image file');

% convert to floating-point in [0,1] range
img = single(img) / 255;

%% Create object
% we load a pre-trained model
modelFilename = fullfile(mexopencv.root(),'test','model.yml.gz');
if exist(modelFilename, 'file') ~= 2
    % download model from GitHub
    url = 'https://cdn.rawgit.com/opencv/opencv_extra/3.3.0/testdata/cv/ximgproc/model.yml.gz';
    disp('Downloading model...')
    urlwrite(url, modelFilename);
end

tic
pDollar = cv.StructuredEdgeDetection(modelFilename);
toc

%% Detect edges
tic
edges = pDollar.detectEdges(img);
toc

%%
% convert grayscale [0,1] float image to 8-bit
e8u = uint8(edges * 255);

%%
% computes orientation from edge map
orientation_map = pDollar.computeOrientation(edges);

%%
% suppress edges
edge_nms = pDollar.edgesNms(edges, orientation_map);

%% Display result
subplot(221), imshow(img), title('image')
subplot(222), imshow(e8u), title('edges')
subplot(223), imshow(edge_nms), title('edges NMS')
