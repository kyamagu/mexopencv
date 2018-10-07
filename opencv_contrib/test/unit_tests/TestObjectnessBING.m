classdef TestObjectnessBING
    %TestObjectnessBING

    methods (Static)
        function test_1
            saliency = cv.ObjectnessBING();

            resdir = tempname();
            cObj = onCleanup(@() deleteDir(resdir));
            saliency.setTrainingPath(get_training_path());
            saliency.setBBResDir(resdir);

            img = imread(fullfile(mexopencv.root(),'test','balloon.jpg'));
            objectnessBoundingBox = saliency.computeSaliency(img);
            validateattributes(objectnessBoundingBox, {'cell'}, {'vector'});
            cellfun(@(bb) validateattributes(bb, {'numeric'}, ...
                {'vector', 'integer', 'numel',4}), objectnessBoundingBox);

            objectnessValues = saliency.getObjectnessValues();
            validateattributes(objectnessValues, {'numeric'}, ...
                {'vector', 'numel',numel(objectnessBoundingBox)});
        end
    end

end

function deleteDir(fname)
    if isdir(fname)
        if mexopencv.isOctave()
            %HACK: dont ask for confirmation
            confirm_recursive_rmdir(false, 'local');
        end
        rmdir(fname, 's');
    end
end

function training_path = get_training_path()
    training_path = fullfile(mexopencv.root(),'test','ObjectnessTrainedModel');
    if ~isdir(training_path)
        % download trained models from GitHub
        files = {
            'ObjNessB2W8HSV.idx.yml.gz'
            'ObjNessB2W8HSV.wS1.yml.gz'
            'ObjNessB2W8HSV.wS2.yml.gz'
            'ObjNessB2W8I.idx.yml.gz'
            'ObjNessB2W8I.wS1.yml.gz'
            'ObjNessB2W8I.wS2.yml.gz'
            'ObjNessB2W8MAXBGR.idx.yml.gz'
            'ObjNessB2W8MAXBGR.wS1.yml.gz'
            'ObjNessB2W8MAXBGR.wS2.yml.gz'
        };
        mkdir(training_path);
        for i=1:numel(files)
            url = 'https://cdn.rawgit.com/opencv/opencv_contrib/3.2.0/modules/saliency/samples/ObjectnessTrainedModel/';
            urlwrite([url files{i}], fullfile(training_path,files{i}));
        end
    end
end
