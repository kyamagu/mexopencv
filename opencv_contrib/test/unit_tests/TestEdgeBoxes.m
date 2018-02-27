classdef TestEdgeBoxes
    %TestEdgeBoxes

    methods (Static)
        function test_1
            [E,O] = get_inputs();
            obj = cv.EdgeBoxes('MaxBoxes',30);
            obj.MaxBoxes = 30;
            boxes = obj.getBoundingBoxes(E, O);
            validateattributes(boxes, {'cell'}, {'vector'});
            cellfun(@(r) validateattributes(r, {'numeric'}, ...
                {'vector', 'numel',4}), boxes);
        end
    end

end

function [E,O] = get_inputs()
    img = imread(fullfile(mexopencv.root(),'test','balloon.jpg'));
    img = single(img) / 255;

    pDollar = cv.StructuredEdgeDetection(get_model_file());
    E = pDollar.detectEdges(img);
    O = pDollar.computeOrientation(E);
    E = pDollar.edgesNms(E, O);
end

function fname = get_model_file()
    fname = fullfile(mexopencv.root(),'test','model.yml.gz');
    if exist(fname, 'file') ~= 2
        % download model from GitHub
        url = 'https://cdn.rawgit.com/opencv/opencv_extra/3.2.0/testdata/cv/ximgproc/model.yml.gz';
        urlwrite(url, fname);
    end
end
