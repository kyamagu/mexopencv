classdef TestFindChessboardCorners
    %TestFindChessboardCorners

    methods (Static)
        function test_1
            img = imread(fullfile(mexopencv.root(),'test','left01.jpg'));
            patternSize = [9 6];
            [corners,found] = cv.findChessboardCorners(img, patternSize, ...
                'AdaptiveThresh',true, 'NormalizeImage',true, 'FastCheck',true);
            validateattributes(found, {'logical'}, {'scalar'});
            if found
                validateattributes(corners, {'cell'}, ...
                    {'vector', 'numel',prod(patternSize)});
                cellfun(@(v) validateattributes(v, {'numeric'}, ...
                    {'vector', 'numel',2}), corners);
            end
        end

        function test_error_1
            try
                cv.findChessboardCorners();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
