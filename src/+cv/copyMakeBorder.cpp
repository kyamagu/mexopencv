/**
 * @file copyMakeBorder.cpp
 * @brief mex interface for cv::copyMakeBorder
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
    nargchk(nrhs>=2 && nlhs<=1);

    // Argument vector: (src, t, b, l, r) or (src, [t b l r])
    vector<MxArray> rhs(prhs, prhs+nrhs);
    bool vect_variant = (rhs[1].numel() == 4);
    nargchk(vect_variant ? ((nrhs%2)==0) : (nrhs>=5 && (nrhs%2)!=0));

    // Option processing
    int borderType = cv::BORDER_DEFAULT;
    bool isolated = false;  // TODO: only makes sense for ROI submatrices
    Scalar value;
    for (int i=(vect_variant ? 2 : 5); i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="BorderType")
            borderType = BorderType[rhs[i+1].toString()];
        else if (key=="Isolated")
            isolated = rhs[i+1].toBool();
        else if (key=="Value")
            value = rhs[i+1].toScalar();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    borderType |= (isolated ? cv::BORDER_ISOLATED : 0);

    // Process
    Mat src(rhs[0].toMat()), dst;
    int top, bottom, left, right;
    if (vect_variant) {
        vector<int> v(rhs[1].toVector<int>());
        nargchk(v.size() == 4);
        top    = v[0];
        bottom = v[1];
        left   = v[2];
        right  = v[3];
    }
    else {
        top    = rhs[1].toInt();
        bottom = rhs[2].toInt();
        left   = rhs[3].toInt();
        right  = rhs[4].toInt();
    }
    copyMakeBorder(src, dst, top, bottom, left, right, borderType, value);
    plhs[0] = MxArray(dst);
}
