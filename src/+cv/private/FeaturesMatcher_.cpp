/**
 * @file FeaturesMatcher_.cpp
 * @brief mex interface for cv::detail::FeaturesMatcher
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
map<int,Ptr<FeaturesMatcher> > obj_;
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
        nargchk(nrhs>=3 && nlhs<=1);
        obj_[++last_id] = createFeaturesMatcher(
            rhs[2].toString(), rhs.begin() + 3, rhs.end());
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }
    // static methods
    else if (method == "matchesGraphAsString") {
        nargchk(nrhs==4 && nlhs<=1);
        vector<MatchesInfo> pairwise_matches(MxArrayToVectorMatchesInfo(rhs[2]));
        float conf_threshold = rhs[3].toFloat();
        vector<String> pathes;
        pathes.reserve(pairwise_matches.size());
        for (int i=0; i<pairwise_matches.size(); ++i) {
            ostringstream ss;
            ss << "img" << (i+1);
            pathes.push_back(ss.str());
        }
        string str(matchesGraphAsString(
            pathes, pairwise_matches, conf_threshold));
        plhs[0] = MxArray(str);
        return;
    }
    else if (method == "leaveBiggestComponent") {
        nargchk(nrhs==5 && nlhs<=1);
        vector<ImageFeatures> features(MxArrayToVectorImageFeatures(rhs[2]));
        vector<MatchesInfo> pairwise_matches(MxArrayToVectorMatchesInfo(rhs[3]));
        float conf_threshold = rhs[4].toFloat();
        vector<int> indices(leaveBiggestComponent(
            features, pairwise_matches, conf_threshold));
        plhs[0] = MxArray(indices);
        return;
    }

    // Big operation switch
    Ptr<FeaturesMatcher> obj = obj_[id];
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
    else if (method == "collectGarbage") {
        nargchk(nrhs==2 && nlhs==0);
        obj->collectGarbage();
    }
    else if (method == "isThreadSafe") {
        nargchk(nrhs==2 && nlhs<=1);
        bool tf = obj->isThreadSafe();
        plhs[0] = MxArray(tf);
    }
    else if (method == "match") {
        nargchk(nrhs==4 && nlhs<=1);
        ImageFeatures features1(MxArrayToImageFeatures(rhs[2])),
                      features2(MxArrayToImageFeatures(rhs[3]));
        MatchesInfo matches_info;
        obj->operator()(features1, features2, matches_info);
        plhs[0] = toStruct(matches_info);
    }
    else if (method == "match_pairwise") {
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
        vector<ImageFeatures> features(MxArrayToVectorImageFeatures(rhs[2]));
        vector<MatchesInfo> pairwise_matches;
        obj->operator()(features, pairwise_matches, mask.getUMat(ACCESS_READ));
        plhs[0] = toStruct(pairwise_matches);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
