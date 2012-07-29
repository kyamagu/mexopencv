/**
 * @file composeRT.cpp
 * @brief mex interface for composeRT
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

/// Field names for struct
const char* _fieldnames[] = {"rvec3", "tvec3", "dr3dr1", "dr3dt1", "dr3dr2",
    "dr3dt2", "dt3dr1", "dt3dt1", "dt3dr2", "dt3dt2"};
/// Create a struct
mxArray* valueStruct(const Mat& rvec3, const Mat& tvec3, const Mat& dr3dr1,
    const Mat& dr3dt1, const Mat& dr3dr2, const Mat& dr3dt2, const Mat& dt3dr1,
    const Mat& dt3dt1, const Mat& dt3dr2, const Mat& dt3dt2)
{
    mxArray* p = mxCreateStructMatrix(1,1,10,_fieldnames);
    if (!p)
        mexErrMsgIdAndTxt("mexopencv:error","Allocation error");
    mxSetField(p,0,"rvec3",MxArray(rvec3));
    mxSetField(p,0,"tvec3",MxArray(tvec3));
    mxSetField(p,0,"dr3dr1",MxArray(dr3dr1));
    mxSetField(p,0,"dr3dt1",MxArray(dr3dt1));
    mxSetField(p,0,"dr3dr2",MxArray(dr3dr2));
    mxSetField(p,0,"dr3dt2",MxArray(dr3dt2));
    mxSetField(p,0,"dt3dr1",MxArray(dt3dr1));
    mxSetField(p,0,"dt3dt1",MxArray(dt3dt1));
    mxSetField(p,0,"dt3dr2",MxArray(dt3dr2));
    mxSetField(p,0,"dt3dt2",MxArray(dt3dt2));
    return p;
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
    if (nrhs!=4 || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    
    Mat rvec1(rhs[0].toMat(CV_32F));
    Mat tvec1(rhs[1].toMat(CV_32F));
    Mat rvec2(rhs[2].toMat(CV_32F));
    Mat tvec2(rhs[3].toMat(CV_32F));
    Mat rvec3, tvec3, dr3dr1, dr3dt1, dr3dr2, dr3dt2, dt3dr1, dt3dt1, dt3dr2, dt3dt2;
    
    // Process
    composeRT(rvec1, tvec1, rvec2, tvec2, rvec3, tvec3, dr3dr1, dr3dt1, dr3dr2, dr3dt2, dt3dr1, dt3dt1, dt3dr2, dt3dt2);

    plhs[0] = valueStruct(rvec3, tvec3, dr3dr1, dr3dt1, dr3dr2, dr3dt2, dt3dr1, dt3dt1, dt3dr2, dt3dt2);
}
