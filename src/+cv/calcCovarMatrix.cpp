/**
 * @file calcCovarMatrix.cpp
 * @brief mex interface for cv::calcCovarMatrix
 * @ingroup core
 * @author Amro
 * @date 2015
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
    nargchk(nrhs>=1 && (nrhs%2)==1 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    Mat mean;
    int flags = cv::COVAR_NORMAL | cv::COVAR_ROWS;
    int ctype = CV_64F;
    for (int i=1; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="Mean") {
            mean = rhs[i+1].toMat();
            flags |= cv::COVAR_USE_AVG;
        }
        else if (key=="Flags")
            flags = rhs[i+1].toInt();
        else if (key=="Scrambled") {
            //UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::COVAR_SCRAMBLED);
            UPDATE_FLAG(flags, !rhs[i+1].toBool(), cv::COVAR_NORMAL);
        }
        else if (key=="Normal")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::COVAR_NORMAL);
        else if (key=="UseAvg")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::COVAR_USE_AVG);
        else if (key=="Scale")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::COVAR_SCALE);
        else if (key=="Rows") {
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::COVAR_ROWS);
            UPDATE_FLAG(flags, !rhs[i+1].toBool(), cv::COVAR_COLS);
        }
        else if (key=="Cols") {
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::COVAR_COLS);
            UPDATE_FLAG(flags, !rhs[i+1].toBool(), cv::COVAR_ROWS);
        }
        else if (key=="CType")
            ctype = (rhs[i+1].isChar()) ?
                ClassNameMap[rhs[i+1].toString()] : rhs[i+1].toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    Mat samples(rhs[0].toMat()), covar;
    calcCovarMatrix(samples, covar, mean, flags, ctype);
    plhs[0] = MxArray(covar);
    if (nlhs>1)
        plhs[1] = MxArray(mean);
}
