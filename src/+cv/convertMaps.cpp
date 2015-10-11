/**
 * @file convertMaps.cpp
 * @brief mex interface for cv::convertMaps
 * @ingroup imgproc
 * @author Kota Yamaguchi
 * @date 2012
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

namespace {
/// Map type specification
const ConstMap<string,int> DstM1Type = ConstMap<string,int>
    ("int16",   CV_16SC2)
    ("single1", CV_32FC1)
    ("single2", CV_32FC2);
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
    nargchk(nrhs>=1 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Decide argument format
    bool separate_variant = (nrhs>=2 && rhs[1].isNumeric());
    nargchk((nrhs%2) == (separate_variant ? 0 : 1));

    // Option processing
    int dstmap1type = -1;
    bool nninterpolation = false;
    for (int i=(separate_variant ? 2 : 1); i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="DstMap1Type")
            dstmap1type = (rhs[i+1].isChar()) ?
                DstM1Type[rhs[i+1].toString()] : rhs[i+1].toInt();
        else if (key=="NNInterpolation")
            nninterpolation = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Apply
    Mat map1(rhs[0].toMat(rhs[0].isInt16() ? CV_16S : CV_32F)),
        map2, dstmap1, dstmap2;
    if (separate_variant)
        map2 = rhs[1].toMat(rhs[1].isUint16() ? CV_16U : CV_32F);
    convertMaps(map1, map2, dstmap1, dstmap2, dstmap1type, nninterpolation);
    plhs[0] = MxArray(dstmap1);
    if (nlhs>1)
        plhs[1] = MxArray(dstmap2);
}
