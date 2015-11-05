classdef TestResize
    %TestResize

    methods (Static)
        function test_1
            img = imread(fullfile(mexopencv.root(),'test','img001.jpg'));
            ref = img(1:2:end,1:2:end,:);
            dst = cv.resize(img, 0.5, 0.5, 'Interpolation','Nearest');
            validateattributes(dst, {class(img)}, {'size',size(ref)});
            assert(isequal(ref, dst));
        end

        function test_2
            img = imread(fullfile(mexopencv.root(),'test','img001.jpg'));
            ref = img(1:2:end,1:2:end,:);
            dst = cv.resize(img, [256,256], 'Interpolation','Nearest');
            validateattributes(dst, {class(img)}, {'size',size(ref)});
            assert(all(abs(ref(:) - dst(:)) < 1e-5));
        end

        function test_3
            img = imread(fullfile(mexopencv.root(),'test','img001.jpg'));
            interps = {'Nearest', 'Linear', 'Cubic', 'Area', 'Lanczos4'};
            for i=1:numel(interps)
                dst = cv.resize(img, [700 800], 'Interpolation',interps{i});
                validateattributes(dst, {class(img)}, {'size',[800 700 size(img,3)]});
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
