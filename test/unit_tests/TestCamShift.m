classdef TestCamShift
    %TestCamShift

    methods (Static)
        function test_1
            im = imread(fullfile(mexopencv.root(),'test','img001.jpg'));
            im = im(:,:,1:2);
            edges = {linspace(0,256,32+1), linspace(0,256,32+1)};
            H = cv.calcHist(im, edges);
            B = cv.calcBackProject(im, H, edges);
            win = [150 330 190 130];
            [box,win2] = cv.CamShift(B, win);
            validateattributes(box, {'struct'}, {'scalar'});
            assert(all(ismember({'center','size','angle'}, fieldnames(box))));
            validateattributes(box.center, {'numeric'}, {'vector', 'numel',2});
            validateattributes(box.size, {'numeric'}, {'vector', 'numel',2});
            validateattributes(box.angle, {'numeric'}, {'scalar'});
            validateattributes(win2, {'numeric'}, {'vector', 'numel',4});
        end

        function test_error_1
            try
                cv.CamShift();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
