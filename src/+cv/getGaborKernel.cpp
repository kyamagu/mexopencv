/**
 * @file getGaborKernel.cpp
 * @brief mex interface for cv::getGaborKernel
 * @ingroup imgproc
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
    nargchk((nrhs%2)==0 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    Size ksize(21,21);
    double sigma = 5.0;
    double theta = CV_PI*0.25;
    double lambd = 10.0;
    double gamma = 0.75;
    double psi = CV_PI*0.5;
    int ktype = CV_64F;
    for (int i=0; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "KSize")
            ksize = rhs[i+1].toSize();
        else if (key == "Sigma")
            sigma = rhs[i+1].toDouble();
        else if (key == "Theta")
            theta = rhs[i+1].toDouble();
        else if (key == "Lambda")
            lambd = rhs[i+1].toDouble();
        else if (key == "Gamma")
            gamma = rhs[i+1].toDouble();
        else if (key == "Psi")
            psi = rhs[i+1].toDouble();
        else if (key == "KType")
            ktype = (rhs[i+1].isChar()) ?
                ClassNameMap[rhs[i+1].toString()] : rhs[i+1].toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat kernel = getGaborKernel(ksize, sigma, theta, lambd, gamma, psi, ktype);
    plhs[0] = MxArray(kernel);
}
