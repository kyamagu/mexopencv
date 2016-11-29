classdef TestInterpolateCornersCharuco
    %TestInterpolateCornersCharuco

    methods (Static)
        function test_1
            [img, board] = get_image_markers();
            [corners, ids] = cv.detectMarkers(img, board{end});
            [charucoCorners, charucoIds, num] = cv.interpolateCornersCharuco(...
                corners, ids, img, board);
            validateattributes(charucoCorners, {'cell'}, {'vector'});
            cellfun(@(c) validateattributes(c, {'numeric'}, ...
                {'vector', 'numel',2}), charucoCorners);
            validateattributes(charucoIds, {'numeric'}, ...
                {'vector', 'integer', 'nonnegative'});
            assert(isequal(numel(charucoCorners),numel(charucoIds)));
            validateattributes(num, {'numeric'}, ...
                {'scalar', 'integer', 'nonnegative'});
            assert(isequal(num,numel(charucoIds)));
        end

        function test_error_argnum
            try
                cv.interpolateCornersCharuco();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

function [img, board] = get_image_markers()
    % markers in a 5x7 charuco board
    board = {5, 7, 60, 40, '6x6_50'};
    img = cv.drawCharucoBoard(board, [340 460], 'MarginSize',20);
    img = repmat(img, [1 1 3]);
end
