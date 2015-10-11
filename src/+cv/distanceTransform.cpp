/**
 * @file distanceTransform.cpp
 * @brief mex interface for cv::distanceTransform
 * @ingroup imgproc
 * @author Kota Yamaguchi
 * @date 2012
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

namespace {
/// Mask size for distance transform
const ConstMap<string,int> DistMask = ConstMap<string,int>
    ("3",       cv::DIST_MASK_3)
    ("5",       cv::DIST_MASK_5)
    ("Precise", cv::DIST_MASK_PRECISE);

/// distance transform label types
const ConstMap<string,int> DistLabelTypes = ConstMap<string,int>
    ("CComp", cv::DIST_LABEL_CCOMP)
    ("Pixel", cv::DIST_LABEL_PIXEL);
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
    nargchk(nrhs>=1 && (nrhs%2)==1 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    bool with_labels = (nlhs > 1);

    // Option processing
    int distanceType = cv::DIST_L2;
    int maskSize = cv::DIST_MASK_3;
    int labelType = cv::DIST_LABEL_CCOMP;
    int dstType = CV_32F;
    for (int i=1; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="DistanceType")
            distanceType = DistType[rhs[i+1].toString()];
        else if (key=="MaskSize")
            maskSize = (rhs[i+1].isChar()) ?
                DistMask[rhs[i+1].toString()] : rhs[i+1].toInt();
        else if (with_labels && key=="LabelType")
            labelType = DistLabelTypes[rhs[i+1].toString()];
        else if (!with_labels && key=="DstType")
            dstType = ClassNameMap[rhs[i+1].toString()];
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    Mat src(rhs[0].toMat(CV_8U)), dst;
    if (with_labels) {
        Mat labels;
        distanceTransform(src, dst, labels, distanceType, maskSize, labelType);
        plhs[1] = MxArray(labels);
    }
    else {
        distanceTransform(src, dst, distanceType, maskSize, dstType);
    }
    plhs[0] = MxArray(dst);
}
