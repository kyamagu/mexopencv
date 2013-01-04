function facedetect
%FACEDETECT  face detection demo
%
% Before start, addpath('/path/to/mexopencv');
%
disp('Face detection demo. Press any key when done.');

% Load cascade file
xml_file = fullfile(mexopencv.root(),'test','haarcascade_frontalface_alt2.xml');
classifier = cv.CascadeClassifier(xml_file);

% Set up camera
camera = cv.VideoCapture;
pause(3); % Necessary in some environment. See help cv.VideoCapture

% Set up display window
window = figure('KeyPressFcn',@(obj,evt)setappdata(obj,'flag',true));
setappdata(window,'flag',false);

% Start main loop
while true
    % Grab and preprocess an image
    im = camera.read;
    im = cv.resize(im,0.5);
    gr = cv.cvtColor(im,'RGB2GRAY');
    gr = cv.equalizeHist(gr);
    % Detect
    boxes = classifier.detect(gr,'ScaleFactor',1.3,...
                                 'MinNeighbors',2,...
                                 'MinSize',[30,30]);
    % Draw results
    imshow(im);
    for i = 1:numel(boxes)
        rectangle('Position',boxes{i},'EdgeColor','g','LineWidth',2);
    end
    
    % Terminate if any user input
    flag = getappdata(window,'flag');
    if isempty(flag)||flag, break; end
    pause(0.1);
end

% Close
close(window);

end
