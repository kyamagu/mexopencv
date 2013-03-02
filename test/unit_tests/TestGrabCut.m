classdef TestGrabCut
    % Functional Tests for grabCut
    properties (Constant)
        img = imread(fullfile(mexopencv.root(),'test','img001.jpg'));
    end
    
    methods (Static)
        function test_1
            % TEST 1: initialization with bbox must succeed
            bbox = [100,100,280,320]; % [x y w h]
            res = cv.grabCut(TestGrabCut.img,bbox,'Init','Rect');
            %imshow(TestGrabCut.img.*repmat(reshape(uint8(res==3),size(res)),[1,1,3]));
            % grabCut has random components... it's hard to verify
        end

        function test_2
            % TEST 2: initialization with mask must succeed
            bbox = [100,100,200,320]; % [y x w h]
            mask = zeros(size(TestGrabCut.img,1),size(TestGrabCut.img,2),'uint8');
            mask(bbox(2):(bbox(2)+bbox(4)-1),bbox(1):(bbox(1)+bbox(3)-1)) = 3; % Set trimap
            [res, bgdmodel, fgdmodel] = cv.grabCut(TestGrabCut.img,mask,'Init','Mask');
            % grabCut has random components... it's hard to verify
        end
        
        % add more sucess cases

        function test_error_1
            % ERROR TEST 1
            try
                cv.grabCut();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end

        function test_error_2
            % ERROR TEST 2
            try
                mask = zeros(size(TestGrabCut.img,1),size(TestGrabCut.img,2),'uint8');
                cv.grabCut(TestGrabCut.img,mask,'foo');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end

        function test_error_3
            % ERROR TEST 3
            try
                mask = zeros(size(TestGrabCut.img,1),size(TestGrabCut.img,2),'uint8');
                cv.grabCut(TestGrabCut.img,mask,'foo','bar');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end

        function test_error_4
            % ERROR TEST 4
            try
                mask = zeros(size(TestGrabCut.img,1),size(TestGrabCut.img,2),'uint8');
                cv.grabCut(TestGrabCut.img,mask,'Init','foo');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end

        function test_error_5
            % ERROR TEST 5
            try
                mask = zeros(size(TestGrabCut.img,1),size(TestGrabCut.img,2),'uint8');
                cv.grabCut(TestGrabCut.img,mask,'MaxIter','foo');
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
        
        % add more failure cases
    end
end
