classdef TestEstimatePoseCharucoBoard
    %TestEstimatePoseCharucoBoard

    methods (Static)
        function test_1
            [img, board] = get_image_markers();
            [corners, ids] = cv.detectMarkers(img, board{end});
            [charucoCorners, charucoIds] = cv.interpolateCornersCharuco(...
                corners, ids, img, board);
            camMatrix = eye(3);
            distCoeffs = zeros(1,5);
            [rvec, tvec, valid] = cv.estimatePoseCharucoBoard(...
                charucoCorners, charucoIds, board, camMatrix, distCoeffs);
            validateattributes(rvec, {'numeric'}, {'vector', 'numel',3});
            validateattributes(tvec, {'numeric'}, {'vector', 'numel',3});
            validateattributes(valid, {'logical'}, {'scalar'});
        end

        function test_error_argnum
            try
                cv.estimatePoseCharucoBoard();
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
