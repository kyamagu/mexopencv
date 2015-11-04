classdef TestInpaint2
    %TestInpaint2

    methods (Static)
        function test_CIE_Lab
            img = imread(fullfile(mexopencv.root(),'test','lena.jpg'));
            img = cv.resize(img, 0.4, 0.4);
            img(80:100, 80:100, :) = 0;

            mask = 255 * ones(size(img,1), size(img,2), 'uint8');
            mask(80:100, 80:100) = 0;

            % CV_8U
            lab = cv.cvtColor(img, 'RGB2Lab');
            out = cv.inpaint2(lab, mask);
            out = cv.cvtColor(out, 'Lab2RGB');
            validateattributes(out, {class(img)}, {'size',size(img)});

            % CV_32F
            img = single(img) / 255;
            lab = cv.cvtColor(img, 'RGB2Lab');
            out = cv.inpaint2(lab, mask);
            out = cv.cvtColor(out, 'Lab2RGB');
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_grayscale
            %TODO: crashes MATLAB!
            if true
                disp('SKIP');
                return;
            end
        end

        function test_error_1
            try
                cv.inpaint2();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
