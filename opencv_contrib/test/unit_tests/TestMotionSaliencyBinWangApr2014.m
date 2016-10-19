classdef TestMotionSaliencyBinWangApr2014
    %TestMotionSaliencyBinWangApr2014

    methods (Static)
        function test_1
            cap = cv.VideoCapture(get_pedestrian_video());
            assert(cap.isOpened());
            img = cap.read();
            assert(~isempty(img));

            saliency = cv.MotionSaliencyBinWangApr2014();
            saliency.setImagesize(size(img,2), size(img,1));
            saliency.init();
            assert(isequal(saliency.ImageWidth, size(img,2)));
            assert(isequal(saliency.ImageHeight, size(img,1)));

            cname = saliency.getClassName();
            validateattributes(cname, {'char'}, {'vector', 'nonempty'});

            for i=1:min(10,cap.FrameCount)
                img = cap.read();
                img = cv.cvtColor(img, 'RGB2GRAY');

                saliencyMap = saliency.computeSaliency(img);
                validateattributes(saliencyMap, {'single'}, ...
                    {'size',[size(img,1) size(img,2)], 'binary'});
            end
        end
    end

end

function fname = get_pedestrian_video()
    fname = fullfile(mexopencv.root(),'test','768x576.avi');
    if ~exist(fname, 'file')
        % download video from Github
        url = 'https://cdn.rawgit.com/opencv/opencv/3.1.0/samples/data/768x576.avi';
        disp('Downloading video...')
        urlwrite(url, fname);
    end
end
