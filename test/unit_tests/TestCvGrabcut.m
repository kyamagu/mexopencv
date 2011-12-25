classdef TestCvGrabcut
    % Functional Tests for grabcut
    methods (Static)
        function test_1
            % TEST 1: initialization with bbox must succeed
            img = imread('img001.jpg');
            bbox = [158 22 210 560]; % [y x w h]
            res = grabcut(img,bbox,'Init','Rect');
            % grabcut has random components... it's hard to verify
            % correctness
        end

        function test_2
            % TEST 2: initialization with mask must succeed
            img = imread('img001.jpg');
            bbox = [158 22 210 560]; % [y x w h]
            mask = zeros(size(img,1),size(img,2),'uint8');
            mask(bbox(2):(bbox(2)+bbox(4)-1),bbox(1):(bbox(1)+bbox(3)-1)) = 3; % Set trimap
            res = grabcut(img,mask,'Init','Mask');
            % grabcut has random components... it's hard to verify
            % correctness
        end
        
        % add more sucess cases

        function test_error_1
            % ERROR TEST 1
            try
                grabcut();
            catch e
                assert(strcmp(e.identifier,'CvGrabcut:invalidArgs'));
            end
        end

        function test_error_2
            % ERROR TEST 2
            try
                img = imread('img001.jpg');
                mask = zeros(size(img,1),size(img,2),'uint8');
                grabcut(img,mask,'foo');
            catch e
                assert(strcmp(e.identifier,'CvGrabcut:invalidArgs'));
            end
        end

        function test_error_3
            % ERROR TEST 3
            try
                img = imread('img001.jpg');
                mask = zeros(size(img,1),size(img,2),'uint8');
                grabcut(img,mask,'foo','bar');
            catch e
                assert(strcmp(e.identifier,'CvGrabcut:invalidOption'));
            end
        end

        function test_error_4
            % ERROR TEST 4
            try
                img = imread('img001.jpg');
                mask = zeros(size(img,1),size(img,2),'uint8');
                grabcut(img,mask,'Init','foo');
            catch e
                assert(strcmp(e.identifier,'CvGrabcut:invalidOption'));
            end
        end

        function test_error_5
            % ERROR TEST 5
            try
                img = imread('img001.jpg');
                mask = zeros(size(img,1),size(img,2),'uint8');
                grabcut(img,mask,'MaxIter','foo');
            catch e
                assert(strcmp(e.identifier,'CvGrabcut:invalidOption'));
            end
        end
        
        % add more failure cases
    end
end