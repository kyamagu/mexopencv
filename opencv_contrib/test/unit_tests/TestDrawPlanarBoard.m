classdef TestDrawPlanarBoard
    %TestDrawPlanarBoard

    methods (Static)
        function test_1
            board = {'GridBoard', 5, 7, 60, 10, '6x6_50'};
            imgSz = [5 7]*(60+10) + 10;
            img = cv.drawPlanarBoard(board, imgSz, 'MarginSize',10);
            validateattributes(img, {'uint8'}, {'size',fliplr(imgSz)});
        end

        function test_error_argnum
            try
                cv.drawPlanarBoard();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
