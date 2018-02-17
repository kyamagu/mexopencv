classdef TestStructuredEdgeDetection
    %TestStructuredEdgeDetection

    properties (Constant)
        im = fullfile(mexopencv.root(),'test','balloon.jpg');
    end

    methods (Static)
        function test_1
            img = imread(TestStructuredEdgeDetection.im);
            img = single(img) / 255.0;

            modelFilename = get_model_file();
            pDollar = cv.StructuredEdgeDetection(modelFilename);

            E = pDollar.detectEdges(img);
            validateattributes(E, {'single'}, ...
                {'size',[size(img,1) size(img,2)], '>=',0, '<=',1});

            O = pDollar.computeOrientation(E);
            validateattributes(O, {'single'}, ...
                {'size',[size(img,1) size(img,2)]});

            E_nms = pDollar.edgesNms(E, O);
            validateattributes(E_nms, {'single'}, ...
                {'size',[size(img,1) size(img,2)], '>=',0, '<=',1});
        end

        function test_custom_feat_extract
            % skip test if external M-file is not found on the path
            if ~exist('myRFFeatureGetter.m', 'file')
                error('mexopencv:testskip', 'undefined function');
            end

            img = imread(TestStructuredEdgeDetection.im);
            img = single(img) / 255.0;

            modelFilename = get_model_file();
            pDollar = cv.StructuredEdgeDetection(modelFilename, ...
                'myRFFeatureGetter');
            E = pDollar.detectEdges(img);
        end

        function test_get_features
            img = imread(TestStructuredEdgeDetection.im);
            img = single(img) / 255.0;

            opts = struct();
            opts.normRad = 4;
            opts.grdSmooth = 0;
            opts.shrink = 2;
            opts.nChns = 13;
            opts.nOrients = 4;

            features = cv.StructuredEdgeDetection.getFeatures(img, opts);
            validateattributes(features, {'numeric'}, {'real', 'ndims',3});
            sz = size(features);
            %assert(sz(1) * opts.shrink == size(img,1));
            %assert(sz(2) * opts.shrink == size(img,2));
            assert(sz(3) == opts.nChns);
        end
    end

end

function features = myRFFeatureGetter(src, opts)
    if false
        nsize = fix([size(src,1) size(src,2)] ./ opts.shrink);
        features = zeros([nsize opts.nChns], 'single');
        %TODO: ... compute features
    else
        % call opencv's implementation
        features = cv.StructuredEdgeDetection.getFeatures(src, opts);
    end
end

function fname = get_model_file()
    fname = fullfile(mexopencv.root(),'test','model.yml.gz');
    if exist(fname, 'file') ~= 2
        % download model from GitHub
        url = 'https://cdn.rawgit.com/opencv/opencv_extra/3.2.0/testdata/cv/ximgproc/model.yml.gz';
        urlwrite(url, fname);
    end
end
