/**
 * @file Estimator_.cpp
 * @brief mex interface for cv::detail::Estimator
 * @ingroup stitching
 * @author Amro
 * @date 2017
 */
#include "mexopencv.hpp"
#include "mexopencv_stitching.hpp"
#include "opencv2/stitching.hpp"
#include "opencv2/stitching/detail/autocalib.hpp"
#include <typeinfo>
using namespace std;
using namespace cv;
using namespace cv::detail;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<Estimator> > obj_;
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
    nargchk(nrhs>=2 && nlhs<=4);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());

    // Constructor is called. Create a new object from argument
    if (method == "new") {
        nargchk(nrhs>=3 && nlhs<=1);
        obj_[++last_id] = createEstimator(
            rhs[2].toString(), rhs.begin() + 3, rhs.end());
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }
    // static methods
    else if (method == "focalsFromHomography") {
        nargchk(nrhs==3 && nlhs<=4);
        Mat H(rhs[2].toMat(CV_64F));
        double f0, f1;
        bool f0_ok, f1_ok;
        focalsFromHomography(H, f0, f1, f0_ok, f1_ok);
        if (nlhs > 2)
            plhs[2] = MxArray(f0_ok);
        else if (!f0_ok)
            mexErrMsgIdAndTxt("mexopencv:error",
                "Estimated focal length along X-axis failed");
        if (nlhs > 3)
            plhs[3] = MxArray(f1_ok);
        else if (!f1_ok)
            mexErrMsgIdAndTxt("mexopencv:error",
                "Estimated focal length along Y-axis failed");
        plhs[0] = MxArray(f0);
        if (nlhs > 1)
            plhs[1] = MxArray(f1);
        return;
    }
    else if (method == "estimateFocal") {
        nargchk(nrhs==4 && nlhs<=1);
        vector<ImageFeatures> features(MxArrayToVectorImageFeatures(rhs[2]));
        vector<MatchesInfo> pairwise_matches(MxArrayToVectorMatchesInfo(rhs[3]));
        vector<double> focals;
        estimateFocal(features, pairwise_matches, focals);
        plhs[0] = MxArray(focals);
        return;
    }
    else if (method == "calibrateRotatingCamera") {
        nargchk(nrhs==3 && nlhs<=2);
        vector<Mat> Hs;
        {
            vector<MxArray> arr(rhs[2].toVector<MxArray>());
            Hs.reserve(arr.size());
            for (vector<MxArray>::const_iterator it = arr.begin(); it != arr.end(); ++it)
                Hs.push_back(it->toMat(CV_64F));
        }
        Mat K;
        bool success = calibrateRotatingCamera(Hs, K);
        if (nlhs > 1)
            plhs[1] = MxArray(success);
        else if (!success)
            mexErrMsgIdAndTxt("mexopencv:error",
                "Calibrating rotating Camera failed");
        plhs[0] = MxArray(K);
        return;
    }

    // Big operation switch
    Ptr<Estimator> obj = obj_[id];
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
    else if (method == "estimate") {
        nargchk(nrhs==4 && nlhs<=2);
        vector<ImageFeatures> features(MxArrayToVectorImageFeatures(rhs[2]));
        vector<MatchesInfo> pairwise_matches(MxArrayToVectorMatchesInfo(rhs[3]));
        vector<CameraParams> cameras;
        bool success = obj->operator()(features, pairwise_matches, cameras);
        if (nlhs > 1)
            plhs[1] = MxArray(success);
        else if (!success)
            mexErrMsgIdAndTxt("mexopencv:error", "Estimation failed");
        plhs[0] = toStruct(cameras);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
