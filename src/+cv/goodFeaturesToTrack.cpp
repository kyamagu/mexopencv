/**
 * @file goodFeaturesToTrack.cpp
 * @brief mex interface for goodFeaturesToTrack
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
    if (nrhs<1 || ((nrhs%2)!=1) || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    int maxCorners=1000;
    double qualityLevel=0.01;
    double minDistance=2.0;
    Mat mask;
    int blockSize=3;
    bool useHarrisDetector=false;
    double k=0.04;
    for (int i=1; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="MaxCorners")
            maxCorners = rhs[i+1].toInt();
        else if (key=="QualityLevel")
            qualityLevel = rhs[i+1].toDouble();
        else if (key=="MinDistance")
            minDistance = rhs[i+1].toDouble();
        else if (key=="Mask")
            mask = rhs[i+1].toMat(CV_8U);
        else if (key=="BlockSize")
            blockSize = rhs[i+1].toInt();
        else if (key=="UseHarrisDetector")
            useHarrisDetector = rhs[i+1].toBool();
        else if (key=="K")
            k = rhs[i+1].toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    
    // Process
    Mat image = (rhs[0].isUint8()) ? rhs[0].toMat(CV_8U) : rhs[0].toMat(CV_32F);
    vector<Point2f> corners;
    goodFeaturesToTrack(image, corners, maxCorners, qualityLevel, minDistance,
        mask, blockSize, useHarrisDetector, k);
    plhs[0] = MxArray(corners);
}
