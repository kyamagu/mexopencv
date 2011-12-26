/**
 * @file filter2D.cpp
 * @brief mex interface for filter2D
 * @author Kota Yamaguchi
 * @date 2011
 * @details
 * <pre>
 * Usage:
 *   result = fliter2d(img, kernel)
 * </pre>
 */
#include "cvmx.hpp"
#include <string.h>
using namespace cv;

/**
 * Main entry called from Matlab
 * @param nlhs number of left-hand-side arguments
 * @param plhs pointers to mxArrays in the left-hand-side
 * @param nrhs number of right-hand-side arguments
 * @param prhs pointers to mxArrays in the right-hand-side
 *
 * Wrapper for filter2D
 */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
	// Check the number of arguments
	if(nrhs<2 || nrhs>3 || nlhs>1)
        mexErrMsgIdAndTxt("filter2D:invalidArgs","Wrong number of arguments");
	
	// Convert mxArray to cv::Mat
	Mat img = cvmxArrayToMat(prhs[0],CV_32F);
	Mat kernel = cvmxArrayToMat(prhs[1],CV_32F);
	
	// Option processing
	if (nrhs>2 && mxGetClassID(prhs[2])==mxCHAR_CLASS) {
	    std::string str(cvmxArrayToString(prhs[2]));
	    if (str=="conv2")   // Convolution
	        flip(kernel,kernel,-1);
	    else
	        mexErrMsgIdAndTxt("filter2D:invalidOption","Unrecognized option");
	}
	
	// Apply filter 2D
	// There seems to be a bug in filter when BORDER_CONSTANT is used
	Point anchor((kernel.cols-1)/2,(kernel.rows-1)/2);
	if (kernel.cols == 1 || kernel.rows == 1)
	    filter2D(
            img,                    // src type
            img,                    // dst type
            -1,                     // dst depth
            kernel,                 // 2D kernel
            anchor,                 // anchor point, center if (-1,-1)
            0,                      // bias added after filtering
            BORDER_DEFAULT          // border type
            );
	else
	    filter2D(
            img,                    // src type
            img,                    // dst type
            -1,                     // dst depth
            kernel,                 // 2D kernel
            anchor,                 // anchor point, center if (-1,-1)
            0,                      // bias added after filtering
            BORDER_CONSTANT         // border type
            );
	
	// Convert cv::Mat to mxArray
	plhs[0] = cvmxArrayFromMat(img,mxGetClassID(prhs[0]));
}
