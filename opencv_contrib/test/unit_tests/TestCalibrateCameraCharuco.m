classdef TestCalibrateCameraCharuco
    %TestCalibrateCameraCharuco

    methods (Static)
        function test_1
            %TODO: we need some charuco calibration images: charuco%d.jpg
            % (or create synthetic images of board in different perspectives)
            if true
                error('mexopencv:testskip', 'todo');
            end
            N = 4;
            corners = cell(1,N);
            ids = cell(1,N);
            for i=1:N
                [corners{i}, ids{i}, imgSize, board] = get_markers(i);
            end
            [camMatrix, distCoeffs, err, rvecs, tvecs] = ...
                cv.calibrateCameraCharuco(corners, ids, board, imgSize);
            validateattributes(camMatrix, {'numeric'}, {'size',[3 3]});
            validateattributes(distCoeffs, {'numeric'}, {'vector', 'numel',5});
            validateattributes(err, {'numeric'}, {'scalar'});
            validateattributes(rvecs, {'cell'}, {'vector', 'numel',N});
            cellfun(@(v) validateattributes(v, {'numeric'}, ...
                {'vector', 'numel',3}), rvecs);
            validateattributes(tvecs, {'cell'}, {'vector', 'numel',N});
            cellfun(@(v) validateattributes(v, {'numeric'}, ...
                {'vector', 'numel',3}), tvecs);
        end

        function test_error_argnum
            try
                cv.calibrateCameraCharuco();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end

function [cornersCH, idsCH, imgSize, board] = get_markers(i)
    % get markers from i-th calibration image
    % (same charuco board viewed from different angles)
    img = imread(fullfile(mexopencv.root(),'test',sprintf('charuco%d.jpg',i)));
    imgSize = [size(img,2) size(img,1)];
    board = {5, 7, 60, 40, '6x6_50'};
    [corners, ids, rejected] = cv.detectMarkers(img, board{end});
    [corners, ids, rejected] = cv.refineDetectedMarkers(img, ...
        ['CharucoBoard' board], corners, ids, rejected);
    [cornersCH, idsCH] = cv.interpolateCornersCharuco(corners, ids, img, board);
end
