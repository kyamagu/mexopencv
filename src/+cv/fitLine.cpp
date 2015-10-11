/**
 * @file fitLine.cpp
 * @brief mex interface for cv::fitLine
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
    int distType = cv::DIST_L2;
    double param = 0;
    double reps = 0.01;
    double aeps = 0.01;
    for (int i=1; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="DistType")
            distType = DistType[rhs[i+1].toString()];
        else if (key=="Param")
            param = rhs[i+1].toDouble();
        else if (key=="RadiusEps")
            reps = rhs[i+1].toDouble();
        else if (key=="AngleEps")
            aeps = rhs[i+1].toDouble();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    Mat line;  // 4x1 or 6x1
    if (rhs[0].isNumeric()) {
        Mat points(rhs[0].toMat(CV_32F));
        fitLine(points, line, distType, param, reps, aeps);
    }
    else if (rhs[0].isCell() && !rhs[0].isEmpty()) {
        mwSize n = rhs[0].at<MxArray>(0).numel();
        if (n == 2) {
            vector<Point2f> points(rhs[0].toVector<Point2f>());
            fitLine(points, line, distType, param, reps, aeps);
        }
        else if (n == 3) {
            vector<Point3f> points(rhs[0].toVector<Point3f>());
            fitLine(points, line, distType, param, reps, aeps);
        }
        else
            mexErrMsgIdAndTxt("mexopencv:error","Invalid input");
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Invalid input");
    plhs[0] = MxArray(line);
}
