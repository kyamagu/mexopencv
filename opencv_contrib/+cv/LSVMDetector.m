classdef LSVMDetector < handle
    %LSVMDETECTOR Latent SVM detector
    %
    % Discriminatively Trained Part Based Models for Object Detection
    %
    % The object detector described below has been initially proposed by
    % P.F. Felzenszwalb in [Felzenszwalb2010a]. It is based on a
    % Dalal-Triggs detector that uses a single filter on histogram of
    % oriented gradients (HOG) features to represent an object category.
    % This detector uses a sliding window approach, where a filter is
    % applied at all positions and scales of an image. The first innovation
    % is enriching the Dalal-Triggs model using a star-structured
    % part-based model defined by a "root" filter (analogous to the
    % Dalal-Triggs filter) plus a set of parts filters and associated
    % deformation models. The score of one of star models at a particular
    % position and scale within an image is the score of the root filter at
    % the given location plus the sum over parts of the maximum, over
    % placements of that part, of the part filter score on its location
    % minus a deformation cost easuring the deviation of the part from its
    % ideal location relative to the root. Both root and part filter scores
    % are defined by the dot product between a filter (a set of weights)
    % and a subwindow of a feature pyramid computed from the input image.
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
    % The basic usage is the following:
    %
    %    im = imread('/path/to/cat.jpg');
    %    detector = cv.LSVMDetector('/path/to/cat.xml');
    %    detections = detector.detect(im);
    %
    % The detector can also accept multiple models by cell array:
    %
    %    detector = cv.LSVMDetector({'cat.xml','car.xml'});
    %
    % The xml file must be a format compatible to OpenCV's Latent SVM
    % detector, but you can convert models from the original implementation
    % in [Felzenszwalb2010a] using mat2xml method. Check the latest models
    % in http://www.cs.brown.edu/~pff/latent/
    %
    % See also cv.LSVMDetector.LSVMDetector cv.LSVMDetector.detect
    %          cv.LSVMDetector.mat2xml
    %
    
    properties (SetAccess = private)
        % Object ID
        id
    end
    
    methods
        function this = LSVMDetector(filenames, varargin)
            %LSVMDETECTOR Load and create a new detector
            %
            %    detector = cv.LSVMDetector(filenames)
            %    detector = cv.LSVMDetector(filenames, classnames)
            %
            % Load the trained models from given .xml files and return a new
            % LSVMDetector detector.
            %
            % ## Input
            % * __filenames__ A set of filenames storing the trained detectors
            %       (models). Each file contains one model. See examples of such
            %       files here https://github.com/Itseez/opencv_extra/testdata/cv/LSVMDetector/models_VOC2007/
            %
            %  * __classnames__ A set of trained models names. If it's empty
            %        then the name of each model will be constructed from the
            %        name of file containing the model. E.g. the model stored in
            %        "/home/user/cat.xml" will get the name "cat".
            %
            % ## Output
            % * __detector__ LSVMDetector detector instance.
            %
            % `filenames` is a string or a cell array of strings specifying
            % the location of model files. Optionally the method takes class
            % names as a cell array of strings that has the same size to
            % filenames. By default, `classnames` are set to the name of the
            % file without xml extension.
            %
            % See also cv.LSVMDetector.detect
            %
            this.id = LSVMDetector_(0, 'new', filenames, varargin{:});
        end
        
        function delete(this)
            %DELETE Destructor
            %
            % See also cv.LSVMDetector
            %
            LSVMDetector_(this.id, 'delete');
        end
        
        function status = isEmpty(this)
            %ISEMPTY Check if the detector is empty
            %
            % See also cv.LSVMDetector
            %
            status = LSVMDetector_(this.id, 'isEmpty');
        end
        
        function names = getClassNames(this)
            %GETCLASSNAMES Get names of the object classes
            %
            %    names = detector.getClassNames()
            %
            % Return the class (model) `names` that were passed in constructor
            % or extracted from models filenames in those methods.
            %
            % ## Output
            % * __names__ a cell array of strings
            %
            % See also cv.LSVMDetector
            %
            names = LSVMDetector_(this.id, 'getClassNames');
        end
        
        function s = getClassCount(this)
            %GETCLASSCOUNT Get size of the detector
            %
            %    s = detector.getClassCount()
            %
            % Return a count of loaded models (classes).
            %
            % ## Output
            % * __s__ a numeric value
            %
            % See also cv.LSVMDetector
            %
            s = LSVMDetector_(this.id, 'getClassCount');
        end

        function objects = detect(this, im, varargin)
            %DETECT Detects objects
            %
            %    objects = detector.detect(im, 'Option', optionValue, ...)
            %
            % Find rectangular regions in the given image that are likely to
            % contain objects of loaded classes (models) and corresponding
            % confidence levels.
            %
            % ## Input
            % * __im__ Matrix of the type `uint8` of an image where objects
            %       are to be detected.
            %
            % ## Output
            % * __objects__ Struct array of detected objects. It has the
            %     following fields:
            %     * __rect__ rectangle `[x,y,w,h]` of the object
            %     * __score__ score of the detection
            %     * __class__ name of the object class
            %
            % ## Options
            % * __OverlapThreshold__ Threshold for the non-maximum suppression
            %     algorithm. default 0.5
            %
            % See also cv.LSVMDetector
            %
            objects = LSVMDetector_(this.id, 'detect', im, varargin{:});
        end
    end
    
    methods (Static)
        function mat2xml(matpath, xmlpath)
            %MAT2XML Convert [Felzenszwalb2010] model files to xml
            %
            %    cv.LSVMDetector.mat2xml(matpath, xmlpath)
            %
            % ## Input
            % * __matpath__ path to the model mat file
            % * __xmlpath__ path to the model xml file
            %
            % The method converts [Felzenszwalb2010] model files to xml
            % format specified by OpenCV's implementation. The usage is the
            % following
            %
            %    matpath = 'VOC2009/cat_final.mat';
            %    xmlpath = 'cat.xml';
            %    cv.LSVMDetector.mat2xml(matpath, xmlpath);
            %
            % Check the latest models in
            % http://www.cs.brown.edu/~pff/latent/
            %
            % This mat2xml utility is taken from 
            % opencv_extra/testdata/cv/latentsvmdetector/mat2xml.m
            % in the opencv development branch.
            %
            % See also cv.LSVMDetector
            %
            load(matpath);
            num_feat = 31;
            rootfilters = cell(1,length(model.rootfilters));
            for i = 1:length(model.rootfilters)
              rootfilters{i} = model.rootfilters{i}.w;
            end
            partfilters = cell(1,length(model.partfilters));
            for i = 1:length(model.partfilters)
              partfilters{i} = model.partfilters{i}.w;
            end
            [ridx,oidx,root,rsize,numparts] = deal(cell(...
                1,model.numcomponents));
            [pidx,didx,part,psize] = deal(cell(...
                model.numcomponents,length(model.components{1}.parts)));
            for c = 1:model.numcomponents
              ridx{c} = model.components{c}.rootindex;
              oidx{c} = model.components{c}.offsetindex;
              root{c} = model.rootfilters{ridx{c}}.w;
              rsize{c} = [size(root{c},1) size(root{c},2)];
              numparts{c} = length(model.components{c}.parts);
              for j = 1:numparts{c}
                pidx{c,j} = model.components{c}.parts{j}.partindex;
                didx{c,j} = model.components{c}.parts{j}.defindex;
                part{c,j} = model.partfilters{pidx{c,j}}.w;
                psize{c,j} = [size(part{c,j},1) size(part{c,j},2)];
                % reverse map from partfilter index to (component, part#)
                % rpidx{pidx{c,j}} = [c j];
              end
            end

            f = fopen(xmlpath, 'wb');
            fprintf(f, '<Model>\n');
            fprintf(f, '\t<!-- Number of components -->\n');
            fprintf(f, '\t<NumComponents>%d</NumComponents>\n', model.numcomponents);
            fprintf(f, '\t<!-- Number of features -->\n');
            fprintf(f, '\t<P>%d</P>\n', num_feat);
            fprintf(f, '\t<!-- Score threshold -->\n');
            fprintf(f, '\t<ScoreThreshold>%.16f</ScoreThreshold>\n', model.thresh);
            for c = 1:model.numcomponents
                fprintf(f, '\t<Component>\n');
                fprintf(f, '\t\t<!-- Root filter description -->\n');
                fprintf(f, '\t\t<RootFilter>\n');
                fprintf(f, '\t\t\t<!-- Dimensions -->\n');
                rootfilter = root{c};
                fprintf(f, '\t\t\t<sizeX>%d</sizeX>\n', rsize{c}(2));
                fprintf(f, '\t\t\t<sizeY>%d</sizeY>\n', rsize{c}(1));
                fprintf(f, '\t\t\t<!-- Weights (binary representation) -->\n');
                fprintf(f, '\t\t\t<Weights>');
                for jj = 1:rsize{c}(1)
                    for ii = 1:rsize{c}(2)
                        for kk = 1:num_feat
                            fwrite(f, rootfilter(jj, ii, kk), 'double');
                        end
                    end
                end
                fprintf(f, '\t\t\t</Weights>\n');
                fprintf(f, '\t\t\t<!-- Linear term in score function -->\n');
                fprintf(f, '\t\t\t<LinearTerm>%.16f</LinearTerm>\n', model.offsets{1,c}.w);
                fprintf(f, '\t\t</RootFilter>\n\n');
                fprintf(f, '\t\t<!-- Part filters description -->\n');
                fprintf(f, '\t\t<PartFilters>\n');
                fprintf(f, '\t\t\t<NumPartFilters>%d</NumPartFilters>\n', numparts{c});

                for j=1:numparts{c}
                    fprintf(f, '\t\t\t<!-- Part filter %d description -->\n', j);
                    fprintf(f, '\t\t\t<PartFilter>\n');
                    partfilter = part{c,j};
                    anchor = model.defs{didx{c,j}}.anchor;
                    def = model.defs{didx{c,j}}.w;

                    fprintf(f, '\t\t\t\t<!-- Dimensions -->\n');
                    fprintf(f, '\t\t\t\t<sizeX>%d</sizeX>\n', psize{c,j}(2));
                    fprintf(f, '\t\t\t\t<sizeY>%d</sizeY>\n', psize{c,j}(1));
                    fprintf(f, '\t\t\t\t<!-- Weights (binary representation) -->\n');
                    fprintf(f, '\t\t\t\t<Weights>');
                    for jj = 1:psize{c,j}(1)
                        for ii = 1:psize{c,j}(2)
                            for kk = 1:num_feat
                                fwrite(f, partfilter(jj, ii, kk), 'double');
                            end
                        end
                    end
                    fprintf(f, '\t\t\t\t</Weights>\n');
                    fprintf(f, '\t\t\t\t<!-- Part filter offset -->\n');
                    fprintf(f, '\t\t\t\t<V>\n');
                    fprintf(f, '\t\t\t\t\t<Vx>%d</Vx>\n', anchor(1));
                    fprintf(f, '\t\t\t\t\t<Vy>%d</Vy>\n', anchor(2));
                    fprintf(f, '\t\t\t\t</V>\n');
                    fprintf(f, '\t\t\t\t<!-- Quadratic penalty function coefficients -->\n');
                    fprintf(f, '\t\t\t\t<Penalty>\n');
                    fprintf(f, '\t\t\t\t\t<dx>%.16f</dx>\n', def(2));
                    fprintf(f, '\t\t\t\t\t<dy>%.16f</dy>\n', def(4));
                    fprintf(f, '\t\t\t\t\t<dxx>%.16f</dxx>\n', def(1));
                    fprintf(f, '\t\t\t\t\t<dyy>%.16f</dyy>\n', def(3));
                    fprintf(f, '\t\t\t\t</Penalty>\n');
                     fprintf(f, '\t\t\t</PartFilter>\n');
                end
                fprintf(f, '\t\t</PartFilters>\n');
                fprintf(f, '\t</Component>\n');
            end
            fprintf(f, '</Model>');
            fclose(f);
        end
    end
end

