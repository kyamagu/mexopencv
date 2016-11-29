classdef TestEstimatePoseSingleMarkers
    %TestEstimatePoseSingleMarkers

    methods (Static)
        function test_1
            [img, d] = get_image_markers();
            corners = cv.detectMarkers(img, d.dict);
            camMatrix = eye(3);
            distCoeffs = zeros(1,5);
            [rvecs, tvecs] = cv.estimatePoseSingleMarkers(corners, ...
                d.mlen, camMatrix, distCoeffs);
            validateattributes(rvecs, {'cell'}, {'vector'});
            cellfun(@(v) validateattributes(v, {'numeric'}, ...
                {'vector', 'numel',3}), rvecs);
            validateattributes(tvecs, {'cell'}, {'vector'});
            cellfun(@(v) validateattributes(v, {'numeric'}, ...
                {'vector', 'numel',3}), tvecs);
            assert(isequal(numel(rvecs),numel(tvecs)));
        end

        function test_error_argnum
            try
                cv.estimatePoseSingleMarkers();
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
