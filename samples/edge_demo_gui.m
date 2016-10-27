%% Canny Edge Detection demo
% This sample demonstrates Canny edge detection.
%
% <https://github.com/opencv/opencv/blob/3.1.0/samples/cpp/edge.cpp>
%

function varargout = edge_demo_gui(im)
    % load source image
    if nargin < 1
        im = fullfile(mexopencv.root(),'test','fruits.jpg');
        src = cv.imread(im, 'Color',true);
    elseif ischar(im)
        src = cv.imread(im, 'Color',true);
    else
        src = im;
    end

    % create the UI
    h = buildGUI(src);
    if nargout > 1, varargout{1} = h; end
end

function onChange(~,~,h)
    %ONCHANGE  Event handler for UI controls

    % retrieve current values from UI controls
    thresh = round(get(h.slid, 'Value'));
    set(h.txt, 'String',sprintf('Threshold: %3d',thresh));

    % Run the edge detector on grayscale
    bwEdge = cv.Canny(h.gray, thresh*[1 3], 'ApertureSize',3);
    cEdge = bsxfun(@times, h.src, uint8(bwEdge~=0));

    % show result
    set(h.img, 'CData',cEdge);
    drawnow;
end

function h = buildGUI(img)
    %BUILDGUI  Creates the UI

    % parameters
    thresh = 1;
    max_thresh = 100;
    sz = size(img);
    sz(2) = max(sz(2), 250);  % minimum figure width

    % build the user interface (no resizing to keep it simple)
    h = struct();
    h.src = img;
    h.gray = cv.blur(cv.cvtColor(img, 'RGB2GRAY'), 'KSize',[3 3]);
    h.fig = figure('Name','Edge map', ...
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
