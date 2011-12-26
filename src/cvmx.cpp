/**
 * @file cvmx.cpp
 * @brief Implemenation of data converters and utilities
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "cvmx.hpp"
using namespace cv;
using namespace std;

// Local namescope
namespace {
/**
 * Translates data type definition used in OpenCV to that of Matlab
 * @param classid data type of matlab's mxArray. e.g., mxDOUBLE_CLASS
 * @return opencv's data type. e.g., CV_8U
 */
int cvmxClassIdToMatDepth(mxClassID classid) {
	switch(classid) {
	case mxDOUBLE_CLASS:	return CV_64F;
	case mxSINGLE_CLASS:	return CV_32F;
	case mxINT8_CLASS:		return CV_8S;
	case mxUINT8_CLASS:		return CV_8U;
	case mxINT16_CLASS:		return CV_16S;
	case mxUINT16_CLASS:	return CV_16U;
	case mxINT32_CLASS:		return CV_32S;
	default: 				return CV_USRTYPE1;
	}
}

/**
 * Translates data type definition used in Matlab to that of OpenCV
 * @param depth data depth of opencv's Mat class. e.g., CV_32F
 * @return data type of matlab's mxArray. e.g., mxDOUBLE_CLASS
 */
mxClassID cvmxClassIdFromMatDepth(int depth) {
	switch(depth) {
	case CV_64F:	return mxDOUBLE_CLASS;
	case CV_32F:	return mxSINGLE_CLASS;
	case CV_8S:		return mxINT8_CLASS;
	case CV_8U:		return mxUINT8_CLASS;
	case CV_16S:	return mxINT16_CLASS;
	case CV_16U:	return mxUINT16_CLASS;
	case CV_32S:	return mxINT32_CLASS;
	default: 		return mxUNKNOWN_CLASS;
	}
}
}

/**
 * Convert mxArray* cv::Mat
 * @param arr mxArray object
 * @param depth depth of cv::Mat. e.g., CV_8U, CV_32F. default: automatic conversion
 * @return cv::Mat object
 * 
 * The first/second/third dimensions of mxArray are mapped to width/height/channels, respectively
 * The returned mat is transposed due to the memory alignment of Matlab.
 * To fix it, call mat.t() when needed. This however requires copying data
 */
cv::Mat cvmxArrayToMat(const mxArray *arr, int depth) {
	// Create cv::Mat object
	mwSize nDim = mxGetNumberOfDimensions(arr);
	const mwSize *dims = mxGetDimensions(arr);
	int nChannels = (nDim > 2) ? dims[2] : 1;
	if (depth == CV_USRTYPE1)
		depth = cvmxClassIdToMatDepth(mxGetClassID(arr));
	cv::Mat mat(dims[1],dims[0],CV_MAKETYPE(depth,nChannels));
	
	// Copy each channel
	std::vector<cv::Mat> mv(nChannels);
	mwSize subs[] = {0,0,0};
	for (int i = 0; i<nChannels; ++i) {
		subs[2] = i;
		void *ptr = reinterpret_cast<void*>(
				reinterpret_cast<size_t>(mxGetData(arr))+
				mxGetElementSize(arr)*mxCalcSingleSubscript(arr,3,subs));
		cv::Mat m(mat.rows,mat.cols,
				CV_MAKETYPE(cvmxClassIdToMatDepth(mxGetClassID(arr)),1),
				ptr,mxGetElementSize(arr)*mat.cols);
		m.convertTo(mv[i],CV_MAKETYPE(depth,1)); // Read from mxArray through m
	}
	cv::merge(mv,mat);
	return mat;
}

/**
 * Convert cv::Mat to mxArray*
 * @param mat cv::Mat object
 * @param classid classid of mxArray. e.g., mxDOUBLE_CLASS. default: automatic conversion
 * @return mxArray object
 *
 * The width/height/channels of cv::Mat are are mapped to the first/second/third dimensions of
 * mxArray, respectively.
 */
mxArray* cvmxArrayFromMat(const cv::Mat& mat, mxClassID classid) {
	// Create a new mxArray
	int nChannels = mat.channels();
	mwSize nDim = (nChannels>1) ? 3 : 2;
	mwSize dims[] = {mat.cols, mat.rows, (nChannels>1) ? nChannels : 0};
	if (classid == mxUNKNOWN_CLASS)
		classid = cvmxClassIdFromMatDepth(mat.depth());
	mxArray *arr = mxCreateNumericArray(nDim,dims,classid,mxREAL);
	
	// Copy each channel
	std::vector<cv::Mat> mv;
	cv::split(mat,mv);
	mwSize subs[] = {0,0,0};
	int type = CV_MAKETYPE(cvmxClassIdToMatDepth(classid),1); // destination type
	for (int i = 0; i < nChannels; ++i) {
		subs[2] = i;
		void *ptr = reinterpret_cast<void*>(
				reinterpret_cast<size_t>(mxGetData(arr))+
				mxGetElementSize(arr)*mxCalcSingleSubscript(arr,3,subs));
		cv::Mat m(mat.rows,mat.cols,type,ptr,mxGetElementSize(arr)*mat.cols);
		mv[i].convertTo(m,type); // Write to mxArray through m
	}
	
	return arr;
}


// Initialize border type
namespace {
std::map<std::string, int> create_border_type() {
	std::map<std::string, int> m;
	m["Replicate"]		= BORDER_REPLICATE;
	m["Constant"]   	= BORDER_CONSTANT;
	m["Reflect"] 		= BORDER_REFLECT;
	m["Wrap"]			= BORDER_WRAP;
	m["Reflect101"] 	= BORDER_REFLECT_101;
	m["Transparent"]	= BORDER_TRANSPARENT;
	m["Default"] 		= BORDER_DEFAULT;
	m["Isolated"]		= BORDER_ISOLATED;
	return m;
}
}
std::map<std::string, int> const BorderType::m = create_border_type();