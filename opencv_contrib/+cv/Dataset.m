classdef Dataset < handle
    %DATASET  Class for working with different datasets
    %
    % The datasets module includes classes for working with different
    % datasets: load data, evaluate different algorithms on them, contains
    % benchmarks, etc.
    %
    % It is planned to have:
    %
    % - basic: loading code for all datasets to help start work with them.
    % - next stage: quick benchmarks for all datasets to show how to solve
    %   them using OpenCV and implement evaluation code.
    % - finally: implement on OpenCV state-of-the-art algorithms, which solve
    %   these tasks.
    %
    % Includes classes from the following categories:
    %
    % - Action Recognition
    % - Face Recognition
    % - Gesture Recognition
    % - Human Pose Estimation
    % - Image Registration
    % - Image Segmentation
    % - Multiview Stereo Matching
    % - Object Recognition
    % - Pedestrian Detection
    % - SLAM
    % - Text Recognition
    % - Tracking
    %
    % See also: cv.Dataset.Dataset
    %

    properties (SetAccess = private)
        % Object ID
        id
        % Object class
        klass
    end

    methods
        function this = Dataset(dstype)
            %DATASET  Constructor
            %
            %     ds = cv.Dataset(dstype)
            %
            % ## Input
            % * __dstype__ Dataset class implementation. One of:
            %   * **AR_hmdb** HMDB: A Large Human Motion Database
            %   * **AR_sports** Sports-1M Dataset
            %   * **FR_adience** Adience
            %   * **FR_lfw** Labeled Faces in the Wild
            %   * **GR_chalearn** ChaLearn Looking at People
            %   * **GR_skig** Sheffield Kinect Gesture Dataset
            %   * **HPE_humaneva** HumanEva Dataset
            %   * **HPE_parse** PARSE Dataset
            %   * **IR_affine** Affine Covariant Regions Datasets
            %   * **IR_robot** Robot Data Set
            %   * **IS_bsds** The Berkeley Segmentation Dataset and Benchmark
            %   * **IS_weizmann** Weizmann Segmentation Evaluation Database
            %   * **MSM_epfl** EPFL Multi-View Stereo
            %   * **MSM_middlebury** Stereo - Middlebury Computer Vision
            %   * **OR_imagenet** ImageNet
            %   * **OR_mnist** MNIST
            %   * **OR_pascal** PASCAL Object Recognition Database
            %   * **OR_sun** SUN Database
            %   * **PD_caltech** Caltech Pedestrian Detection Benchmark
            %   * **PD_inria** INRIA Person Dataset
            %   * **SLAM_kitti** KITTI Vision Benchmark
            %   * **SLAM_tumindoor** TUMindoor Dataset
            %   * **TR_chars** The Chars74K Dataset
            %   * **TR_icdar** ICDAR
            %   * **TR_svt** The Street View Text Dataset
            %   * **TRACK_vot** VOT 2015 Database
            %   * **TRACK_alov** Amsterdam Library of Ordinary Videos (ALOV++)
            %
            % ### HMDB: A Large Human Motion Database
            %
            % Implements loading dataset: "HMDB: A Large Human Motion Database"
            % [Link](http://serre-lab.clps.brown.edu/resource/hmdb-a-large-human-motion-database/)
            %
            % Usage:
            %
            % - From link above download dataset files: `hmdb51_org.rar` &
            %   `test_train_splits.rar`.
            % - Unpack them. Unpack all archives from directory: `hmdb51_org/`
            %   and remove them.
            % - To load data run:
            %
            %       ds = cv.Dataset('AR_hmdb');
            %       ds.load('/home/user/path_to_unpacked_folders/');
            %
            % Benchmark:
            %
            % - For this dataset was implemented benchmark with accuracy:
            %   0.107407 (using precomputed HOG/HOF "STIP" features from site,
            %   averaging for 3 splits)
            %
            % Note:
            %
            % - Precomputed features should be unpacked in the same folder:
            %   `/home/user/path_to_unpacked_folders/hmdb51_org_stips/`.
            % - Also unpack all archives from directory: `hmdb51_org_stips/`
            %   and remove them.
            %
            % ### Sports-1M Dataset
            %
            % Implements loading dataset: "Sports-1M Dataset"
            % [Link](http://cs.stanford.edu/people/karpathy/deepvideo/)
            %
            % Usage:
            %
            % - From link above download dataset
            %   [files](https://code.google.com/p/sports-1m-dataset/).
            % - To load data run:
            %
            %       ds = cv.Dataset('AR_sports');
            %       ds.load('/home/user/path_to_downloaded_folders/');
            %
            % ### Adience
            %
            % Implements loading dataset: "Adience"
            % [Link](http://www.openu.ac.il/home/hassner/Adience/data.html)
            %
            % Usage:
            %
            % - From link above download any dataset file:
            %   `faces.tar.gz\aligned.tar.gz` and files with splits:
            %   `fold_0_data.txt-fold_4_data.txt`,
            %   `fold_frontal_0_data.txt-fold_frontal_4_data.txt`. (For face
            %   recognition task another splits should be created)
            % - Unpack dataset file to some folder and place split files into
            %   the same folder.
            % - To load data run:
            %
            %       ds = cv.Dataset('FR_adience');
            %       ds.load('/home/user/path_to_created_folder/');
            %
            % ### Labeled Faces in the Wild
            %
            % Implements loading dataset: "Labeled Faces in the Wild"
            % [Link](http://vis-www.cs.umass.edu/lfw/)
            %
            % Usage:
            %
            % - From link above download any dataset file:
            %   `lfw.tgz\lfwa.tar.gz\lfw-deepfunneled.tgz\lfw-funneled.tgz`
            %   and files with pairs: 10 test splits: `pairs.txt` and
            %   developer train split: `pairsDevTrain.txt`.
            % - Unpack dataset file and place `pairs.txt` and
            %   `pairsDevTrain.txt` in created folder.
            % - To load data run:
            %
            %       ds = cv.Dataset('FR_lfw');
            %       ds.load('/home/user/path_to_unpacked_folder/lfw2/');
            %
            % Benchmark:
            %
            % - For this dataset was implemented benchmark with accuracy:
            %   0.623833 +/- 0.005223 (train split: `pairsDevTrain.txt`,
            %   dataset: lfwa)
            %
            % ### ChaLearn Looking at People
            %
            % Implements loading dataset: "ChaLearn Looking at People"
            % [Link](http://gesture.chalearn.org/)
            %
            % Usage
            %
            % - Follow instruction from site above, download files for dataset
            %   "Track 3: Gesture Recognition": `Train1.zip`-`Train5.zip`,
            %   `Validation1.zip`-`Validation3.zip` (Register on
            %   [site](http://codalab.org/) and accept the
            %   [terms](http://www.codalab.org/competitions/991#learn_the_details)
            %   and conditions of competition. There are three mirrors for
            %   downloading dataset files. When I downloaded data only mirror:
            %   "Universitat Oberta de Catalunya" works).
            % - Unpack train archives `Train1.zip`-`Train5.zip` to folder
            %   `Train/`, validation archives
            %   `Validation1.zip`-`Validation3.zip` to folder `Validation/`
            % - Unpack all archives in `Train/` & `Validation/` in the folders
            %   with the same names, for example: `Sample0001.zip` to
            %   `Sample0001/`
            % - To load data run:
            %
            %       ds = cv.Dataset('GR_chalearn');
            %       ds.load('/home/user/path_to_unpacked_folders/');
            %
            % ### Sheffield Kinect Gesture Dataset
            %
            % Implements loading dataset: "Sheffield Kinect Gesture Dataset"
            % [Link](http://lshao.staff.shef.ac.uk/data/SheffieldKinectGesture.htm)
            %
            % Usage:
            %
            % - From link above download dataset files:
            %   `subject1_dep.7z`-`subject6_dep.7z`,
            %   `subject1_rgb.7z`-`subject6_rgb.7z`.
            % - Unpack them.
            % - To load data run:
            %
            %       ds = cv.Dataset('GR_skig');
            %       ds.load('/home/user/path_to_unpacked_folders/');
            %
            % ### HumanEva Dataset
            %
            % Implements loading dataset: "HumanEva Dataset"
            % [Link](http://humaneva.is.tue.mpg.de)
            %
            % Usage:
            %
            % - From link above download dataset files for `HumanEva-I` (tar)
            %   and `HumanEva-II`.
            % - Unpack them to `HumanEva_1` and `HumanEva_2` accordingly.
            % - To load data run:
            %
            %       ds = cv.Dataset('HPE_humaneva');
            %       ds.load('/home/user/path_to_unpacked_folders/');
            %
            % ### PARSE Dataset
            %
            % Implements loading dataset: "PARSE Dataset"
            % [Link](http://www.ics.uci.edu/~dramanan/papers/parse/)
            %
            % Usage:
            %
            % - From link above download dataset file: `people.zip`.
            % - Unpack it.
            % - To load data run:
            %
            %       ds = cv.Dataset('HPE_parse');
            %       ds.load('/home/user/path_to_unpacked_folder/people_all/');
            %
            % ### Affine Covariant Regions Datasets
            %
            % Implements loading dataset: "Affine Covariant Regions Datasets"
            % [Link](http://www.robots.ox.ac.uk/~vgg/data/data-aff.html)
            %
            % Usage:
            %
            % - From link above download dataset files:
            %   `bark\bikes\boat\graf\leuven\trees\ubc\wall.tar.gz`.
            % - Unpack them.
            % - To load data, for example, for "bark", run:
            %
            %       ds = cv.Dataset('IR_affine');
            %       ds.load('/home/user/path_to_unpacked_folder/bark/');
            %
            % ### Robot Data Set
            %
            % Implements loading dataset: "Robot Data Set, Point Feature Data Set - 2010"
            % [Link](http://roboimagedata.compute.dtu.dk/?page_id=24)
            %
            % Usage:
            %
            % - From link above download dataset files:
            %   `SET001_6.tar.gz`-`SET055_60.tar.gz`
            % - Unpack them to one folder.
            % - To load data run:
            %
            %       ds = cv.Dataset('IR_robot');
            %       ds.load('/home/user/path_to_unpacked_folder/');
            %
            % ### The Berkeley Segmentation Dataset and Benchmark
            %
            % Implements loading dataset: "The Berkeley Segmentation Dataset and Benchmark"
            % [Link](https://www.eecs.berkeley.edu/Research/Projects/CS/vision/bsds/)
            %
            % Usage:
            %
            % - From link above download dataset files:
            %   `BSDS300-human.tgz` & `BSDS300-images.tgz`.
            % - Unpack them.
            % - To load data run:
            %
            %       ds = cv.Dataset('IS_bsds');
            %       ds.load('/home/user/path_to_unpacked_folder/BSDS300/');
            %
            % ### Weizmann Segmentation Evaluation Database
            %
            % Implements loading dataset: "Weizmann Segmentation Evaluation Database"
            % [Link](http://www.wisdom.weizmann.ac.il/~vision/Seg_Evaluation_DB/)
            %
            % Usage:
            %
            % - From link above download dataset files:
            %   `Weizmann_Seg_DB_1obj.ZIP` & `Weizmann_Seg_DB_2obj.ZIP`.
            % - Unpack them.
            % - To load data, for example, for `1 object` dataset, run:
            %
            %       ds = cv.Dataset('IS_weizmann');
            %       ds.load('/home/user/path_to_unpacked_folder/1obj/');
            %
            % ### EPFL Multi-View Stereo
            %
            % Implements loading dataset: "EPFL Multi-View Stereo"
            % [Link](http://cvlab.epfl.ch/data/strechamvs)
            %
            % Usage:
            %
            % - From link above download dataset files:
            %   `castle_dense\castle_dense_large\castle_entry\fountain\herzjesu_dense\herzjesu_dense_large_bounding\cameras\images\p.tar.gz`.
            % - Unpack them in separate folder for each object. For example,
            %   for "fountain", in folder `fountain/` :
            %   `fountain_dense_bounding.tar.gz -> bounding/`,
            %   `fountain_dense_cameras.tar.gz -> camera/`,
            %   `fountain_dense_images.tar.gz -> png/`,
            %   `fountain_dense_p.tar.gz -> P/`
            % - To load data, for example, for "fountain", run:
            %
            %       ds = cv.Dataset('MSM_epfl');
            %       ds.load('/home/user/path_to_unpacked_folder/fountain/');
            %
            % ### Stereo - Middlebury Computer Vision
            %
            % Implements loading dataset: "Stereo - Middlebury Computer Vision"
            % [Link](http://vision.middlebury.edu/mview/)
            %
            % Usage:
            %
            % - From link above download dataset files:
            %   `dino\dinoRing\dinoSparseRing\temple\templeRing\templeSparseRing.zip`
            % - Unpack them.
            % - To load data, for example "temple" dataset, run:
            %
            %       ds = cv.Dataset('MSM_middlebury');
            %       ds.load('/home/user/path_to_unpacked_folder/temple/');
            %
            % ### ImageNet
            %
            % Implements loading dataset: "ImageNet"
            % [Link](http://www.image-net.org/)
            %
            % Usage:
            %
            % - From link above download dataset files:
            %   `ILSVRC2010_images_train.tar`, `ILSVRC2010_images_test.tar`,
            %   `ILSVRC2010_images_val.tar` & devkit:
            %   `ILSVRC2010_devkit-1.0.tar.gz` (Implemented loading of 2010
            %   dataset as only this dataset has ground truth for test data,
            %   but structure for ILSVRC2014 is similar)
            % - Unpack them to: `some_folder/train/`, `some_folder/test/`,
            %   `some_folder/val` &
            %   `some_folder/ILSVRC2010_validation_ground_truth.txt`,
            %   `some_folder/ILSVRC2010_test_ground_truth.txt`.
            % - Create file with labels: `some_folder/labels.txt`, for
            %   example, using python script below (each file's row format:
            %   `synset,labelID,description`. For example:
            %   "n07751451,18,plum").
            % - Unpack all tar files in train.
            % - To load data run:
            %
            %       ds = cv.Dataset('OR_imagenet');
            %       ds.load('/home/user/some_folder/');
            %
            % Python script to parse `meta.mat`:
            %
            % ```python
            % import scipy.io
            % meta_mat = scipy.io.loadmat("devkit-1.0/data/meta.mat")
            %
            % labels_dic = dict((m[0][1][0], m[0][0][0][0]-1) for m in meta_mat['synsets']
            % label_names_dic = dict((m[0][1][0], m[0][2][0]) for m in meta_mat['synsets']
            %
            % for label in labels_dic.keys():
            %     print "{0},{1},{2}".format(label, labels_dic[label], label_names_dic[label])
            % ```
            %
            % ### MNIST
            %
            % Implements loading dataset: "MNIST"
            % [Link](http://yann.lecun.com/exdb/mnist/)
            %
            % Usage:
            %
            % - From link above download dataset files:
            %   `t10k-images-idx3-ubyte.gz`, `t10k-labels-idx1-ubyte.gz`,
            %   `train-images-idx3-ubyte.gz`, `train-labels-idx1-ubyte.gz`.
            % - Unpack them.
            % - To load data run:
            %
            %       ds = cv.Dataset('OR_mnist');
            %       ds.load('/home/user/path_to_unpacked_files/');
            %
            % ### SUN Database
            %
            % Implements loading dataset: "SUN Database, Scene Recognition Benchmark. SUN397"
            % [Link](http://vision.cs.princeton.edu/projects/2010/SUN/)
            %
            % Usage:
            %
            % - From link above download dataset file: `SUN397.tar` & file
            %   with splits: `Partitions.zip`
            % - Unpack `SUN397.tar` into folder: `SUN397/` & `Partitions.zip`
            %   into folder: `SUN397/Partitions/`
            % - To load data run:
            %
            %       ds = cv.Dataset('OR_sun');
            %       ds.load('/home/user/path_to_unpacked_files/SUN397/');
            %
            % ### Caltech Pedestrian Detection Benchmark
            %
            % Implements loading dataset: "Caltech Pedestrian Detection Benchmark"
            % [Link](http://www.vision.caltech.edu/Image_Datasets/CaltechPedestrians/)
            %
            % Usage:
            %
            % - From link above download dataset files:
            %   `set00.tar`-`set10.tar`.
            % - Unpack them to separate folder.
            % - To load data run:
            %
            %       ds = cv.Dataset('PD_caltech');
            %       ds.load('/home/user/path_to_unpacked_folders/');
            %
            % Note:
            %
            % - First version of Caltech Pedestrian dataset loading. Code to
            %   unpack all frames from seq files commented as their number is
            %   huge! So currently load only meta information without data.
            % - Also ground truth isn't processed, as need to convert it from
            %   mat files first.
            %
            % ### KITTI Vision Benchmark
            %
            % Implements loading dataset: "KITTI Vision Benchmark"
            % [Link](http://www.cvlibs.net/datasets/kitti/eval_odometry.php)
            %
            % Usage:
            %
            % - From link above download "Odometry" dataset files:
            %   `data_odometry_gray`, `data_odometry_color`,
            %   `data_odometry_velodyne`, `data_odometry_poses`,
            %   `data_odometry_calib.zip`.
            % - Unpack `data_odometry_poses.zip`, it creates folder
            %   `dataset/poses/`. After that unpack `data_odometry_gray.zip`,
            %   `data_odometry_color.zip`, `data_odometry_velodyne.zip`.
            %   Folder `dataset/sequences/` will be created with folders
            %   `00/..21/`. Each of these folders will contain: `image_0/`,
            %   `image_1/`, `image_2/`, `image_3/`, `velodyne/` and files
            %   `calib.txt` & `times.txt`. These two last files will be
            %   replaced after unpacking `data_odometry_calib.zip` at the end.
            % - To load data run:
            %
            %       ds = cv.Dataset('SLAM_kitti');
            %       ds.load('/home/user/path_to_unpacked_folder/dataset/');
            %
            % ### TUMindoor Dataset
            %
            % Implements loading dataset: "TUMindoor Dataset"
            % [Link](http://www.navvis.lmt.ei.tum.de/dataset/)
            %
            % Usage:
            %
            % - From link above download dataset files:
            %   `dslr\info\ladybug\pointcloud.tar.bz2` for each dataset:
            %   `11-11-28 (1st floor)`, `11-12-13 (1st floor N1)`,
            %   `11-12-17a (4th floor)`, `11-12-17b (3rd floor)`,
            %   `11-12-17c (Ground I)`, `11-12-18a (Ground II)`,
            %   `11-12-18b (2nd floor)`
            % - Unpack them in separate folder for each dataset.
            %   `dslr.tar.bz2 -> dslr/`, `info.tar.bz2 -> info/`,
            %   `ladybug.tar.bz2 -> ladybug/`,
            %   `pointcloud.tar.bz2 -> pointcloud/`.
            % - To load each dataset run:
            %
            %       ds = cv.Dataset('SLAM_tumindoor');
            %       ds.load('/home/user/path_to_unpacked_folders/');
            %
            % ### The Chars74K Dataset
            %
            % Implements loading dataset: "The Chars74K Dataset"
            % [Link](http://www.ee.surrey.ac.uk/CVSSP/demos/chars74k/)
            %
            % Usage:
            %
            % - From link above download dataset files:
            %   `EnglishFnt\EnglishHnd\EnglishImg\KannadaHnd\KannadaImg.tgz`,
            %   `ListsTXT.tgz`.
            % - Unpack them.
            % - Move `.m` files from folder `ListsTXT/` to appropriate folder.
            %   For example, `English/list_English_Img.m` for `EnglishImg.tgz`.
            % - To load data, for example "EnglishImg", run:
            %
            %       ds = cv.Dataset('TR_chars');
            %       ds.load('/home/user/path_to_unpacked_folder/English/');
            %
            % ### The Street View Text Dataset
            %
            % Implements loading dataset: "The Street View Text Dataset"
            % [Link](http://vision.ucsd.edu/~kai/svt/)
            %
            % Usage:
            %
            % - From link above download dataset file: `svt.zip`.
            % - Unpack it.
            % - To load data run:
            %
            %       ds = cv.Dataset('TR_svt');
            %       ds.load('/home/user/path_to_unpacked_folder/svt/svt1/');
            %
            % Benchmark:
            %
            % - For this dataset was implemented benchmark with accuracy
            %   (mean f1): 0.217
            %
            % ### VOT 2015 Database
            %
            % Implements loading dataset: VOT 2015
            % [Link](http://box.vicos.si/vot/vot2015.zip)
            %
            % VOT 2015 dataset comprises 60 short sequences showing various
            % objects in challenging backgrounds. The sequences were chosen
            % from a large pool of sequences including the ALOV dataset, OTB2
            % dataset, non-tracking datasets, Computer Vision Online,
            % Professor Bob Fisher's Image Database, Videezy, Center for
            % Research in Computer Vision, University of Central Florida, USA,
            % NYU Center for Genomics and Systems Biology, Data Wrangling,
            % Open Access Directory and Learning and Recognition in Vision
            % Group, INRIA, France. The VOT sequence selection protocol was
            % applied to obtain a representative set of challenging sequences.
            %
            % Usage:
            %
            % - From link above download dataset file: `vot2015.zip`
            % - Unpack `vot2015.zip` into folder: `VOT2015/`
            % - To load data run:
            %
            %       ds = cv.Dataset('TRACK_vot');
            %       ds.load('/home/user/path_to_unpacked_files/VOT2015/');
            %
            % ### Amsterdam Library of Ordinary Videos for tracking
            %
            % Implements loading daataset: ALOV++
            % [Link](http://www.alov300.org/)
            %
            % See also: cv.Dataset.load
            %
            this.klass = dstype;
            this.id = Dataset_(0, 'new', this.klass);
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     ds.delete()
            %
            % See also: cv.Dataset
            %
            if isempty(this.id), return; end
            Dataset_(this.id, 'delete', this.klass);
        end

        function typename = typeid(this)
            %TYPEID  Name of the C++ type (RTTI)
            %
            %     typename = ds.typeid()
            %
            % ## Output
            % * __typename__ Name of C++ type
            %
            typename = Dataset_(this.id, 'typeid', this.klass);
        end
    end

    %% Dataset
    methods
        function load(this, dpath)
            %LOAD  Load dataset
            %
            %     ds.load(dpth)
            %
            % ## Input
            % * __dpath__ directory path for dataset files.
            %
            % NOTE: Be careful that some dataset loaders require that the path
            % end with a slash, while others don't. Failing to match this
            % requirement could easily crash MATLAB! (Sorry, the OpenCV C++
            % code is inconsistent and there is no convention here).
            %
            % See also: cv.Dataset.getNumSplits
            %
            Dataset_(this.id, 'load', this.klass, dpath);
        end

        function num = getNumSplits(this)
            %GETNUMSPLITS  Get Number of data splits
            %
            %     num = ds.getNumSplits()
            %
            % ## Output
            % * __num__ number of splits.
            %
            % See also: cv.Dataset.getTrain, cv.Dataset.getTest,
            %  cv.Dataset.getValidation
            %
            num = Dataset_(this.id, 'getNumSplits', this.klass);
        end

        function data = getTrain(this, varargin)
            %GETTRAIN  Get training data
            %
            %     data = ds.getTrain('OptionName',optionValue, ...)
            %
            % ## Output
            % * __data__ training data samples.
            %
            % ## Options
            % * __SplitNum__ split number. default 0
            %
            % See also: cv.Dataset.getTest, cv.Dataset.getValidation
            %
            data = Dataset_(this.id, 'getTrain', this.klass, varargin{:});
        end

        function data = getTest(this, varargin)
            %GETTEST  Get testing data
            %
            %     data = ds.getTest('OptionName',optionValue, ...)
            %
            % ## Output
            % * __data__ testing data samples.
            %
            % ## Options
            % * __SplitNum__ split number. default 0
            %
            % See also: cv.Dataset.getTrain, cv.Dataset.getValidation
            %
            data = Dataset_(this.id, 'getTest', this.klass, varargin{:});
        end

        function data = getValidation(this, varargin)
            %GETVALIDATION  Get validation data
            %
            %     data = ds.getValidation('OptionName',optionValue, ...)
            %
            % ## Output
            % * __data__ validation data samples.
            %
            % ## Options
            % * __SplitNum__ split number. default 0
            %
            % See also: cv.Dataset.getTrain, cv.Dataset.getTest
            %
            data = Dataset_(this.id, 'getValidation', this.klass, varargin{:});
        end
    end

    %% Util functions
    methods (Static)
        function createDirectory(dirPath)
            %CREATEDIRECTORY  Create directory
            %
            %     cv.Dataset.createDirectory(dirPath)
            %
            % ## Input
            % * __dirPath__ directory path.
            %
            % See also: cv.Dataset.getDirList, mkdir
            %
            Dataset_(0, 'createDirectory', '', dirPath);
        end

        function fileNames = getDirList(dirName)
            %GETDIRLIST  Get directory listing
            %
            %     fileNames = cv.Dataset.createDirectory(dirName)
            %
            % ## Input
            % * __dirName__ directory name.
            %
            % ## Output
            % * __fileNames__ list of file and directory names.
            %
            % See also: cv.Dataset.createDirectory, dir
            %
            fileNames = Dataset_(0, 'getDirList', '', dirName);
        end

        function elems = split(s, delim)
            %SPLIT  Split string by delimiter
            %
            %     elems = cv.Dataset.split(s, delim)
            %
            % ## Input
            % * __s__ string.
            % * __delim__ delimiter character.
            %
            % ## Output
            % * __elems__ list of elements.
            %
            % See also: strsplit
            %
            elems = Dataset_(0, 'split', '', s, delim);
        end
    end

end
