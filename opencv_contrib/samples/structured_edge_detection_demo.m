%% Structured Edge Detection demo
% This sample demonstrates structured forests for fast edge detection.
%
% <https://github.com/opencv/opencv_contrib/blob/3.1.0/modules/ximgproc/samples/structured_edge_detection.cpp>
%

%% Load image
% read RGB image
img = cv.imread(fullfile(mexopencv.root(),'test','balloon.jpg'), 'Color',true);
assert(~isempty(img), 'Cannot read image file');

% convert to floating point in [0,1] range
img = single(img) / 255;

%% Create object
% we load a pre-trained model
modelFilename = fullfile(mexopencv.root(),'test','model.yml.gz');
if exist(modelFilename, 'file') ~= 2
    % download model from GitHub
    url = 'https://cdn.rawgit.com/opencv/opencv_extra/3.1.0/testdata/cv/ximgproc/model.yml.gz';
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

% convert grayscale [0,1] float image to 8-bit
edges = uint8(edges * 255);

%% Display result
subplot(211), imshow(img), title('image')
subplot(212), imshow(edges), title('edges')
