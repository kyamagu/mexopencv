classdef TestEstimateRigidTransform
    %TestEstimateRigidTransform
    properties (Constant)
        im = 255*uint8([...
            0 0 0 0 0 0 0 0 0 0;...
            0 0 0 0 0 0 0 0 0 0;...
            0 0 0 0 0 0 0 0 0 0;...
            0 0 0 1 1 1 1 0 0 0;...
            0 0 0 1 0 1 0 0 0 0;...
            0 0 0 1 1 1 0 0 0 0;...
            0 0 0 0 0 0 1 0 0 0;...
            0 0 0 0 0 0 0 0 0 0;...
            0 0 0 0 0 0 0 0 0 0;...
            0 0 0 0 0 0 0 0 0 0;...
        ]);
    end

    methods (Static)
        function test_1
            im1 = TestEstimateRigidTransform.im;
            im2 = circshift(im1, [0 1]);
            M = cv.estimateRigidTransform(im1, im2, 'FullAffine',false);
        end

        function test_images_input
            im1 = cv.imread(fullfile(mexopencv.root(),'test','RubberWhale1.png'), 'Grayscale',true);
            im2 = cv.imread(fullfile(mexopencv.root(),'test','RubberWhale2.png'), 'Grayscale',true);
            M = cv.estimateRigidTransform(im1, im2, 'FullAffine',true);
            validateattributes(M, {'double'}, {'size',[2 3]});
        end

        function test_points_input
            N = 100;
            pts1 = rand(2,N)*10;                  % a set of 2D points
            aff = randn(2,3);                     % true affine transformation
            pts2 = aff * [pts1; ones(1,N)];       % transform pts1
            pts2 = pts2 + randn(size(pts2))*0.01; % add noise
            M = cv.estimateRigidTransform(...
                num2cell(pts1,1), num2cell(pts2,1), 'FullAffine',true);
            validateattributes(M, {'double'}, {'size',[2 3]});
            norm(M - aff);
        end

        function test_error_1
            try
                cv.estimateRigidTransform();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
