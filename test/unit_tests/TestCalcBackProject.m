classdef TestCalcBackProject
    %TestCalcBackProject
    properties (Constant)
        img = fullfile(mexopencv.root(),'test','img001.jpg');
    end

    methods (Static)
        function test_1
            % 2D histogram
            img = imread(TestCalcBackProject.img);
            im = single(img);
            [h,w,~] = size(im);
            histSize = [30, 32];
            edges1 = linspace(0, 256, histSize(1)+1);
            edges2 = linspace(0, 256, histSize(2)+1);
            edges = {edges1, edges2};
            H = cv.calcHist(img(:,:,[1 2]), edges);

            B = cv.calcBackProject(im(:,:,[1 2]), H, edges);
            validateattributes(B, {class(im)}, {'size',[h,w]});

            BB = cv.calcBackProject({im(:,:,1), im(:,:,2)}, H, edges);
            validateattributes(BB, {class(im)}, {'size',[h,w]});
            assert(isequal(B,BB));

            BB = cv.calcBackProject(im, H, edges, 'Channels',[1 2]-1);
            validateattributes(BB, {class(im)}, {'size',[h,w]});
            assert(isequal(B,BB));

            BB = cv.calcBackProject(im, H, {edges1([1 end]), edges2([1 end])}, ...
                'Uniform',true, 'Channels',[1 2]-1);
            validateattributes(BB, {class(im)}, {'size',[h,w]});
            assert(isequal(B,BB));

            HH = cv.calcHist(img(:,:,[1 2]), edges, 'Sparse',true);
            BB = cv.calcBackProject(im(:,:,[1 2]), HH, edges);
            validateattributes(BB, {class(im)}, {'size',[h,w]});
            assert(isequal(B,BB));
        end

        function test_histc
            % compare against HISTC
            im = cv.imread(TestCalcBackProject.img, 'Grayscale',true);  % uint8 grayscale
            edges = [0 50 100 150 200 256];                             % 1D histogram
            H1 = cv.calcHist(im, edges);
            B1 = cv.calcBackProject(single(im), H1, edges);
            [H2,B2]  = histc(im(:), edges);
            B2 = reshape(H2(B2), size(im));
            assert(isequal(H1, H2(1:end-1)));
            assert(isequal(B1,B2));
        end

        function test_histcounts
            % compare against the new HISTCOUNTS function
            if mexopencv.isOctave() || verLessThan('matlab','8.4')
                disp('SKIP');
                return
            end
            im = cv.imread(TestCalcBackProject.img, 'Grayscale',true);  % uint8 grayscale
            edges = [0 50 100 150 200 256];                             % 1D histogram
            H1 = cv.calcHist(im, edges);
            B1 = cv.calcBackProject(single(im), H1, edges);
            [H2,~,B2]  = histcounts(im, [edges(1:end-1) 255]);
            B2 = H2(B2);
            assert(isequal(H1(:), H2(:)));
            assert(isequal(B1,B2));
        end

        function test_nd_hist
            % multi-dimensional histogram (4-D)
            X = rand([400,500,4], 'single');
            [h,w,~] = size(X);
            edges = {[0 1], [0 1], [0 1], [0 1]};
            histSize = [7 8 9 10];
            H = cv.calcHist(X, edges, 'HistSize',histSize, 'Uniform',true);
            B = cv.calcBackProject(X, H, edges, 'Uniform',true);
            validateattributes(B, {'single'}, {'size',[h,w]});
        end

        function test_error_1
            try
                cv.calcBackProject();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
