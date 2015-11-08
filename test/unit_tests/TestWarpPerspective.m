classdef TestWarpPerspective
    %TestWarpPerspective
    properties (Constant)
        img = fullfile(mexopencv.root(),'test','img001.jpg');
    end

    methods (Static)
        function test_1
            im = imread(TestWarpPerspective.img);
            M = eye(3,3);  % identity transform
            dst = cv.warpPerspective(im, M);
            validateattributes(dst, {class(im)}, {'size',size(im)});
            assert(isequal(im, dst));
        end

        function test_2
            im = cv.imread(TestWarpPerspective.img, 'Grayscale',true);
            M = eye(3,3);  % identity transform
            dst = cv.warpPerspective(im, M, 'DSize',[256 256], ...
                'Interpolation','Linear', 'WarpInverse',false, ...
                'BorderType','Constant', 'BorderValue',0);
            validateattributes(dst, {class(im)}, {'size',[256 256]});
        end

        function test_3
            im = imread(TestWarpPerspective.img);
            [h,w,~] = size(im);
            H = eye(3) + [...
                randn()/50      randn()/100     randi([10 20]);
                randn()/100     randn()/50      randi([10 20]);
                (1+rand())/5000 (1+rand())/5000             0];
            dst = cv.warpPerspective(im, H, 'Dst',im, 'BorderType','Transparent');
            validateattributes(dst, {class(im)}, {'size',size(im)});
        end

        function test_error_1
            try
                cv.warpPerspective();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
