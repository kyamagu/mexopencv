classdef TestNorm
    %TestNorm

    methods (Static)
        function test_1
            img = imread(fullfile(mexopencv.root(),'test','cat.jpg'));
            n = cv.norm(img);
            assert(isscalar(n) && isa(n,'double'));
            n = cv.norm(img, 'NormType','L1');
            assert(isscalar(n) && isa(n,'double'));
            n = cv.norm(img, 'NormType','Inf');
            assert(isscalar(n) && isa(n,'double'));
        end

        function test_2
            img1 = imread(fullfile(mexopencv.root(),'test','left01.jpg'));
            img2 = imread(fullfile(mexopencv.root(),'test','right01.jpg'));
            d = cv.norm(img1, img2);
            assert(isscalar(d) && isa(d,'double'));
            d = cv.norm(img1, img2, 'Relative',true);
            assert(isscalar(d) && isa(d,'double'));
        end

        function test_3
            img = imread(fullfile(mexopencv.root(),'test','left01.jpg'));
            mask = rand(size(img)) > 0.5;
            n = cv.norm(img, 'Mask',mask);
            assert(isscalar(n) && isa(n,'double'));
        end

        function test_error
            try
                cv.norm();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
