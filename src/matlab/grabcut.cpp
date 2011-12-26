/**
 * @file grabCut.cpp
 * @brief mex interface for OpenCV's grabCut
 * @author Kota Yamaguchi
 * @date 2011
 * @details
 * <pre>
 * Usage:
 *   [ trimap ] = grabCut(img, bbox);
 *   [ trimap ] = grabCut(img, trimap);
 *   [ trimap ] = grabCut(img, trimap, 'Init', initMethod, ...);
 *   [ trimap ] = grabCut(img, trimap, 'MaxIter', maxIter, ...);
 * Input:
 *   img: uint8 type H-by-W-by-3 RGB array
 *   bbox: 1-by-4 double array [x y w h]
 *         It will automatically create a trimap initialized with
 *         label 0 for background and label 3 for foreground (see trimap)
 *   trimap: uint8 H-by-W array of labels {0:bg, 1:fg, 2:probably-bg, 3:probably-fg}
 *   options: 'Init' can take either 'Rect' or 'Mask'. Default to the form of second argument
 *            'MaxIter' specifies maximum number of iteration.
 * Output:
 *   trimap: uint8 H-by-W array with {0:bg, 1:fg, 2:probably-bg, 3:probably-fg}
 * </pre>
 */
#include "cvmx.hpp"
#include <string.h>
using namespace cv;

// Local functions
namespace {
	// Number of element in a matrix (not in an n-d array)
	inline size_t numel(const mxArray *arr) { return mxGetM(arr)*mxGetN(arr); }
}

/**
 * Main entry called from Matlab
 * @param nlhs number of left-hand-side arguments
 * @param plhs pointers to mxArrays in the left-hand-side
 * @param nrhs number of right-hand-side arguments
 * @param prhs pointers to mxArrays in the right-hand-side
 *
 * This is the entry point of the function
 */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
	// Check the input format
	if (nrhs<2 || (nrhs%2)!=0 || nlhs>1)
        mexErrMsgIdAndTxt("grabCut:invalidArgs","Wrong number of arguments");
	if (mxGetClassID(prhs[0])!=mxUINT8_CLASS)
        mexErrMsgIdAndTxt("grabCut:invalidArgs","Only UINT8 type is supported");
    if (mxGetNumberOfDimensions(prhs[0])!=3)
        mexErrMsgIdAndTxt("grabCut:invalidArgs","Only RGB format is supported");
	
	// Convert mxArray to cv::Mat
	Mat img(cvmxArrayToMat(prhs[0],CV_8U));
	
	// Option processing
	int iterCount = 10;
	int mode = (mxIsDouble(prhs[1]) && numel(prhs[1])==4) ?
	            GC_INIT_WITH_RECT : GC_INIT_WITH_MASK; // Automatic determination
	if (nrhs>2) {
	    for (int i=2; i<nrhs; i+=2) {
            if (mxGetClassID(prhs[i])==mxCHAR_CLASS) {
                std::string key(cvmxArrayToString(prhs[i]));
                if (key=="Init" && mxGetClassID(prhs[i+1])==mxCHAR_CLASS) {
                    std::string val(cvmxArrayToString(prhs[i+1]));
                    if (val=="Rect")
                        mode = GC_INIT_WITH_RECT;
                    else if (val=="Mask")
                        mode = GC_INIT_WITH_MASK;
                    else
                        mexErrMsgIdAndTxt("grabCut:invalidOption","Unrecognized option");
                }
                else if (key=="MaxIter" && mxGetClassID(prhs[i+1])==mxDOUBLE_CLASS)
                    iterCount = static_cast<int>(mxGetScalar(prhs[i+1]));
                else
                    mexErrMsgIdAndTxt("grabCut:invalidOption","Unrecognized option");
            }
            else
                mexErrMsgIdAndTxt("grabCut:invalidOption","Unrecognized option");
        }
	}
	
	// Initialize mask and rect
	Mat mask;
	Rect rect;
	if (mode == GC_INIT_WITH_MASK)
		if (mxGetM(prhs[0])==mxGetM(prhs[1]) && mxGetNumberOfDimensions(prhs[1])==2)
			mask = cvmxArrayToMat(prhs[1],CV_8U);
		else
	        mexErrMsgIdAndTxt("grabCut:invalidArgs","Mask size incomatible to the image");
	else {
	    if (mxIsDouble(prhs[1]) && numel(prhs[1])==4) {
    	    double *ptr = mxGetPr(prhs[1]);
	        rect = Rect(ptr[1],ptr[0],ptr[3],ptr[2]); // Be careful that image is transposed
	    }
	    else
	        mexErrMsgIdAndTxt("grabCut:invalidArgs","Unsupported type: rect must be 1x4 double");
	}
	
	// Apply grabCut
	Mat bgdModel, fgdModel;
	grabCut(img, mask, rect, bgdModel, fgdModel, iterCount, mode);
	
	// Convert cv::Mat to mxArray
	plhs[0] = cvmxArrayFromMat(mask, mxUINT8_CLASS);
}
