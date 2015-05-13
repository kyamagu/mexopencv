/**
 * @file SIFT.cpp
 * @brief mex interface for SIFT
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
#include "opencv2/xfeatures2d.hpp"
using namespace std;
using namespace cv;
using namespace cv::xfeatures2d;

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

    // return the descriptor size (128)
    if (nrhs==1 && rhs[0].isChar() && rhs[0].toString()=="DescriptorSize") {
        plhs[0] = MxArray((SIFT::create())->descriptorSize());
        return;
    }

    // Option processing
    Mat mask;
    int _nfeatures=0;
    int _nOctaveLayers=3;
    double _contrastThreshold=0.04;
    double _edgeThreshold=10;
    double _sigma=1.6;
    for (int i=1; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="NFeatures")
            _nfeatures = rhs[i+1].toInt();
        else if (key=="NOctaveLayers")
            _nOctaveLayers = rhs[i+1].toInt();
        else if (key=="ConstrastThreshold")
            _contrastThreshold = rhs[i+1].toDouble();
        else if (key=="EdgeThreshold")
            _edgeThreshold = rhs[i+1].toDouble();
        else if (key=="Sigma")
            _sigma = rhs[i+1].toDouble();
        else if (key=="Mask")
            mask = rhs[i+1].toMat(CV_8U);
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    Ptr<SIFT> sift = SIFT::create(_nfeatures,_nOctaveLayers,_contrastThreshold,_edgeThreshold,
        _sigma);
    Mat image(rhs[0].toMat());
    vector<KeyPoint> keypoints;
    bool useProvidedKeypoints=false;
    if (nlhs>1) {
        Mat descriptors;
        sift->detectAndCompute(image, mask, keypoints, descriptors, useProvidedKeypoints);
        plhs[1] = MxArray(descriptors);
    }
    else
        sift->detect(image, keypoints, mask);
    plhs[0] = MxArray(keypoints);
}
