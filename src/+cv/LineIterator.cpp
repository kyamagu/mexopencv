/**
 * @file LineIterator.cpp
 * @brief mex interface for cv::LineIterator
 * @ingroup imgproc
 * @author Amro
 * @date 2017
 */
#include "mexopencv.hpp"
#include "opencv2/imgproc.hpp"
using namespace std;
using namespace cv;

//NOTE: LineIterator is exposed as a function rather than a class because it
// it stores a reference to the input matrix from the constructor, so the mat
// must exist and remain for the duration of the iterator object lifetime.

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
    nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    int connectivity = 8;
    bool leftToRight = false;
    for (int i=3; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "Connectivity")
            connectivity = rhs[i+1].toInt();
        else if (key == "LeftToRight")
            leftToRight = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat img(rhs[0].toMat());
    Point pt1(rhs[1].toPoint()), pt2(rhs[2].toPoint());
    LineIterator it(img, pt1, pt2, connectivity, leftToRight);
    vector<Point> pts;
    pts.reserve(it.count);
    for (int i = 0; i < it.count; ++i) {
        pts.push_back(it.pos());
        ++it;
    }
    plhs[0] = MxArray(Mat(pts,false).reshape(1,0));  // Nx2 numeric matrix
    if (nlhs > 1)
        plhs[1] = MxArray(it.count);
}
