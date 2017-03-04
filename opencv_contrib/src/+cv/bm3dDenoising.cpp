/**
 * @file bm3dDenoising.cpp
 * @brief mex interface for cv::xphoto::bm3dDenoising
 * @ingroup xphoto
 * @author Amro
 * @date 2017
 */
#include "mexopencv.hpp"
#include "opencv2/xphoto.hpp"
using namespace std;
using namespace cv;
using namespace cv::xphoto;

namespace {
/// BM3D transform types for option processing
const ConstMap<string,int> TransformTypesMap = ConstMap<string,int>
    ("Haar", cv::xphoto::HAAR);

/// BM3D algorithm steps for option processing
const ConstMap<string,int> Bm3dStepsMap = ConstMap<string,int>
    ("All", cv::xphoto::BM3D_STEPALL)
    ("1",   cv::xphoto::BM3D_STEP1)
    ("2",   cv::xphoto::BM3D_STEP2);
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

    // Option processing
    float h = 1;
    int templateWindowSize = 4;
    int searchWindowSize = 16;
    int blockMatchingStep1 = 2500;
    int blockMatchingStep2 = 400;
    int groupSize = 8;
    int slidingStep = 1;
    float beta = 2.0f;
    int normType = cv::NORM_L2;
    int step = cv::xphoto::BM3D_STEPALL;
    int transformType = cv::xphoto::HAAR;
    Mat basic;
    for (int i=1; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "Basic")
            basic = rhs[i+1].toMat(rhs[i+1].isUint16() ? CV_16U : CV_8U);
        else if (key == "H")
            h = rhs[i+1].toFloat();
        else if (key == "TemplateWindowSize")
            templateWindowSize = rhs[i+1].toInt();
        else if (key == "SearchWindowSize")
            searchWindowSize = rhs[i+1].toInt();
        else if (key == "BlockMatchingStep1")
            blockMatchingStep1 = rhs[i+1].toInt();
        else if (key == "BlockMatchingStep2")
            blockMatchingStep2 = rhs[i+1].toInt();
        else if (key == "GroupSize")
            groupSize = rhs[i+1].toInt();
        else if (key == "SlidingStep")
            slidingStep = rhs[i+1].toInt();
        else if (key == "Beta")
            beta = rhs[i+1].toFloat();
        else if (key == "NormType")
            normType = NormType[rhs[i+1].toString()];
        else if (key == "Step")
            step = (rhs[i+1].isChar()) ?
                Bm3dStepsMap[rhs[i+1].toString()] : rhs[i+1].toInt();
        else if (key == "TransformType")
            transformType = TransformTypesMap[rhs[i+1].toString()];
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat src(rhs[0].toMat(rhs[0].isUint16() ? CV_16U : CV_8U)),
        dst;
    if (nlhs > 1 || !basic.empty()) {
        bm3dDenoising(src, basic, dst, h, templateWindowSize, searchWindowSize,
            blockMatchingStep1, blockMatchingStep2, groupSize, slidingStep,
            beta, normType, step, transformType);
        if (nlhs > 1)
            plhs[1] = MxArray(basic);
    }
    else
        bm3dDenoising(src, dst, h, templateWindowSize, searchWindowSize,
            blockMatchingStep1, blockMatchingStep2, groupSize, slidingStep,
            beta, normType, step, transformType);
    plhs[0] = MxArray(dst);
}
