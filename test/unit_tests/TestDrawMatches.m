classdef TestDrawMatches
    %TestDrawMatches
    properties (Constant)
        img1 = fullfile(mexopencv.root(),'test','left01.jpg');
        img2 = fullfile(mexopencv.root(),'test','right01.jpg');
    end

    methods (Static)
        function test_1
            im1 = imread(TestDrawMatches.img1);
            im2 = imread(TestDrawMatches.img2);
            obj = cv.ORB();
            [kpts1, feat1] = obj.detectAndCompute(im1);
            [kpts2, feat2] = obj.detectAndCompute(im2);
            matcher = cv.DescriptorMatcher('BruteForce-Hamming');
            m = matcher.match(feat1, feat2);
            out = cv.drawMatches(im1, kpts1, im2, kpts2, m);
            validateattributes(out, {class(im1)}, {'size',...
                [max(size(im1,1),size(im2,1)), size(im1,2)+size(im2,2), 3]});
        end

        function test_2
            im1 = imread(TestDrawMatches.img1);
            im2 = imread(TestDrawMatches.img2);
            obj = cv.ORB();
            [kpts1, feat1] = obj.detectAndCompute(im1);
            [kpts2, feat2] = obj.detectAndCompute(im2);
            matcher = cv.DescriptorMatcher('BruteForce-Hamming');
            m = matcher.match(feat1, feat2);

            [~,ord] = sort([m.distance]);
            mask = false(size(ord));
            mask(ord(1:min(20,end))) = true;

            out = cv.drawMatches(im1, kpts1, im2, kpts2, m, ...
                'MatchesMask',mask, ...
                'OutImage',repmat(cat(2,im1,im2), [1 1 3]), ...
                'MatchColor',[255 0 0], 'SinglePointColor',[0 255 0], ...
                'NotDrawSinglePoints',true, 'DrawRichKeypoints',true);
            validateattributes(out, {class(im1)}, {'size',...
                [max(size(im1,1),size(im2,1)), size(im1,2)+size(im2,2), 3]});
        end

        function test_error_1
            try
                cv.drawMatches();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end
end
