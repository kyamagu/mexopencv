classdef TestImreadmulti
    %TestImreadmulti

    methods (Static)
        function test_read_pages
            filename = which('mri.tif');
            if isempty(filename)
                disp('SKIP')
                return
            end

            imgs = cv.imreadmulti(filename);
            validateattributes(imgs, {'cell'}, {'vector', 'nonempty'});
            cellfun(@(im) validateattributes(im, {'uint8'}, ...
                {'nonempty', 'ndims',2}), imgs);
        end

        function test_compare
            % TIFF file with 27 grayscale images
            filename = which('mri.tif');
            if isempty(filename)
                disp('SKIP')
                return
            end

            % number of pages
            info = imfinfo(filename);
            num_pages = numel(info);

            % read all pages
            imgs1 = cv.imreadmulti(filename, 'AnyColor',true, 'AnyDepth',true);
            validateattributes(imgs1, {'cell'}, {'vector', 'numel',num_pages});

            % compare against imread from MATLAB
            imgs2 = cell(1,num_pages);
            for i=1:num_pages
                % (convert indexed images to grayscale)
                [X,map] = imread(filename, 'Info',info, 'Index',i);
                imgs2{i} = ind2gray(X, map);
            end
            assert(isequal(imgs1(:), imgs2(:)), 'Images are not equal');
        end

        function test_single_page
            filename = fullfile(mexopencv.root(),'test','fruits.jpg');
            imgs = cv.imreadmulti(filename);
            validateattributes(imgs, {'cell'}, {'vector', 'numel',1});
        end

        function test_error_non_existant_file
            try
                cv.imreadmulti('non_existant_image.tif');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
        function test_error_argnum
            try
                cv.imreadmulti();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
