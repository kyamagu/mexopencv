/**
 * @file FacemarkKazemi_.cpp
 * @brief mex interface for cv::face::FacemarkKazemi
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
map<int,Ptr<FacemarkKazemi> > obj_;
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

/** Create an instance of FacemarkKazemi using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created cv::face::FacemarkKazemi
 */
Ptr<FacemarkKazemi> createFacemarkKazemi(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    FacemarkKazemi::Params parameters;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "CascadeDepth")
            parameters.cascade_depth = static_cast<unsigned long>(val.toInt());
        else if (key == "TreeDepth")
            parameters.tree_depth = static_cast<unsigned long>(val.toInt());
        else if (key == "NumTreesPerCascadeLevel")
            parameters.num_trees_per_cascade_level = static_cast<unsigned long>(val.toInt());
        else if (key == "LearningRate")
            parameters.learning_rate = val.toFloat();
        else if (key == "OversamplingAmount")
            parameters.oversampling_amount = static_cast<unsigned long>(val.toInt());
        else if (key == "NumTestCoordinates")
            parameters.num_test_coordinates = static_cast<unsigned long>(val.toInt());
        else if (key == "Lambda")
            parameters.lambda = val.toFloat();
        else if (key == "NumTestSplits")
            parameters.num_test_splits = static_cast<unsigned long>(val.toInt());
        else if (key == "ConfigFile")
            parameters.configfile = val.toString();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return FacemarkKazemi::create(parameters);
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
    nargchk(nrhs>=3 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    int id = rhs[0].toInt();
    func = rhs[1].toString();
    string method(rhs[2].toString());

    // constructor call
    if (method == "new") {
        nargchk(nrhs>=3 && nlhs<=1);
        obj_[++last_id] = createFacemarkKazemi(rhs.begin() + 3, rhs.end());
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }

    // Big operation switch
    Ptr<FacemarkKazemi> obj = obj_[id];
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
    else if (method == "training") {
        nargchk(nrhs>=7 && (nrhs%2)==1 && nlhs<=1);
        string modelFilename = "face_landmarks.dat";
        for (int i=7; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "ModelFilename")
                modelFilename = rhs[i+1].toString();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        //vector<Mat> images(rhs[3].toVector<Mat>());
        vector<Mat> images;
        {
            vector<MxArray> arr(rhs[3].toVector<MxArray>());
            images.reserve(arr.size());
            for (vector<MxArray>::const_iterator it = arr.begin(); it != arr.end(); ++it)
                images.push_back(it->toMat(CV_8U));
        }
        vector<vector<Point2f> > landmarks(MxArrayToVectorVectorPoint<float>(rhs[4]));
        string configfile(rhs[5].toString());
        Size scale(rhs[6].toSize());
        bool b = obj->training(images, landmarks, configfile, scale, modelFilename);
        plhs[0] = MxArray(b);
    }
    else if (method == "loadModel") {
        nargchk(nrhs==4 && nlhs==0);
        string filename(rhs[3].toString());
        obj->loadModel(filename);
    }
    else if (method == "fit") {
        nargchk(nrhs==5 && nlhs<=2);
        Mat image(rhs[3].toMat(CV_8U));
        vector<Rect> faces(rhs[4].toVector<Rect>());
        vector<vector<Point2f> > landmarks;
        bool b = obj->fit(image, faces, landmarks);
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
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
