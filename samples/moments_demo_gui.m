%% Image Moments
% We learn to calculate the moments of an image.
%
% In this sample you will learn how to use the following OpenCV functions:
%
% * <matlab:doc('cv.moments') cv.moments>
% * <matlab:doc('cv.contourArea') cv.contourArea>
% * <matlab:doc('cv.arcLength') cv.arcLength>
%
% Sources:
%
% * <https://docs.opencv.org/3.4.0/d0/d49/tutorial_moments.html>
% * <https://github.com/opencv/opencv/blob/3.4.0/samples/cpp/tutorial_code/ShapeDescriptors/moments_demo.cpp>
%

function varargout = moments_demo_gui(im)
    % load source image
    if nargin < 1
        src = imread(fullfile(mexopencv.root(),'test','monster.jpg'));
    elseif ischar(im)
        src = imread(im);
    else
        src = im;
    end

    % Convert image to gray and blur it
    if size(src,3) == 3
        src = cv.cvtColor(src, 'RGB2GRAY');
    end
    src = cv.blur(src, 'KSize',[3 3]);

    % create the UI
    h = buildGUI(src);
    if nargout > 0, varargout{1} = h; end
end

function onChange(~,~,h)
    %ONCHANGE  Event handler for UI controls

    % retrieve current values from UI controls
    thresh = round(get(h.slid, 'Value'));
    set(h.txt, 'String',sprintf('Canny thresh: %3d',thresh));

    % Detect edges using Canny
    canny_output = cv.Canny(h.src, [thresh thresh*2], 'ApertureSize',3);

    % Find contours
    contours = cv.findContours(canny_output, 'Mode','Tree', 'Method','Simple');

    % Get the moments and compute the mass center
    mu = cell(size(contours));
    mc = cell(size(contours));
    for i=1:numel(contours)
        mu{i} = cv.moments(contours{i}, 'BinaryImage',false);
        mc{i} = [mu{i}.m10, mu{i}.m01] ./ mu{i}.m00;
    end

    % Draw contours
    drawing = zeros([size(canny_output) 3], 'uint8');
    for i=1:numel(contours)
        clr = randi([0 255], [1 3], 'uint8');
        drawing = cv.drawContours(drawing, contours, 'ContourIdx',i-1, ...
            'Color',clr, 'Thickness',2);
        drawing = cv.circle(drawing, mc{i}, 4, ...
            'Color',clr, 'Thickness','Filled');
    end

    % show result
    set(h.img, 'CData',drawing);
    drawnow;

    % Calculate the area with the moments 00 and compare with the result of
    % the OpenCV function
    fprintf('\t Info: Area and Contour Length \n');
    for i=1:numel(contours)
        fprintf([' * Contour[%d] - Area (M_00) = %.2f - Area OpenCV: %.2f' ...
            ' - Length: %.2f \n'], i, mu{i}.m00, ...
            cv.contourArea(contours{i}), ...
            cv.arcLength(contours{i}, 'Closed',true));
    end
end

function h = buildGUI(img)
    %BUILDGUI  Creates the UI

    % parameters
    thresh = 100;
    max_thresh = 255;
    sz = size(img);
    sz(2) = max(sz(2), 250);  % minimum figure width

    % build the user interface (no resizing to keep it simple)
    h = struct();
    h.src = img;
    h.fig = figure('Name','Image Moments Demo', ...
        'NumberTitle','off', 'Menubar','none', 'Resize','off', ...
        'Position',[200 200 sz(2) sz(1)+29]);
    if ~mexopencv.isOctave()
        %HACK: not implemented in Octave
        movegui(h.fig, 'center');
    end
    h.ax = axes('Parent',h.fig, 'Units','pixels', 'Position',[1 30 sz(2) sz(1)]);
    if ~mexopencv.isOctave()
        h.img = imshow(img, 'Parent',h.ax);
    else
        %HACK: https://savannah.gnu.org/bugs/index.php?45473
        axes(h.ax);
        h.img = imshow(img);
    end
    h.txt = uicontrol('Parent',h.fig, 'Style','text', 'FontSize',11, ...
        'Position',[5 5 130 20], 'String',sprintf('Canny thresh: %3d',thresh));
    h.slid = uicontrol('Parent',h.fig, 'Style','slider', 'Value',thresh, ...
        'Min',0, 'Max',max_thresh, 'SliderStep',[1 10]./(max_thresh-0), ...
        'Position',[135 5 sz(2)-135-5 20]);

    % hook event handlers, and trigger default start
    set(h.slid, 'Callback',{@onChange,h}, ...
        'Interruptible','off', 'BusyAction','cancel');
    onChange([],[],h);
end
