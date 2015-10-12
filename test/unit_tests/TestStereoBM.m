classdef TestStereoBM
    %TestStereoBM

    methods (Static)
        function test_1
            bm = cv.StereoBM();
        end

        function test_2
            im1 = imread(fullfile(mexopencv.root(),'test','tsukuba_l.png'));
            im2 = imread(fullfile(mexopencv.root(),'test','tsukuba_r.png'));
            bm = cv.StereoBM('NumDisparities',16, 'BlockSize',15);
            D = bm.compute(im1, im2);
            validateattributes(D, {'int16'}, {'size',[size(im1,1) size(im1,2)]});

            % points cloud
            %{
            [X,Y] = ndgrid(1:size(D,1), 1:size(D,2));
            C = imread(fullfile(mexopencv.root(),'test','tsukuba.png'));
            scatter3(X(:), Y(:), D(:), 6, reshape(im2double(C),[],3), '.'); axis equal
            %}
        end
    end

end
