/**
 * @file MxArray.cpp
 * @brief Implemenation of data converters and utilities
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "MxArray.hpp"
using namespace cv;

// Local namescope
namespace {
/**
 * Translates data type definition used in OpenCV to that of Matlab
 * @param classid data type of matlab's mxArray. e.g., mxDOUBLE_CLASS
 * @return opencv's data type. e.g., CV_8U
 */
int classIdToDepth(mxClassID classid) {
	switch (classid) {
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
mxClassID depthToClassId(int depth) {
	switch (depth) {
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

/** Convert MxArray to scalar primitive type T
 */
template <typename T>
T MxArray::value() const
{
	if (numel()!=1)
		mexErrMsgIdAndTxt("mexopencv:error","MxArray is not a scalar value");
	if (!(isNumeric()||isChar()||isLogical()))
		mexErrMsgIdAndTxt("mexopencv:error","MxArray is not primitive type");
	return static_cast<T>(mxGetScalar(p_));
};


/** MxArray constructor from mxArray*
 * @param arr mxArray pointer given by mexFunction
 */
MxArray::MxArray(const mxArray *arr) : p_(arr) {}

/** MxArray constructor from double
 * @param d double value
 */
MxArray::MxArray(const double d) : p_(mxCreateDoubleScalar(d)) {}

/** MxArray constructor from int
 * @param i int value
 */
MxArray::MxArray(const int i) : p_(mxCreateDoubleScalar(static_cast<double>(i))) {}

/** MxArray constructor from bool
 * @param b bool value
 */
MxArray::MxArray(const bool b) : p_(mxCreateLogicalScalar(b)) {}

/** MxArray constructor from std::string
 * @param s reference to a string value
 */
MxArray::MxArray(const std::string& s) : p_(mxCreateString(s.c_str())) {}

/**
 * Convert cv::Mat to MxArray
 * @param mat cv::Mat object
 * @param classid classid of mxArray. e.g., mxDOUBLE_CLASS. default: automatic conversion
 * @param transpose optional Optional transposition to the return value. default
 *                  false. When true, it reduces internal copying operation
 * @return MxArray object
 *
 * The width/height/channels of cv::Mat are are mapped to the first/second/third dimensions of
 * mxArray, respectively.
 */
MxArray::MxArray(const cv::Mat& mat, mxClassID classid, bool transpose)
{
	const cv::Mat& rm = (transpose) ? mat : cv::Mat(mat.t());
	// Create a new mxArray
	int nChannels = rm.channels();
	mwSize nDim = (nChannels>1) ? 3 : 2;
	mwSize dims[] = {rm.cols, rm.rows, (nChannels>1) ? nChannels : 0};
	if (classid == mxUNKNOWN_CLASS)
		classid = depthToClassId(rm.depth());
	p_ = mxCreateNumericArray(nDim,dims,classid,mxREAL);
	
	// Copy each channel
	std::vector<cv::Mat> mv;
	cv::split(rm,mv);
	std::vector<mwSize> si(3,0); // subscript index
	int type = CV_MAKETYPE(classIdToDepth(classid),1); // destination type
	for (int i = 0; i < nChannels; ++i) {
		si[2] = i;
		void *ptr = reinterpret_cast<void*>(
				reinterpret_cast<size_t>(mxGetData(p_))+
				mxGetElementSize(p_)*subs(si));
		cv::Mat m(rm.rows,rm.cols,type,ptr,mxGetElementSize(p_)*rm.cols);
		mv[i].convertTo(m,type); // Write to mxArray through m
	}
}

/**
 * Convert MxArray to cv::Mat
 * @param depth depth of cv::Mat. e.g., CV_8U, CV_32F. default: automatic conversion
 * @param transpose optional Optional transposition of the input value. default
 *                  false. When true, it reduces internal copying operation
 * @return cv::Mat object
 * 
 * The first/second/third dimensions of mxArray are mapped to height/width/channels, respectively
 */
cv::Mat MxArray::toMat(int depth, bool transpose) const
{
	// Create cv::Mat object
	std::vector<mwSize> d = dims();
	int nChannels = (d.size() > 2) ? d[2] : 1;
	if (depth == CV_USRTYPE1)
		depth = classIdToDepth(classID());
	cv::Mat mat(d[1],d[0],CV_MAKETYPE(depth,nChannels));
	
	// Copy each channel
	std::vector<cv::Mat> mv(nChannels);
	std::vector<mwSize> si(3,0); // subscript index
	for (int i = 0; i<nChannels; ++i) {
		si[2] = i;
		void *pd = reinterpret_cast<void*>(
				reinterpret_cast<size_t>(mxGetData(p_))+
				mxGetElementSize(p_)*subs(si));
		cv::Mat m(mat.rows,mat.cols,
				CV_MAKETYPE(classIdToDepth(classID()),1),
				pd,mxGetElementSize(p_)*mat.cols);
		m.convertTo(mv[i],CV_MAKETYPE(depth,1)); // Read from mxArray through m
	}
	cv::merge(mv,mat);
	return (transpose) ? mat : cv::Mat(mat.t());
}

/** Convert MxArray to scalar double
 * @return int value
 */
int MxArray::toInt() const { return value<int>(); }

/** Convert MxArray to scalar int
 * @return double value
 */
double MxArray::toDouble() const { return value<double>(); }

/** Convert MxArray to scalar int
 * @return double value
 */
bool MxArray::toBool() const { return value<bool>(); }

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

/** Return dimension vector
 * @return vector of number of elements in each dimension
 */
std::vector<mwSize> MxArray::dims() const
{
	const mwSize *d = mxGetDimensions(p_);
	return std::vector<mwSize>(d,d+ndims());
}

/** Offset from first element to desired element
 * @return linear offset of the specified subscript index
 */
mwIndex MxArray::subs(mwIndex i, mwIndex j) const
{
	if (i < 0 || i >= rows() || j < 0 || j >= cols())
		mexErrMsgIdAndTxt("mexopencv:error","Subscript out of range");
	mwIndex s[] = {i,j};
	return mxCalcSingleSubscript(p_, 2, s);
}

/** Offset from first element to desired element
 * @return linear offset of the specified subscript index
 */
mwIndex MxArray::subs(std::vector<mwIndex>& si) const
{
	return mxCalcSingleSubscript(p_, si.size(), &si[0]);
}
