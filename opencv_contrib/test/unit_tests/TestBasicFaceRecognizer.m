classdef TestBasicFaceRecognizer
    %TestBasicFaceRecognizer

    methods (Static)
        function test_1
            % load some images/labels
            [images,labels,img] = loadData();
            N = numel(images);
            sz = prod(size(img));

            recognizers = {'Eigenfaces', 'Fisherfaces'};
            for i=1:numel(recognizers)
                % create
                model = cv.BasicFaceRecognizer(recognizers{i}, ...
                    'NumComponents',0, 'Threshold',realmax);
                validateattributes(model.NumComponents, ...
                    {'numeric'}, {'scalar', 'integer'});
                validateattributes(model.Threshold, ...
                    {'numeric'}, {'scalar', 'real'});
                validateattributes(model.typeid(), ...
                    {'char'}, {'row', 'nonempty'});

                % train
                model.train(images, labels);

                % predict
                [lbl,dist] = model.predict(img);
                validateattributes(lbl, {'numeric'}, {'scalar', 'integer'});
                assert(ismember(lbl, unique(labels(:))));
                validateattributes(dist, {'numeric'}, {'scalar', 'real'});

                results = model.predict_collect(img);
                validateattributes(results, {'struct'}, {'vector', 'numel',N});
                validateattributes([results.label], {'numeric'}, ...
                    {'vector', 'integer', 'numel',N});
                validateattributes([results.distance], {'numeric'}, ...
                    {'vector', 'real', 'numel',N});

                % model data
                lbl = model.getLabels();
                validateattributes(lbl, {'numeric'}, ...
                    {'vector', 'integer', 'numel',N});
                assert(isequal(lbl, labels));

                M = model.getMean();
                validateattributes(M, {'numeric'}, {'vector', 'numel',sz});

                EV = model.getEigenValues();
                validateattributes(EV, {'numeric'}, ...
                    {'numel',model.NumComponents});

                W = model.getEigenVectors();
                validateattributes(W, {'numeric'}, ...
                    {'size',[sz model.NumComponents]});

                Y = model.getProjections();
                validateattributes(Y, {'cell'}, {'numel',N});
                cellfun(@(P) validateattributes(P, {'numeric'}, ...
                    {'vector', 'numel',model.NumComponents}), Y);
            end
        end

        function test_save_load
            [images, labels] = loadData();
            model = cv.BasicFaceRecognizer('Eigenfaces');
            model.train(images, labels);

            filename = [tempname() '.xml'];
            cObj = onCleanup(@() deleteFile(filename));
            model.save(filename);
            assert(exist(filename,'file')==2);

            %HACK: OpenCV bug: on load, model does not get properly cleared first!
            % (specificly the projections are appended)
            % so load should only be called on a newly created model,
            % not an existing instance that was already trained.
            model2 = cv.BasicFaceRecognizer('Eigenfaces');
            model2.load(filename);
        end

        function test_labels_info
            model = cv.BasicFaceRecognizer('Eigenfaces');
            model.setLabelInfo(1, 'person1');
            model.setLabelInfo(2, 'person2');
            validateattributes(model.getLabelInfo(1), ...
                {'char'}, {'row', 'nonempty'});
            assert(isequal(model.getLabelInfo(1), 'person1'));
            assert(isempty(model.getLabelInfo(999)));
            validateattributes(model.getLabelsByString('person'), ...
                {'numeric'}, {'vector', 'integer'});
        end
    end

end

function deleteFile(fname)
    if exist(fname, 'file') == 2
        delete(fname);
    end
end

function [images,labels,testImg] = loadData()
    % train
    filesL = cv.glob(fullfile(mexopencv.root(),'test','left1*.jpg'), 'Recursive',false);
    filesR = cv.glob(fullfile(mexopencv.root(),'test','right1*.jpg'), 'Recursive',false);
    files = [filesL(:); filesR(:)];
    images = cell(size(files));
    for i=1:numel(files)
        images{i} = cv.imread(files{i}, 'Grayscale',true, 'ReduceScale',4);
    end
    % test
    labels = [1*ones(numel(filesL),1); 2*ones(numel(filesR),1)];
    testImg = cv.imread(fullfile(mexopencv.root(),'test','left01.jpg'), ...
        'Grayscale',true, 'ReduceScale',4);
end
