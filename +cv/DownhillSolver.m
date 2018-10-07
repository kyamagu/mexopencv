classdef DownhillSolver < handle
    %DOWNHILLSOLVER  Non-linear non-constrained minimization of a function
    %
    % defined on an `n`-dimensional Euclidean space, using the **Nelder-Mead**
    % method, also known as downhill simplex method. The basic idea about the
    % method can be obtained from
    % [Nelder-Mead method](https://en.wikipedia.org/wiki/Nelder-Mead_method).
    %
    % It should be noted, that this method, although deterministic, is rather
    % a heuristic and therefore may converge to a local minima, not necessary
    % a global one. It is iterative optimization technique, which at each
    % step uses an information about the values of a function evaluated only
    % at `n+1` points, arranged as a simplex in `n`-dimensional space (hence
    % the second name of the method). At each step new point is chosen to
    % evaluate function at, obtained value is compared with previous ones and
    % based on this information simplex changes it's shape, slowly moving to
    % the local minimum. Thus this method is using only function values to
    % make decision, on contrary to, say, Nonlinear Conjugate Gradient method
    % (which is also implemented in OpenCV).
    %
    % Algorithm stops when the number of function evaluations done exceeds
    % `Termcrit.maxCount`, when the function values at the vertices of simplex
    % are within `Termcrit.epsilon` range or simplex becomes so small that it
    % can enclosed in a box with `Termcrit.epsilon` sides, whatever comes
    % first, for some defined by user positive integer `Termcrit.maxCount` and
    % positive non-integer `Termcrit.epsilon`.
    %
    % NOTE: term criteria should meet the following conditions:
    %
    % * `type == 'Count+EPS' && epsilon > 0 && maxCount > 0`
    %
    % See also: cv.ConjGradSolver, fminsearch
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    properties (Dependent)
        % The optimized function represented by a structure with the
        % following fields:
        %
        % * __dims__ dimensinoality of the objective function.
        % * __fun__ name of M-file that evaluates the objective function.
        %
        % It should be set before the call to cv.DownhillSolver.minimize,
        % as default value is not usable.
        ObjectiveFunction
        % initial step that will be used in downhill simplex algorithm.
        % Roughly said, it determines the spread (size in each dimension)
        % of an initial simplex.
        %
        % Step, together with initial point (given in cv.DownhillSolver.minimize)
        % are two `n`-dimensional vectors that are used to determine the shape
        % of initial simplex. Roughly said, initial point determines the
        % position of a simplex (it will become simplex's centroid), while
        % step determines the spread (size in each dimension) of a simplex. To
        % be more precise, if `s` and `x` are the initial step and initial
        % point respectively, the vertices of a simplex will be:
        % `v_0 := x_0 - (1/2)s` and `v_i := x_0 + s_i` for `i=1,2,...,n` where
        % `s_i` denotes projections of the initial step of `n`-th coordinate
        % (the result of projection is treated to be vector given by
        % `s_i := e_i . <e_i . s>`, where `e_i` form canonical basis).
        InitStep
        % Terminal criteria for solver.
        %
        % This method is not necessary to be called before the first call to
        % cv.DownhillSolver.minimize, as the default value is sensible.
        %
        % Algorithm stops when the number of function evaluations done exceeds
        % `Termcrit.maxCount`, when the function values at the vertices of
        % simplex are within `Termcrit.epsilon` range or simplex becomes so
        % small that it can enclosed in a box with `Termcrit.epsilon` sides,
        % whatever comes first.
        TermCriteria
    end

    methods
        function this = DownhillSolver(varargin)
            %DOWNHILLSOLVER  Creates a DownhillSolver object
            %
            %     solver = cv.DownhillSolver()
            %     solver = cv.DownhillSolver('OptionName', optionValue, ...)
            %
            % ## Options
            % * __Function__ Objective function that will be minimized,
            %   specified as a structure with the following fields:
            %   * __dims__ Number of dimensions
            %   * __fun__ string, name of M-file that implements the `calc`
            %     method. It should receive a vector of the specified
            %     dimension, and return a scalar value of the objective
            %     function evaluated at that point.
            % * __InitStep__ Initial step, that will be used to construct the
            %   initial simplex. default `[1, 1, 0.0]`.
            % * __TermCriteria__ Terminal criteria to the algorithm. default
            %   `struct('type','Count+EPS', 'maxCount',5000, 'epsilon',1e-6)`
            %
            % All the parameters are optional, so this procedure can be called
            % even without parameters at all. In this case, the default values
            % will be used. As default value for terminal criteria are the
            % only sensible ones, `ObjectiveFunction` and `InitStep` should be
            % set upon the obtained object, if the respective parameters were
            % not given in the constructor. Otherwise, the two ways (give them
            % to ctor or miss them out and set the `ObjectiveFunction` and
            % `InitStep` properties) are absolutely equivalent (and will drop
            % the same errors in the same way, should invalid input be
            % detected).
            %
            this.id = DownhillSolver_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     solver.delete()
            %
            % See also: cv.DownhillSolver
            %
            if isempty(this.id), return; end
            DownhillSolver_(this.id, 'delete');
        end

        function [x,fx] = minimize(this, x0)
            %MINIMIZE  Runs the algorithm and performs the minimization
            %
            %     [x,fx] = solver.minimize(x0)
            %
            % ## Input
            % * __x0__ The initial point, that will become a centroid of an
            %   initial simplex.
            %
            % ## Output
            % * __x__ After the algorithm will terminate, it will be set
            %   to the point where the algorithm stops, the point of possible
            %   minimum.
            % * __fx__ The value of a function at the point found.
            %
            % The sole input parameter determines the centroid of the starting
            % simplex (roughly, it tells where to start), all the others
            % (terminal criteria, initial step, function to be minimized) are
            % supposed to be set via the setters before the call to this
            % method or the default values (not always sensible) will be used.
            %
            [x,fx] = DownhillSolver_(this.id, 'minimize', x0);
        end
    end

    %% Algorithm
    methods (Hidden)
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     solver.clear()
            %
            % See also: cv.DownhillSolver.empty
            %
            DownhillSolver_(this.id, 'clear');
        end

        function b = empty(this)
            %EMPTY  Returns true if the algorithm is empty
            %
            %     b = solver.empty()
            %
            % ## Output
            % * __b__ returns true of the algorithm is empty (e.g. in the very
            %   beginning or after unsuccessful read).
            %
            % See also: cv.DownhillSolver.clear
            %
            b = DownhillSolver_(this.id, 'empty');
        end

        function name = getDefaultName(this)
            %GETDEFAULTNAME  Returns the algorithm string identifier
            %
            %     name = solver.getDefaultName()
            %
            % ## Output
            % * __name__ This string is used as top level XML/YML node tag
            %   when the object is saved to a file or string.
            %
            % See also: cv.DownhillSolver.save, cv.DownhillSolver.load
            %
            name = DownhillSolver_(this.id, 'getDefaultName');
        end

        function save(this, filename)
            %SAVE  Saves the algorithm to a file
            %
            %     obj.save(filename)
            %
            % ## Input
            % * __filename__ Name of the file to save to.
            %
            % This method stores the algorithm parameters in a file storage.
            %
            % See also: cv.DownhillSolver.load
            %
            DownhillSolver_(this.id, 'save', filename);
        end

        function load(this, fname_or_str)
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
            % This method reads algorithm parameters from a file storage.
            % The previous model state is discarded.
            %
            % See also: cv.DownhillSolver.save
            %
            DownhillSolver_(this.id, 'load', fname_or_str);
        end
    end

    %% Getters/Setters
    methods
        function value = get.ObjectiveFunction(this)
            value = DownhillSolver_(this.id, 'get', 'Function');
        end
        function set.ObjectiveFunction(this, value)
            DownhillSolver_(this.id, 'set', 'Function', value);
        end

        function value = get.InitStep(this)
            value = DownhillSolver_(this.id, 'get', 'InitStep');
        end
        function set.InitStep(this, value)
            DownhillSolver_(this.id, 'set', 'InitStep', value);
        end

        function value = get.TermCriteria(this)
            value = DownhillSolver_(this.id, 'get', 'TermCriteria');
        end
        function set.TermCriteria(this, value)
            DownhillSolver_(this.id, 'set', 'TermCriteria', value);
        end
    end
end
