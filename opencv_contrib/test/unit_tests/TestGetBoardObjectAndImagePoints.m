classdef TestGetBoardObjectAndImagePoints
    %TestGetBoardObjectAndImagePoints

    methods (Static)
        function test_1
            [img, board] = get_image_markers();
            [corners, ids] = cv.detectMarkers(img, board{end});
            [objPoints, imgPoints] = cv.getBoardObjectAndImagePoints(...
                board, corners, ids);
            validateattributes(objPoints, {'cell'}, ...
                {'vector', 'numel',4*prod([board{2:3}])});
            cellfun(@(c) validateattributes(c, {'numeric'}, ...
                {'vector', 'numel',3}), objPoints);
            validateattributes(imgPoints, {'cell'}, ...
                {'vector', 'numel',4*prod([board{2:3}])});
            cellfun(@(c) validateattributes(c, {'numeric'}, ...
                {'vector', 'numel',2}), imgPoints);
        end

        function test_error_argnum
            try
                cv.getBoardObjectAndImagePoints();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

function [img, board] = get_image_markers()
    % markers in a 5x7 planar board
    board = {'GridBoard', 5, 7, 60, 10, '6x6_50'};
    img = cv.drawPlanarBoard(board, [360 500], 'MarginSize',10);
    img = repmat(img, [1 1 3]);
end
