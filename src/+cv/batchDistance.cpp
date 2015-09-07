/**
 * @file batchDistance.cpp
 * @brief mex interface for cv::batchDistance
 * @ingroup core
 * @author Amro
 * @date 2015
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
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    // Check the number of arguments
    nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    int dtype = -1;
    int normType = cv::NORM_L2;
    int K = 0;
    Mat mask;
    int update = 0;
    bool crosscheck = false;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="DType")
            dtype = (rhs[i+1].isChar()) ?
                ClassNameMap[rhs[i+1].toString()] : rhs[i+1].toInt();
        else if (key=="NormType")
            normType = NormType[rhs[i+1].toString()];
        else if (key=="K")
            K = rhs[i+1].toInt();
        else if (key=="Mask")
            mask = rhs[i+1].toMat(CV_8U);
        else if (key=="Update")
            update = rhs[i+1].toInt();
        else if (key=="CrossCheck")
            crosscheck = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    Mat src1(rhs[0].toMat(rhs[0].isUint8() ? CV_8U : CV_32F)),
        src2(rhs[1].toMat(rhs[1].isUint8() ? CV_8U : CV_32F));
    Mat dst, nidx;
    batchDistance(src1, src2, dst, dtype, (K>0 ? nidx : noArray()),
        normType, K, mask, update, crosscheck);
    plhs[0] = MxArray(dst);
    if (nlhs>1)
        plhs[1] = MxArray(nidx);
}
