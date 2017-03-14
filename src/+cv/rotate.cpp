/**
 * @file rotate.cpp
 * @brief mex interface for cv::rotate
 * @ingroup core
 * @author Amro
 * @date 2017
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

namespace {
/// Rotation codes
const ConstMap<string,int> RotateMap = ConstMap<string,int>
    ("90CW",  cv::ROTATE_90_CLOCKWISE)
    ("180",   cv::ROTATE_180)
    ("90CCW", cv::ROTATE_90_COUNTERCLOCKWISE);
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
    nargchk(nrhs==2 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Process
    Mat src(rhs[0].toMat()), dst;
    int rotateCode = RotateMap[rhs[1].toString()];
    rotate(src, dst, rotateCode);
    plhs[0] = MxArray(dst);
}
