classdef TestBoardDump
    %TestBoardDump

    methods (Static)
        function test_board_grid
            board = {'GridBoard', 5, 7, 60, 10, '6x6_50'};
            b = cv.boardDump(board);
            validateattributes(b, {'struct'}, {'scalar'});
            validateattributes(b.objPoints, {'cell'}, ...
                {'vector', 'numel',prod([board{2:3}])});
            cellfun(@(c) validateattributes(c, {'cell'}, ...
                {'vector', 'numel',4}), b.objPoints);
            cellfun(@(c) cellfun(@(p) validateattributes(p, ...
                {'numeric'}, {'vector', 'numel',3}), c), b.objPoints);
            validateattributes(b.dictionary, {'struct'}, {'scalar'});
            assert(isequal(b.dictionary.markerSize, str2double(board{end}(1))));
            validateattributes(b.ids, {'numeric'}, {'vector', 'integer', ...
                'nonnegative', 'numel',prod([board{2:3}])});
            assert(isequal(b.gridSize, [board{2:3}]));
            assert(isequal(b.markerLength, board{4}));
            assert(isequal(b.markerSeparation, board{5}));
        end

        function test_board_charuco
            board = {'CharucoBoard', 5, 7, 60, 40, '6x6_50'};
            b = cv.boardDump(board);
            validateattributes(b, {'struct'}, {'scalar'});
            validateattributes(b.objPoints, {'cell'}, {'vector'});
            cellfun(@(c) validateattributes(c, {'cell'}, ...
                {'vector', 'numel',4}), b.objPoints);
            cellfun(@(c) cellfun(@(p) validateattributes(p, ...
                {'numeric'}, {'vector', 'numel',3}), c), b.objPoints);
            validateattributes(b.dictionary, {'struct'}, {'scalar'});
            assert(isequal(b.dictionary.markerSize, str2double(board{end}(1))));
            validateattributes(b.ids, {'numeric'}, ...
                {'vector', 'integer', 'nonnegative'});
            assert(isequal(numel(b.objPoints), numel(b.ids), ...
                fix(prod([board{2:3}])/2)));
            assert(isequal(b.chessboardSize, [board{2:3}]));
            assert(isequal(b.squareLength, board{4}));
            assert(isequal(b.markerLength, board{5}));
            validateattributes(b.chessboardCorners, {'cell'}, {'vector'});
            cellfun(@(c) validateattributes(c, {'numeric'}, ...
                {'vector', 'numel',3}), b.chessboardCorners);
            validateattributes(b.nearestMarkerIdx, {'cell'}, {'vector'});
            cellfun(@(c) validateattributes(c, {'numeric'}, ...
                {'vector', 'integer', 'numel',2}), b.nearestMarkerIdx);
            validateattributes(b.nearestMarkerCorners, {'cell'}, {'vector'});
            cellfun(@(c) validateattributes(c, {'numeric'}, ...
                {'vector', 'integer', 'numel',2}), b.nearestMarkerCorners);
            assert(isequal(numel(b.nearestMarkerCorners), ...
                numel(b.nearestMarkerCorners), (board{2}-1)*(board{3}-1)));
        end

        function test_board
            board = {'GridBoard', 5, 7, 60, 10, '6x6_50'};
            b = cv.boardDump(board);
            bb = cv.boardDump({'Board', b.objPoints, b.dictionary, b.ids});
            assert(isequal(b.objPoints, bb.objPoints));
            assert(isequal(b.dictionary, bb.dictionary));
            assert(isequal(b.ids, bb.ids));
        end

        function test_board_struct
            board = {'GridBoard', 5, 7, 60, 10, '6x6_50'};
            b1 = cv.boardDump(board);
            b1 = rmfield(b1, {'gridSize', 'markerLength', 'markerSeparation'});
            b2 = cv.boardDump(b1);
            assert(isequal(b1, b2));
        end

        function test_error_argnum
            try
                cv.boardDump();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
