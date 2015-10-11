classdef TestNormalize

    methods (Static)
        function test_minmax_gray
            img = imread(fullfile(mexopencv.root(),'test','left01.jpg'));
            I = cv.normalize(img, 'NormType','MinMax', 'DType','int8', ...
                'Alpha',-50, 'Beta',100);
            J = my_normalize_minmax(img, -50, 100, 'int8');
            assert(max(abs(double(I(:))-double(J(:)))) < 1e-6);
            validateattributes(I, {class(J)}, {'size',size(J)});
        end

        function test_minmax_color
            img = imread(fullfile(mexopencv.root(),'test','cat.jpg'));
            I = cv.normalize(img, 'NormType','MinMax', 'DType','double', ...
                'Alpha',0, 'Beta',1);
            J = my_normalize_minmax(img, 0, 1, 'double');
            assert(max(abs(double(I(:))-double(J(:)))) < 1e-6);
            validateattributes(I, {class(J)}, {'size',size(J)});
        end

        function test_lp_1
            img = imread(fullfile(mexopencv.root(),'test','cat.jpg'));
            I = cv.normalize(img, 'NormType','L1', 'DType','double', ...
                'Alpha',1);
            J = my_normalize_Lp(img, 'L1', 1, 'double');
            assert(max(abs(double(I(:))-double(J(:)))) < 1e-6);
            validateattributes(I, {class(J)}, {'size',size(J)});
        end

        function test_lp_2
            img = imread(fullfile(mexopencv.root(),'test','left01.jpg'));
            I = cv.normalize(img, 'NormType','L2', 'DType','double', ...
                'Alpha',1);
            J = my_normalize_Lp(img, 'L2', 1, 'double');
            assert(max(abs(double(I(:))-double(J(:)))) < 1e-6);
            validateattributes(I, {class(J)}, {'size',size(J)});
        end

        function test_lp_inf
            img = imread(fullfile(mexopencv.root(),'test','left01.jpg'));
            I = cv.normalize(img, 'NormType','Inf', 'DType','double', ...
                'Alpha',1);
            J = my_normalize_Lp(img, 'Inf', 1, 'double');
            assert(max(abs(double(I(:))-double(J(:)))) < 1e-6);
            validateattributes(I, {class(J)}, {'size',size(J)});
        end

        function test_mask
            img = imread(fullfile(mexopencv.root(),'test','left01.jpg'));
            mask = (rand(size(img)) > 0.5);
            I = cv.normalize(img, 'NormType','MinMax', 'Mask',mask);
            I = cv.normalize(img, 'NormType','L2', 'Mask',mask);
            validateattributes(I, {class(img)}, {'size',size(img)});
        end

        function test_error
            try
                cv.normalize();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

% Helper function that works like cv.normalize with NormType=MinMax
function Y = my_normalize_minmax(X, alpha, beta, klass)
    if nargin < 2, alpha = 1; end
    if nargin < 3, beta = 0; end
    if nargin < 4, klass = class(X); end
    % scale and shift
    a = min([alpha beta]);
    b = max([alpha beta]);
    mn = double(min(X(:)));
    mx = double(max(X(:)));
    Y = (double(X) - mn)./(mx - mn) .* (b - a) + a;
    % cv::saturate_cast<>
    Y = my_saturate_cast(Y, klass);
end

% Helper function that works like cv.normalize with NormType=Lp
function Y = my_normalize_Lp(X, Lp, alpha, klass)
    if nargin < 2, Lp = 'L2'; end
    if nargin < 3, alpha = 1; end
    if nargin < 4, klass = class(X); end
    switch upper(Lp)
        case 'L1',  p = 1;
        case 'L2',  p = 2;
        case 'INF', p = Inf;
        otherwise,  p = 2;
    end
    % scale
    Y = double(X);
    Y = Y ./ norm(Y(:),p) .* alpha;
    % cv::saturate_cast<>
    Y = my_saturate_cast(Y, klass);
end

function X = my_saturate_cast(X, klass)
    if isinteger(cast(0,klass))
        X = round(X);
    end
    X = cast(X, klass);
end
