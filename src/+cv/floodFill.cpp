/**
 * @file floodFill.cpp
 * @brief mex interface for floodFill
 * @author Kota Yamaguchi
 * @date 2012
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
 *
 * This is the entry point of the function
 */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    
    // Check the input format
    if (nrhs<3 || (nrhs%2)!=1 || nlhs>4)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Option processing
    bool useMask = false;
    Mat mask;
    Scalar loDiff;
    Scalar upDiff;
    int connectivity = 4;
    bool fixedRange = false;
    bool maskOnly = false;
    for (int i=3; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="Mask") {
            useMask = true;
            mask = rhs[i+1].toMat(CV_8U);
        }
        else if (key=="LoDiff")
            loDiff = rhs[i+1].toScalar();
        else if (key=="UpDiff")
            upDiff = rhs[i+1].toScalar();
        else if (key=="Connectivity") {
            connectivity = rhs[i+1].toInt();
            if (!(connectivity==4||connectivity==8))
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Connectivity must be either 4 or 8");
        }
        else if (key=="FixedRange")
            fixedRange = rhs[i+1].toBool();
        else if (key=="MaskOnly")
            maskOnly = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    
    // Apply
    Mat img(rhs[0].toMat());
    Point seed = rhs[1].toPoint();
    Scalar newVal = rhs[2].toScalar();
    Rect rect;
    int flags = connectivity |
        ((fixedRange) ? FLOODFILL_FIXED_RANGE : 0) |
        ((maskOnly)   ? FLOODFILL_MASK_ONLY   : 0);
    int area = 0;
    if (useMask) {
        area = floodFill(img, mask, seed, newVal, &rect, loDiff, upDiff, flags);
        plhs[0] = MxArray(img);
        if (nlhs>1)
            plhs[1] = MxArray(mask,mxLOGICAL_CLASS);
        if (nlhs>2)
            plhs[2] = MxArray(rect);
        if (nlhs>3)
            plhs[3] = MxArray(area);
    }
    else {
        area = floodFill(img, seed, newVal, &rect, loDiff, upDiff, flags);
        plhs[0] = MxArray(img);
        if (nlhs>1)
            plhs[1] = MxArray(rect);
        if (nlhs>2)
            plhs[2] = MxArray(area);
    }
}
