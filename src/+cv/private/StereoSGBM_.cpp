/**
 * @file StereoSGBM_.cpp
 * @brief mex interface for cv::StereoSGBM
 * @ingroup calib3d
 * @author Kota Yamaguchi, Amro
 * @date 2012, 2015
 */
#include "mexopencv.hpp"
#include "opencv2/calib3d.hpp"
using namespace std;
using namespace cv;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<StereoSGBM> > obj_;

/// Option values for StereoSGBM mode
const ConstMap<string, int> SGBMModeMap = ConstMap<string, int>
    ("SGBM",     cv::StereoSGBM::MODE_SGBM)
    ("HH",       cv::StereoSGBM::MODE_HH)
    ("SGBM3Way", cv::StereoSGBM::MODE_SGBM_3WAY)
    ("HH4",      cv::StereoSGBM::MODE_HH4);
const ConstMap<int, string> InvSGBMModeMap = ConstMap<int, string>
    (cv::StereoSGBM::MODE_SGBM,      "SGBM")
    (cv::StereoSGBM::MODE_HH,        "HH")
    (cv::StereoSGBM::MODE_SGBM_3WAY, "SGBM3Way")
    (cv::StereoSGBM::MODE_HH4,       "HH4");

/** Create an instance of StereoSGBM using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created StereoSGBM
 */
Ptr<StereoSGBM> create_StereoSGBM(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    int minDisparity = 0;
    int numDisparities = 16;
    int blockSize = 3;
    int P1 = 0;
    int P2 = 0;
    int disp12MaxDiff = 0;
    int preFilterCap = 0;
    int uniquenessRatio = 0;
    int speckleWindowSize = 0;
    int speckleRange = 0;
    int mode = cv::StereoSGBM::MODE_SGBM;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "MinDisparity")
            minDisparity = val.toInt();
        else if (key == "NumDisparities")
            numDisparities = val.toInt();
        else if (key == "BlockSize")
            blockSize = val.toInt();
        else if (key == "P1")
            P1 = val.toInt();
        else if (key == "P2")
            P2 = val.toInt();
        else if (key == "Disp12MaxDiff")
            disp12MaxDiff = val.toInt();
        else if (key == "PreFilterCap")
            preFilterCap = val.toInt();
        else if (key == "UniquenessRatio")
            uniquenessRatio = val.toInt();
        else if (key == "SpeckleWindowSize")
            speckleWindowSize = val.toInt();
        else if (key == "SpeckleRange")
            speckleRange = val.toInt();
        else if (key == "Mode")
            mode = (val.isChar() ?
                SGBMModeMap[val.toString()] : val.toInt());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return StereoSGBM::create(minDisparity, numDisparities,
        blockSize, P1, P2, disp12MaxDiff, preFilterCap, uniquenessRatio,
        speckleWindowSize, speckleRange, mode);
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
    nargchk(nrhs>=2 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());

    // Constructor is called. Create a new object from argument
    if (method == "new") {
        nargchk(nrhs>=2 && nlhs<=1);
        obj_[++last_id] = create_StereoSGBM(rhs.begin() + 2, rhs.end());
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }

    // Big operation switch
    Ptr<StereoSGBM> obj = obj_[id];
    if (obj.empty())
        mexErrMsgIdAndTxt("mexopencv:error", "Object not found id=%d", id);
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
        mexUnlock();
    }
    else if (method == "clear") {
        nargchk(nrhs==2 && nlhs==0);
        obj->clear();
    }
    else if (method == "save") {
        nargchk(nrhs==3 && nlhs==0);
        obj->save(rhs[2].toString());
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
        obj_[id] = (loadFromString ?
            Algorithm::loadFromString<StereoSGBM>(rhs[2].toString(), objname) :
            Algorithm::load<StereoSGBM>(rhs[2].toString(), objname));
    }
    else if (method == "empty") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->empty());
    }
    else if (method == "getDefaultName") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->getDefaultName());
    }
    else if (method == "compute") {
        nargchk(nrhs==4 && nlhs<=1);
        Mat left(rhs[2].toMat(CV_8U)),
            right(rhs[3].toMat(CV_8U)),
            disparity;
        obj->compute(left, right, disparity);
        plhs[0] = MxArray(disparity);
    }
    else if (method == "get") {
        nargchk(nrhs==3 && nlhs<=1);
        string prop(rhs[2].toString());
        if (prop == "MinDisparity")
            plhs[0] = MxArray(obj->getMinDisparity());
        else if (prop == "NumDisparities")
            plhs[0] = MxArray(obj->getNumDisparities());
        else if (prop == "BlockSize")
            plhs[0] = MxArray(obj->getBlockSize());
        else if (prop == "P1")
            plhs[0] = MxArray(obj->getP1());
        else if (prop == "P2")
            plhs[0] = MxArray(obj->getP2());
        else if (prop == "Disp12MaxDiff")
            plhs[0] = MxArray(obj->getDisp12MaxDiff());
        else if (prop == "PreFilterCap")
            plhs[0] = MxArray(obj->getPreFilterCap());
        else if (prop == "UniquenessRatio")
            plhs[0] = MxArray(obj->getUniquenessRatio());
        else if (prop == "SpeckleWindowSize")
            plhs[0] = MxArray(obj->getSpeckleWindowSize());
        else if (prop == "SpeckleRange")
            plhs[0] = MxArray(obj->getSpeckleRange());
        else if (prop == "Mode")
            plhs[0] = MxArray(InvSGBMModeMap[obj->getMode()]);
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        if (prop == "MinDisparity")
            obj->setMinDisparity(rhs[3].toInt());
        else if (prop == "NumDisparities")
            obj->setNumDisparities(rhs[3].toInt());
        else if (prop == "BlockSize")
            obj->setBlockSize(rhs[3].toInt());
        else if (prop == "P1")
            obj->setP1(rhs[3].toInt());
        else if (prop == "P2")
            obj->setP2(rhs[3].toInt());
        else if (prop == "Disp12MaxDiff")
            obj->setDisp12MaxDiff(rhs[3].toInt());
        else if (prop == "PreFilterCap")
            obj->setPreFilterCap(rhs[3].toInt());
        else if (prop == "UniquenessRatio")
            obj->setUniquenessRatio(rhs[3].toInt());
        else if (prop == "SpeckleWindowSize")
            obj->setSpeckleWindowSize(rhs[3].toInt());
        else if (prop == "SpeckleRange")
            obj->setSpeckleRange(rhs[3].toInt());
        else if (prop == "Mode")
            obj->setMode(rhs[3].isChar() ?
                SGBMModeMap[rhs[3].toString()] : rhs[3].toInt());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
