classdef TestEstimatePoseBoard
    %TestEstimatePoseBoard

    methods (Static)
        function test_1
            [img, board] = get_image_markers();
            [corners, ids] = cv.detectMarkers(img, board{end});
            camMatrix = eye(3);
            distCoeffs = zeros(1,5);
            [rvec, tvec, num] = cv.estimatePoseBoard(corners, ids, ...
                board, camMatrix, distCoeffs);
            validateattributes(rvec, {'numeric'}, {'vector', 'numel',3});
            validateattributes(tvec, {'numeric'}, {'vector', 'numel',3});
            validateattributes(num, {'numeric'}, ...
                {'scalar', 'integer', 'nonnegative'});
        end

        function test_error_argnum
            try
                cv.estimatePoseBoard();
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
