/**
 * @file FAST.cpp
 * @brief mex interface for cv::FAST
 * @ingroup features2d
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

namespace {
/// FAST neighborhood types
const ConstMap<string, int> FASTTypeMap = ConstMap<string, int>
    ("TYPE_5_8",  cv::FastFeatureDetector::TYPE_5_8)
    ("TYPE_7_12", cv::FastFeatureDetector::TYPE_7_12)
    ("TYPE_9_16", cv::FastFeatureDetector::TYPE_9_16);
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
    nargchk(nrhs>=1 && (nrhs%2)==1 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    int threshold = 10;
    bool nonmaxSupression = true;
    int type = cv::FastFeatureDetector::TYPE_9_16;
    for (int i=1; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "Threshold")
            threshold = rhs[i+1].toInt();
        else if (key == "NonmaxSuppression")
            nonmaxSupression = rhs[i+1].toBool();
        else if (key == "Type")
            type = FASTTypeMap[rhs[i+1].toString()];
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s",key.c_str());
    }

    // Process
    Mat image(rhs[0].toMat(CV_8U));
    vector<KeyPoint> keypoints;
    FAST(image, keypoints, threshold, nonmaxSupression, type);
    plhs[0] = MxArray(keypoints);
}
