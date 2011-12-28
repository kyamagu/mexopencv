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
		explicit MxArray(const double& d);
		explicit MxArray(const std::string& s);
		virtual ~MxArray() {};
		
		// Explicit converters
		cv::Mat convertTo(int depth=CV_USRTYPE1) const;
		template <typename T> T scalar() const;
		
		// Implicit converters
		operator const mxArray*() const { return p_; };
		operator mxArray*() const { return const_cast<mxArray*>(p_); };
		operator std::string() const;
		operator int() const;
		operator double() const;
		operator bool() const;
		operator cv::Mat() const { return convertTo(); };
		template <typename T> operator cv::Point_<T>() const;
		template <typename T> operator cv::Size_<T>() const;
		template <typename T> operator cv::Rect_<T>() const;
		
		// Status checker
		inline bool isint8() const { return mxIsInt8(p_); }
		inline bool isuint8() const { return mxIsUint8(p_); }
		inline bool isint16() const { return mxIsInt16(p_); }
		inline bool isuint16() const { return mxIsUint16(p_); }
		inline bool isint32() const { return mxIsInt32(p_); }
		inline bool isuint32() const { return mxIsUint32(p_); }
		inline bool isint64() const { return mxIsInt64(p_); }
		inline bool isuint64() const { return mxIsUint64(p_); }
		inline bool issingle() const { return mxIsSingle(p_); }
		inline bool isdouble() const { return mxIsDouble(p_); }
		inline bool ischar() const { return mxIsChar(p_); }
		inline bool isnumeric() const { return mxIsNumeric(p_); }
		inline bool islogical() const { return mxIsLogical(p_); }
		inline bool isempty() const { return mxIsEmpty(p_); }
		inline bool isscalar() const { return mxGetM(p_)==1&&mxGetN(p_)==1; }
		inline bool isstruct() const { return mxIsStruct(p_); }
		inline bool issparse() const { return mxIsSparse(p_); }
		inline bool iscell() const { return mxIsCell(p_); }
		
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
	if (!isscalar())
		mexErrMsgIdAndTxt("cvmx:invalidType","MxArray is not scalar");
	if (!(isnumeric()||ischar()||islogical()))
		mexErrMsgIdAndTxt("cvmx:invalidType","MxArray is not primitive");
	return static_cast<T>(mxGetScalar(p_));
};

/** Convert MxArray to Point_<T>
 */
template <typename T>
MxArray::operator cv::Point_<T>() const
{
	if (!isnumeric() || (mxGetM(p_)*mxGetN(p_))!=2)
		mexErrMsgIdAndTxt("cvmx:invalidType","MxArray is not Point");
	return cv::Point_<T>(at<T>(0),at<T>(1));
}

/** Convert MxArray to Size_<T>
 */
template <typename T>
MxArray::operator cv::Size_<T>() const
{
	if (!isnumeric() || (mxGetM(p_)*mxGetN(p_))!=2)
		mexErrMsgIdAndTxt("cvmx:invalidType","MxArray is not Size");
	return cv::Size_<T>(at<T>(0),at<T>(1));
}

/** Convert MxArray to Rect_<T>
 */
template <typename T>
MxArray::operator cv::Rect_<T>() const
{
	if (!isnumeric() || (mxGetM(p_)*mxGetN(p_))!=4)
		mexErrMsgIdAndTxt("cvmx:invalidType","MxArray is not Size");
	return cv::Rect_<T>(at<T>(0),at<T>(1),at<T>(2),at<T>(3));
}

/** Template for element accessor
 */
template <typename T>
const T MxArray::at(size_t index) const
{
	if (mxGetM(p_)*mxGetN(p_) <= index)
		mexErrMsgIdAndTxt("cvmx:rangeError","Accessing invalid range");
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
			mexErrMsgIdAndTxt("cvmx:invalidType","MxArray is not primitive");
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