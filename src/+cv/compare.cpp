/**
 * @file compare.cpp
 * @brief mex interface for cv::compare
 * @ingroup core
 * @author Amro
 * @date 2016
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

namespace {
/// comparison types map of relational operators for option processing
const ConstMap<string,int> CompTypesMap = ConstMap<string,int>
    ("eq", cv::CMP_EQ)
    ("gt", cv::CMP_GT)
    ("ge", cv::CMP_GE)
    ("lt", cv::CMP_LT)
    ("le", cv::CMP_LE)
    ("ne", cv::CMP_NE);
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
    nargchk(nrhs==3 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Process
    Mat src1(rhs[0].toMat()),
        src2(rhs[1].toMat()),
        dst;
    int cmpop = CompTypesMap[rhs[2].toString()];
    compare(src1, src2, dst, cmpop);
    plhs[0] = MxArray(dst);
}
