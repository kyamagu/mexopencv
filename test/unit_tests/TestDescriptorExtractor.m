classdef TestDescriptorExtractor
    %TestDescriptorExtractor

    properties (Constant)
        im = fullfile(mexopencv.root(),'test','tsukuba_l.png');
        extractors = { ...
            ... % features2d (opencv)
            'BRISK', 'ORB', 'KAZE', 'AKAZE', ...
            ... % xfeatures2d (opencv_contrib)
            'SIFT', 'SURF', ...
            'BriefDescriptorExtractor', 'DAISY', 'FREAK', 'LATCH', 'LUCID', ...
            'VGG', 'BoostDesc'
        };
    end

    methods (Static)
        function test_compute_img
            img = cv.imread(TestDescriptorExtractor.im, ...
                'Grayscale',true, 'ReduceScale',2);
            kpts0 = cv.FAST(img, 'Threshold',20);
            for i=1:numel(TestDescriptorExtractor.extractors)
                try
                    obj = cv.DescriptorExtractor(...
                        TestDescriptorExtractor.extractors{i});
                catch ME
                    %TODO: check if opencv_contrib/xfeatures2d is available
                    %error('mexopencv:testskip', 'contrib');
                    continue;
                end
                typename = obj.typeid();
                ntype = obj.defaultNorm();

                % KAZE/AKAZE descriptors only work with their own detectors
                switch TestDescriptorExtractor.extractors{i}
                    case 'KAZE'
                        if ~mexopencv.isOctave()
                            kpts = detect(cv.KAZE(), img);
                        else
                            %HACK: https://savannah.gnu.org/bugs/index.php?54800
                            o = cv.KAZE();
                            kpts = o.detect(img);
                        end
                    case 'AKAZE'
                        if ~mexopencv.isOctave()
                            kpts = detect(cv.AKAZE(), img);
                        else
                            %HACK: https://savannah.gnu.org/bugs/index.php?54800
                            o = cv.AKAZE();
                            kpts = o.detect(img);
                        end
                    otherwise
                        kpts = kpts0;
                end

                % LUCID works on RGB images
                if strcmp(TestDescriptorExtractor.extractors{i}, 'LUCID')
                    im = cv.cvtColor(img, 'GRAY2RGB');
                else
                    im = img;
                end

                [desc, kpts2] = obj.compute(im, kpts);
                validateattributes(kpts2, {'struct'}, {'vector'});
                assert(all(ismember(fieldnames(kpts), fieldnames(kpts2))));
                validateattributes(desc, {obj.descriptorType()}, ...
                    {'size',[numel(kpts2) obj.descriptorSize()]});
            end
        end

        function test_compute_imgset
            img = cv.imread(TestDescriptorExtractor.im, ...
                'Grayscale',true, 'ReduceScale',2);
            kpts0 = cv.FAST(img, 'Threshold',50);
            for i=1:numel(TestDescriptorExtractor.extractors)
                try
                    obj = cv.DescriptorExtractor(...
                        TestDescriptorExtractor.extractors{i});
                catch ME
                    %TODO: check if opencv_contrib/xfeatures2d is available
                    %error('mexopencv:testskip', 'contrib');
                    continue;
                end

                % KAZE/AKAZE descriptors only work with their own detectors
                switch TestDescriptorExtractor.extractors{i}
                    case 'KAZE'
                        if ~mexopencv.isOctave()
                            kpts = detect(cv.KAZE(), img);
                        else
                            %HACK: https://savannah.gnu.org/bugs/index.php?54800
                            o = cv.KAZE();
                            kpts = o.detect(img);
                        end
                    case 'AKAZE'
                        if ~mexopencv.isOctave()
                            kpts = detect(cv.AKAZE(), img);
                        else
                            %HACK: https://savannah.gnu.org/bugs/index.php?54800
                            o = cv.AKAZE();
                            kpts = o.detect(img);
                        end
                    otherwise
                        kpts = kpts0;
                end
                kpts = {kpts, kpts};

                % LUCID works on RGB images
                if strcmp(TestDescriptorExtractor.extractors{i}, 'LUCID')
                    im = cv.cvtColor(img, 'GRAY2RGB');
                else
                    im = img;
                end
                imgs = {im, im};

                [descs, kpts] = obj.compute(imgs, kpts);
                validateattributes(kpts, {'cell'}, {'vector'});
                validateattributes(descs, {'cell'}, ...
                    {'vector', 'numel',numel(imgs)});
                cellfun(@(d,k) validateattributes(d, ...
                    {obj.descriptorType()}, ...
                    {'size',[numel(k) obj.descriptorSize()]}), descs, kpts);
            end
        end
    end

end
