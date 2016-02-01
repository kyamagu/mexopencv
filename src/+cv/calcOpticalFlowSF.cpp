/**
 * @file calcOpticalFlowSF.cpp
 * @brief mex interface for calcOpticalFlowSF
 * @author Ronnachai Jaroensri
 * @date 25 Jan 2016
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
 * Based on documentation found here: http://docs.opencv.org/2.4/modules/video/doc/motion_analysis_and_object_tracking.html#calcopticalflowsf
 */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    // Check the number of arguments
    if ( (nrhs != 5 && nrhs != 15) || nlhs > 1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    
    Mat prevImg(rhs[0].toMat(CV_8U)), nextImg(rhs[1].toMat(CV_8U));
    Mat flow;
    
    if (prevImg.channels() != 3) {
        mexWarnMsgIdAndTxt("mexopencv:warning", "First Image is not "
                "a 3-channel image. This may produce unexpected result.");
        cvtColor(prevImg, prevImg, CV_GRAY2BGR);
    }

    if (nextImg.channels() != 3) {
        mexWarnMsgIdAndTxt("mexopencv:warning", "Second Image is not "
                "a 3-channel image. This may produce unexpected result.");
        cvtColor(nextImg, nextImg, CV_GRAY2BGR);
    }

    // read required parameters
    int layers = rhs[2].toInt();
    int averaging_block_size = rhs[3].toInt();
    int max_flow = rhs[4].toInt();
    
    if (nrhs == 5) {
        // call the first version
        calcOpticalFlowSF(prevImg, nextImg, flow, 
                layers, averaging_block_size, max_flow);
    } else {
        // read in the rest of the parameters
        double sigma_dist = rhs[5].toDouble();
        double sigma_color = rhs[6].toDouble();
        int postprocess_window = rhs[7].toInt();
        double sigma_dist_fix = rhs[8].toDouble();
        double sigma_color_fix = rhs[9].toDouble();
        double occ_thr = rhs[10].toDouble();
        int upscale_averaging_radius = rhs[11].toInt();
        double upscale_sigma_dist = rhs[12].toDouble();
        double upscale_sigma_color = rhs[13].toDouble();
        double speed_up_thr = rhs[14].toDouble();
        
        calcOpticalFlowSF(prevImg, nextImg, flow, 
                layers, averaging_block_size, max_flow, sigma_dist,
                sigma_color, postprocess_window, sigma_dist_fix,
                sigma_color_fix, occ_thr, upscale_averaging_radius,
                upscale_sigma_dist, upscale_sigma_color, speed_up_thr);
        
    }
    
    plhs[0] = MxArray(flow);
}
