/**
 * @file Facemark_.cpp
 * @brief mex interface for cv::face::Facemark, cv::face::FacemarkLBF, cv::face::FacemarkAAM
 * @ingroup face
 * @author Amro
 * @date 2018
 */
#include "mexopencv.hpp"
#include "opencv2/face.hpp"
using namespace std;
using namespace cv;
using namespace cv::face;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<Facemark> > obj_;
/// name of MATLAB function to evaluate (custom face detector)
string func;

/** Custom face detector implemented as a MATLAB function
 * @param image_ input image.
 * @param faces_ output faces.
 * @param userData optional user-specified parameters (unused here)
 * @return success flag.
 */
bool matlab_face_detector(InputArray image_, OutputArray faces_, void *userData)
{
    // create input to evaluate MATLAB function
    mxArray *lhs, *rhs[2];
    rhs[0] = MxArray(func);
    rhs[1] = MxArray(image_.getMat());

    // evaluate specified function in MATLAB as:
    // faces = feval("func", image)
    bool success = (mexCallMATLAB(1, &lhs, 2, rhs, "feval") == 0);
    if (success) {
        vector<Rect> faces(MxArray(lhs).toVector<Rect>());
        Mat(faces).copyTo(faces_);
    }

    // cleanup
    mxDestroyArray(lhs);
    mxDestroyArray(rhs[0]);
    mxDestroyArray(rhs[1]);

    // return success flag
    return success;
}

/** Convert an MxArray to cv::face::FacemarkAAM::Config
 * @param arr struct-array MxArray object
 * @param idx linear index of the struct array element
 * @return config object
 */
FacemarkAAM::Config MxArrayToConfig(const MxArray& arr, mwIndex idx = 0)
{
    return FacemarkAAM::Config(
        arr.isField("R")        ? arr.at("R",        idx).toMat(CV_32F) : Mat::eye(2,2,CV_32F),
        arr.isField("t")        ? arr.at("t",        idx).toPoint2f()   : Point2f(0,0),
        arr.isField("scale")    ? arr.at("scale",    idx).toFloat()     : 1.0f,
        arr.isField("scaleIdx") ? arr.at("scaleIdx", idx).toInt()       : 0
    );
}

/** Convert an MxArray to std::vector<cv::face::FacemarkAAM::Config>
 * @param arr struct-array MxArray object
 * @return vector of config objects
 */
vector<FacemarkAAM::Config> MxArrayToVectorConfig(const MxArray& arr)
{
    const mwSize n = arr.numel();
    vector<FacemarkAAM::Config> configs;
    configs.reserve(n);
    if (arr.isCell())
        for (mwIndex i = 0; i < n; ++i)
            configs.push_back(MxArrayToConfig(arr.at<MxArray>(i)));
    else if (arr.isStruct())
        for (mwIndex i = 0; i < n; ++i)
            configs.push_back(MxArrayToConfig(arr,i));
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "MxArray unable to convert to std::vector<cv::face::FacemarkAAM::Config>");
    return configs;
}

/** Create an instance of FacemarkLBF using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created cv::face::FacemarkLBF
 */
