/**
 * @file distanceTransform.cpp
 * @brief mex interface for distanceTransform
 * @author Kota Yamaguchi
 * @date 2012
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

/** Mask size for distance transform
 */
const ConstMap<std::string,int> DistMask = ConstMap<std::string,int>
    ("3",CV_DIST_MASK_3)
    ("5",CV_DIST_MASK_5)
    ("Precise",CV_DIST_MASK_PRECISE);

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
    int distanceType = CV_DIST_L2;
    int maskSize = 3;
    for (int i=1; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="DistanceType") {
            distanceType = DistType[rhs[i+1].toString()];
            if (distanceType!=CV_DIST_L1 &&
                distanceType!=CV_DIST_L2 &&
                distanceType!=CV_DIST_C)
                mexErrMsgIdAndTxt("mexopencv:error","Unsupported option");
        }
        else if (key=="MaskSize")
            if (rhs[i].classID()==mxCHAR_CLASS && rhs[i+1].toString()=="MaskPrecise")
                maskSize = CV_DIST_MASK_PRECISE;
            else
                maskSize = rhs[i+1].toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    
    // Process
    Mat src(rhs[0].toMat()), dst;
    if (nlhs > 1) {
        Mat labels;
        distanceTransform(src, dst, labels, distanceType, maskSize);
        plhs[0] = MxArray(dst);
        plhs[1] = MxArray(labels);
    }
    else {
        distanceTransform(src, dst, distanceType, maskSize);
        plhs[0] = MxArray(dst);
    }
}
