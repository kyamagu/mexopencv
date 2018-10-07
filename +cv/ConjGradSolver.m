classdef ConjGradSolver < handle
    %CONJGRADSOLVER  Non-linear non-constrained minimization of a function with known gradient
    %
    % defined on an `n`-dimensional Euclidean space, using the Nonlinear
    % **Conjugate Gradient** method. The implementation was done based on the
    % beautifully clear explanatory article [1].
    %
    % The method can be seen as an adaptation of a standard
    % [Conjugate Gradient method](https://en.wikipedia.org/wiki/Conjugate_gradient_method)
    % for numerically solving the systems of linear equations.
    %
    % It should be noted, that this method, although deterministic, is rather
    % a heuristic method and therefore may converge to a local minima, not
    % necessary a global one. What is even more disastrous, most of its
    % behaviour is ruled by gradient, therefore it essentially cannot
    % distinguish between local minima and maxima. Therefore, if it starts
    % sufficiently near to the local maximum, it may converge to it. Another
    % obvious restriction is that it should be possible to compute the
    % gradient of a function at any point, thus it is preferable to have
    % analytic expression for gradient and computational burden should be born
    % by the user.
    %
    % The latter responsibility is accompilished via the `getGradient` method of
    % the function being optimized). This method takes point a point in
    % `n`-dimensional space (input argument represents the array of
    % coordinates of that point) and comput its gradient (it should be
    % returned in the output as an array).
    %
    % NOTE: term criteria should meet one of the following conditions:
    %
    % * `type == 'Count+EPS' && epsilon > 0 && maxCount > 0`
    % * `type == 'Count' && maxCount > 0`
    %
    % ## References
    % [1]:
    % > An Introduction to the Conjugate Gradient Method Without the Agonizing Pain
    % > [PDF](http://www.cs.cmu.edu/~quake-papers/painless-conjugate-gradient.pdf)
    % > by Jonathan Richard Shewchuk.
    %
    % See also: cv.DownhillSolver, fminunc
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
        % * __gradfun__ name of M-file that evaluates the gradient. default ''
        % * __gradeps__ used by finite difference method, in case `gradfun`
        %   was not supplied. default 1e-3
        %
        % It should be set before the call to cv.ConjGradSolver.minimize,
        % as default value is not usable.
        ObjectiveFunction
        % Terminal criteria for solver.
        %
        % This method is not necessary to be called before the first call to
        % cv.ConjGradSolver.minimize, as the default value is sensible.
        %
        % Algorithm stops when the number of function evaluations done exceeds
        % `Termcrit.maxCount`, when the function values at the vertices of
        % simplex are within `Termcrit.epsilon` range or simplex becomes so
        % small that it can enclosed in a box with `Termcrit.epsilon` sides,
        % whatever comes first.
        TermCriteria
    end

    methods
        function this = ConjGradSolver(varargin)
            %CONJGRADSOLVER  Creates an ConjGradSolver object
            %
            %     solver = cv.ConjGradSolver()
            %     solver = cv.ConjGradSolver('OptionName', optionValue, ...)
            %
            % ## Options
            % * __Function__ Objective function that will be minimized,
            %   specified as a structure with the following fields (`gradfun`
            %   and `gradeps` are optional fields):
            %   * __dims__ Number of dimensions
            %   * __fun__ string, name of M-file that implements the `calc`
            %     method. It should receive a vector of the specified
            %     dimension, and return a scalar value of the objective
            %     function evaluated at that point.
            %   * __gradfun__ string, name of M-file that implements the
            %     `getGradient` method. It should receive an `ndims` vector,
            %     and return a vector of partial derivatives. If an empty
            %     string is specified (default), the gradient is approximated
            %     using finite difference method as:
            %     `F'(x) = (F(x+h) - F(x-h)) / 2*h` (at the cost of exta
            %     function evaluations and less accuracy).
            %   * __gradeps__ gradient step `h` used in finite difference
            %     method. default 1e-3
            % * __TermCriteria__ Terminal criteria to the algorithm. default
            %   `struct('type','Count+EPS', 'maxCount',5000, 'epsilon',1e-6)`
            %
            % All the parameters are optional, so this procedure can be called
            % even without parameters at all. In this case, the default values
            % will be used. As default value for terminal criteria are the
            % only sensible ones, `ObjectiveFunction` should be set upon the
            % obtained object, if the function was not given in the constructor.
            % Otherwise, the two ways (submit it to ctor or miss it out and
            % set the `ObjectiveFunction` property) are absolutely equivalent
            % (and will drop the same errors in the same way, should invalid
            % input be detected).
            %
            this.id = ConjGradSolver_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     solver.delete()
            %
            % See also: cv.ConjGradSolver
            %
            if isempty(this.id), return; end
            ConjGradSolver_(this.id, 'delete');
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
            % (terminal criteria, function to be minimized) are supposed to be
            % set via the setters before the call to this method or the
            % default values (not always sensible) will be used.
            %
            [x,fx] = ConjGradSolver_(this.id, 'minimize', x0);
        end
    end

    %% Algorithm
    methods (Hidden)
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     solver.clear()
            %
            % See also: cv.ConjGradSolver.empty
            %
            ConjGradSolver_(this.id, 'clear');
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
            % See also: cv.ConjGradSolver.clear
            %
            b = ConjGradSolver_(this.id, 'empty');
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
            % See also: cv.ConjGradSolver.save, cv.ConjGradSolver.load
            %
            name = ConjGradSolver_(this.id, 'getDefaultName');
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
            % See also: cv.ConjGradSolver.load
            %
            ConjGradSolver_(this.id, 'save', filename);
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
            % See also: cv.ConjGradSolver.save
            %
            ConjGradSolver_(this.id, 'load', fname_or_str);
        end
    end

    %% Getters/Setters
    methods
        function value = get.ObjectiveFunction(this)
            value = ConjGradSolver_(this.id, 'get', 'Function');
        end
        function set.ObjectiveFunction(this, value)
            ConjGradSolver_(this.id, 'set', 'Function', value);
        end

        function value = get.TermCriteria(this)
            value = ConjGradSolver_(this.id, 'get', 'TermCriteria');
        end
        function set.TermCriteria(this, value)
            ConjGradSolver_(this.id, 'set', 'TermCriteria', value);
        end
    end
end
