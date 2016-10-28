%% GrabCut segmentation demo
% An example using the GrabCut algorithm.
%
% This program demonstrates GrabCut segmentation: select an object in a
% region and then grabcut will attempt to segment it out.
%
% <https://github.com/opencv/opencv/blob/3.1.0/samples/cpp/grabcut.cpp>
%

function varargout = grabcut_demo_gui(im)
    % load an image
    if nargin < 1
        src = imread(fullfile(mexopencv.root(),'test','fruits.jpg'));
    elseif isempty(im)
        fmts = imformats;
        filtspec = strjoin(strcat('*.', [fmts.ext]), ';');
        [fn,fp] = uigetfile(filtspec, 'Select an image');
        if fp==0, error('No file selected'); end
        src = imread(fullfile(fp,fn));
    elseif ischar(im)
        src = imread(im);
    else
        src = im;
    end

    % we expect an 8-bit RGB image
    validateattributes(src, {'uint8'}, ...
        {'ndims',3, 'size',[nan nan 3], 'nonempty'});

    % initialize app state, and create the UI
    app = initApp(src);
    h = buildGUI(src);

    % hook event handlers
    opts = {'Interruptible','off', 'BusyAction','cancel'};
    set(h.pop, 'Callback',@onChange);
    set(h.btn(1), 'Callback',@onHelp);
    set(h.btn(2), 'Callback',@onReset);
    set(h.btn(3), 'Callback',@onNext, opts{:});
    set(h.fig, 'WindowKeyPressFcn',@onType, ...
        'WindowButtonDownFcn',@onMouseDown, opts{:});

    % return graphics handles
    if nargout > 1, varargout{1} = h; end

    % ========== Event Handlers ==========

    function onHelp(~,~)
        %ONHELP  Display usage help dialog

        helpdlg({
            'This program demonstrates GrabCut segmentation:'
            'select an object in a region and then grabcut'
            'will attempt to segment it out.'
            ''
            'Select a rectangular area around the object you'
            'want to segment.'
            ''
            'Hot keys:'
            'ESC - quit the program'
            'r - restore the original image'
            'n - next iteration'
            'left mouse button - First set rectangle, then set pixels'
            '    as either BGD/FGD/PR_BGD/PR_FGD depending on selected'
            '    mode in dropdown menu.'
        });
    end

    function onReset(~,~)
        %ONRESET  Event handler for reset button

        app.mask(:) = 0;
        app.bgdModel(:) = 0;
        app.fgdModel(:) = 0;
        app.rect = zeros(0,4);
        app.rectxy = zeros(0,2);
        app.pts = repmat({zeros(0,2)}, [1 4]);
        app.iterCount = 0;
        app.isInitialized = false;

        set(h.txt, 'String','Iter =  0');
        set(h.img, 'CData',app.img0);
        set(h.rect, 'XData',NaN, 'YData',NaN);
        set(h.line(:), 'XData',NaN, 'YData',NaN);
        drawnow;
    end

    function onNext(~,~)
        %ONNEXT  Event handler for next button

        if app.isInitialized
            % set pixels in GC mask using label points
            if any(~cellfun(@isempty, app.pts))
                setLblsInMask();
            end
            % continue using current mask
            tic
            [app.mask, app.bgdModel, app.fgdModel] = cv.grabCut(...
                app.img0, app.mask, 'Mode','Eval', 'IterCount',1, ...
                'BgdModel',app.bgdModel, 'FgdModel',app.fgdModel);
            toc
        elseif any(~cellfun(@isempty, app.pts))
            % set foreground pixels in GC mask using rectangle
            % and set pixels in GC mask using label points
            setRectInMask();
            setLblsInMask();
            % init using mask
            tic
            [app.mask, app.bgdModel, app.fgdModel] = cv.grabCut(...
                app.img0, app.mask, 'Mode','InitWithMask', 'IterCount',1);
            toc
        elseif ~isempty(app.rect)
            % init using rectangle
            rect = app.rect - [1 1 0 0];
            tic
            [app.mask, app.bgdModel, app.fgdModel] = cv.grabCut(...
                app.img0, rect, 'Mode','InitWithRect', 'IterCount',1);
            toc
        else
            disp('rect must be determined');
            return;
        end

        % mark mask as initialized, and increment counter
        app.isInitialized = true;
        app.iterCount = app.iterCount + 1;

        % show result
        showImage();
    end

    function onType(~,e)
        %ONTYPE  Event handler for key press on figure

        % handle keys
        switch e.Key
            case {'q', 'escape'}
                close(h.fig);
                return;

            case 'h'
                onHelp([],[]);

            case 'r'
                onReset([],[]);

            case 'n'
                onNext([],[]);

            case {'1', '2', '3', '4'}
                app.currIdx = str2double(e.Key);
                set(h.pop, 'Value',app.currIdx);
                drawnow;
        end
    end

    function onChange(~,~)
        %ONCHANGE  Event handler for UI controls

        % retrieve current value from popup menu
        app.currIdx = get(h.pop, 'Value');
    end

    function onMouseDown(~,~)
        %ONMOUSEDOWN  Event handler for mouse down on figure

        % ignore anything but left mouse clicks
        if ~strcmp(get(h.fig,'SelectionType'), 'normal')
            return;
        end

        % one of two phases: drawing rectangle, or free-drawing of points
        if isempty(app.rect)
            % select and draw rectangle
            select_rectangle();
            if isempty(app.rect), return; end
            set(h.rect, 'XData',app.rectxy(:,1), 'YData',app.rectxy(:,2));
            drawnow;
        else
            % attach event handlers, and change mouse pointer
            set(h.fig, 'Pointer','circle', ...
                'WindowButtonMotionFcn',@onMouseMove, ...
                'WindowButtonUpFcn',@onMouseUp);
        end
    end

    function onMouseMove(~,~)
        %ONMOUSEMOVE  Event handler for mouse move on figure

        % get current point and append it
        app.pts{app.currIdx}(end+1,:) = getCurrentPoint();

        % update corresponding graphic line
        set(h.line(app.currIdx), ...
            'XData',app.pts{app.currIdx}(:,1), ...
            'YData',app.pts{app.currIdx}(:,2));
        drawnow;
    end

    function onMouseUp(~,~)
        %ONMOUSEUP  Event handler for mouse up on figure

        % detach event handlers, and restore mouse pointer
        set(h.fig, 'Pointer','arrow', ...
            'WindowButtonMotionFcn','', ...
            'WindowButtonUpFcn','');
    end

    % ========== Helper Functions ==========

    function showImage()
        res = app.img0;
        if app.isInitialized
            % background pixels
            binMask = repmat(app.mask == 0 | app.mask == 2, [1 1 3]);
            res(binMask) = 0;
        end
        set(h.img, 'CData',res);
        set(h.txt, 'String',sprintf('Iter = %2d',app.iterCount));
        drawnow;
    end

    function setRectInMask()
        % convert rectangle to binary mask
        rect_mask = poly2mask(app.rectxy(:,1), app.rectxy(:,2), ...
            app.sz(1), app.sz(2));

        % set foreground pixels in GC mask using rectangle
        app.mask(:) = 0;          % BGD
        app.mask(rect_mask) = 3;  % PR_FGD
    end

    function setLblsInMask()
        % set pixels in GC mask: BGD, FGD, PR_BGD, PR_FGD
        radius = 5;
        for i=1:4
            %{
            x = axes2pix(app.sz(2), get(h.img,'XData'), app.pts{idx}(:,1));
            y = axes2pix(app.sz(1), get(h.img,'YData'), app.pts{idx}(:,2));
            x = min(max(x,1), sz(2));
            y = min(max(y,1), sz(1));
            x = round(x) - 1;
            y = round(y) - 1;
            %}
            for k=1:size(app.pts{i},1)
                app.mask = cv.circle(app.mask, app.pts{i}(k,:)-1, radius, ...
                    'Color',uint8(i-1), 'Thickness','Filled');
            end
        end

        % clear label points
        app.pts = repmat({zeros(0,2)}, [1 4]);
        set(h.line(:), 'XData',NaN, 'YData',NaN);
    end

    function select_rectangle()
        %TODO: consider IMRECT from image_toolbox
        % create rubberband box to prompt user for a rectangle
        p1 = getCurrentPoint(); % retrieve mouse location before dragging
        rbbox;                  % ignore its output (figure coordinates)
        pause(0.005);           % CP might not get updated if selection was too fast
        p2 = getCurrentPoint(); % retrieve mouse location after dragging

        % form rectangle from two points: [x y w h]
        tl = min([p1;p2]);   % top-left corner
        br = max([p1;p2]);   % bottom-right corner
        if all((br-tl) > 1)  % ignore small rectangles
            app.rect = [tl br-tl];
            app.rectxy = [tl; tl+[app.rect(3) 0]; br; tl+[0 app.rect(4)]; tl];
        end
    end

    function p = getCurrentPoint()
        % retrieve current mouse location
        p = get(h.ax, 'CurrentPoint');
        p = p(1,1:2);

        % clamp to within image coordinates
        p = max(p, [1 1]);
        p = min(p, [app.sz(2) app.sz(1)]);
    end
