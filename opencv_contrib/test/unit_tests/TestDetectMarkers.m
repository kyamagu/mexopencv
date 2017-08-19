classdef TestDetectMarkers
    %TestDetectMarkers

    methods (Static)
        function test_1
            [img, d] = get_image_markers();
            params = struct('cornerRefinementMethod','None');
            [corners, ids, rejected] = cv.detectMarkers(img, d.dict, ...
                'DetectorParameters',params);
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
                cv.detectMarkers();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

function [img, d] = get_image_markers()
    % 2 separate markers
    d = struct();
    d.dict = '6x6_50';
    d.ids = randi([0 49], [1 2]);
    d.mlen = 100;
    img = 255 * ones(300, 'uint8');
    img(11:110,11:110) = cv.drawMarkerAruco(d.dict, d.ids(1), d.mlen);
    img(151:250,151:250) = cv.drawMarkerAruco(d.dict, d.ids(2), d.mlen);
    img = repmat(img, [1 1 3]);
end
