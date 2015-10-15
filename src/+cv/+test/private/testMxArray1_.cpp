/**
 * @file testMxArray1_.cpp
 * @brief Unit tests for MxArray class
 * @author Amro
 * @ingroup test
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
    // Set a cutom error handler to be called by cv::error() and cousins,
    // this replaces the default behavior which prints error info on stderr.
    // Note that OpenCV will still throw a C++ exception after running the
    // handler, but since we terminate with mexErrMsgIdAndTxt it wont matter.
    cv::redirectError(MexErrorHandler);

    // Check the number of arguments
    nargchk(nrhs>=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    string method(rhs[0].toString());

    if (method == "toMat_row_vector") {
        nargchk(nrhs==2 && nlhs<=1);
        Mat m(rhs[1].toMat());
        CV_Assert(m.depth() == CV_64F && m.channels() == 1);
        CV_Assert(m.total() == 10 && m.dims == 2 && m.rows == 1 && m.cols == 10);
        const double *data = m.ptr<double>();
        const size_t len = m.total() * m.channels();
        for (size_t i=0; i<len; i++)
            CV_Assert(data[i] == (i+1));
        plhs[0] = MxArray(true);
    }
    else if (method == "toMat_col_vector") {
        nargchk(nrhs==2 && nlhs<=1);
        Mat m(rhs[1].toMat());
        CV_Assert(m.depth() == CV_64F && m.channels() == 1);
        CV_Assert(m.total() == 10 && m.dims == 2 && m.rows == 10 && m.cols == 1);
        const double *data = m.ptr<double>();
        const size_t len = m.total() * m.channels();
        for (size_t i=0; i<len; i++)
            CV_Assert(data[i] == (i+1));
        plhs[0] = MxArray(true);
    }
    else if (method == "fromMat_row_vector") {
        nargchk(nrhs==1 && nlhs<=1);
        Mat m = (Mat_<double>(1,10) << 1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
        MxArray arr(m);
        CV_Assert(arr.isDouble());
        CV_Assert(arr.ndims() == 2 && arr.rows() == 1 && arr.cols() == 10);
        plhs[0] = arr;
    }
    else if (method == "fromMat_col_vector") {
        nargchk(nrhs==1 && nlhs<=1);
        Mat m = (Mat_<double>(10,1) << 1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
        MxArray arr(m);
        CV_Assert(arr.isDouble());
        CV_Assert(arr.ndims() == 2 && arr.rows() == 10 && arr.cols() == 1);
        plhs[0] = arr;
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized method %s", method.c_str());
}
