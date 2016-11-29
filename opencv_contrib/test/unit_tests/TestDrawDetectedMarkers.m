classdef TestDrawDetectedMarkers
    %TestDrawDetectedMarkers

    methods (Static)
        function test_1
            [img, d] = get_image_markers();
            [corners, ids, rejected] = cv.detectMarkers(img, d.dict);
            out = cv.drawDetectedMarkers(img, corners, 'IDs',ids);
            if ~isempty(rejected)
                out = cv.drawDetectedMarkers(out, rejected, ...
                    'BorderColor',[255 255 0]);
            end
            validateattributes(out, {class(img)}, {'size',size(img)});
        end

        function test_error_argnum
            try
                cv.drawDetectedMarkers();
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
