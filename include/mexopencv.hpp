/**
 * @file cvmx.hpp
 * @brief data converter and utilities for mxArray and cv::Mat
 * @author Kota Yamaguchi
 * @date 2011
 * @details
 * Usage:
 * @code
 * Mat m = MxArray(a);
 * mxArray* a = MxArray(m);
 * @endcode
 */
#ifndef __CVMX_HPP__
#define __CVMX_HPP__

#include "mex.h"
#include "cv.h"
#include <map>
#include <string>

/** mxArray object wrapper for conversion and manipulation
 */
class MxArray {
	public:
		// Constructor is converter
		explicit MxArray(const mxArray *arr);
		explicit MxArray(const cv::Mat& mat, mxClassID classid=mxUNKNOWN_CLASS);
		explicit MxArray(const int& i);
		explicit MxArray(const double& d);
		explicit MxArray(const bool& b);
		explicit MxArray(const std::string& s);
		virtual ~MxArray() {};
		
		// Converters
		operator const mxArray*() const { return p_; };
		operator mxArray*() const { return const_cast<mxArray*>(p_); };
		std::string toString() const;
		int toInt() const;
		double toDouble() const;
		bool toBool() const;
		cv::Mat toMat(int depth=CV_USRTYPE1) const;
		template <typename T> cv::Point_<T> toPoint() const;
		template <typename T> cv::Size_<T> toSize() const;
		template <typename T> cv::Rect_<T> toRect() const;
		
		// Generic scalar converter
		template <typename T> T scalar() const;
		
		// Status checker
		inline bool isInt8() const { return mxIsInt8(p_); }
		inline bool isUint8() const { return mxIsUint8(p_); }
		inline bool isInt16() const { return mxIsInt16(p_); }
		inline bool isUint16() const { return mxIsUint16(p_); }
		inline bool isInt32() const { return mxIsInt32(p_); }
		inline bool isUint32() const { return mxIsUint32(p_); }
		inline bool isInt64() const { return mxIsInt64(p_); }
		inline bool isUint64() const { return mxIsUint64(p_); }
		inline bool isSingle() const { return mxIsSingle(p_); }
		inline bool isDouble() const { return mxIsDouble(p_); }
		inline bool isChar() const { return mxIsChar(p_); }
		inline bool isNumeric() const { return mxIsNumeric(p_); }
		inline bool isLogical() const { return mxIsLogical(p_); }
		inline bool isEmpty() const { return mxIsEmpty(p_); }
		inline bool isScalar() const { return mxGetM(p_)==1&&mxGetN(p_)==1; }
		inline bool isStruct() const { return mxIsStruct(p_); }
		inline bool isSparse() const { return mxIsSparse(p_); }
		inline bool isCell() const { return mxIsCell(p_); }
		
		// Accessor
		template <typename T> const T at(size_t index) const;
	private:
		const mxArray* p_;
};


/** Convert MxArray to scalar primitive type T
 */
template <typename T>
T MxArray::scalar() const
{
	if (!isScalar())
		mexErrMsgIdAndTxt("mexopencv:error","MxArray is not scalar");
	if (!(isNumeric()||isChar()||isLogical()))
		mexErrMsgIdAndTxt("mexopencv:error","MxArray is not primitive");
	return static_cast<T>(mxGetScalar(p_));
};

/** Convert MxArray to Point_<T>
 */
template <typename T>
cv::Point_<T> MxArray::toPoint() const
{
	if (!isNumeric() || (mxGetM(p_)*mxGetN(p_))!=2)
		mexErrMsgIdAndTxt("mexopencv:error","MxArray is not Point");
	return cv::Point_<T>(at<T>(0),at<T>(1));
}

/** Convert MxArray to Size_<T>
 */
template <typename T>
cv::Size_<T> MxArray::toSize() const
{
	if (!isNumeric() || (mxGetM(p_)*mxGetN(p_))!=2)
		mexErrMsgIdAndTxt("mexopencv:error","MxArray is not Size");
	return cv::Size_<T>(at<T>(0),at<T>(1));
}

/** Convert MxArray to Rect_<T>
 */
template <typename T>
cv::Rect_<T> MxArray::toRect() const
{
	if (!isNumeric() || (mxGetM(p_)*mxGetN(p_))!=4)
		mexErrMsgIdAndTxt("mexopencv:error","MxArray is not Size");
	return cv::Rect_<T>(at<T>(0),at<T>(1),at<T>(2),at<T>(3));
}

/** Template for element accessor
 */
template <typename T>
const T MxArray::at(size_t index) const
{
	if (mxGetM(p_)*mxGetN(p_) <= index)
		mexErrMsgIdAndTxt("mexopencv:error","Accessing invalid range");
	switch (mxGetClassID(p_)) {
		case mxCHAR_CLASS:
			return static_cast<T>(*(mxGetChars(p_)+index));
		case mxDOUBLE_CLASS:
			return static_cast<T>(*(mxGetPr(p_)+index));
		case mxINT8_CLASS:
			static_cast<T>(*(reinterpret_cast<int8_t*>(mxGetData(p_))+index));
		case mxUINT8_CLASS:
			static_cast<T>(*(reinterpret_cast<uint8_t*>(mxGetData(p_))+index));
		case mxINT16_CLASS:
			static_cast<T>(*(reinterpret_cast<int16_t*>(mxGetData(p_))+index));
		case mxUINT16_CLASS:
			static_cast<T>(*(reinterpret_cast<uint16_t*>(mxGetData(p_))+index));
		case mxINT32_CLASS:
			static_cast<T>(*(reinterpret_cast<int32_t*>(mxGetData(p_))+index));
		case mxUINT32_CLASS:
			static_cast<T>(*(reinterpret_cast<uint32_t*>(mxGetData(p_))+index));
		case mxINT64_CLASS:
			static_cast<T>(*(reinterpret_cast<int64_t*>(mxGetData(p_))+index));
		case mxUINT64_CLASS:
			static_cast<T>(*(reinterpret_cast<uint64_t*>(mxGetData(p_))+index));
		case mxSINGLE_CLASS:
			static_cast<T>(*(reinterpret_cast<float*>(mxGetData(p_))+index));
		case mxLOGICAL_CLASS:
			static_cast<T>(*(reinterpret_cast<mxLogical*>(mxGetData(p_))+index));
		default:
			mexErrMsgIdAndTxt("mexopencv:error","MxArray is not primitive");
	}
}

/** BorderType helper for option processing
 *
 */
struct BorderType {
	static int get(const mxArray *arr);
	static std::map<std::string, int> const m;
	static std::map<std::string, int> create_border_type() {
		std::map<std::string, int> m;
		m["Replicate"]		= cv::BORDER_REPLICATE;
		m["Constant"]   	= cv::BORDER_CONSTANT;
		m["Reflect"] 		= cv::BORDER_REFLECT;
		m["Wrap"]			= cv::BORDER_WRAP;
		m["Reflect101"] 	= cv::BORDER_REFLECT_101;
		m["Transparent"]	= cv::BORDER_TRANSPARENT;
		m["Default"] 		= cv::BORDER_DEFAULT;
		m["Isolated"]		= cv::BORDER_ISOLATED;
		return m;
	}
};

#endif