Ptr<FacemarkLBF> createFacemarkLBF(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    FacemarkLBF::Params parameters;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "ShapeOffset")
            parameters.shape_offset = val.toDouble();
        else if (key == "CascadeFace")
            parameters.cascade_face = val.toString();
        else if (key == "Verbose")
            parameters.verbose = val.toBool();
        else if (key == "NLandmarks")
            parameters.n_landmarks = val.toInt();
        else if (key == "InitShapeN")
            parameters.initShape_n = val.toInt();
        else if (key == "StagesN")
            parameters.stages_n = val.toInt();
        else if (key == "TreeN")
            parameters.tree_n = val.toInt();
        else if (key == "TreeDepth")
            parameters.tree_depth = val.toInt();
        else if (key == "BaggingOverlap")
            parameters.bagging_overlap = val.toDouble();
        else if (key == "ModelFilename")
            parameters.model_filename = val.toString();
        else if (key == "SaveModel")
            parameters.save_model = val.toBool();
        else if (key == "Seed")
            parameters.seed = static_cast<unsigned>(val.toInt());
        else if (key == "FeatsM")
            parameters.feats_m = val.toVector<int>();
        else if (key == "RadiusM")
            parameters.radius_m = val.toVector<double>();
        else if (key == "Pupils") {
            if (!val.isCell() || val.numel() != 2)
                mexErrMsgIdAndTxt("mexopencv:error", "Invalid arguments");
            vector<MxArray> arr(val.toVector<MxArray>());
            parameters.pupils[0] = arr[0].toVector<int>();
            parameters.pupils[1] = arr[1].toVector<int>();
        }
        else if (key == "DetectROI")
            parameters.detectROI = val.toRect();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return FacemarkLBF::create(parameters);
}

/** Create an instance of FacemarkAAM using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created cv::face::FacemarkAAM
 */
Ptr<FacemarkAAM> createFacemarkAAM(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    FacemarkAAM::Params parameters;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "ModelFilename")
            parameters.model_filename = val.toString();
        else if (key == "M")
            parameters.m = val.toInt();
        else if (key == "N")
            parameters.n = val.toInt();
        else if (key == "NIter")
            parameters.n_iter = val.toInt();
        else if (key == "Verbose")
            parameters.verbose = val.toBool();
        else if (key == "SaveModel")
            parameters.save_model = val.toBool();
        else if (key == "MaxM")
            parameters.max_m = val.toInt();
        else if (key == "MaxN")
            parameters.max_n = val.toInt();
        else if (key == "TextureMaxM")
            parameters.texture_max_m = val.toInt();
        else if (key == "Scales")
            parameters.scales = val.toVector<float>();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return FacemarkAAM::create(parameters);
}

/** Create an instance of Facemark using options in arguments
 * @param type facemark algorithm, one of:
 *    - "LBF"
 *    - "AAM"
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created cv::face::Facemark
 */
Ptr<Facemark> createFacemark(
    const string& type,
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    Ptr<Facemark> p;
    if (type == "LBF")
        p = createFacemarkLBF(first, last);
    else if (type == "AAM")
        p = createFacemarkAAM(first, last);
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized facemark %s", type.c_str());
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error", "Failed to create Facemark");
    return p;
}
}

