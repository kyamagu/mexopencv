classdef TestDrawDetectedDiamonds
    %TestDrawDetectedDiamonds

    methods (Static)
        function test_1
            [img, diamond] = get_image_markers();
            [corners, ids] = cv.detectMarkers(img, diamond.dict);
            [diamondCorners, diamondIds] = cv.detectCharucoDiamond(img, ...
                corners, ids, diamond.slen / diamond.mlen);
            out = cv.drawDetectedDiamonds(img, diamondCorners, ...
                'IDs',diamondIds, 'BorderColor',[0 0 255]);
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_error_argnum
            try
                cv.drawDetectedDiamonds();
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
