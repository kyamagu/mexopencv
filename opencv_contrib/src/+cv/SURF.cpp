/**
 * @file SURF.cpp
 * @brief mex interface for SURF
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
#include "opencv2/nonfree/nonfree.hpp"
using namespace std;
using namespace cv;

namespace {

/// Initialization flag
bool initialized = false;

}


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

    if (!initialized) {
        initModule_nonfree();
        initialized = true;
    }

    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);

    // return the descriptor size (64/128)
    if (nrhs==1 && rhs[0].isChar() && rhs[0].toString()=="DescriptorSize") {
        plhs[0] = MxArray(SURF().descriptorSize());
        return;
    }

    // Option processing
    double hessianThreshold=100;
    int nOctaves=4;
    int nOctaveLayers=2;
    bool extended=true;
    bool upright=false;
    Mat mask;
    for (int i=1; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="HessianThreshold")
            hessianThreshold = rhs[i+1].toDouble();
        else if (key=="NOctaves")
            nOctaves = rhs[i+1].toInt();
        else if (key=="NOctaveLayers")
            nOctaveLayers = rhs[i+1].toInt();
        else if (key=="Extended")
            extended = rhs[i+1].toBool();
        else if (key=="UpRight")
            upright = rhs[i+1].toBool();
        else if (key=="Mask")
            mask = rhs[i+1].toMat(CV_8U);
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    SURF surf(hessianThreshold,nOctaves,nOctaveLayers,extended,upright);
    Mat image(rhs[0].toMat());
    vector<KeyPoint> keypoints;
    bool useProvidedKeypoints=false;
    if (nlhs>1) {
        vector<float> descriptors;
        surf(image, mask, keypoints, descriptors, useProvidedKeypoints);
        Mat m(descriptors);
        plhs[1] = MxArray(m.reshape(0, keypoints.size()));
    }
    else
        surf(image, mask, keypoints);
    plhs[0] = MxArray(keypoints);
}
