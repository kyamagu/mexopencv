classdef TestCalcHist
    %TestCalcHist
    properties (Constant)
        img = fullfile(mexopencv.root(),'test','img001.jpg');
    end

    methods (Static)
        function test_1
            % 2D histogram
            im = imread(TestCalcHist.img);
            histSize = [30, 32];
            edges1 = linspace(0, 256, histSize(1)+1);
            edges2 = linspace(0, 256, histSize(2)+1);
            edges = {edges1, edges2};

            H = cv.calcHist(im(:,:,[1 2]), edges);
            validateattributes(H, {'single'}, {'nonsparse', 'size',histSize});

            HH = cv.calcHist({im(:,:,1), im(:,:,2)}, edges);
            validateattributes(HH, {'single'}, {'nonsparse', 'size',histSize});
            assert(isequal(H,HH));

            HH = cv.calcHist(im, edges, 'Channels',[1 2]-1);
            validateattributes(HH, {'single'}, {'nonsparse', 'size',histSize});
            assert(isequal(H,HH));

            HH = cv.calcHist(im, edges, 'Channels',[1 2]-1, 'HistSize',histSize);
            validateattributes(HH, {'single'}, {'nonsparse', 'size',histSize});
            assert(isequal(H,HH));

            HH = cv.calcHist(im, {edges1([1 end]), edges2([1 end])}, ...
                'Uniform',true, 'Channels',[1 2]-1, 'HistSize',histSize);
            validateattributes(HH, {'single'}, {'nonsparse', 'size',histSize});
            assert(isequal(H,HH));

            HH(:) = 0;
            HH = cv.calcHist(im(:,:,[1 2]), edges, 'Hist',HH);
            validateattributes(HH, {'single'}, {'nonsparse', 'size',histSize});
            assert(isequal(H,HH));

            HH = cv.calcHist(im(:,:,[1 2]), edges, 'Sparse',true);
            validateattributes(HH, {'double'}, {'size',histSize});
            assert(issparse(HH) && isequal(H,full(HH)));
        end

        function test_histc
            % compare against HISTC
            im = cv.imread(TestCalcHist.img, 'Grayscale',true);  % uint8 grayscale
            edges = [0 50 100 150 200 256];                      % 1D histogram
            H1 = cv.calcHist(im, edges);
            H2  = histc(im(:), edges);
            assert(isequal(H1, H2(1:end-1)));

            % with a mask
            mask = false(size(im));
            mask(100:300,100:300) = true;
            H1 = cv.calcHist(im, edges, 'Mask',mask);
            H2  = histc(im(mask), edges);
            assert(isequal(H1, H2(1:end-1)));
        end

        function test_histcounts
            % compare against the new HISTCOUNTS function
            if mexopencv.isOctave() || verLessThan('matlab','8.4')
                disp('SKIP');
                return
            end
            im = cv.imread(TestCalcHist.img, 'Grayscale',true);  % uint8 grayscale
            edges = [0 50 100 150 200 256];                      % 1D histogram
            H1 = cv.calcHist(im, edges);
            H2  = histcounts(im, [edges(1:end-1) 255]);
            assert(isequal(H1(:), H2(:)));

            % with a mask
            mask = false(size(im));
            mask(100:300,100:300) = true;
            H1 = cv.calcHist(im, edges, 'Mask',mask);
            H2  = histcounts(im(mask), [edges(1:end-1) 255]);
            assert(isequal(H1(:), H2(:)));
        end

        function test_nd_hist
            % multi-dimensional histogram (4-D)
            X = rand([400,500,4], 'single');
            [h,w,~] = size(X);
            edges = {[0 1], [0 1], [0 1], [0 1]};
            histSize = [7 8 9 10];
            H = cv.calcHist(X, edges, 'HistSize',histSize, 'Uniform',true);
            %---
            %TODO: there's a bug in MxArray::MxArray(Mat) when mat.dims>2
            %validateattributes(H, {'single'}, {'ndims',4, 'size',histSize});
            %assert(isequal(sum(H(:)), h*w));
            %---
        end

        function test_error_1
            try
                cv.calcHist();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
