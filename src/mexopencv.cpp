/**
 * @file mexopencv.cpp
 * @brief Implemenation of data converters and utilities
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
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
	case mxLOGICAL_CLASS:	return CV_8U;
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
	case CV_8U:		return mxUINT8_CLASS; // No mapping to logical
	case CV_16S:	return mxINT16_CLASS;
	case CV_16U:	return mxUINT16_CLASS;
	case CV_32S:	return mxINT32_CLASS;
	default: 		return mxUNKNOWN_CLASS;
	}
}
}

/** MxArray constructor from mxArray*
 * @param arr mxArray pointer given by mexFunction
 */
MxArray::MxArray(const mxArray *arr) : p_(arr) {}

/** MxArray constructor from double
 * @param d reference to a double value
 */
MxArray::MxArray(const double& d)
{
	p_ = mxCreateDoubleScalar(d);
}

/** MxArray constructor from std::string
 * @param s reference to a string value
 */
MxArray::MxArray(const int& i)
{
	p_ = mxCreateDoubleScalar(static_cast<double>(i));
}

/** MxArray constructor from std::string
 * @param s reference to a string value
 */
MxArray::MxArray(const string& s)
{
	p_ = mxCreateString(s.c_str());
}

/** MxArray constructor from std::string
 * @param s reference to a string value
 */
MxArray::MxArray(const bool& b)
{
	p_ = mxCreateLogicalScalar(b);
}

/**
 * Convert cv::Mat to MxArray
 * @param mat cv::Mat object
 * @param classid classid of mxArray. e.g., mxDOUBLE_CLASS. default: automatic conversion
 * @return MxArray object
 *
 * The width/height/channels of cv::Mat are are mapped to the first/second/third dimensions of
 * mxArray, respectively.
 */
MxArray::MxArray(const cv::Mat& mat, mxClassID classid)
{
	// Create a new mxArray
	int nChannels = mat.channels();
	mwSize nDim = (nChannels>1) ? 3 : 2;
	mwSize dims[] = {mat.cols, mat.rows, (nChannels>1) ? nChannels : 0};
	if (classid == mxUNKNOWN_CLASS)
		classid = cvmxClassIdFromMatDepth(mat.depth());
	p_ = mxCreateNumericArray(nDim,dims,classid,mxREAL);
	
	// Copy each channel
	std::vector<cv::Mat> mv;
	cv::split(mat,mv);
	mwSize subs[] = {0,0,0};
	int type = CV_MAKETYPE(cvmxClassIdToMatDepth(classid),1); // destination type
	for (int i = 0; i < nChannels; ++i) {
		subs[2] = i;
		void *ptr = reinterpret_cast<void*>(
				reinterpret_cast<size_t>(mxGetData(p_))+
				mxGetElementSize(p_)*mxCalcSingleSubscript(p_,3,subs));
		cv::Mat m(mat.rows,mat.cols,type,ptr,mxGetElementSize(p_)*mat.cols);
		mv[i].convertTo(m,type); // Write to mxArray through m
	}
}

/**
 * Convert MxArray to cv::Mat
 * @param depth depth of cv::Mat. e.g., CV_8U, CV_32F. default: automatic conversion
 * @return cv::Mat object
 * 
 * The first/second/third dimensions of mxArray are mapped to width/height/channels, respectively
 * The returned mat is transposed due to the memory alignment of Matlab.
 * To fix it, call mat.t() when needed. This however requires copying data
 */
cv::Mat MxArray::toMat(int depth) const
{
	// Create cv::Mat object
	mwSize nDim = mxGetNumberOfDimensions(p_);
	const mwSize *dims = mxGetDimensions(p_);
	int nChannels = (nDim > 2) ? dims[2] : 1;
	if (depth == CV_USRTYPE1)
		depth = cvmxClassIdToMatDepth(mxGetClassID(p_));
	cv::Mat mat(dims[1],dims[0],CV_MAKETYPE(depth,nChannels));
	
	// Copy each channel
	std::vector<cv::Mat> mv(nChannels);
	mwSize subs[] = {0,0,0};
	for (int i = 0; i<nChannels; ++i) {
		subs[2] = i;
		void *pd = reinterpret_cast<void*>(
				reinterpret_cast<size_t>(mxGetData(p_))+
				mxGetElementSize(p_)*mxCalcSingleSubscript(p_,3,subs));
		cv::Mat m(mat.rows,mat.cols,
				CV_MAKETYPE(cvmxClassIdToMatDepth(mxGetClassID(p_)),1),
				pd,mxGetElementSize(p_)*mat.cols);
		m.convertTo(mv[i],CV_MAKETYPE(depth,1)); // Read from mxArray through m
	}
	cv::merge(mv,mat);
	return mat;
}

/** Convert MxArray to scalar double
 * @return int value
 */
int MxArray::toInt() const { return scalar<int>(); }

/** Convert MxArray to scalar int
 * @return double value
 */
double MxArray::toDouble() const { return scalar<double>(); }

/** Convert MxArray to scalar int
 * @return double value
 */
bool MxArray::toBool() const { return scalar<bool>(); }

/** Convert MxArray to std::string
 * @return std::string value
 */
std::string MxArray::toString() const
{
	if (!isChar())
		mexErrMsgIdAndTxt("mexopencv:error","MxArray not of type char");
	char *pc = mxArrayToString(p_);
	std::string s(pc);
	mxFree(pc);
	return s;
}

// Initialize border type
std::map<std::string, int> const BorderType::m = BorderType::create_border_type();
int BorderType::get(const mxArray *arr) {
	std::map<std::string,int>::const_iterator mi =
		BorderType::m.find(MxArray(arr).toString());
	if (mi == BorderType::m.end())
		mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
	return (*mi).second;
}