function facedetect
%FACEDETECT  face detection demo
%
% Before start, addpath('/path/to/mexopencv');
%
disp('Face detection demo. Press Ctrl-C when done.');

% Load cascade file
root = fileparts(fileparts(mfilename('fullpath')));
xml_file = fullfile(root,'test','haarcascade_frontalface_alt2.xml');
classifier = cv.CascadeClassifier(xml_file);

% Set up camera
camera = cv.VideoCapture;
pause(3); % Necessary in some environment. See help cv.VideoCapture

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
    hold on;
    for i = 1:numel(boxes)
        rectangle('Position',boxes{i},'EdgeColor','g');
    end
    hold off;
    pause(0.3);
end

end