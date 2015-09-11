classdef TestResize
    %TestResize
    properties (Constant)
        img = imread(fullfile(mexopencv.root(),'test','img001.jpg'));
    end

    methods (Static)
        function test_1
            im = TestResize.img;
            ref = im(1:2:end,1:2:end,:);
            dst = cv.resize(im, 0.5, 0.5, 'Interpolation','Nearest');
            validateattributes(dst, {class(im)}, {'size',size(ref)});
            assert(isequal(ref, dst));
        end

        function test_2
            im = TestResize.img;
            ref = im(1:2:end,1:2:end,:);
            dst = cv.resize(im, [256,256], 'Interpolation','Nearest');
            validateattributes(dst, {class(im)}, {'size',size(ref)});
            assert(all(abs(ref(:) - dst(:)) < 1e-5));
        end

        function test_3
            im = TestResize.img;
            interps = {'Nearest', 'Linear', 'Cubic', 'Area', 'Lanczos4'};
            for i=1:numel(interps)
                dst = cv.resize(im, [700 800], 'Interpolation',interps{i});
                validateattributes(dst, {class(im)}, {'size',[800 700 size(im,3)]});
            end
        end

        function test_error_1
            try
                cv.resize();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
