classdef Plot2d < handle
    %PLOT2D  Class to plot 2D data
    %
    % This plot module allows you to easily plot data in 1D or 2D. You can
    % change the size of the window, the limits of the axis and the colors of
    % each element. You can also show in real time the plot you are building
    % or save the plot as an image (png).
    %
    % ## Example
    %
    %     x = linspace(-2*pi, 2*pi, 100);
    %     y = sin(x) + randn(size(x))*0.1;
    %     p = cv.Plot2d(x, y);
    %     p.PlotSize = [640 480];
    %     img = p.render();
    %     imshow(img)
    %
    % See also: cv.Plot2d.Plot2d, plot
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent, GetAccess = private)
        % min value for x-axis
        MinX
        % min value for y-axis
        MinY
        % max value for x-axis
        MaxX
        % max value for y-axis
        MaxY
        % line width. default 1
        PlotLineWidth
        % Switches data visualization mode. If true then neighbour plot points
        % will be connected by lines. In other case data will be plotted as a
        % set of standalone points. default true
        NeedPlotLine
        % line color (RGB). default [0,255,255]
        PlotLineColor
        % background color (RGB). default [0,0,0]
        PlotBackgroundColor
        % axis color (RGB). default [0,0,255]
        PlotAxisColor
        % grid color (RGB). default [255,255,255]
        PlotGridColor
        % text color (RGB). default [255,255,255]
        PlotTextColor
        % plot dimensions `[w,h]` ([400,300] minimum size). default [600,400]
        PlotSize
        % whether grid lines are drawn. default true
        ShowGrid
        % whether text is drawn. default true
        ShowText
        % number of grid lines. default 10
        GridLinesNumber
        % invert plot orientation. default false
        InvertOrientation
        % the index of the point in data array which coordinates will be
        % printed on the top-left corner of the plot (if ShowText is true).
        % defaults to last point
        PointIdxToPrint
    end

    methods
        function this = Plot2d(varargin)
            %PLOT2D  Creates Plot2d object
            %
            %     obj = cv.Plot2d(dataY)
            %     obj = cv.Plot2d(dataX, dataY)
            %
            % ## Input
            % * __dataY__ 1xN or Nx1 matrix containing `Y` values of points to
            %   plot. In the first variant, `X` values will be equal to
            %   indexes of corresponding elements in data matrix, i.e
            %   `x = 0:(numel(y)-1)`.
            % * __dataX__ 1xN or Nx1 matrix, `X` values of points to plot.
            %
            % See also: cv.Plot2d.render
            %
            this.id = Plot2d_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.Plot2d
            %
            if isempty(this.id), return; end
            Plot2d_(this.id, 'delete');
        end

        function plotResult = render(this, varargin)
            %RENDER  Renders the plot to a matrix
            %
            %     plotResult = obj.render()
            %     plotResult = obj.render('OptionName',optionValue, ...)
            %
            % ## Output
            % * __plotResult__ Plot result, 8-bit 3-channel image.
            %
            % ## Options
            % * __FlipChannels__ whether to flip the order of color channels
            %   in output, from OpenCV's BGR to between MATLAB's RGB.
            %   default true
            %
            % See also: plot, getframe, print
            %
            plotResult = Plot2d_(this.id, 'render', varargin{:});
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.Plot2d.empty, cv.Plot2d.load
            %
            Plot2d_(this.id, 'clear');
        end

        function b = empty(this)
            %EMPTY  Checks if detector object is empty
            %
            %     b = obj.empty()
            %
            % ## Output
            % * __b__ Returns true if the detector object is empty (e.g in the
            %   very beginning or after unsuccessful read).
            %
            % See also: cv.Plot2d.clear, cv.Plot2d.load
            %
            b = Plot2d_(this.id, 'empty');
        end

        function save(this, filename)
            %SAVE  Saves the algorithm parameters to a file
            %
            %     obj.save(filename)
            %
            % ## Input
            % * __filename__ Name of the file to save to.
            %
            % This method stores the algorithm parameters in the specified
            % XML or YAML file.
            %
            % See also: cv.Plot2d.load
            %
            Plot2d_(this.id, 'save', filename);
        end

        function load(this, fname_or_str, varargin)
            %LOAD  Loads algorithm from a file or a string
            %
            %     obj.load(fname)
            %     obj.load(str, 'FromString',true)
            %     obj.load(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __fname__ Name of the file to read.
            % * __str__ String containing the serialized model you want to
            %   load.
            %
            % ## Options
            % * __ObjName__ The optional name of the node to read (if empty,
            %   the first top-level node will be used). default empty
            % * __FromString__ Logical flag to indicate whether the input is a
            %   filename or a string containing the serialized model.
            %   default false
            %
            % This method reads algorithm parameters from the specified XML or
            % YAML file (either from disk or serialized string). The previous
            % algorithm state is discarded.
            %
            % See also: cv.Plot2d.save
            %
            Plot2d_(this.id, 'load', fname_or_str, varargin{:});
        end

        function name = getDefaultName(this)
            %GETDEFAULTNAME  Returns the algorithm string identifier
            %
            %     name = obj.getDefaultName()
            %
            % ## Output
            % * __name__ This string is used as top level XML/YML node tag
            %   when the object is saved to a file or string.
            %
            % See also: cv.Plot2d.save, cv.Plot2d.load
            %
            name = Plot2d_(this.id, 'getDefaultName');
        end
    end

    %% Getters/Setters
    methods
        function set.MinX(this, value)
            Plot2d_(this.id, 'set', 'MinX', value);
        end

        function set.MinY(this, value)
            Plot2d_(this.id, 'set', 'MinY', value);
        end

        function set.MaxX(this, value)
            Plot2d_(this.id, 'set', 'MaxX', value);
        end

        function set.MaxY(this, value)
            Plot2d_(this.id, 'set', 'MaxY', value);
        end

        function set.PlotLineWidth(this, value)
            Plot2d_(this.id, 'set', 'PlotLineWidth', value);
        end

        function set.NeedPlotLine(this, value)
            Plot2d_(this.id, 'set', 'NeedPlotLine', value);
        end

        function set.PlotLineColor(this, value)
            Plot2d_(this.id, 'set', 'PlotLineColor', value);
        end

        function set.PlotBackgroundColor(this, value)
            Plot2d_(this.id, 'set', 'PlotBackgroundColor', value);
        end

        function set.PlotAxisColor(this, value)
            Plot2d_(this.id, 'set', 'PlotAxisColor', value);
        end

        function set.PlotGridColor(this, value)
            Plot2d_(this.id, 'set', 'PlotGridColor', value);
        end

        function set.PlotTextColor(this, value)
            Plot2d_(this.id, 'set', 'PlotTextColor', value);
        end

        function set.PlotSize(this, value)
            Plot2d_(this.id, 'set', 'PlotSize', value);
        end

        function set.ShowGrid(this, value)
            Plot2d_(this.id, 'set', 'ShowGrid', value);
        end

        function set.ShowText(this, value)
            Plot2d_(this.id, 'set', 'ShowText', value);
        end

        function set.GridLinesNumber(this, value)
            Plot2d_(this.id, 'set', 'GridLinesNumber', value);
        end

        function set.InvertOrientation(this, value)
            Plot2d_(this.id, 'set', 'InvertOrientation', value);
        end

        function set.PointIdxToPrint(this, value)
            Plot2d_(this.id, 'set', 'PointIdxToPrint', value);
        end

    end

end
