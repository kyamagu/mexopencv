classdef TestRefineDetectedMarkers
    %TestRefineDetectedMarkers

    methods (Static)
        function test_1
            [img, board] = get_image_markers();
            [corners, ids, rejected] = cv.detectMarkers(img, board{end});
            [corners, ids, rejected] = cv.refineDetectedMarkers(...
                img, board, corners, ids, rejected);
            validateattributes(corners, {'cell'}, {'vector'});
            cellfun(@(c) validateattributes(c, {'cell'}, ...
                {'vector', 'numel',4}), corners);
            cellfun(@(c) cellfun(@(p) validateattributes(p, ...
                {'numeric'}, {'vector', 'numel',2}), c), corners);
            validateattributes(ids, {'numeric'}, ...
                {'vector', 'integer', 'nonnegative'});
            assert(isequal(numel(corners),numel(ids)));
            if ~isempty(rejected)
                validateattributes(rejected, {'cell'}, {'vector'});
                cellfun(@(c) validateattributes(c, {'cell'}, ...
                    {'vector', 'numel',4}), rejected);
                cellfun(@(c) cellfun(@(p) validateattributes(p, ...
                    {'numeric'}, {'vector', 'numel',2}), c), rejected);
            end
        end

        function test_error_argnum
            try
                cv.refineDetectedMarkers();
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
