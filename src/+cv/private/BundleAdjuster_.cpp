/**
 * @file BundleAdjuster_.cpp
 * @brief mex interface for cv::detail::BundleAdjusterBase
 * @ingroup stitching
 * @author Amro
 * @date 2016
 */
#include "mexopencv.hpp"
#include "mexopencv_stitching.hpp"
#include "opencv2/stitching.hpp"
#include <typeinfo>
using namespace std;
using namespace cv;
using namespace cv::detail;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<BundleAdjusterBase> > obj_;
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
        nargchk(nrhs>=3 && nlhs<=1);
        obj_[++last_id] = createBundleAdjusterBase(
            rhs[2].toString(), rhs.begin() + 3, rhs.end());
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }
    // static methods
    else if (method == "waveCorrect") {
        nargchk(nrhs>=3 && nlhs<=1);
        WaveCorrectKind kind = cv::detail::WAVE_CORRECT_HORIZ;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "Kind")
                kind = WaveCorrectionMap[rhs[i+1].toString()];
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        vector<Mat> rmats;
        {
            vector<MxArray> arr(rhs[2].toVector<MxArray>());
            rmats.reserve(arr.size());
            for (vector<MxArray>::const_iterator it = arr.begin(); it != arr.end(); ++it)
                rmats.push_back(it->toMat(it->isDouble() ? CV_64F : CV_32F));
        }
        waveCorrect(rmats, kind);
        plhs[0] = MxArray(rmats);
        return;
    }

    // Big operation switch
    Ptr<BundleAdjusterBase> obj = obj_[id];
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
    else if (method == "refine") {
        nargchk(nrhs==5 && nlhs<=2);
        vector<ImageFeatures> features(MxArrayToVectorImageFeatures(rhs[2]));
        vector<MatchesInfo> pairwise_matches(MxArrayToVectorMatchesInfo(rhs[3]));
        vector<CameraParams> cameras(MxArrayToVectorCameraParams(rhs[4]));
        bool success = obj->operator()(features, pairwise_matches, cameras);
        if (nlhs > 1)
            plhs[1] = MxArray(success);
        else if (!success)
            mexErrMsgIdAndTxt("mexopencv:error", "Bundle adjustment failed");
        plhs[0] = toStruct(cameras);
    }
    else if (method == "get") {
        nargchk(nrhs==3 && nlhs<=1);
        string prop(rhs[2].toString());
        if (prop == "ConfThresh")
            plhs[0] = MxArray(obj->confThresh());
        else if (prop == "RefinementMask")
            plhs[0] = MxArray(obj->refinementMask());
        else if (prop == "TermCriteria")
            plhs[0] = MxArray(obj->termCriteria());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        if (prop == "ConfThresh")
            obj->setConfThresh(rhs[3].toDouble());
        else if (prop == "RefinementMask")
            obj->setRefinementMask(rhs[3].toMat(CV_8U));
        else if (prop == "TermCriteria")
            obj->setTermCriteria(rhs[3].toTermCriteria());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
