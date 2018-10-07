/**
 * @file pointPolygonTest.cpp
 * @brief mex interface for cv::pointPolygonTest
 * @ingroup imgproc
 * @author Kota Yamaguchi
 * @date 2013
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
    nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    bool measureDist = false;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "MeasureDist")
            measureDist = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    Mat contour;
    vector<Point2f> contour_; // defined here, to allow data sharing w/o copy
    if (rhs[0].isCell()) {
        contour_ = rhs[0].toVector<Point2f>();
        contour = Mat(contour_,false).reshape(1,0);  // Nx2
    }
    else
        contour = rhs[0].toMat(rhs[0].isInt32() ? CV_32S : CV_32F);

    // Process
    vector<double> results;
    vector<Point2f> pts(rhs[1].toVector<Point2f>());
    results.reserve(pts.size());
    for (size_t i = 0; i < pts.size(); ++i)
        results.push_back(pointPolygonTest(contour, pts[i], measureDist));
    plhs[0] = MxArray(results);
}
