classdef TestMatchTemplate
    %TestMatchTemplate
    properties (Constant)
        im = fullfile(mexopencv.root(),'test','img001.jpg');
    end

    methods (Static)
        function test_result_grayscale
            img = cv.imread(TestMatchTemplate.im, 'Grayscale',true);
            tmpl = img(150:350,150:350);
            result = cv.matchTemplate(img, tmpl);
            validateattributes(result, {'numeric'}, ...
                {'real', '2d', 'size',size(img)-size(tmpl)+1});
        end

        function test_result_rgb
            img = imread(TestMatchTemplate.im);
            tmpl = img(150:350,150:350,:);
            result = cv.matchTemplate(img, tmpl);
            [H,W,~] = size(img);
            [h,w,~] = size(tmpl);
            validateattributes(result, {'numeric'}, ...
                {'real', '2d', 'size',[H-h+1,W-w+1]});
        end

        function test_methods
            img = cv.imread(TestMatchTemplate.im, 'Grayscale',true);
            tmpl = img(150:350,150:350);
            comp1 = {'SqDiff', 'CCorr', 'CCoeff'};
            comp2 = strcat(comp1,'Normed');
            for i=1:numel(comp1)
                result = cv.matchTemplate(img, tmpl, 'Method',comp1{i});
                result = cv.matchTemplate(img, tmpl, 'Method',comp2{i});
            end
        end

        function test_mask_grayscale
            img = cv.imread(TestMatchTemplate.im, 'Grayscale',true);
            tmpl = img(150:350,150:350);
            mask = false(size(tmpl));
            mask(50:150,10:end-10) = true;
            result = cv.matchTemplate(img, tmpl, 'Mask',mask);
        end

        function test_mask_rgb
            img = imread(TestMatchTemplate.im);
            tmpl = img(150:350,150:350,:);
            mask = false(size(tmpl));
            mask(50:150,10:end-10,:) = true;
            result = cv.matchTemplate(img, tmpl, 'Mask',mask);
        end

        function test_compare_normxcorr2
            % requires Image Processing Toolbox
            if mexopencv.isOctave()
                img_lic = 'image';
                img_pkg = img_lic;
            else
                img_lic = 'image_toolbox';
                img_pkg = 'images';
            end
            if ~license('test', img_lic) || isempty(ver(img_pkg))
                disp('SKIP');
                return;
            end

            try
                img = cv.imread('peppers.png', 'Grayscale',true);
                tmpl = cv.imread('onion.png', 'Grayscale',true);
            catch ME
                img = cv.imread(fullfile(mexopencv.root(),'test','pic1.png'), 'Grayscale',true);
                tmpl = cv.imread(fullfile(mexopencv.root(),'test','templ.png'), 'Grayscale',true);
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
