%% Inpainting demo
%
% Inpainting repairs damage to images by flood-filling the damage with
% surrounding image areas.
%
% <https://github.com/opencv/opencv/blob/3.1.0/samples/cpp/inpaint.cpp>
%

function varargout = inpaint_demo(im)
    % load an image
    if nargin < 1
        img = sampleImage();
    elseif isempty(im)
        [im,cancel] = imgetfile();
        assert(~cancel, 'No file selected');
        img = imread(im);
    elseif ischar(im)
        img = cv.imread(im, 'Color',true);
    else
        img = im;
    end
    assert(size(img,3) == 3, 'Expecting a color image');

    % build and initialize GUI
    h = buildGUI(img);
    if nargout > 1, varargout{1} = h; end

    % display instructions
    onHelp([],[]);
end

%% Helper functions
function img = sampleImage()
    fname = fullfile(mexopencv.root(),'test','lena.jpg');
    img = cv.imread(fname, 'Color',true);

    % draw some instructions on top of image
    opts = {'Color',[255 0 0], 'FontFace','HersheyTriplex', ...
        'Thickness',2, 'LineType','AA'};
    img = cv.putText(img, 'try to remove', [100 50], opts{:});
    img = cv.putText(img, 'the following text.', [70 150], opts{:});
end

function data = initData(img)
    %INITDATA  Initialize app data

    data = struct();
    data.img = img;         % input image
    data.img_marked = img;  % input image with mask drawn on it

    % inpaint mask of same size
    % (indicates the area that needs to be inpainted)
    [data.h,data.w,~] = size(img);
    data.mask = zeros([data.h, data.w], 'uint8');

    % keep track of location of the last point pressed with the mouse
    data.prev_pt = [];
end

function handles = buildGUI(img)
    %BUILDGUI  Creates the UI

    % common props
    [h,w,~] = size(img);
    fprops = {'Menubar','none', 'Resize','off', ...
        'BusyAction','cancel', 'Interruptible','off'};
    aprops = {'Units','normalized', 'Position',[0 0 1 1]};

    % show input image
    hFig(1) = figure('Name','Image', 'Position',[100 200 w h], fprops{:});
    hAx(1) = axes('Parent',hFig(1), aprops{:});
    hImg(1) = imshow(img, 'Parent',hAx(1));

    % show output image
    hFig(2) = figure('Name','Inpaint', 'Position',[200+w 200 w h], fprops{:});
    hAx(2) = axes('Parent',hFig(2), aprops{:});
    hImg(2) = imshow(img, 'Parent',hAx(2));

    % initialize structs of handles and data
    handles = struct();
    handles.hFig = hFig;
    handles.hAx = hAx;
    handles.hImg = hImg;
    guidata(hFig(1), initData(img));

    % hook-up figure event handlers
    set(hFig, 'KeyPressFcn',{@onKeyPress,handles});
    set(hFig(1), 'WindowButtonDownFcn',{@onMouseDown,handles}, ...
        'WindowButtonUpFcn',{@onMouseUp,handles}, ...
        'WindowButtonMotionFcn',{@onMouseMove,handles});
end

function p = getCurrentPoint(handles, data)
    % retrieve current mouse location
    p = get(handles.hAx(1), 'CurrentPoint');
    p = p(1,1:2);

    % convert axes coordinates to image pixel coordinates
    p(1) = axes2pix(data.w, get(handles.hImg(1),'XData'), p(1));
    p(2) = axes2pix(data.h, get(handles.hImg(1),'YData'), p(2));
end

%% Callback functions
function onHelp(~,~)
    %ONHELP  Display usage help dialog

    h = helpdlg({
        'Paint something on the left image using the mouse.'
        'Close figures when done.'
        'Hot keys:'
        '  r: restore the original image'
        '  q: quit the program'
    }, 'Inpaint demo');
    set(h, 'WindowStyle','modal');
end

function onKeyPress(~,e,handles)
    %ONKEYPRESS  Event handler for key press on figure

    % make sure both figures are still open
    if ~all(ishghandle(handles.hFig)), return; end

    % handle keys
    switch lower(e.Key)
        case 'r'
            % reset data
            data = guidata(handles.hFig(1));
            data.img_marked = data.img;
            data.mask(:) = 0;
            data.prev_pt = [];
            guidata(handles.hFig(1), data);
            % reset images
            set(handles.hImg(1), 'CData',data.img);
            set(handles.hImg(2), 'CData',data.img);
            drawnow;
        case 'h'
            onHelp([],[]);
        case {'q', 'escape'}
            % close both figures
            close(handles.hFig);
    end
end

function onMouseDown(o,~,handles)
    %ONMOUSEDOWN  Event handler for mouse down on figure

    % make sure both figures are still open
    if ~all(ishghandle(handles.hFig)), return; end

    % get current point and store it as starting point
    data = guidata(handles.hFig(1));
    data.prev_pt = getCurrentPoint(handles, data);
    guidata(handles.hFig(1), data);

    % change cursor shape to indicate drawing mode
    set(o, 'Pointer','cross')
end

function onMouseMove(~,~,handles)
    %ONMOUSEMOVE  Event handler for mouse move on figure

    % make sure both figures are still open
    if ~all(ishghandle(handles.hFig)), return; end

    % if mouse was not pressed, quit
    data = guidata(handles.hFig(1));
    if isempty(data.prev_pt), return; end

    % get current point (ending point)
    pt = getCurrentPoint(handles, data);

    % draw line connecting from previous point to current
    % on both mask and marked image
    data.mask = cv.line(data.mask, data.prev_pt, pt, ...
        'Color',255, 'Thickness',10);   % non-zero value
    data.img_marked = cv.line(data.img_marked, data.prev_pt, pt, ...
        'Color',[255 255 255], 'Thickness',10); % white

    % store point as new starting point
    data.prev_pt = pt;
    guidata(handles.hFig(1), data);

    % show image with markers
    set(handles.hImg(1), 'CData',data.img_marked);
    drawnow;
end

function onMouseUp(o,~,handles)
    %ONMOUSEUP  Event handler for mouse up on figure

    % make sure both figures are still open
    if ~all(ishghandle(handles.hFig)), return; end

    % clear point
    data = guidata(handles.hFig(1));
    data.prev_pt = [];
    guidata(handles.hFig(1), data);

    % change cursor shape back to normal
    set(o, 'Pointer','arrow')

    % perform inpainting using specified mask
    out = cv.inpaint(data.img, data.mask, 'Radius',3, 'Method','Telea');

    % show the inpainting
    set(handles.hImg(2), 'CData',out);
    drawnow;
end
