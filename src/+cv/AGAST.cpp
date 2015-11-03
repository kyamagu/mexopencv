/**
 * @file AGAST.cpp
 * @brief mex interface for cv::AGAST
 * @ingroup features2d
 * @author Amro
 * @date 2015
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

namespace {
/// AGAST neighborhood types
const ConstMap<std::string, int> AgastTypeMap = ConstMap<std::string, int>
    ("AGAST_5_8",   cv::AgastFeatureDetector::AGAST_5_8)
    ("AGAST_7_12d", cv::AgastFeatureDetector::AGAST_7_12d)
    ("AGAST_7_12s", cv::AgastFeatureDetector::AGAST_7_12s)
    ("OAST_9_16",   cv::AgastFeatureDetector::OAST_9_16);
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
    int type = cv::AgastFeatureDetector::OAST_9_16;
    for (int i=1; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "Threshold")
            threshold = rhs[i+1].toInt();
        else if (key == "NonmaxSuppression")
            nonmaxSupression = rhs[i+1].toBool();
        else if (key == "Type")
            type = AgastTypeMap[rhs[i+1].toString()];
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s",key.c_str());
    }

    // Process
    Mat image(rhs[0].toMat(CV_8U));
    vector<KeyPoint> keypoints;
    AGAST(image, keypoints, threshold, nonmaxSupression, type);
    plhs[0] = MxArray(keypoints);
}
