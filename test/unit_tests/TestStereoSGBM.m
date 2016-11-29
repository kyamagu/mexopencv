classdef TestStereoSGBM
    %TestStereoSGBM

    methods (Static)
        function test_1
            bm = cv.StereoSGBM();
            assert(isobject(bm));

            bm.NumDisparities = 64;
            assert(isequal(bm.NumDisparities, 64));
        end

        function test_2
            im1 = imread(fullfile(mexopencv.root(),'test','tsukuba_l.png'));
            im2 = imread(fullfile(mexopencv.root(),'test','tsukuba_r.png'));
            bm = cv.StereoSGBM('MinDisparity',0, 'NumDisparities',16, 'BlockSize',15);
            D = bm.compute(im1, im2);
            validateattributes(D, {'int16'}, {'size',[size(im1,1) size(im1,2)]});
        end
    end

end
