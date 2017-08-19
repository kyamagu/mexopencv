classdef TestImgHash
    %TestImgHash

    methods (Static)
        function test_1
            img1 = imread(fullfile(mexopencv.root(), 'test', 'tsukuba_l.png'));
            img2 = imread(fullfile(mexopencv.root(), 'test', 'tsukuba_r.png'));

            algs = {'AverageHash', 'BlockMeanHash', 'ColorMomentHash',
                'MarrHildrethHash', 'PHash', 'RadialVarianceHash'};
            for i=1:numel(algs)
                obj = cv.ImgHash(algs{i});
                hash1 = obj.compute(img1);
                hash2 = obj.compute(img2);
                validateattributes(hash1, {'numeric'}, {'vector'});
                validateattributes(hash1, {'numeric'}, {'vector'});
                val = obj.compare(hash1, hash2);
                validateattributes(val, {'numeric'}, {'scalar'});
            end
        end

        function test_2
            img = imread(fullfile(mexopencv.root(), 'test', 'tsukuba.png'));

            hash = cv.ImgHash.averageHash(img);
            validateattributes(hash, {'uint8'}, {'vector'}); % 'numel',8

            hash = cv.ImgHash.blockMeanHash(img, 'Mode','Mode1');
            validateattributes(hash, {'uint8'}, {'vector'}); % 'numel',32|121 (Mode0|Mode1)

            hash = cv.ImgHash.colorMomentHash(img);
            validateattributes(hash, {'double'}, {'vector'}); % 'numel',42

            hash = cv.ImgHash.marrHildrethHash(img, 'Alpha',2);
            validateattributes(hash, {'uint8'}, {'vector'}); % 'numel',72

            hash = cv.ImgHash.pHash(img);
            validateattributes(hash, {'uint8'}, {'vector'}); % 'numel',8

            hash = cv.ImgHash.radialVarianceHash(img, 'Sigma',1);
            validateattributes(hash, {'uint8'}, {'vector'}); % 'numel',40
        end
    end

end
