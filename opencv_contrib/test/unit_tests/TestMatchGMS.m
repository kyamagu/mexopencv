classdef TestMatchGMS
    %TestMatchGMS

    methods (Static)
        function test_1
            im1 = imread(fullfile(mexopencv.root(),'test','left01.jpg'));
            im2 = imread(fullfile(mexopencv.root(),'test','right01.jpg'));
            sz1 = [size(im1,2), size(im1,1)];
            sz2 = [size(im2,2), size(im2,1)];
            obj = cv.ORB('MaxFeatures',5000, 'FastThreshold',0);
            [kpts1, feat1] = obj.detectAndCompute(im1);
            [kpts2, feat2] = obj.detectAndCompute(im2);
            matcher = cv.DescriptorMatcher('BruteForce-Hamming');
            m = matcher.match(feat1, feat2);

            mGMS = cv.matchGMS(sz1, kpts1, sz2, kpts2, m);
            validateattributes(mGMS, {'struct'}, {'vector'});
            assert(all(ismember(TestDescriptorMatcher.fields, ...
                fieldnames(mGMS))));
        end

        function test_error_argnum
            try
                cv.matchGMS();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
