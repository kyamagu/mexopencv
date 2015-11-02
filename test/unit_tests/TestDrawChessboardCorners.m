classdef TestDrawChessboardCorners
    %TestDrawChessboardCorners

    methods (Static)
        function test_1
            img = imread(fullfile(mexopencv.root(),'test','left01.jpg'));
            patternSize = [9 6];
            [corners,found] = cv.findChessboardCorners(img, patternSize);

            out = repmat(img, [1 1 3]);
            out = cv.drawChessboardCorners(out, patternSize, corners, ...
                'PatternWasFound',found);
            validateattributes(out, {class(img)}, {'3d', 'size',[size(img) 3]})
        end

        function test_2
            img = imread(fullfile(mexopencv.root(),'test','left01.jpg'));
            patternSize = [9 6];
            [corners,found] = cv.findChessboardCorners(img, patternSize);
            corners = cat(1, corners{:});

            out = cv.drawChessboardCorners(img, patternSize, corners, ...
                'PatternWasFound',found);
            validateattributes(out, {class(img)}, {'2d', 'size',size(img)})
        end

        function test_error_1
            try
                cv.drawChessboardCorners();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
