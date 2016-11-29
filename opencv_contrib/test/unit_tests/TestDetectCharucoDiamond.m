classdef TestDetectCharucoDiamond
    %TestDetectCharucoDiamond

    methods (Static)
        function test_1
            [img, diamond] = get_image_markers();
            [corners, ids] = cv.detectMarkers(img, diamond.dict);
            [diamondCorners, diamondIds] = cv.detectCharucoDiamond(img, ...
                corners, ids, diamond.slen / diamond.mlen);
            validateattributes(diamondCorners, {'cell'}, {'vector'});
            cellfun(@(c) validateattributes(c, {'cell'}, ...
                {'vector', 'numel',4}), diamondCorners);
            cellfun(@(c) cellfun(@(p) validateattributes(p, ...
                {'numeric'}, {'vector', 'numel',2}), c), diamondCorners);
            validateattributes(diamondIds, {'cell'}, {'vector'});
            cellfun(@(d) validateattributes(d, {'numeric'}, ...
                {'vector', 'numel',4, 'integer', 'nonnegative'}), diamondIds);
            assert(isequal(numel(diamondCorners),numel(diamondIds)));
        end

        function test_error_argnum
            try
                cv.detectCharucoDiamond();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

function [img, d] = get_image_markers()
    % 4 markers in a diamond
    d = struct();
    d.dict = '6x6_50';
    d.ids = randi([0 49], [1 4]);
    d.slen = 80;
    d.mlen = 50;
    img = cv.drawCharucoDiamond(d.dict, d.ids, d.slen, d.mlen);
    img = repmat(img, [1 1 3]);
end