/**
 * Main entry called from Matlab
 * @param nlhs number of left-hand-side arguments
 * @param plhs pointers to mxArrays in the left-hand-side
 * @param nrhs number of right-hand-side arguments
 * @param prhs pointers to mxArrays in the right-hand-side
 */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    // Check the number of arguments
    nargchk(nrhs>=3 && nlhs<=3);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    int id = rhs[0].toInt();
    func = rhs[1].toString();
    string method(rhs[2].toString());

    // constructor call
    if (method == "new") {
        nargchk(nrhs>=4 && nlhs<=1);
        obj_[++last_id] = createFacemark(
            rhs[3].toString(), rhs.begin() + 4, rhs.end());
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }
    // static method call
    else if (method == "getFacesHAAR") {
        nargchk(nrhs==5 && nlhs<=2);
        Mat image(rhs[3].toMat(CV_8U));
        string face_cascade_name(rhs[4].toString());
        vector<Rect> faces;
        bool b = cv::face::getFacesHAAR(image, faces, face_cascade_name);
        plhs[0] = MxArray(faces);
        if (nlhs > 1)
            plhs[1] = MxArray(b);
        return;
    }
    else if (method == "loadDatasetList") {
        nargchk(nrhs==5 && nlhs<=3);
        string imageList(rhs[3].toString());
        string annotationList(rhs[4].toString());
        vector<String> images, annotations;
        bool b = cv::face::loadDatasetList(
            imageList, annotationList, images, annotations);
        plhs[0] = MxArray(images);
        if (nlhs > 1)
            plhs[1] = MxArray(annotations);
        if (nlhs > 2)
            plhs[2] = MxArray(b);
        return;
    }
    else if (method == "loadTrainingData1") {
        nargchk(nrhs>=5 && (nrhs%2)==1 && nlhs<=3);
        float offset = 0.0f;
        for (int i=5; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "Offset")
                offset = rhs[i+1].toFloat();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        string imageList(rhs[3].toString());
        string groundTruth(rhs[4].toString());
        vector<String> images;
        vector<vector<Point2f> > facePoints;
        bool b = cv::face::loadTrainingData(
            imageList, groundTruth, images, facePoints, offset);
        plhs[0] = MxArray(images);
        if (nlhs > 1)
            plhs[1] = MxArray(facePoints);
        if (nlhs > 2)
            plhs[2] = MxArray(b);
        return;
    }
    else if (method == "loadTrainingData2") {
        nargchk(nrhs>=4 && (nrhs%2)==0 && nlhs<=3);
        char delim = ' ';
        float offset = 0.0f;
        for (int i=4; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "Delim")
                delim = (!rhs[i+1].isEmpty()) ? rhs[i+1].toString()[0] : ' ';
            else if (key == "Offset")
                offset = rhs[i+1].toFloat();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        string filename(rhs[3].toString());
        vector<String> images;
        vector<vector<Point2f> > facePoints;
        bool b = cv::face::loadTrainingData(
            filename, images, facePoints, delim, offset);
        plhs[0] = MxArray(images);
        if (nlhs > 1)
            plhs[1] = MxArray(facePoints);
        if (nlhs > 2)
            plhs[2] = MxArray(b);
        return;
    }
    else if (method == "loadTrainingData3") {
        nargchk(nrhs==4 && nlhs<=3);
        vector<string> filenames(rhs[3].toVector<string>());
        vector<vector<Point2f> > trainlandmarks;
        vector<String> trainimages;
        bool b = cv::face::loadTrainingData(
            vector<String>(filenames.begin(), filenames.end()),
            trainlandmarks, trainimages);
        plhs[0] = MxArray(trainlandmarks);
        if (nlhs > 1)
            plhs[1] = MxArray(trainimages);
        if (nlhs > 2)
            plhs[2] = MxArray(b);
        return;
    }
    else if (method == "loadFacePoints") {
        nargchk(nrhs>=4 && (nrhs%2)==0 && nlhs<=2);
        float offset = 0.0f;
        for (int i=4; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "Offset")
                offset = rhs[i+1].toFloat();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        string filename(rhs[3].toString());
        vector<Point2f> points;
        bool b = cv::face::loadFacePoints(filename, points, offset);
        plhs[0] = MxArray(points);
        if (nlhs > 1)
            plhs[1] = MxArray(b);
        return;
    }
    else if (method == "drawFacemarks") {
        nargchk(nrhs>=5 && (nrhs%2)==1 && nlhs<=1);
        Scalar color(255,0,0);
        for (int i=5; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "Color")
                color = rhs[i+1].toScalar();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat image(rhs[3].toMat(CV_8U));
        vector<Point2f> points(rhs[4].toVector<Point2f>());
        cv::face::drawFacemarks(image, points, color);
        plhs[0] = MxArray(image);
        return;
    }

    // Big operation switch
    Ptr<Facemark> obj = obj_[id];
    if (obj.empty())
        mexErrMsgIdAndTxt("mexopencv:error", "Object not found id=%d", id);
    if (method == "delete") {
        nargchk(nrhs==3 && nlhs==0);
        obj_.erase(id);
        mexUnlock();
    }
    else if (method == "clear") {
        nargchk(nrhs==3 && nlhs==0);
        obj->clear();
    }
    else if (method == "empty") {
        nargchk(nrhs==3 && nlhs<=1);
        plhs[0] = MxArray(obj->empty());
    }
    else if (method == "getDefaultName") {
        nargchk(nrhs==3 && nlhs<=1);
        plhs[0] = MxArray(obj->getDefaultName());
    }
    else if (method == "read") {
        nargchk(nrhs>=4 && (nrhs%2)==0 && nlhs==0);
        string objname;
        bool loadFromString = false;
        for (int i=4; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "ObjName")
                objname = rhs[i+1].toString();
            else if (key == "FromString")
                loadFromString = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        FileStorage fs(rhs[3].toString(), FileStorage::READ +
            (loadFromString ? FileStorage::MEMORY : 0));
        if (!fs.isOpened())
            mexErrMsgIdAndTxt("mexopencv:error", "Failed to open file");
        FileNode fn(objname.empty() ? fs.getFirstTopLevelNode() : fs[objname]);
        if (fn.empty())
            mexErrMsgIdAndTxt("mexopencv:error", "Failed to get node");
        obj->read(fn);
    }
    else if (method == "write") {
        nargchk(nrhs==4 && nlhs<=1);
        FileStorage fs(rhs[3].toString(), FileStorage::WRITE +
            ((nlhs > 0) ? FileStorage::MEMORY : 0));
        if (!fs.isOpened())
            mexErrMsgIdAndTxt("mexopencv:error", "Failed to open file");
        fs << obj->getDefaultName() << "{";
        obj->write(fs);
        fs << "}";
        if (nlhs > 0)
            plhs[0] = MxArray(fs.releaseAndGetString());
    }
    else if (method == "addTrainingSample") {
        nargchk(nrhs==5 && nlhs<=1);
        Mat image(rhs[3].toMat(CV_8U));
        vector<Point2f> landmarks(rhs[4].toVector<Point2f>());
        bool b = obj->addTrainingSample(image, landmarks);
        plhs[0] = MxArray(b);
    }
    else if (method == "training") {
        nargchk(nrhs==3 && nlhs==0);
        obj->training(NULL);  //NOTE: null for unused input
    }
    else if (method == "loadModel") {
        nargchk(nrhs==4 && nlhs==0);
        string model(rhs[3].toString());
        obj->loadModel(model);
    }
    else if (method == "fit") {
        nargchk(nrhs>=5 && (nrhs%2)==1 && nlhs<=2);
        vector<FacemarkAAM::Config> configs;
        for (int i=5; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "Configs")
                configs = MxArrayToVectorConfig(rhs[i+1]);
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat image(rhs[3].toMat(CV_8U));
        vector<Rect> faces(rhs[4].toVector<Rect>());
        vector<vector<Point2f> > landmarks;
        bool b = obj->fit(image, faces, landmarks,
            !configs.empty() ? &configs : NULL);
        plhs[0] = MxArray(landmarks);
        if (nlhs > 1)
            plhs[1] = MxArray(b);
    }
    else if (method == "setFaceDetector") {
        nargchk(nrhs==4 && nlhs<=1);
        func = rhs[3].toString();
        bool b = obj->setFaceDetector(matlab_face_detector, NULL);
        plhs[0] = MxArray(b);
    }
    else if (method == "getFaces") {
        nargchk(nrhs==4 && nlhs<=2);
        Mat image(rhs[3].toMat(CV_8U));
        vector<Rect> faces;
        bool b = obj->getFaces(image, faces);
        plhs[0] = MxArray(faces);
        if (nlhs > 1)
            plhs[1] = MxArray(b);
    }
    else if (method == "getData") {
        nargchk(nrhs==3 && nlhs<=2);
        bool b;
        Ptr<FacemarkAAM> p = obj.dynamicCast<FacemarkAAM>();
        if (!p.empty()) {
            // AAM
            FacemarkAAM::Data items;
            b = obj->getData(&items);
            plhs[0] = MxArray(items.s0);
        }
        else {
            // LBF
            b = obj->getData(NULL);  //NOTE: null for unused output
            plhs[0] = MxArray(Mat());
        }
        if (nlhs > 1)
            plhs[1] = MxArray(b);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
