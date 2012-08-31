/**
 * @file imencode.cpp
 * @brief mex interface for imencode
 * @author Kota Yamaguchi
 * @date 2012
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
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    // Check the number of arguments
    if (nrhs<2 || (nrhs%2)!=0 || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");

    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);

    // Option processing
    vector<int> params;
    for (int i=2; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key == "JpegQuality") {
            int val = rhs[i+1].toInt();
            if (val < 0 || 100 < val)
                mexErrMsgIdAndTxt("mexopencv:error","Invalid parameter");
            params.push_back(CV_IMWRITE_JPEG_QUALITY);
            params.push_back(val);
        }
        else if (key == "PngCompression") {
            int val = rhs[i+1].toInt();
            if (val < 0 || 9 < val)
                mexErrMsgIdAndTxt("mexopencv:error","Invalid parameter");
            params.push_back(CV_IMWRITE_PNG_COMPRESSION);
            params.push_back(val);
        }
        else if (key == "PxmBinary") {
            int val = rhs[i+1].toInt();
            if (val < 0 || 1 < val)
                mexErrMsgIdAndTxt("mexopencv:error","Invalid parameter");
            params.push_back(CV_IMWRITE_PXM_BINARY);
            params.push_back(val);
        }
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    string ext(rhs[0].toString());
    Mat m(rhs[1].toMat(CV_8U));
    // OpenCV's default is BGR while Matlab's is RGB
    if (m.type()==CV_8UC3)
        cvtColor(m,m,CV_RGB2BGR);
    vector<uchar> buf;
    if (!imencode(ext, m, buf, params))
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    plhs[0] = MxArray(Mat(buf), mxUINT8_CLASS, false);
}
