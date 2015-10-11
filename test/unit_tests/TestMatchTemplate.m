classdef TestMatchTemplate
    %TestMatchTemplate
    properties (Constant)
        im = imread(fullfile(mexopencv.root(),'test','img001.jpg'));
    end

    methods (Static)
        function test_result_grayscale
            img = rgb2gray(TestMatchTemplate.im);
            tmpl = img(150:350,150:350);
            result = cv.matchTemplate(img, tmpl);
            validateattributes(result, {'numeric'}, ...
                {'real', '2d', 'size',size(img)-size(tmpl)+1});
        end

        function test_result_rgb
            img = TestMatchTemplate.im;
            tmpl = img(150:350,150:350,:);
            result = cv.matchTemplate(img, tmpl);
            [H,W,~] = size(img);
            [h,w,~] = size(tmpl);
            validateattributes(result, {'numeric'}, ...
                {'real', '2d', 'size',[H-h+1,W-w+1]});
        end

        function test_methods
            img = rgb2gray(TestMatchTemplate.im);
            tmpl = img(150:350,150:350);
            comp1 = {'SqDiff', 'CCorr', 'CCoeff'};
            comp2 = strcat(comp1,'Normed');
            for i=1:numel(comp1)
                result = cv.matchTemplate(img, tmpl, 'Method',comp1{i});
                result = cv.matchTemplate(img, tmpl, 'Method',comp2{i});
            end
        end

        function test_mask_grayscale
            img = rgb2gray(TestMatchTemplate.im);
            tmpl = img(150:350,150:350);
            mask = false(size(tmpl));
            mask(50:150,10:end-10) = true;
            result = cv.matchTemplate(img, tmpl, 'Mask',mask);
        end

        function test_mask_rgb
            img = TestMatchTemplate.im;
            tmpl = img(150:350,150:350,:);
            mask = false(size(tmpl));
            mask(50:150,10:end-10,:) = true;
            result = cv.matchTemplate(img, tmpl, 'Mask',mask);
        end

        function test_compare_normxcorr2
            if mexopencv.isOctave()
                img_tlbx = 'image';
            else
                img_tlbx = 'image_toolbox';
            end
            if ~license('test', img_tlbx), return; end
            try
                img = rgb2gray(imread('peppers.png'));
                tmpl = rgb2gray(imread('onion.png'));
            catch ME
                disp('SKIP')
                return
            end

            result = cv.matchTemplate(img, tmpl, 'Method','CCorrNormed');
            [row1,col1] = find(result == max(result(:)));

            C = normxcorr2(tmpl, img);
            [h,w] = size(tmpl);
            C = C(h:end-h+1,w:end-w+1);
            [row2,col2] = find(C == max(C(:)));

            %assert(isequal(row1,row2) && isequal(col1,col2));
        end

        function test_error_1
            try
                cv.matchTemplate();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
