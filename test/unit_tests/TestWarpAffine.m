classdef TestWarpAffine
    %TestWarpAffine
    properties (Constant)
        img = fullfile(mexopencv.root(),'test','img001.jpg');
    end

    methods (Static)
        function test_1
            im = imread(TestWarpAffine.img);
            M = eye(2,3);  % identity transform
            dst = cv.warpAffine(im, M);
            validateattributes(dst, {class(im)}, {'size',size(im)});
            assert(isequal(im, dst));
        end

        function test_2
            im = cv.imread(TestWarpAffine.img, 'Grayscale',true);
            M = eye(2,3);  % identity transform
            dst = cv.warpAffine(im, M, 'DSize',[256 256], ...
                'Interpolation','Linear', 'WarpInverse',false, ...
                'BorderType','Constant', 'BorderValue',0);
            validateattributes(dst, {class(im)}, {'size',[256 256]});
        end

        function test_3
            im = imread(TestWarpAffine.img);
            [h,w,~] = size(im);
            M = cv.getRotationMatrix2D([w h]./2, 30, 0.7);
            dst = cv.warpAffine(im, M, 'Dst',im, 'BorderType','Transparent');
            validateattributes(dst, {class(im)}, {'size',size(im)});
        end

        function test_error_1
            try
                cv.warpAffine();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