end

% ========== Initializer functions ==========

function app = initApp(img)
    %INITAPP  Initialize app state

    app = struct();
    app.img0 = img;
    app.sz = size(img);
    app.mask = zeros(size(img,1), size(img,2), 'uint8');
    app.bgdModel = zeros(1,64);
    app.fgdModel = zeros(1,64);
    app.currIdx = 1;
    app.pts = repmat({zeros(0,2)}, [1 4]);
    app.rect = zeros(0, 4);
    app.rectxy = zeros(0,2);
    app.iterCount = 0;
    app.isInitialized = false;
end

function h = buildGUI(img)
    %BUILDGUI  Creates the UI

    % parameters
    sz = size(img);
    sz(2) = max(sz(2), 350);  % minimum figure width

    % build the user interface (no resizing to keep it simple)
    h = struct();
    h.fig = figure('Name','GrabCut Demo', ...
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
    %axis(h.ax, 'on');
    h.btn(1) = uicontrol('Parent',h.fig, 'Style','pushbutton', ...
        'Position',[5 5 60 20], 'String','Help');
    h.btn(2) = uicontrol('Parent',h.fig, 'Style','pushbutton', ...
        'Position',[70 5 60 20], 'String','Reset');
    h.btn(3) = uicontrol('Parent',h.fig, 'Style','pushbutton', ...
        'Position',[135 5 60 20], 'String','Next');
    h.txt = uicontrol('Parent',h.fig, 'Style','text', 'FontSize',11, ...
        'Position',[200 5 60 20], 'String','Iter =  0');
    h.pop = uicontrol('Parent',h.fig, 'Style','popupmenu', ...
        'Position',[260 5 80 20], 'String',{'BGD','FGD','PR_BGD','PR_FGD'});

    % initialize lines
    clr = 'rbcmg';
    for i=1:4
        %TODO: use animatedline
        %if ~mexopencv.isOctave() && ~verLessThan('matlab','8.4')
        %h.line(i) = animatedline(..);
        %end
        h.line(i) = line(NaN, NaN, 'Color',clr(i), 'Parent',h.ax, ...
            'LineStyle','none', 'Marker','.', 'MarkerSize',10);
    end
    h.rect = line(NaN, NaN, 'Color',clr(5), 'Parent',h.ax, 'LineWidth',2);
end
