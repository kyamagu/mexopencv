/**
 * @file MxArray.hpp
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
#ifndef __MXARRAY_HPP__
#define __MXARRAY_HPP__

#include "mex.h"
#include "cv.h"
#include <map>
#include <string>

/** mxArray object wrapper for conversion and manipulation
 */
class MxArray {
	public:
		explicit MxArray(const mxArray *arr);
		explicit MxArray(const int i);
		explicit MxArray(const double d);
		explicit MxArray(const bool b);
		explicit MxArray(const std::string& s);
		explicit MxArray(const cv::Mat& mat, mxClassID classid=mxUNKNOWN_CLASS, bool transpose=false);
		template <typename T> explicit MxArray(const std::vector<T>& v);
		/// Destructor
		virtual ~MxArray() {};
		
		/// Implicit conversion to const mxArray*
		operator const mxArray*() const { return p_; };
		/// Implicit conversion to mxArray*
		operator mxArray*() const { return const_cast<mxArray*>(p_); };
		
		int toInt() const;
		double toDouble() const;
		bool toBool() const;
		std::string toString() const;
		cv::Mat toMat(int depth=CV_USRTYPE1, bool transpose=false) const;
		template <typename T> cv::Point_<T> toPoint() const;
		template <typename T> cv::Point3_<T> toPoint3() const;
		template <typename T> cv::Size_<T> toSize() const;
		template <typename T> cv::Rect_<T> toRect() const;
		template <typename T> cv::Scalar_<T> toScalar() const;
		
		// mxArray API wrapper
		
		/// Class ID of mxArray
		inline mxClassID classID() const { return mxGetClassID(p_); }
		/// Class name of mxArray
		inline const std::string className() const { return std::string(mxGetClassName(p_)); }
		/// Number of elements in an array
		inline mwSize numel() const { return mxGetNumberOfElements(p_); }
		/// Number of dimensions
		inline mwSize ndims() const { return mxGetNumberOfDimensions(p_); }
		std::vector<mwSize> dims() const;
		/// Number of rows in array
		inline mwSize rows() const { return mxGetM(p_); }
		/// Number of columns in array
		inline mwSize cols() const { return mxGetN(p_); }
		mwIndex subs(mwIndex i, mwIndex j) const;
		mwIndex subs(std::vector<mwIndex>& si) const;
		/// Determine whether input is cell array
		inline bool isCell() const { return mxIsCell(p_); }
		/// Determine whether input is string array
		inline bool isChar() const { return mxIsChar(p_); }
		/// Determine whether array is member of specified class
		inline bool isClass(std::string s) const { return mxIsClass(p_, s.c_str()); }
		/// Determine whether data is complex
		inline bool isComplex() const { return mxIsComplex(p_); }
		/// Determine whether mxArray represents data as double-precision, floating-point numbers
		inline bool isDouble() const { return mxIsDouble(p_); }
		/// Determine whether array is empty
		inline bool isEmpty() const { return mxIsEmpty(p_); }
		/// Determine whether input is finite
		static inline bool isFinite(double d) { return mxIsFinite(d); }
		/// Determine whether array was copied from MATLAB global workspace
		inline bool isFromGlobalWS() const { return mxIsFromGlobalWS(p_); };
		/// Determine whether input is infinite
		static inline bool isInf(double d) { return mxIsInf(d); }
		/// Determine whether array represents data as signed 8-bit integers
		inline bool isInt8() const { return mxIsInt8(p_); }
		/// Determine whether array represents data as signed 16-bit integers
		inline bool isInt16() const { return mxIsInt16(p_); }
		/// Determine whether array represents data as signed 32-bit integers
		inline bool isInt32() const { return mxIsInt32(p_); }
		/// Determine whether array represents data as signed 64-bit integers
		inline bool isInt64() const { return mxIsInt64(p_); }
		/// Determine whether array is of type mxLogical
		inline bool isLogical() const { return mxIsLogical(p_); }
		/// Determine whether scalar array is of type mxLogical
		inline bool isLogicalScalar() const { return mxIsLogicalScalar(p_); }
		/// Determine whether scalar array of type mxLogical is true
		inline bool isLogicalScalarTrue() const { return mxIsLogicalScalarTrue(p_); }
		/// Determine whether input is NaN (Not-a-Number)
		static inline bool isNaN(double d) { return mxIsNaN(d); }
		/// Determine whether array is numeric
		inline bool isNumeric() const { return mxIsNumeric(p_); }
		/// Determine whether array represents data as single-precision, floating-point numbers
		inline bool isSingle() const { return mxIsSingle(p_); }
		/// Determine whether input is sparse array
		inline bool isSparse() const { return mxIsSparse(p_); }
		/// Determine whether input is structure array
		inline bool isStruct() const { return mxIsStruct(p_); }
		/// Determine whether array represents data as unsigned 8-bit integers
		inline bool isUint8() const { return mxIsUint8(p_); }
		/// Determine whether array represents data as unsigned 16-bit integers
		inline bool isUint16() const { return mxIsUint16(p_); }
		/// Determine whether array represents data as unsigned 32-bit integers
		inline bool isUint32() const { return mxIsUint32(p_); }
		/// Determine whether array represents data as unsigned 64-bit integers
		inline bool isUint64() const { return mxIsUint64(p_); }
		
