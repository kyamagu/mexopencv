classdef RectSelector < handle
    %RECTSELECTOR  Select a rectangle by drawing a box using the mouse
    %
    % You can set a callback function to be invoked when a selection is made
    % (asynchronous). You can also block and wait for a selection to be made
    % (synchronous).
    %
    % ## Sources:
    %
    % * https://github.com/opencv/opencv/blob/3.3.1/samples/python/common.py
    % * https://github.com/opencv/opencv_contrib/blob/3.2.0/modules/tracking/src/roiSelector.cpp
    % * https://github.com/opencv/opencv/blob/3.3.1/modules/highgui/src/roiSelector.cpp
    %
    % See also: imrect, rbbox, dragrect
    %

    properties
        clip       % logical, clip rectangle coordinates to image limits
        crosshair  % logical, whether to draw crosshairs inside rectangle
        callback   % function handle, called when a rectangle is selected
    end

    properties (Access = private)
        waiting  % keep track of uiwait/uiresume state
        lh       % event listener object
        handles  % struct of graphics handles (image, line, axes, figure)
        lims     % x/y axis limits of image [xmn xmx ymn ymx]
        pt       % selection starting point [x y]
        rect     % selection rectangle [x1 y1 x2 y2] (2 opposing corners TL/BR)
    end

    methods
        function obj = RectSelector(himg)
            %RECTSELECTOR  Constructor
            %
            %     obj = RectSelector(himg)
            %
            % ## Input
            % * __himg__ handle to image graphics object
            %

            assert(ishghandle(himg) && strcmp(get(himg, 'Type'), 'image'));

            % initialize state
            obj.clip = false;
            obj.crosshair = false;
            obj.callback = '';
            obj.waiting = false;
            obj.pt = [];
            obj.rect = [];
            obj.lims = [get(himg, 'XData'), get(himg, 'YData')];

            % create a line object to plot dragging box
            hax = ancestor(himg, 'axes');
            hfig = ancestor(hax, 'figure');
            hlin = line('XData',NaN, 'YData',NaN, 'Parent',hax, ...
                'Color','g', 'LineWidth',2);

            % store graphics handles
            obj.handles = struct('img',himg, 'lin',hlin, 'ax',hax, 'fig',hfig);

            % attach mouse press event handlers
            % (we could also use iptaddcallback/iptremovecallback which
            % supports having multiple callbacks without overriding existing
            % ones if any)
            set(hfig, 'WindowButtonDownFcn',@obj.onMouseDown, ...
                'Interruptible','off', 'BusyAction','cancel');

            % call destructor when paired graphics object is destroyed
            obj.lh = event.listener(hfig, 'ObjectBeingDestroyed', ...
                @(~,~) obj.delete());
        end

        function delete(obj)
            %DELETE  Destructor
            %
            %     obj.delete()
            %

            % remove event listener
            if ~isempty(obj.lh)
                delete(obj.lh);
            end

            % detach mouse press event handler
            set(obj.handles.fig, 'WindowButtonDownFcn','');

            % delete line object
            delete(obj.handles.lin);

            % resume execution if waiting
            resume(obj);
        end

        function setLineProps(obj, varargin)
            %SETLINEPROPS  Set line properties
            %
            %     obj.setLineProps(...)
            %
            % See also: set, line
            %

            set(obj.handles.lin, varargin{:});
        end

        function bool = isDragging(obj)
            %ISDRAGGING  Return whether we are currently in dragging mode
            %
            %     bool = obj.isDragging()
            %
            % ## Output
            % * __bool__ true or false
            %

            bool = ~isempty(obj.pt);
        end

        function pos = getPosition(obj)
            %GETPOSITION  Get last position of selected rectangle
            %
            %     pos = obj.getPosition()
            %
            % ## Output
            % * __pos__ last rectangle position `[x y w h]`, empty otherwise
            %

            if ~isempty(obj.rect)
                pos = cv.Rect.from2points(obj.rect(1:2), obj.rect(3:4));
            else
                pos = [];
            end
        end

        function pos = wait(obj)
            %WAIT  Block and wait for a rectangle selection to be made
            %
            %     pos = obj.wait()
            %
            % ## Output
            % * __pos__ rectangle position `[x y w h]`
            %
            % See also: uiwait, waitfor
            %

            pos = [];
            if ~obj.waiting
                obj.waiting = true;
                uiwait(obj.handles.fig);

                % destructor could have been called if figure was closed
                % (by the ObjectBeingDestroyed even listener)
                if isvalid(obj)
                    obj.waiting = false;
                    pos = obj.getPosition();
                end
            end
        end

        function resume(obj)
            %RESUME  Resume, useful to cancel waiting from UI callbacks
            %
            %     obj.resume()
            %
            % See also: uiresume
            %

            if obj.waiting
                obj.waiting = false;
                uiresume(obj.handles.fig);
            end
        end
    end

    methods (Access = private)
        function cp = currentPoint(obj)
            %CURRENTPOINT  Get current axis point
            %
            %     cp = obj.currentPoint()
            %
            % ## Output
            % * __cp__ current axis point (in data units) `[x,y]`
            %

            % get current point
            cp = get(obj.handles.ax, 'CurrentPoint');
            cp = cp(1,1:2);

            % clamp to within image coordinates
            if obj.clip
                cp = min(max(cp, obj.lims([1 3])), obj.lims([2 4]));
            end
        end

        function onMouseDown(obj, ~, ~)
            %ONMOUSEDOWN  Event handler for figure mouse press

            % starting point of rectangle
            obj.pt = currentPoint(obj);

            % show dragging box
            set(obj.handles.lin, 'XData',obj.pt(1), 'YData',obj.pt(2));

            % attach mouse move/release event handlers, and change pointer
            set(obj.handles.fig, 'Pointer','cross', ...
                'WindowButtonMotionFcn',@obj.onMouseMove, ...
                'WindowButtonUpFcn',@obj.onMouseUp);
        end

        function onMouseMove(obj, ~, ~)
            %ONMOUSEMOVE  Event handler for figure mouse move

            % compute top-left and bottom-right corners of rectangle
            cp = currentPoint(obj);
            obj.rect = [min(cp, obj.pt), max(cp, obj.pt)];

            % show dragging box
            x = [1 3 3 1 1];
            y = [2 2 4 4 2];
            if obj.crosshair
                x = [x 3 1 3];
                y = [y 4 4 2];
            end
            set(obj.handles.lin, 'XData',obj.rect(x), 'YData',obj.rect(y));
        end

        function onMouseUp(obj, ~, ~)
            %ONMOUSEUP  Event handler for figure mouse release

            % detach mouse move/release event handlers, and restore pointer
            set(obj.handles.fig, 'Pointer','arrow', ...
                'WindowButtonMotionFcn','', 'WindowButtonUpFcn','');

            % reset dragging box
            obj.pt = [];
            set(obj.handles.lin, 'XData',NaN, 'YData',NaN);

            % evaluate user callback function
            if ~isempty(obj.callback)
                feval(obj.callback, obj.getPosition());
            end

            % resume execution if waiting
            resume(obj);
        end
    end
end
