/**
 * @file FASTForPointSet.cpp
 * @brief mex interface for cv::xfeatures2d::FASTForPointSet
 * @ingroup xfeatures2d
 * @author Amro
 * @date 2017
 */
#include "mexopencv.hpp"
#include "opencv2/xfeatures2d.hpp"
using namespace std;
using namespace cv;
using namespace cv::xfeatures2d;

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
    nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    int threshold = 10;
    bool nonmaxSupression = true;
    int type = cv::FastFeatureDetector::TYPE_9_16;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "Threshold")
            threshold = rhs[i+1].toInt();
        else if (key == "NonmaxSuppression")
            nonmaxSupression = rhs[i+1].toBool();
        else if (key == "Type")
            type = FASTTypeMap[rhs[i+1].toString()];
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat image(rhs[0].toMat(CV_8U));
    vector<KeyPoint> keypoints(rhs[1].toVector<KeyPoint>());
    FASTForPointSet(image, keypoints, threshold, nonmaxSupression, type);
    plhs[0] = MxArray(keypoints);
}
