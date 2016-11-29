classdef TestDrawCharucoBoard
    %TestDrawCharucoBoard

    methods (Static)
        function test_1
            board = {5, 7, 60, 40, '6x6_50'};
            imgSz = [5 7]*60 + 2*(60-40);
            img = cv.drawCharucoBoard(board, imgSz, 'MarginSize',60-40);
            validateattributes(img, {'uint8'}, {'size',fliplr(imgSz)});
        end

        function test_error_argnum
            try
                cv.drawCharucoBoard();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
