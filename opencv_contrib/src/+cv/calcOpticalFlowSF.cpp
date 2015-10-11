/**
 * @file calcOpticalFlowSF.cpp
 * @brief mex interface for cv::optflow::calcOpticalFlowSF
 * @ingroup optflow
 * @author Amro
 * @date 2015
 */
#include "mexopencv.hpp"
#include "opencv2/optflow.hpp"
using namespace std;
using namespace cv;
using namespace cv::optflow;

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
    nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    int layers = 3;
    int averaging_block_size = 2;
    int max_flow = 4;
    double sigma_dist = 4.1;
    double sigma_color = 25.5;
    int postprocess_window = 18;
    double sigma_dist_fix = 55.0;
    double sigma_color_fix = 25.5;
    double occ_thr = 0.35;
    int upscale_averaging_radius = 18;
    double upscale_sigma_dist = 55.0;
    double upscale_sigma_color = 25.5;
    double speed_up_thr = 10;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "Layers")
            layers = rhs[i+1].toInt();
        else if (key == "AveragingBlockSize")
            averaging_block_size = rhs[i+1].toInt();
        else if (key == "MaxFlow")
            max_flow = rhs[i+1].toInt();
        else if (key == "SigmaDist")
            sigma_dist = rhs[i+1].toDouble();
        else if (key == "SigmaColor")
            sigma_color = rhs[i+1].toDouble();
        else if (key == "PostprocessWindow")
            postprocess_window = rhs[i+1].toInt();
        else if (key == "SigmaDistFix")
            sigma_dist_fix = rhs[i+1].toDouble();
        else if (key == "SigmaColorFix")
            sigma_color_fix = rhs[i+1].toDouble();
        else if (key == "OccThr")
            occ_thr = rhs[i+1].toDouble();
        else if (key == "UpscaleAveragingRadius")
            upscale_averaging_radius = rhs[i+1].toInt();
        else if (key == "UpscaleSigmaDist")
            upscale_sigma_dist = rhs[i+1].toDouble();
        else if (key == "UpscaleSigmaColor")
            upscale_sigma_color = rhs[i+1].toDouble();
        else if (key == "SpeedUpThr")
            speed_up_thr = rhs[i+1].toDouble();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat from(rhs[0].toMat(CV_8U)), to(rhs[1].toMat(CV_8U)), flow;
    calcOpticalFlowSF(from, to, flow,
        layers, averaging_block_size, max_flow,
        sigma_dist, sigma_color, postprocess_window, sigma_dist_fix,
        sigma_color_fix, occ_thr, upscale_averaging_radius,
        upscale_sigma_dist, upscale_sigma_color, speed_up_thr);
    plhs[0] = MxArray(flow);
}
