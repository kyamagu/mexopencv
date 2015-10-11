/**
 * @file StereoSGBM_.cpp
 * @brief mex interface for cv::StereoSGBM
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
map<int,Ptr<StereoSGBM> > obj_;

/// Option values for StereoSGBM mode
const ConstMap<string, int> SGBMModeMap = ConstMap<string, int>
    ("SGBM", StereoSGBM::MODE_SGBM)
    ("HH",   StereoSGBM::MODE_HH);
const ConstMap<int, string> InvSGBMModeMap = ConstMap<int, string>
    (StereoSGBM::MODE_SGBM, "SGBM")
    (StereoSGBM::MODE_HH,   "HH");
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
        int minDisparity = 0;
        int numDisparities = 64;
        int blockSize = 7;
        int P1 = 0;
        int P2 = 0;
        int disp12MaxDiff = 0;
        int preFilterCap = 0;
        int uniquenessRatio = 0;
        int speckleWindowSize = 0;
        int speckleRange = 0;
        int mode = StereoSGBM::MODE_SGBM;
        for (int i=2; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="MinDisparity")
                minDisparity = rhs[i+1].toInt();
            else if (key=="NumDisparities")
                numDisparities = rhs[i+1].toInt();
            else if (key=="BlockSize")
                blockSize = rhs[i+1].toInt();
            else if (key=="P1")
                P1 = rhs[i+1].toInt();
            else if (key=="P2")
                P2 = rhs[i+1].toInt();
            else if (key=="Disp12MaxDiff")
                disp12MaxDiff = rhs[i+1].toInt();
            else if (key=="PreFilterCap")
                preFilterCap = rhs[i+1].toInt();
            else if (key=="UniquenessRatio")
                uniquenessRatio = rhs[i+1].toInt();
            else if (key=="SpeckleWindowSize")
                speckleWindowSize = rhs[i+1].toInt();
            else if (key=="SpeckleRange")
                speckleRange = rhs[i+1].toInt();
            else if (key=="Mode")
                mode = SGBMModeMap[rhs[i+1].toString()];
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
        }
        obj_[++last_id] = StereoSGBM::create(minDisparity, numDisparities,
            blockSize, P1, P2, disp12MaxDiff, preFilterCap, uniquenessRatio,
            speckleWindowSize, speckleRange, mode);
        plhs[0] = MxArray(last_id);
        return;
    }

    // Big operation switch
    Ptr<StereoSGBM> obj = obj_[id];
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
        /*
        obj_[id] = (loadFromString ?
            Algorithm::loadFromString<StereoSGBM>(rhs[2].toString(), objname) :
            Algorithm::load<StereoSGBM>(rhs[2].toString(), objname));
        */
        ///*
        // HACK: workaround because StereoSGBM::create() doesnt accept zero arguments
        FileStorage fs(rhs[2].toString(), FileStorage::READ +
            (loadFromString ? FileStorage::MEMORY : 0));
        obj->read(objname.empty() ? fs.getFirstTopLevelNode() : fs[objname]);
        if (obj.empty())
            mexErrMsgIdAndTxt("mexopencv:error", "Failed to load algorithm");
        //*/
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
        if (prop == "Mode")
            plhs[0] = MxArray(InvSGBMModeMap[obj->getMode()]);
        else if (prop == "P1")
            plhs[0] = MxArray(obj->getP1());
        else if (prop == "P2")
            plhs[0] = MxArray(obj->getP2());
        else if (prop == "PreFilterCap")
            plhs[0] = MxArray(obj->getPreFilterCap());
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
        if (prop == "Mode")
            obj->setMode(SGBMModeMap[rhs[3].toString()]);
        else if (prop == "P1")
            obj->setP1(rhs[3].toInt());
        else if (prop == "P2")
            obj->setP2(rhs[3].toInt());
        else if (prop == "PreFilterCap")
            obj->setPreFilterCap(rhs[3].toInt());
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
