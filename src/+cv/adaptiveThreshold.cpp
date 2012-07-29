/**
 * @file adaptiveThreshold.cpp
 * @brief mex interface for adaptiveThreshold
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

/** Adaptive thresholding type map for option processing
 */
const ConstMap<std::string,int> AdaptiveMethod = ConstMap<std::string,int>
    ("Mean",    cv::ADAPTIVE_THRESH_MEAN_C)
    ("Gaussian",cv::ADAPTIVE_THRESH_GAUSSIAN_C);

/**
 * Main entry called from Matlab
 * @param nlhs number of left-hand-side arguments
 * @param plhs pointers to mxArrays in the left-hand-side
 * @param nrhs number of right-hand-side arguments
 * @param prhs pointers to mxArrays in the right-hand-side
 *
 * This is the entry point of the function
 */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    
    // Check the input format
    if (nrhs<2 || (nrhs%2)!=0 || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Option processing
    int adaptiveMethod = ADAPTIVE_THRESH_MEAN_C;
    int thresholdType = THRESH_BINARY;
    int blockSize = 3;
    double C = 5;
    for (int i=2; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="AdaptiveMethod")
            adaptiveMethod = AdaptiveMethod[rhs[i+1].toString()];
        else if (key=="ThresholdType") {
            thresholdType = ThreshType[rhs[i+1].toString()];
            if (!(thresholdType==THRESH_BINARY||thresholdType==THRESH_BINARY_INV))
                mexErrMsgIdAndTxt("mexopencv:error","Invalid threshold type");
        }
        else if (key=="BlockSize") {
            blockSize = rhs[i+1].toInt();
            if ((blockSize%2)!=1)
                mexErrMsgIdAndTxt("mexopencv:error","BlockSize must be odd");
        }
        else if (key=="C")
            C = rhs[i+1].toDouble();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    
    // Apply
    Mat src(rhs[0].toMat(CV_8U)), dst;
    double maxValue = rhs[1].toDouble();
    adaptiveThreshold(src, dst, maxValue, adaptiveMethod, thresholdType,
        blockSize, C);
    plhs[0] = MxArray(dst);
}
