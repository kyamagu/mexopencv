/**
 * @file moments.cpp
 * @brief mex interface for cv::moments
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
    bool binaryImage = false;
    for (int i=1; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="BinaryImage")
            binaryImage = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    Moments m;
    if (rhs[0].isNumeric() || rhs[0].isLogical()) {
        // raster image
        binaryImage |= rhs[0].isLogical();
        Mat array(rhs[0].toMat());  // CV_8U, CV_16U, CV_16S, CV_32F, CV_64F
        m = moments(array, binaryImage);
    }
    else if (rhs[0].isCell()) {
        // contour points
        if (!rhs[0].isEmpty() && rhs[0].at<MxArray>(0).isInt32()) {
            vector<Point> array(rhs[0].toVector<Point>());
            m = moments(array, binaryImage);
        }
        else {
            vector<Point2f> array(rhs[0].toVector<Point2f>());
            m = moments(array, binaryImage);
        }
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error", "Invalid input");
    plhs[0] = MxArray(m);
}
