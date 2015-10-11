/**
 * @file StereoBM_.cpp
 * @brief mex interface for cv::StereoBM
 * @ingroup calib3d
 * @author Kota Yamaguchi, Amro
 * @date 2012, 2015
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<StereoBM> > obj_;

/// Option values for StereoBM PreFilterType
const ConstMap<string, int> PreFilerTypeMap = ConstMap<string, int>
    ("NormalizedResponse", StereoBM::PREFILTER_NORMALIZED_RESPONSE)
    ("XSobel",             StereoBM::PREFILTER_XSOBEL);
const ConstMap<int, string> InvPreFilerTypeMap = ConstMap<int, string>
    (StereoBM::PREFILTER_NORMALIZED_RESPONSE, "NormalizedResponse")
    (StereoBM::PREFILTER_XSOBEL,              "XSobel");
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
        nargchk((nrhs%2)==0 && nlhs<=1);
        int numDisparities = 0;
        int blockSize = 21;
        for (int i=2; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="NumDisparities")
                numDisparities = rhs[i+1].toInt();
            else if (key=="BlockSize")
                blockSize = rhs[i+1].toInt();
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
        }
        obj_[++last_id] = StereoBM::create(numDisparities, blockSize);
        plhs[0] = MxArray(last_id);
        return;
    }

    // Big operation switch
    Ptr<StereoBM> obj = obj_[id];
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
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
            if (key=="ObjName")
                objname = rhs[i+1].toString();
            else if (key=="FromString")
                loadFromString = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
        }
        obj_[id] = (loadFromString ?
            Algorithm::loadFromString<StereoBM>(rhs[2].toString(), objname) :
            Algorithm::load<StereoBM>(rhs[2].toString(), objname));
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
        if (prop == "PreFilterCap")
            plhs[0] = MxArray(obj->getPreFilterCap());
        else if (prop == "PreFilterSize")
            plhs[0] = MxArray(obj->getPreFilterSize());
        else if (prop == "PreFilterType")
            plhs[0] = MxArray(InvPreFilerTypeMap[obj->getPreFilterType()]);
        else if (prop == "ROI1")
            plhs[0] = MxArray(obj->getROI1());
        else if (prop == "ROI2")
            plhs[0] = MxArray(obj->getROI2());
        else if (prop == "SmallerBlockSize")
            plhs[0] = MxArray(obj->getSmallerBlockSize());
        else if (prop == "TextureThreshold")
            plhs[0] = MxArray(obj->getTextureThreshold());
        else if (prop == "UniquenessRatio")
            plhs[0] = MxArray(obj->getUniquenessRatio());
        else if (prop == "BlockSize")
            plhs[0] = MxArray(obj->getBlockSize());
        else if (prop == "Disp12MaxDiff")
            plhs[0] = MxArray(obj->getDisp12MaxDiff());
        else if (prop == "MinDisparity")
            plhs[0] = MxArray(obj->getMinDisparity());
        else if (prop == "NumDisparities")
            plhs[0] = MxArray(obj->getNumDisparities());
        else if (prop == "SpeckleRange")
            plhs[0] = MxArray(obj->getSpeckleRange());
        else if (prop == "SpeckleWindowSize")
            plhs[0] = MxArray(obj->getSpeckleWindowSize());
        else
            mexErrMsgIdAndTxt("mexopencv:error", "Unrecognized property");
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        if (prop == "PreFilterCap")
            obj->setPreFilterCap(rhs[3].toInt());
        else if (prop == "PreFilterSize")
            obj->setPreFilterSize(rhs[3].toInt());
        else if (prop == "PreFilterType")
            obj->setPreFilterType(PreFilerTypeMap[rhs[3].toString()]);
        else if (prop == "ROI1")
            obj->setROI1(rhs[3].toRect());
        else if (prop == "ROI2")
            obj->setROI2(rhs[3].toRect());
        else if (prop == "SmallerBlockSize")
            obj->setSmallerBlockSize(rhs[3].toInt());
        else if (prop == "TextureThreshold")
            obj->setTextureThreshold(rhs[3].toInt());
        else if (prop == "UniquenessRatio")
            obj->setUniquenessRatio(rhs[3].toInt());
        else if (prop == "BlockSize")
            obj->setBlockSize(rhs[3].toInt());
        else if (prop == "Disp12MaxDiff")
            obj->setDisp12MaxDiff(rhs[3].toInt());
        else if (prop == "MinDisparity")
            obj->setMinDisparity(rhs[3].toInt());
        else if (prop == "NumDisparities")
            obj->setNumDisparities(rhs[3].toInt());
        else if (prop == "SpeckleRange")
            obj->setSpeckleRange(rhs[3].toInt());
        else if (prop == "SpeckleWindowSize")
            obj->setSpeckleWindowSize(rhs[3].toInt());
        else
            mexErrMsgIdAndTxt("mexopencv:error", "Unrecognized property");
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation");
}
