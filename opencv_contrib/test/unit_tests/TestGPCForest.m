classdef TestGPCForest
    %TestGPCForest

    methods (Static)
        function test_1
            [img1, img2, flo] = readRubberWhale();
            gpc = cv.GPCForest();
            % NOTE: train can be slow
            gpc.train({img1}, {img2}, {flo}, 'MaxTreeDepth',8, ...
                'DescriptorType','WHT', 'PrintProgress',false);

            if false
                forestFile = fullfile(tempdir(), 'forest.yml.gz');
                gpc.save(forestFile);
                gpc.load(forestFile);
                delete(forestFile);
            end

            C = gpc.findCorrespondences(img1, img2, 'UseOpenCL',false);
            validateattributes(C, {'struct'}, {'vector'});
            assert(all(ismember({'first', 'second'}, fieldnames(C))));
            %assert(calcAvgEPE(C,flo) < 0.5, 'bad accuracy');
        end
    end

end

% https://github.com/opencv/opencv_contrib/blob/3.2.0/modules/optflow/test/test_OF_accuracy.cpp

function [img1, img2, flo] = readRubberWhale()
    im1 = fullfile(mexopencv.root(), 'test', 'RubberWhale1.png');
    im2 = fullfile(mexopencv.root(), 'test', 'RubberWhale2.png');
    GT = fullfile(mexopencv.root(), 'test', 'RubberWhale.flo');
    if exist(GT, 'file') ~= 2
        % attempt to download ground thruth flow from GitHub
        url = 'https://cdn.rawgit.com/opencv/opencv_extra/3.2.0/testdata/cv/optflow/RubberWhale.flo';
        urlwrite(url, GT);
    end

    img1 = imread(im1);
    img2 = imread(im2);
    flo = cv.readOpticalFlow(GT);

    % take half the size for speed
    sz = fix(size(img1)/2);
    img1 = img1(1:sz(1), 1:sz(2), :);
    img2 = img2(1:sz(1), 1:sz(2), :);
    flo = flo(1:sz(1), 1:sz(2), :);
end

function avg = calcAvgEPE(corrs, flo)
    is_finite = @(x) all(isfinite(x)) && all(abs(x) < 1e9);
    err = 0;
    count = 0;
    for i=1:numel(corrs)
        uv1 = single(corrs(i).second - corrs(i).first);
        uv2 = flo(corrs(i).first(2), corrs(i).first(1), :);
        if is_finite(uv1) && is_finite(uv2)
            err = err + norm(uv1(:) - uv2(:));
            count = count + 1;
        end
    end
    avg = err / count;  % average endpoint error
end
