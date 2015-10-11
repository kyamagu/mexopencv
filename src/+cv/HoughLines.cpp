/**
 * @file HoughLines.cpp
 * @brief mex interface for cv::HoughLines
 * @ingroup imgproc
 * @author Kota Yamaguchi
 * @date 2011
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
    nargchk(nrhs>=1 && (nrhs%2)==1 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    double rho = 1;
    double theta = CV_PI/180;
    int threshold = 80;
    double srn = 0;
    double stn = 0;
    double min_theta = 0;
    double max_theta = CV_PI;
    for (int i=1; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="Rho")
            rho = rhs[i+1].toDouble();
        else if (key=="Theta")
            theta = rhs[i+1].toDouble();
        else if (key=="Threshold")
            threshold = rhs[i+1].toInt();
        else if (key=="SRN")
            srn = rhs[i+1].toDouble();
        else if (key=="STN")
            stn = rhs[i+1].toDouble();
        else if (key=="MinTheta")
            min_theta = rhs[i+1].toDouble();
        else if (key=="MaxTheta")
            max_theta = rhs[i+1].toDouble();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    Mat image(rhs[0].toMat(CV_8U));
    vector<Vec2f> lines;
    HoughLines(image, lines, rho, theta, threshold, srn, stn,
        min_theta, max_theta);
    plhs[0] = MxArray(lines);
}
