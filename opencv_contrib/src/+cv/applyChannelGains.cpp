/**
 * @file applyChannelGains.cpp
 * @brief mex interface for cv::xphoto::applyChannelGains
 * @ingroup xphoto
 * @author Amro
 * @date 2017
 */
#include "mexopencv.hpp"
#include "opencv2/xphoto.hpp"
using namespace std;
using namespace cv;
using namespace cv::xphoto;

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
    nargchk(nrhs==2 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Process
    Mat src(rhs[0].toMat(rhs[0].isUint16() ? CV_16U : CV_8U)), dst;
    Vec3f gains(rhs[1].toVec<float,3>());
    applyChannelGains(src, dst, gains[0], gains[1], gains[2]);
    plhs[0] = MxArray(dst);
}
