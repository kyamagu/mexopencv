/**
 * @file AffineFeature2D_.cpp
 * @brief mex interface for cv::xfeatures2d::AffineFeature2D
 * @ingroup xfeatures2d
 * @author Amro
 * @date 2017
 */
#include "mexopencv.hpp"
#include "mexopencv_features2d.hpp"
#include "opencv2/xfeatures2d.hpp"
#include <typeinfo>
using namespace std;
using namespace cv;
using namespace cv::xfeatures2d;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<AffineFeature2D> > obj_;

/// Field names for cv::xfeatures2d::Elliptic_KeyPoint.
const char *cv_elliptic_keypoint_fields[9] = {"pt", "size", "angle",
    "response", "octave", "class_id", "axes", "si", "transf"};

MxArray toStruct(const Elliptic_KeyPoint &kpt)
{
    MxArray s = MxArray::Struct(cv_elliptic_keypoint_fields, 9);
    s.set("pt",       kpt.pt);
    s.set("size",     kpt.size);
    s.set("angle",    kpt.angle);
    s.set("response", kpt.response);
    s.set("octave",   kpt.octave);
    s.set("class_id", kpt.class_id);
    s.set("axes",     kpt.axes);
    s.set("si",       kpt.si);
    s.set("transf",   kpt.transf);
    return s;
}

MxArray toStruct(const vector<Elliptic_KeyPoint> &kpts)
{
    MxArray s = MxArray::Struct(cv_elliptic_keypoint_fields, 9, 1, kpts.size());
    for (mwIndex i = 0; i < kpts.size(); ++i) {
        s.set("pt",       kpts[i].pt,       i);
        s.set("size",     kpts[i].size,     i);
        s.set("angle",    kpts[i].angle,    i);
        s.set("response", kpts[i].response, i);
        s.set("octave",   kpts[i].octave,   i);
        s.set("class_id", kpts[i].class_id, i);
        s.set("axes",     kpts[i].axes,     i);
        s.set("si",       kpts[i].si,       i);
        s.set("transf",   kpts[i].transf,   i);
    }
    return s;
}

Elliptic_KeyPoint MxArrayToEllipticKeyPoint(const MxArray &arr, mwIndex idx)
{
    Elliptic_KeyPoint kpt;
    kpt.pt       = arr.at("pt", idx).toPoint2f();
    kpt.size     = arr.at("size", idx).toFloat();
    kpt.angle    = arr.isField("angle")    ? arr.at("angle", idx).toFloat() : -1;
    kpt.response = arr.isField("response") ? arr.at("response", idx).toFloat() : 0;
    kpt.octave   = arr.isField("octave")   ? arr.at("octave", idx).toInt() : 0;
    kpt.class_id = arr.isField("class_id") ? arr.at("class_id", idx).toInt() : -1;
    kpt.axes     = arr.at("axes", idx).toSize_<float>();
    kpt.si       = arr.at("si", idx).toFloat();
    kpt.transf   = arr.at("transf", idx).toMatx<float,2,3>();
    return kpt;
}

