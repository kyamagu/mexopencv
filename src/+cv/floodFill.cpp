/**
 * @file floodFill.cpp
 * @brief mex interface for cv::floodFill
 * @ingroup imgproc
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
 */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    // Check the number of arguments
    nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=4);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    Mat mask;
    Scalar loDiff;
    Scalar upDiff;
    int connectivity = 4;
    bool fixedRange = false;
    bool maskOnly = false;
    int maskVal = 0x00;
    for (int i=3; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="Mask")
            mask = rhs[i+1].toMat(CV_8U);
        else if (key=="LoDiff")
            loDiff = rhs[i+1].toScalar();
        else if (key=="UpDiff")
            upDiff = rhs[i+1].toScalar();
        else if (key=="Connectivity")
            connectivity = rhs[i+1].toInt();
        else if (key=="FixedRange")
            fixedRange = rhs[i+1].toBool();
        else if (key=="MaskOnly")
            maskOnly = rhs[i+1].toBool();
        else if (key=="MaskFillValue")
            maskVal = rhs[i+1].toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    if (connectivity!=4 && connectivity!=8)
        mexErrMsgIdAndTxt("mexopencv:error", "Connectivity must be 4 or 8");
    if (maskVal<0 || maskVal>255)
        mexErrMsgIdAndTxt("mexopencv:error", "Fill value between 1 and 255");
    maskVal = (maskVal==0 && maskOnly) ? 1 : maskVal;   // no sense in filling zeros with zeros
    int flags = connectivity |                          // lower 8 bits
        (maskVal << 8) |                                // middle 8 bits
        (fixedRange ? cv::FLOODFILL_FIXED_RANGE : 0) |  // higher 8 bits
        (maskOnly   ? cv::FLOODFILL_MASK_ONLY   : 0);   // higher 8 bits

    // Process
    Mat img(rhs[0].toMat(rhs[0].isUint8() ? CV_8U :
        (rhs[0].isInt32() ? CV_32S : CV_32F)));
    Point seed(rhs[1].toPoint());
    Scalar newVal(rhs[2].toScalar());
    Rect rect;
    int area = 0;
    if (!mask.empty())
        area = floodFill(img, mask, seed, newVal, (nlhs>1 ? &rect : NULL),
            loDiff, upDiff, flags);
    else
        area = floodFill(img, seed, newVal, (nlhs>1 ? &rect : NULL),
            loDiff, upDiff, flags);
    plhs[0] = MxArray(img);
    if (nlhs>1)
        plhs[1] = MxArray(rect);
    if (nlhs>2)
        plhs[2] = MxArray(area);
    if (nlhs>3)
        plhs[3] = MxArray(mask); // keep it as uint8 for MaskFillValue to work
}