		/// Element accessor
		template <typename T> const T at(mwIndex index) const;
		template <typename T> const T at(std::vector<mwIndex>& si) const;
		
		// CONSTANT
		/// Value of infinity
		static double Inf() { return mxGetInf(); }
		/// Value of NaN (Not-a-Number)
		static double NaN() { return mxGetNaN(); }
		/// Value of EPS
		static double Eps() { return mxGetEps(); }
	private:
		const mxArray* p_;
		/// Copy constructor (prohibited)
		explicit MxArray(const MxArray& rhs) {}
		/// Assignment operator (prohibited)
		const MxArray& operator=(const MxArray& rhs) {}
		template <typename T> T value() const;
};


/** MxArray constructor from vector<T>
 * @param v vector of type T
 */
template <typename T>
MxArray::MxArray(const std::vector<T>& v) : p_(mxCreateCellMatrix(1,v.size()))
{
	for (int i = 0; i < v.size(); ++i)
		mxSetCell(const_cast<mxArray*>(p_), i, MxArray(v[i]));
}

/** Convert MxArray to Point_<T>
 */
template <typename T>
cv::Point_<T> MxArray::toPoint() const
{
	if (!isNumeric() || numel()!=2)
		mexErrMsgIdAndTxt("mexopencv:error","MxArray is not Point");
	return cv::Point_<T>(at<T>(0),at<T>(1));
}

/** Convert MxArray to Point3_<T>
 */
template <typename T>
cv::Point3_<T> MxArray::toPoint3() const
{
	if (!isNumeric() || numel()!=3)
		mexErrMsgIdAndTxt("mexopencv:error","MxArray is not Point");
	return cv::Point3_<T>(at<T>(0),at<T>(1),at<T>(2));
}

/** Convert MxArray to Size_<T>
 */
template <typename T>
cv::Size_<T> MxArray::toSize() const
{
	if (!isNumeric() || numel()!=2)
		mexErrMsgIdAndTxt("mexopencv:error","MxArray is incompatible to cv::Size");
	return cv::Size_<T>(at<T>(0),at<T>(1));
}

/** Convert MxArray to Rect_<T>
 * @return cv::Rect_<T> value
 */
template <typename T>
cv::Rect_<T> MxArray::toRect() const
{
	if (!isNumeric() || numel()!=4)
		mexErrMsgIdAndTxt("mexopencv:error","MxArray is incompatible to cv::Rect");
	return cv::Rect_<T>(at<T>(0),at<T>(1),at<T>(2),at<T>(3));
}

/** Convert MxArray to Scalar_<T>
 * @return cv::Scalar_<T> value
 */
template <typename T>
cv::Scalar_<T> MxArray::toScalar() const
{
	if (!isNumeric() || numel()!=4)
		mexErrMsgIdAndTxt("mexopencv:error","MxArray is incompatible to cv::Scalar");
	return cv::Scalar_<T>(at<T>(0),at<T>(1),at<T>(2),at<T>(3));
}

/** Template for element accessor
 * @return value of the element at index
 */
template <typename T>
const T MxArray::at(mwIndex index) const
{
	if (numel() <= index)
		mexErrMsgIdAndTxt("mexopencv:error","Accessing invalid range");
	switch (classID()) {
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
			static_cast<T>(*(mxGetLogicals(p_)+index));
		default:
			mexErrMsgIdAndTxt("mexopencv:error","MxArray is not primitive");
	}
}


/** Template for element accessor
 * @return value of the element at subscript index
 */
template <typename T>
const T MxArray::at(std::vector<mwIndex>& si) const
{
	return at<T>(subs(si));
}

#endif