vector<Elliptic_KeyPoint> MxArrayToVectorEllipticKeyPoint(const MxArray &arr)
{
    const mwSize n = arr.numel();
    vector<Elliptic_KeyPoint> v;
    v.reserve(n);
    if (arr.isCell())
        for (mwIndex i = 0; i < n; ++i)
            v.push_back(MxArrayToEllipticKeyPoint(arr.at<MxArray>(i), 0));
    else if (arr.isStruct())
        for (mwIndex i = 0; i < n; ++i)
            v.push_back(MxArrayToEllipticKeyPoint(arr, i));
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "MxArray unable to convert to vector<Elliptic_KeyPoint>");
    return v;
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
    nargchk(nrhs>=2 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());

    // Constructor is called. Create a new object from argument
    if (method == "new") {
        nargchk((nrhs==3 || nrhs==4) && nlhs<=1);
        // detector
        Ptr<FeatureDetector> detector;
        if (rhs[2].isChar())
            detector = createFeatureDetector(
                rhs[2].toString(), rhs.end(), rhs.end());
        else if (rhs[2].isCell() && rhs[2].numel() >= 1) {
            vector<MxArray> args(rhs[2].toVector<MxArray>());
            detector = createFeatureDetector(
                args[0].toString(), args.begin() + 1, args.end());
        }
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Invalid detector arguments");
        // extractor
        Ptr<DescriptorExtractor> extractor;
        if (nrhs == 4) {
            if (rhs[3].isChar())
                extractor = createDescriptorExtractor(
                    rhs[3].toString(), rhs.end(), rhs.end());
            else if (rhs[3].isCell() && rhs[3].numel() >= 1) {
                vector<MxArray> args(rhs[3].toVector<MxArray>());
                extractor = createDescriptorExtractor(
                    args[0].toString(), args.begin() + 1, args.end());
            }
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Invalid extractor arguments");
        }
        obj_[++last_id] = (nrhs == 3) ? AffineFeature2D::create(detector) :
            AffineFeature2D::create(detector, extractor);
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }

    // Big operation switch
    Ptr<AffineFeature2D> obj = obj_[id];
    if (obj.empty())
        mexErrMsgIdAndTxt("mexopencv:error", "Object not found id=%d", id);
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
        mexUnlock();
    }
    else if (method == "typeid") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(string(typeid(*obj).name()));
    }
    else if (method == "clear") {
        nargchk(nrhs==2 && nlhs==0);
        obj->clear();
    }
    else if (method == "load") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs==0);
        string objname;
        bool loadFromString = false;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "ObjName")
                objname = rhs[i+1].toString();
            else if (key == "FromString")
                loadFromString = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        /*
        obj_[id] = (loadFromString ?
            Algorithm::loadFromString<AffineFeature2D>(rhs[2].toString(), objname) :
            Algorithm::load<AffineFeature2D>(rhs[2].toString(), objname));
        */
        ///*
        // HACK: workaround for missing AffineFeature2D::create()
        FileStorage fs(rhs[2].toString(), FileStorage::READ +
            (loadFromString ? FileStorage::MEMORY : 0));
        if (!fs.isOpened())
            mexErrMsgIdAndTxt("mexopencv:error", "Failed to open file");
        FileNode fn(objname.empty() ? fs.getFirstTopLevelNode() : fs[objname]);
        if (fn.empty())
            mexErrMsgIdAndTxt("mexopencv:error", "Failed to get node");
        obj->read(fn);
        //*/
    }
    else if (method == "save") {
        nargchk(nrhs==3 && nlhs==0);
        obj->save(rhs[2].toString());
    }
    else if (method == "empty") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->empty());
    }
    else if (method == "getDefaultName") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->getDefaultName());
    }
    else if (method == "defaultNorm") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(NormTypeInv[obj->defaultNorm()]);
    }
    else if (method == "descriptorSize") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->descriptorSize());
    }
    else if (method == "descriptorType") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(ClassNameInvMap[obj->descriptorType()]);
    }
    else if (method == "detect") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=1);
        if (rhs[2].isNumeric()) {  // first variant that accepts an image
            Mat mask;
            for (int i=3; i<nrhs; i+=2) {
                string key(rhs[i].toString());
                if (key == "Mask")
                    mask = rhs[i+1].toMat(CV_8U);
                else
                    mexErrMsgIdAndTxt("mexopencv:error",
                        "Unrecognized option %s", key.c_str());
            }
            Mat image(rhs[2].toMat(CV_8U));
            vector<KeyPoint> keypoints;
            obj->detect(image, keypoints, mask);
            plhs[0] = MxArray(keypoints);
        }
        else if (rhs[2].isCell()) {  // second variant that accepts an image set
            vector<Mat> masks;
            for (int i=3; i<nrhs; i+=2) {
                string key(rhs[i].toString());
                if (key == "Mask") {
                    //masks = rhs[i+1].toVector<Mat>();
                    vector<MxArray> arr(rhs[i+1].toVector<MxArray>());
                    masks.clear();
                    masks.reserve(arr.size());
                    for (vector<MxArray>::const_iterator it = arr.begin(); it != arr.end(); ++it)
                        masks.push_back(it->toMat(CV_8U));
                }
                else
                    mexErrMsgIdAndTxt("mexopencv:error",
                        "Unrecognized option %s", key.c_str());
            }
            //vector<Mat> images(rhs[2].toVector<Mat>());
            vector<Mat> images;
            {
                vector<MxArray> arr(rhs[2].toVector<MxArray>());
                images.reserve(arr.size());
                for (vector<MxArray>::const_iterator it = arr.begin(); it != arr.end(); ++it)
                    images.push_back(it->toMat(CV_8U));
            }
            vector<vector<KeyPoint> > keypoints;
            obj->detect(images, keypoints, masks);
            plhs[0] = MxArray(keypoints);
        }
        else
            mexErrMsgIdAndTxt("mexopencv:error", "Invalid arguments");
    }
    else if (method == "compute") {
        nargchk(nrhs==4 && nlhs<=2);
        if (rhs[2].isNumeric()) {  // first variant that accepts an image
            Mat image(rhs[2].toMat(CV_8U)), descriptors;
            vector<KeyPoint> keypoints(rhs[3].toVector<KeyPoint>());
            obj->compute(image, keypoints, descriptors);
            plhs[0] = MxArray(descriptors);
            if (nlhs > 1)
                plhs[1] = MxArray(keypoints);
        }
        else if (rhs[2].isCell()) { // second variant that accepts an image set
            //vector<Mat> images(rhs[2].toVector<Mat>());
            vector<Mat> images, descriptors;
            {
                vector<MxArray> arr(rhs[2].toVector<MxArray>());
                images.reserve(arr.size());
                for (vector<MxArray>::const_iterator it = arr.begin(); it != arr.end(); ++it)
                    images.push_back(it->toMat(CV_8U));
            }
            vector<vector<KeyPoint> > keypoints(rhs[3].toVector(
                const_mem_fun_ref_t<vector<KeyPoint>, MxArray>(
                &MxArray::toVector<KeyPoint>)));
            obj->compute(images, keypoints, descriptors);
            plhs[0] = MxArray(descriptors);
            if (nlhs > 1)
                plhs[1] = MxArray(keypoints);
        }
        else
            mexErrMsgIdAndTxt("mexopencv:error", "Invalid arguments");
    }
    else if (method == "detectAndCompute") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=2);
        Mat mask;
        vector<KeyPoint> keypoints;
        bool useProvidedKeypoints = false;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "Mask")
                mask = rhs[i+1].toMat(CV_8U);
            else if (key == "Keypoints") {
                keypoints = rhs[i+1].toVector<KeyPoint>();
                useProvidedKeypoints = true;
            }
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat image(rhs[2].toMat(CV_8U)), descriptors;
        obj->detectAndCompute(image, mask, keypoints, descriptors,
            useProvidedKeypoints);
        plhs[0] = MxArray(keypoints);
        if (nlhs > 1)
            plhs[1] = MxArray(descriptors);
    }
    else if (method == "detect_elliptic") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=1);
        Mat mask;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "Mask")
                mask = rhs[i+1].toMat(CV_8U);
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat image(rhs[2].toMat(CV_8U));
        vector<Elliptic_KeyPoint> keypoints;
        obj->detect(image, keypoints, mask);
        plhs[0] = toStruct(keypoints);
    }
    else if (method == "detectAndCompute_elliptic") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=2);
        Mat mask;
        vector<Elliptic_KeyPoint> keypoints;
        bool useProvidedKeypoints = false;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "Mask")
                mask = rhs[i+1].toMat(CV_8U);
            else if (key == "Keypoints") {
                keypoints = MxArrayToVectorEllipticKeyPoint(rhs[i+1]);
                useProvidedKeypoints = true;
            }
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat image(rhs[2].toMat(CV_8U)), descriptors;
        obj->detectAndCompute(image, mask, keypoints, descriptors,
            useProvidedKeypoints);
        plhs[0] = toStruct(keypoints);
        if (nlhs > 1)
            plhs[1] = MxArray(descriptors);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s",method.c_str());
}
