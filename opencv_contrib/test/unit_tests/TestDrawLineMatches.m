classdef TestDrawLineMatches
    %TestDrawLineMatches

    properties (Constant)
        img1 = fullfile(mexopencv.root(),'test','left01.jpg');
        img2 = fullfile(mexopencv.root(),'test','right01.jpg');
    end

    methods (Static)
        function test_1
            im1 = imread(TestDrawLineMatches.img1);
            im2 = imread(TestDrawLineMatches.img2);
            obj = cv.BinaryDescriptor();
            [klines1, feat1] = obj.detectAndCompute(im1);
            [klines2, feat2] = obj.detectAndCompute(im2);
            matcher = cv.BinaryDescriptorMatcher();
            m = matcher.match(feat1, feat2);

            im1 = cv.cvtColor(im1, 'GRAY2RGB');
            im2 = cv.cvtColor(im2, 'GRAY2RGB');
            out = cv.drawLineMatches(im1, klines1, im2, klines2, m);
            validateattributes(out, {class(im1)}, {'size',...
                [max(size(im1,1),size(im2,1)), size(im1,2)+size(im2,2), 3]});
        end

        function test_2
            im1 = imread(TestDrawLineMatches.img1);
            im2 = imread(TestDrawLineMatches.img2);
            obj = cv.BinaryDescriptor();
            [klines1, feat1] = obj.detectAndCompute(im1);
            [klines2, feat2] = obj.detectAndCompute(im2);
            matcher = cv.BinaryDescriptorMatcher();
            m = matcher.match(feat1, feat2);

            [~,ord] = sort([m.distance]);
            mask = false(size(ord));
            mask(ord(1:min(20,end))) = true;

            out = cv.drawLineMatches(im1, klines1, im2, klines2, m, ...
                'MatchesMask',mask, ...
                'OutImage',repmat(cat(2,im1,im2), [1 1 3]), ...
                'MatchColor',[255 0 0], 'SingleLineColor',[0 255 0], ...
                'NotDrawSingleLines',true);
            validateattributes(out, {class(im1)}, {'size',...
                [max(size(im1,1),size(im2,1)), size(im1,2)+size(im2,2), 3]});
        end

        function test_error_argnum
            try
                cv.drawLineMatches();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
