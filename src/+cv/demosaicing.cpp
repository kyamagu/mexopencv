/**
 * @file demosaicing.cpp
 * @brief mex interface for cv::demosaicing
 * @ingroup imgproc
 * @author Amro
 * @date 2015
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

namespace {
/// Color conversion types for option processing
const ConstMap<string,int> ColorConv = ConstMap<string,int>
    // Demosaicing
    ("BayerBG2BGR",     cv::COLOR_BayerBG2BGR)
    ("BayerGB2BGR",     cv::COLOR_BayerGB2BGR)
    ("BayerRG2BGR",     cv::COLOR_BayerRG2BGR)
    ("BayerGR2BGR",     cv::COLOR_BayerGR2BGR)
    //
    ("BayerBG2RGB",     cv::COLOR_BayerBG2RGB)
    ("BayerGB2RGB",     cv::COLOR_BayerGB2RGB)
    ("BayerRG2RGB",     cv::COLOR_BayerRG2RGB)
    ("BayerGR2RGB",     cv::COLOR_BayerGR2RGB)
    //
    ("BayerBG2GRAY",    cv::COLOR_BayerBG2GRAY)
    ("BayerGB2GRAY",    cv::COLOR_BayerGB2GRAY)
    ("BayerRG2GRAY",    cv::COLOR_BayerRG2GRAY)
    ("BayerGR2GRAY",    cv::COLOR_BayerGR2GRAY)
    // Demosaicing using Variable Number of Gradients
    ("BayerBG2BGR_VNG", cv::COLOR_BayerBG2BGR_VNG)
    ("BayerGB2BGR_VNG", cv::COLOR_BayerGB2BGR_VNG)
    ("BayerRG2BGR_VNG", cv::COLOR_BayerRG2BGR_VNG)
    ("BayerGR2BGR_VNG", cv::COLOR_BayerGR2BGR_VNG)
    //
    ("BayerBG2RGB_VNG", cv::COLOR_BayerBG2RGB_VNG)
    ("BayerGB2RGB_VNG", cv::COLOR_BayerGB2RGB_VNG)
    ("BayerRG2RGB_VNG", cv::COLOR_BayerRG2RGB_VNG)
    ("BayerGR2RGB_VNG", cv::COLOR_BayerGR2RGB_VNG)
    // Edge-Aware Demosaicing
    ("BayerBG2BGR_EA",  cv::COLOR_BayerBG2BGR_EA)
    ("BayerGB2BGR_EA",  cv::COLOR_BayerGB2BGR_EA)
    ("BayerRG2BGR_EA",  cv::COLOR_BayerRG2BGR_EA)
    ("BayerGR2BGR_EA",  cv::COLOR_BayerGR2BGR_EA)
    // Edge-Aware Demosaicing
    ("BayerBG2RGB_EA",  cv::COLOR_BayerBG2RGB_EA)
    ("BayerGB2RGB_EA",  cv::COLOR_BayerGB2RGB_EA)
    ("BayerRG2RGB_EA",  cv::COLOR_BayerRG2RGB_EA)
    ("BayerGR2RGB_EA",  cv::COLOR_BayerGR2RGB_EA);
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
    nargchk(nrhs>=2 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    int dcn = 0;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="Channels")
            dcn = rhs[i+1].toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    Mat src(rhs[0].toMat(rhs[0].isUint16() ? CV_16U : CV_8U)), dst;
    int code = rhs[1].isChar() ? ColorConv[rhs[1].toString()] : rhs[1].toInt();
    demosaicing(src, dst, code, dcn);
    plhs[0] = MxArray(dst);
}
