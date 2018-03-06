/**
 * @file HoughLinesPointSet.cpp
 * @brief mex interface for cv::HoughLinesPointSet
 * @ingroup imgproc
 * @author Amro
 * @date 2018
 */
#include "mexopencv.hpp"
#include "opencv2/imgproc.hpp"
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
    int lines_max = 200;
    int threshold = 10;
    double min_rho = 0;
    double max_rho = 100;
    double rho_step = 1;
    double min_theta = 0;
    double max_theta = CV_PI/2;
    double theta_step = CV_PI/180;
    for (int i=1; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "LinesMax")
            lines_max = rhs[i+1].toInt();
        else if (key == "Threshold")
            threshold = rhs[i+1].toInt();
        else if (key == "RhoMin")
            min_rho = rhs[i+1].toDouble();
        else if (key == "RhoMax")
            max_rho = rhs[i+1].toDouble();
        else if (key == "RhoStep")
            rho_step = rhs[i+1].toDouble();
        else if (key == "ThetaMin")
            min_theta = rhs[i+1].toDouble();
        else if (key == "ThetaMax")
            max_theta = rhs[i+1].toDouble();
        else if (key == "ThetaStep")
            theta_step = rhs[i+1].toDouble();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    vector<Point2f> points(rhs[0].toVector<Point2f>());
    vector<Vec3d> lines;
    HoughLinesPointSet(points, lines, lines_max, threshold,
        min_rho, max_rho, rho_step, min_theta, max_theta, theta_step);
    plhs[0] = MxArray(lines);
}
