%% Saliency algorithms demo
% This example shows the functionality of "Saliency"
%
% <https://github.com/opencv/opencv_contrib/blob/3.1.0/modules/saliency/samples/computeSaliency.cpp>
%

%% Options
% choose Saliency algorithm
alg = 'SpectralResidual';
alg = validatestring(alg, {'SpectralResidual', 'BinWangApr2014', 'BING'});

% path of input video file to read frames from
video_name = fullfile(mexopencv.root(),'test','768x576.avi');
start_frame = 0;  % index of starting frame
if ~exist(video_name, 'file')
    % download video from Github
    disp('Downloading video...')
    url = 'https://cdn.rawgit.com/opencv/opencv/3.1.0/samples/data/768x576.avi';
    urlwrite(url, video_name);
end

% path to trained Objectness model (for BING algorithm)
training_path = fullfile(mexopencv.root(),'test','ObjectnessTrainedModel');
if strcmp(alg, 'BING') && ~exist(training_path, 'dir')
    % download from GitHub
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
    disp('Downloading trained models...');
    mkdir(training_path);
    for i=1:numel(files)
        url = 'https://cdn.rawgit.com/opencv/opencv_contrib/3.1.0/modules/saliency/samples/ObjectnessTrainedModel/';
        urlwrite([url files{i}], fullfile(training_path,files{i}));
    end
end

%% Prepare video source
cap = cv.VideoCapture(video_name);
assert(cap.isOpened(), 'Could not initialize capturing');
cap.PosFrames = start_frame;

frame = cap.read();
assert(~isempty(frame), 'Could not read data from the video source');

%% Instantiate the specified Saliency
switch alg
    case 'SpectralResidual'
        saliency = cv.StaticSaliencySpectralResidual();
    case 'BinWangApr2014'
        saliency = cv.MotionSaliencyBinWangApr2014();
    case 'BING'
        saliency = cv.ObjectnessBING();
    otherwise
        error('Unrecognized saliency algorithm');
end
disp(saliency)
fprintf('className = %s\n', saliency.getClassName());

%% Compute saliency
switch alg
    case 'SpectralResidual'
        % compute
        tic, saliencyMap = saliency.computeSaliency(frame); toc
        tic, binaryMap = saliency.computeBinaryMap(saliencyMap); toc
        binaryMap = logical(binaryMap ~= 0);

        % show
        subplot(221), imshow(saliencyMap), title('Saliency Map')
        subplot(222), imshow(frame), title('Original Image')
        subplot(223), imshow(binaryMap), title('Binary Map')

    case 'BinWangApr2014'
        % initialize
        sz = size(frame);
        saliency.setImagesize(sz(2), sz(1));
        saliency.init();

        % prepare plots
        subplot(121); hImg(1) = imshow(zeros(sz(1:2),'uint8')); title('img')
        subplot(122); hImg(2) = imshow(zeros(sz(1:2),'single')); title('saliencyMap')

        % loop over frames
        while all(ishghandle(hImg))
            % read frame
            frame = cap.read();
            if isempty(frame), break; end
            set(hImg(1), 'CData',frame)

            % compute motion saliency of current frame
            fprintf('frame #%3d: ', cap.PosFrames);
            frame = cv.cvtColor(frame, 'RGB2GRAY');
            tic, saliencyMap = saliency.computeSaliency(frame); toc

            % show
            %NOTE: for the first dozen frames, saliency is all 1.0
            set(hImg(2), 'CData',saliencyMap)
            drawnow
        end

    case 'BING'
        % initialize
        assert(~isempty(training_path), 'Path of trained files missing');
        saliency.setTrainingPath(training_path);
        saliency.setBBResDir(fullfile(tempdir(),'Results'));

        % compute
        tic
        objectnessBoundingBox = saliency.computeSaliency(frame);
        objectnessValues = saliency.getObjectnessValues();
        toc
        disp('Objectness done');
        dir(fullfile(tempdir(),'Results'))

        %TODO: poor bounding boxes, are they ordered correctly?
        %{
        % sort by values
        [objectnessValues, idx] = sort(objectnessValues, 'descend');
        objectnessBoundingBox = objectnessBoundingBox(idx);
        % keep best K
        num = 10;
        objectnessValues(num+1:end) = [];
        objectnessBoundingBox(num+1:end) = [];
        %}

        % plot bounding boxes around possible objects
        for i=1:min(10, numel(objectnessBoundingBox))
            clr = randi(255, [1 3]);
            bb = objectnessBoundingBox{i};
            val = objectnessValues(i);
            frame = cv.rectangle(frame, bb(1:2), bb(3:4), 'Color',clr);
            frame = cv.putText(frame, num2str(val), bb(1:2)-[0 2], ...
                'Color',clr, 'FontScale',0.5);
        end
        imshow(frame), title('Objectness')
end

%%
% release video source
cap.release();
