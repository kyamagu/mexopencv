classdef DPMDetector < handle
    %DPMDETECTOR  Deformable Part-based Models (DPM) detector
    %
    % ## Discriminatively Trained Part Based Models for Object Detection
    %
    % The object detector described below has been initially proposed by
    % P.F. Felzenszwalb in [Felzenszwalb2010a]. It is based on a
    % Dalal-Triggs detector that uses a single filter on histogram of
    % oriented gradients (HOG) features to represent an object category.
    % This detector uses a sliding window approach, where a filter is
    % applied at all positions and scales of an image.
    %
    % The first innovation is enriching the Dalal-Triggs model using a
    % star-structured part-based model defined by a "root" filter (analogous
    % to the Dalal-Triggs filter) plus a set of parts filters and associated
    % deformation models. The score of one of star models at a particular
    % position and scale within an image is the score of the root filter at
    % the given location plus the sum over parts of the maximum, over
    % placements of that part, of the part filter score on its location
    % minus a deformation cost easuring the deviation of the part from its
    % ideal location relative to the root. Both root and part filter scores
    % are defined by the dot product between a filter (a set of weights)
    % and a subwindow of a feature pyramid computed from the input image.
    %
    % Another improvement is a representation of the class of models by a
    % mixture of star models. The score of a mixture model at a particular
    % position and scale is the maximum over components, of the score of
    % that component model at the given location.
    %
    % The detector was dramatically speeded-up with cascade algorithm proposed
    % by P.F. Felzenszwalb in [Felzenszwalb2010b]. The algorithm prunes
    % partial hypotheses using thresholds on their scores. The basic idea of
    % the algorithm is to use a hierarchy of models defined by an ordering of
    % the original model's parts. For a model with (n+1) parts, including the
    % root, a sequence of (n+1) models is obtained. The i-th model in this
    % sequence is defined by the first i parts from the original model. Using
    % this hierarchy, low scoring hypotheses can be pruned after looking at
    % the best configuration of a subset of the parts. Hypotheses that score
    % high under a weak model are evaluated further using a richer model.
    %
    % ## Example
    % The basic usage is the following:
    %
    %     img = imread(fullfile(mexopencv.root(),'test','cat.jpg'));
    %     detector = cv.DPMDetector(fullfile(mexopencv.root(),'test','cat.xml'));
    %     detections = detector.detect(img);
    %     for i=1:numel(detections)
    %         img = cv.rectangle(img, detections(i).rect, 'Color',[0 255 0]);
    %     end
    %     imshow(img)
    %
    % The detector can also accept multiple models as cell array of strings:
    %
    %     detector = cv.DPMDetector({'cat.xml','car.xml'});
    %
    % The XML file must be a format compatible to OpenCV's DPM detector, but
    % you can convert models from the original implementation in
    % [Felzenszwalb2010a] using cv.DPMDetector.mat2opencvxml method.
    %
    % You can find examples of pre-trained models here:
    % [DPM](https://github.com/opencv/opencv_extra/tree/3.2.0/testdata/cv/dpm/VOC2007_Cascade/)
    %
    % ## References
    % [Felzenszwalb2010a]:
    % > P. Felzenszwalb, R. Girshick, D. McAllester, D. Ramanan
    % > "Object Detection with Discriminatively Trained Part Based Models".
    % > IEEE Transactions on Pattern Analysis and Machine Intelligence,
    % > Vol. 32, No. 9, pages 1627-1645, Sep. 2010.
    % > [PDF](http://www.cs.berkeley.edu/~rbg/papers/Object-Detection-with-Discriminatively-Trained-Part-Based-Models--Felzenszwalb-Girshick-McAllester-Ramanan.pdf)
    %
    % [Felzenszwalb2010b]:
    % > Pedro F. Felzenszwalb, Ross B. Girshick, and David McAllester.
    % > "Cascade Object Detection with Deformable Part Models".
    % > IEEE Conference on Computer Vision and Pattern Recognition (CVPR),
    % > 2010, pages 2241-2248.
    % > [PDF](http://www.cs.berkeley.edu/~rbg/papers/Cascade-Object-Detection-with-Deformable-Part-Models--Felzenszwalb-Girshick-McAllester.pdf)
    %
    % See also: cv.DPMDetector.DPMDetector, cv.DPMDetector.detect
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    methods
        function this = DPMDetector(filenames, varargin)
            %DPMDETECTOR  Load and create a new detector
            %
            %     detector = cv.DPMDetector(filenames)
            %     detector = cv.DPMDetector(filenames, classnames)
            %
            % ## Input
            % * __filenames__ A set of filenames storing the trained detectors
            %   (models). Each file contains one model.
            % * __classnames__ (optional) A set of trained models names. If
            %   it's empty then the name of each model will be constructed
            %   from the name of file containing the model. E.g. the model
            %   stored in "/home/user/cat.xml" will get the name "cat".
            %
            % Load the trained models from given .xml files and return a new
            % DPMDetector detector.
            %
            % `filenames` is a string or a cell array of strings specifying
            % the location of model files. Optionally the method takes class
            % names as a cell array of strings that has the same size to
            % filenames. By default, `classnames` are set to the name of the
            % file without xml extension.
            %
            % See also: cv.DPMDetector, cv.DPMDetector.detect,
            %  cv.DPMDetector.mat2opencvxml
            %
            this.id = DPMDetector_(0, 'new', filenames, varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     detector.delete()
            %
            % See also: cv.DPMDetector
            %
            if isempty(this.id), return; end
            DPMDetector_(this.id, 'delete');
        end

        function status = isEmpty(this)
            %ISEMPTY  Check if the detector is empty
            %
            %     status = detector.isEmpty()
            %
            % ## Output
            % * __status__ boolean
            %
            % See also: cv.DPMDetector.DPMDetector
            %
            status = DPMDetector_(this.id, 'isEmpty');
        end

        function names = getClassNames(this)
            %GETCLASSNAMES  Get names of the object classes
            %
            %     names = detector.getClassNames()
            %
            % ## Output
            % * __names__ a cell array of strings.
            %
            % Return the class (model) `names` that were passed in constructor
            % or extracted from models filenames in those methods.
            %
            % See also: cv.DPMDetector.getClassCount
            %
            names = DPMDetector_(this.id, 'getClassNames');
        end

        function count = getClassCount(this)
            %GETCLASSCOUNT  Return a count of loaded models (classes)
            %
            %     count = detector.getClassCount()
            %
            % ## Output
            % * __count__ a numeric value.
            %
            % See also: cv.DPMDetector.getClassNames
            %
            count = DPMDetector_(this.id, 'getClassCount');
        end

        function objects = detect(this, img)
            %DETECT  Detects objects
            %
            %     objects = detector.detect(img)
            %
            % ## Input
            % * __img__ An image where objects are to be detected
            %   (8-bit integer or 64-bit floating-point color image).
            %
            % ## Output
            % * __objects__ The detections. A struct array of detected objects
            %   with the following fields:
            %   * __rect__ rectangle `[x,y,w,h]` of the object
            %   * __score__ score of the detection
            %   * __class__ name of the object class
            %
            % Find rectangular regions in the given image that are likely to
            % contain objects of loaded classes (models) and corresponding
            % confidence levels.
            %
            % See also: cv.DPMDetector.DPMDetector
            %
            objects = DPMDetector_(this.id, 'detect', img);
        end
    end

    methods (Static)
        function mat2opencvxml(matpath, xmlpath)
            %MAT2OPENCVXML  Convert DPM 2007 model (MAT) to cascade model (XML)
            %
            %     cv.DPMDetector.mat2opencvxml(matpath, xmlpath)
            %
            % ## Input
            % * __matpath__ input MAT filename, path to the DPM VOC 2007
            %   model.
            % * __xmlpath__ output XML filename, path to the OpenCV file
            %   storage model.
            %
            % The method converts [Felzenszwalb2010] model files to xml
            % format specified by OpenCV's implementation. The usage is the
            % following:
            %
            %     matpath = 'VOC2007/cat_final.mat';
            %     xmlpath = 'cat.xml';
            %     cv.DPMDetector.mat2opencvxml(matpath, xmlpath);
            %
            % Check the latest models in:
            %
            % * [Brown](http://www.cs.brown.edu/~pff/latent/)
            % * [Berkeley](http://www.cs.berkeley.edu/~rbg/latent/index.html)
            % * [GitHub](https://github.com/rbgirshick/voc-dpm)
            %
            % This `mat2opencvxml` utility is taken from:
            % [mat2opencvxml.m](https://github.com/opencv/opencv_extra/blob/3.2.0/testdata/cv/dpm/mat2opencvxml.m)
            %
            % See also: cv.DPMDetector
            %

            % load VOC2007 DPM model
            load(matpath);
            thresh = -0.5;
            pca = 5;
            csc_model = cascade_model(model, '2007', pca, thresh);

            num_feat = 32;
            rootfilters = cell(1,length(csc_model.rootfilters));
            for i = 1:length(csc_model.rootfilters)
                rootfilters{i} = csc_model.rootfilters{i}.w;
            end
            partfilters = cell(1,length(csc_model.partfilters));
            for i = 1:length(csc_model.partfilters)
                partfilters{i} = csc_model.partfilters{i}.w;
            end
            [ridx, oidx, root, root_pca, offset, loc, rsize, numparts] = ...
                deal(cell(1,csc_model.numcomponents));
            [pidx, didx, part, part_pca, psize] = ...
                deal(cell(csc_model.numcomponents,length(csc_model.components{1}.parts)));
            for c = 1:csc_model.numcomponents
                ridx{c} = csc_model.components{c}.rootindex;
                oidx{c} = csc_model.components{c}.offsetindex;
                root{c} = csc_model.rootfilters{ridx{c}}.w;
                root_pca{c} = csc_model.rootfilters{ridx{c}}.wpca;
                offset{c} = csc_model.offsets{oidx{c}}.w;
                loc{c} = csc_model.loc{c}.w;
                rsize{c} = [size(root{c},1) size(root{c},2)];
                numparts{c} = length(csc_model.components{c}.parts);
                for j = 1:numparts{c}
                    pidx{c,j} = csc_model.components{c}.parts{j}.partindex;
                    didx{c,j} = csc_model.components{c}.parts{j}.defindex;
                    part{c,j} = csc_model.partfilters{pidx{c,j}}.w;
                    part_pca{c,j} = csc_model.partfilters{pidx{c,j}}.wpca;
                    psize{c,j} = [size(part{c,j},1) size(part{c,j},2)];
                    % reverse map from partfilter index to (component, part#)
                    %rpidx{pidx{c,j}} = [c j];
                end
            end

            maxsizex = ceil(csc_model.maxsize(2));
            maxsizey = ceil(csc_model.maxsize(1));

            pca_rows = size(csc_model.pca_coeff, 1);
            pca_cols = size(csc_model.pca_coeff, 2);

            f = fopen(xmlpath, 'wb');
            fprintf(f, '<?xml version="1.0"?>\n');
            fprintf(f, '<opencv_storage>\n');
            fprintf(f, '<SBin>%d</SBin>\n', csc_model.sbin);
            fprintf(f, '<NumComponents>%d</NumComponents>\n', csc_model.numcomponents);
            fprintf(f, '<NumFeatures>%d</NumFeatures>\n', num_feat);
            fprintf(f, '<Interval>%d</Interval>\n', csc_model.interval);
            fprintf(f, '<MaxSizeX>%d</MaxSizeX>\n', maxsizex);
            fprintf(f, '<MaxSizeY>%d</MaxSizeY>\n', maxsizey);

            % the pca coeff
            fprintf(f, '<PCAcoeff type_id="opencv-matrix">\n');
            fprintf(f,  '\t<rows>%d</rows>\n', pca_rows);
            fprintf(f,  '\t<cols>%d</cols>\n', pca_cols);
            fprintf(f,  '\t<dt>d</dt>\n');
            fprintf(f,  '\t<data>\n');
            for i=1:pca_rows
                fprintf(f,  '\t');
                for j=1:pca_cols
                    fprintf(f,  '%f ', csc_model.pca_coeff(i, j));
                end
                fprintf(f,  '\n');
            end
            fprintf(f,  '\t</data>\n');
            fprintf(f, '</PCAcoeff>\n');
            fprintf(f, '<PCADim>%d</PCADim>\n', pca_cols);
            fprintf(f, '<ScoreThreshold>%.16f</ScoreThreshold>\n', csc_model.thresh);

            fprintf(f, '<Bias>\n');
            for c = 1:csc_model.numcomponents
                fprintf(f,  '%f ', offset{c});
            end
            fprintf(f, '\n</Bias>\n');

            fprintf(f, '<RootFilters>\n');
            for c = 1:csc_model.numcomponents
                rootfilter = root{c};
                rows = size(rootfilter,1);
                cols = size(rootfilter,2);
                depth = size(rootfilter,3);
                fprintf(f, '\t<_ type_id="opencv-matrix">\n');
                fprintf(f,  '\t<rows>%d</rows>\n', rows);
                fprintf(f,  '\t<cols>%d</cols>\n', cols*depth);
                fprintf(f,  '\t<dt>d</dt>\n');
                fprintf(f,  '\t<data>\n');
                for i=1:rows
                    fprintf(f,  '\t');
                    for j=1:cols
                        for k=1:depth
                            fprintf(f,  '%f ', rootfilter(i, j, k));
                        end
                    end
                    fprintf(f,  '\n');
                end
                fprintf(f,  '\t</data>\n');
                fprintf(f, '\t</_>\n');
            end
            fprintf(f, '</RootFilters>\n');

            fprintf(f, '<RootPCAFilters>\n');
            for c = 1:csc_model.numcomponents
                rootfilter_pca = root_pca{c};
                rows = size(rootfilter_pca,1);
                cols = size(rootfilter_pca,2);
                depth = size(rootfilter_pca,3);
                fprintf(f, '\t<_ type_id="opencv-matrix">\n');
                fprintf(f,  '\t<rows>%d</rows>\n', rows);
                fprintf(f,  '\t<cols>%d</cols>\n', cols*depth);
                fprintf(f,  '\t<dt>d</dt>\n');
                fprintf(f,  '\t<data>\n');
                for i=1:rows
                    fprintf(f,  '\t');
                    for j=1:cols
                        for k=1:depth
                            fprintf(f,  '%f ', rootfilter_pca(i, j, k));
                        end
                    end
                    fprintf(f,  '\n');
                end
                fprintf(f,  '\t</data>\n');
                fprintf(f, '\t</_>\n');
            end
            fprintf(f, '</RootPCAFilters>\n');

            fprintf(f, '<PartFilters>\n');
            for c = 1:csc_model.numcomponents
                for p=1:numparts{c}
                    partfilter = part{c,p};
                    rows = size(partfilter,1);
                    cols = size(partfilter,2);
                    depth = size(partfilter,3);
                    fprintf(f, '\t<_ type_id="opencv-matrix">\n');
                    fprintf(f,  '\t<rows>%d</rows>\n', rows);
                    fprintf(f,  '\t<cols>%d</cols>\n', cols*depth);
                    fprintf(f,  '\t<dt>d</dt>\n');
                    fprintf(f,  '\t<data>\n');
                    for i=1:rows
                        fprintf(f,  '\t');
                        for j=1:cols
                            for k=1:depth
                                fprintf(f,  '%f ', partfilter(i, j, k));
                            end
                        end
                        fprintf(f,  '\n');
                    end
                    fprintf(f,  '\t</data>\n');
                    fprintf(f, '\t</_>\n');
                end
            end
            fprintf(f, '</PartFilters>\n');

            fprintf(f, '<PartPCAFilters>\n');
            for c = 1:csc_model.numcomponents
                for p=1:numparts{c}
                    partfilter = part_pca{c,p};
                    rows = size(partfilter,1);
                    cols = size(partfilter,2);
                    depth = size(partfilter,3);
                    fprintf(f, '\t<_ type_id="opencv-matrix">\n');
                    fprintf(f,  '\t<rows>%d</rows>\n', rows);
                    fprintf(f,  '\t<cols>%d</cols>\n', cols*depth);
                    fprintf(f,  '\t<dt>d</dt>\n');
                    fprintf(f,  '\t<data>\n');
                    for i=1:rows
                        fprintf(f,  '\t');
                        for j=1:cols
                            for k=1:depth
                                fprintf(f,  '%f ', partfilter(i, j, k));
                            end
                        end
                        fprintf(f,  '\n');
                    end
                    fprintf(f,  '\t</data>\n');
                    fprintf(f, '\t</_>\n');
                end
            end
            fprintf(f, '</PartPCAFilters>\n');

            fprintf(f, '<PrunThreshold>\n');
            for c = 1:csc_model.numcomponents
                fprintf(f, '\t<_>\n');
                fprintf(f,  '\t');
                t = csc_model.cascade.t{ridx{c}};
                for j=1:length(t)
                    fprintf(f,  '%f ', t(j));
                end
                fprintf(f, '\n\t</_>\n');
            end
            fprintf(f, '</PrunThreshold>\n');

            fprintf(f, '<Anchor>\n');
            for c = 1:csc_model.numcomponents
                for p=1:numparts{c}
                    fprintf(f, '\t<_>\n');
                    fprintf(f,  '\t');
                    anchor = csc_model.defs{didx{c,p}}.anchor;
                    for j=1:length(anchor)
                        fprintf(f,  '%f ', anchor(j));
                    end
                    fprintf(f, '\n\t</_>\n');
                end
            end
            fprintf(f, '</Anchor>\n');

            fprintf(f, '<Deformation>\n');
            for c = 1:csc_model.numcomponents
                for p=1:numparts{c}
                    fprintf(f, '\t<_>\n');
                    fprintf(f,  '\t');
                    def = csc_model.defs{didx{c,p}}.w;
                    for j=1:length(def)
                        fprintf(f,  '%f ', def(j));
                    end
                    fprintf(f, '\n\t</_>\n');
                end
            end
            fprintf(f, '</Deformation>\n');

            fprintf(f, '<NumParts>\n');
            for c = 1:csc_model.numcomponents
                fprintf(f,  '%f ', numparts{c});
            end
            fprintf(f, '</NumParts>\n');

            fprintf(f, '<PartOrder>\n');
            for c = 1:csc_model.numcomponents
                fprintf(f, '\t<_>\n');
                fprintf(f,  '\t');
                order = csc_model.cascade.order{c};
                for i=1:length(order)
                    fprintf(f,  '%f ', order(i));
                end
                fprintf(f, '\n\t</_>\n');
            end
            fprintf(f, '</PartOrder>\n');

            fprintf(f, '<LocationWeight>\n');
            for c = 1:csc_model.numcomponents
                fprintf(f, '\t<_>\n');
                fprintf(f,  '\t');
                loc_w = loc{c};
                for i=1:length(loc_w)
                    fprintf(f,  '%f ', loc_w(i));
                end
                fprintf(f, '\n\t</_>\n');
            end
            fprintf(f, '</LocationWeight>\n');

            fprintf(f, '</opencv_storage>');
            fclose(f);
        end
    end
end
