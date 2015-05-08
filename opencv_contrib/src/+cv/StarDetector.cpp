/**
 * @file StarDetector.cpp
 * @brief mex interface for StarDetector
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

/**
 * Main entry called from Matlab
 * @param nlhs number of left-hand-side arguments
 * @param plhs pointers to mxArrays in the left-hand-side
 * @param nrhs number of right-hand-side arguments
 * @param prhs pointers to mxArrays in the right-hand-side
 */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    // Check the number of arguments
    if (nrhs<1 || ((nrhs%2)!=1) || nlhs>2)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    
    // Option processing
    int maxSize = 45;
    int responseThreshold = 30;
    int lineThresholdProjected = 10;
    int lineThresholdBinarized = 8;
    int suppressNonmaxSize = 5;
    for (int i=1; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="MaxSize")
            maxSize = rhs[i+1].toInt();
        else if (key=="ResponseThreshold")
            responseThreshold = rhs[i+1].toInt();
        else if (key=="LineThresholdProjected")
            lineThresholdProjected = rhs[i+1].toInt();
        else if (key=="LineThresholdBinarized")
            lineThresholdBinarized = rhs[i+1].toInt();
        else if (key=="SuppressNonmaxSize")
            suppressNonmaxSize = rhs[i+1].toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    
    // Process
    StarDetector star_detector(maxSize, responseThreshold,
        lineThresholdProjected, lineThresholdBinarized, suppressNonmaxSize);
    Mat image(rhs[0].toMat());
    vector<KeyPoint> keypoints;
    star_detector(image, keypoints);
    plhs[0] = MxArray(keypoints);
}
