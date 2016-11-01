%% Fit ellipses demo
% This program is demonstration for ellipse fitting. The program finds
% contours and approximate them by ellipses.
%
% Trackbar specify threshold parameter.
%
% White lines are contours. Red lines are fitting ellipses.
%
% <https://github.com/opencv/opencv/blob/3.1.0/samples/cpp/fitellipse.cpp>
%

function varargout = fitellipse_demo_gui(im)
    % load source image
    if nargin < 1
        im = fullfile(mexopencv.root(),'test','stuff.jpg');
        src = cv.imread(im, 'Grayscale',true);
    elseif ischar(im)
        src = cv.imread(im, 'Grayscale',true);
    else
        src = im;
    end
    % we expect a grayscale image
    if size(src,3) == 3, src = cv.cvtColor(src, 'RGB2GRAY'); end

    % create the UI
    h = buildGUI(src);
    if nargout > 1, varargout{1} = h; end
end

function onChange(~,~,h)
    %ONCHANGE  Event handler for UI controls

    % retrieve current values from UI controls
    thresh = round(get(h.slid, 'Value'));
    set(h.txt, 'String',sprintf('Threshold: %3d',thresh));

    % threshold image and compute find contours
    bimg = uint8(h.src >= thresh) * 255;
    contours = cv.findContours(bimg, 'Mode','List', 'Method','None');

    % for each contour
    cimg = zeros([size(bimg) 3], 'uint8');
    for i=1:numel(contours)
        if numel(contours{i}) < 6
            % skip: contour too simple, probably not an ellipse
            continue;
        end

        % approximate by an ellipse
        rrect = cv.fitEllipse(contours{i});
        if max(rrect.size) > min(rrect.size)*30
            % skip: rectangle too tall/wide
            continue;
        end

        % draw contour
        cimg = cv.drawContours(cimg, contours, 'ContourIdx',i-1, ...
            'Color',[255 255 255]);

        % draw ellipse
        cimg = cv.ellipse(cimg, rrect, 'Color',[255 0 0], 'LineType','AA');
        if false
            cimg = cv.ellipse(cimg, rrect.center, rrect.size*0.5, ...
                'Angle',rrect.angle, 'Color',[255 255 0], 'LineType','AA');
        end

        % draw rotated rectangle of ellipse
        vtx = cv.RotatedRect.points(rrect);
        cimg = cv.line(cimg, vtx(1:4,:), vtx([2:4 1],:), ...
            'Color',[0 255 0], 'LineType','AA');
    end

    % show result
    set(h.img, 'CData',cimg);
    drawnow;
end

function h = buildGUI(img)
    %BUILDGUI  Creates the UI

    % parameters
    thresh = 70;
    max_thresh = 255;
    sz = size(img);
    sz(2) = max(sz(2), 250);  % minimum figure width

    % build the user interface (no resizing to keep it simple)
    h = struct();
    h.src = img;
    h.fig = figure('Name','Ellipse Fit', ...
        'NumberTitle','off', 'Menubar','none', 'Resize','off', ...
        'Position',[200 200 sz(2) sz(1)+29]);
    if ~mexopencv.isOctave()
        %HACK: not implemented in Octave
        movegui(h.fig, 'center');
    end
    h.ax = axes('Parent',h.fig, ...
        'Units','pixels', 'Position',[1 30 sz(2) sz(1)]);
    if ~mexopencv.isOctave()
        h.img = imshow(img, 'Parent',h.ax);
    else
        %HACK: https://savannah.gnu.org/bugs/index.php?45473
        axes(h.ax);
        h.img = imshow(img);
    end
    h.txt = uicontrol('Parent',h.fig, 'Style','text', 'FontSize',11, ...
        'Position',[5 5 130 20], 'String',sprintf('Threshold: %3d',thresh));
    h.slid = uicontrol('Parent',h.fig, 'Style','slider', 'Value',thresh, ...
        'Min',0, 'Max',max_thresh, 'SliderStep',[1 10]./(max_thresh-0), ...
        'Position',[135 5 sz(2)-135-5 20]);

    % hook event handlers, and trigger default start
    set(h.slid, 'Callback',{@onChange,h}, ...
        'Interruptible','off', 'BusyAction','cancel');
    onChange([],[],h);
end
