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
#if CV_MINOR_VERSION >= 2
#include "opencv2/opencv.hpp"
#else
#include "opencv/cv.h"
#include "opencv/highgui.h"
#include "opencv/ml.h"
#endif
#include <stdint.h>
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
		explicit MxArray(const cv::Mat& mat, mxClassID classid=mxUNKNOWN_CLASS, bool transpose=true);
#if CV_MINOR_VERSION < 2
		explicit MxArray(const cv::MatND& mat, mxClassID classid=mxUNKNOWN_CLASS);
#endif
		explicit MxArray(const cv::SparseMat& mat);
		explicit MxArray(const cv::KeyPoint& p);
#if CV_MINOR_VERSION >= 2
		explicit MxArray(const cv::DMatch& m);
#endif
		explicit MxArray(const cv::Moments& m);
		explicit MxArray(const cv::RotatedRect& m);
		explicit MxArray(const cv::TermCriteria& t);
		template <typename T> explicit MxArray(const cv::Point_<T>& p);
		template <typename T> explicit MxArray(const cv::Point3_<T>& p);
		template <typename T> explicit MxArray(const cv::Size_<T>& s);
		template <typename T> explicit MxArray(const cv::Rect_<T>& r);
		template <typename T> explicit MxArray(const cv::Scalar_<T>& r);
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
		cv::Mat toMat(int depth=CV_USRTYPE1, bool transpose=true) const;
		cv::MatND toMatND(int depth=CV_USRTYPE1, bool transpose=true) const;
		cv::SparseMat toSparseMat() const;
		cv::Moments toMoments(mwIndex index=0) const;
		cv::KeyPoint toKeyPoint(mwIndex index=0) const;
#if CV_MINOR_VERSION >= 2
		cv::DMatch toDMatch(mwIndex index=0) const;
#endif
		cv::Range toRange() const;
		cv::TermCriteria toTermCriteria(mwIndex index=0) const;
		template <typename T> cv::Point_<T> toPoint_() const;
		template <typename T> cv::Point3_<T> toPoint3_() const;
		template <typename T> cv::Size_<T> toSize_() const;
		template <typename T> cv::Rect_<T> toRect_() const;
		template <typename T> cv::Scalar_<T> toScalar_() const;
		template <typename T> std::vector<T> toStdVector() const;
		
		/// Alias to toPoint_<int>
		inline cv::Point toPoint() const { return toPoint_<int>(); }
		/// Alias to toSize_<int>
		inline cv::Size toSize() const { return toSize_<int>(); }
		/// Alias to toRect_<int>
		inline cv::Rect toRect() const { return toRect_<int>(); }
		/// Alias to toScalar_<double>
		inline cv::Scalar toScalar() const { return toScalar_<double>(); }
		
		// mxArray API wrapper
		
		/// Class ID of mxArray
		inline mxClassID classID() const { return mxGetClassID(p_); }
		/// Class name of mxArray
		inline const std::string className() const { return std::string(mxGetClassName(p_)); }
		/// Number of elements in an array
		inline mwSize numel() const { return mxGetNumberOfElements(p_); }
		/// Number of dimensions
		inline mwSize ndims() const { return mxGetNumberOfDimensions(p_); }
		/// Array of each dimension
		inline const mwSize* dims() const { return mxGetDimensions(p_); };
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
		template <typename T> T value() const;
};

/** std::map wrapper with one-line initialization and lookup method
 * @details
 * Initialization
 * @code
 * const ConstMap<std::string,int> BorderType = ConstMap<std::string,int>
 *     ("Replicate",  cv::BORDER_REPLICATE)
 *     ("Constant",   cv::BORDER_CONSTANT)
 *     ("Reflect",    cv::BORDER_REFLECT);
 * @endcode
 * Lookup
 * @code
 * BorderType["Constant"] // => cv::BORDER_CONSTANT
 * @endcode
 */
template <typename T, typename U>
class ConstMap
{
	private:
		std::map<T, U> m_;
	public:
		/// Constructor with a single key-value pair
		ConstMap(const T& key, const U& val)
		{
			m_[key] = val;
		}
		/// Consecutive insertion operator
		ConstMap<T, U>& operator()(const T& key, const U& val)
		{
			m_[key] = val;
			return *this;
		}
		/// Implicit converter to std::map
		operator std::map<T, U>() { return m_; }
		/// Lookup operator; fail if not found
		U operator [](const T& key) const
		{
			typename std::map<T,U>::const_iterator it = m_.find(key);
			if (it==m_.end())
				mexErrMsgIdAndTxt("mexopencv:error","Value not found");
			return (*it).second;
		}
};

/** MxArray constructor from vector<T>. Make a cell array.
 * @param v vector of type T
 */
template <typename T>
MxArray::MxArray(const std::vector<T>& v) : p_(mxCreateCellMatrix(1,v.size()))
{
	if (!p_)
		mexErrMsgIdAndTxt("mexopencv:error","Allocation error");
	for (int i = 0; i < v.size(); ++i)
		mxSetCell(const_cast<mxArray*>(p_), i, MxArray(v[i]));
}

/** MxArray constructor from cv::Point_<T>
 */
template <typename T>
MxArray::MxArray(const cv::Point_<T>& p) :
	p_(mxCreateNumericMatrix(1,2,mxDOUBLE_CLASS,mxREAL))
{
	if (!p_)
		mexErrMsgIdAndTxt("mexopencv:error","Allocation error");
	double *x = mxGetPr(p_);
	x[0] = p.x;
	x[1] = p.y;
}

/** MxArray constructor from cv::Point3_<T>
 */
template <typename T>
MxArray::MxArray(const cv::Point3_<T>& p) :
	p_(mxCreateNumericMatrix(1,3,mxDOUBLE_CLASS,mxREAL))
{
	if (!p_)
		mexErrMsgIdAndTxt("mexopencv:error","Allocation error");
	double *x = mxGetPr(p_);
	x[0] = p.x;
	x[1] = p.y;
	x[2] = p.z;
}

/** MxArray constructor from cv::Size_<T>
 */
template <typename T>
MxArray::MxArray(const cv::Size_<T>& s) :
	p_(mxCreateNumericMatrix(1,2,mxDOUBLE_CLASS,mxREAL))
{
	if (!p_)
		mexErrMsgIdAndTxt("mexopencv:error","Allocation error");
	double *x = mxGetPr(p_);
	x[0] = s.width;
	x[1] = s.height;
}

/** MxArray constructor from cv::Rect_<T>
 */
template <typename T>
MxArray::MxArray(const cv::Rect_<T>& r) :
	p_(mxCreateNumericMatrix(1,4,mxDOUBLE_CLASS,mxREAL))
{
	if (!p_)
		mexErrMsgIdAndTxt("mexopencv:error","Allocation error");
	double *x = mxGetPr(p_);
	x[0] = r.x;
	x[1] = r.y;
	x[2] = r.width;
	x[3] = r.height;
}

/** MxArray constructor from cv::Scalar_<T>
 */
template <typename T>
MxArray::MxArray(const cv::Scalar_<T>& s) :
	p_(mxCreateNumericMatrix(1,4,mxDOUBLE_CLASS,mxREAL))
{
	if (!p_)
		mexErrMsgIdAndTxt("mexopencv:error","Allocation error");
	double *x = mxGetPr(p_);
	x[0] = s[0];
	x[1] = s[1];
	x[2] = s[2];
	x[3] = s[3];
}

/** Convert MxArray to Point_<T>
 */
template <typename T>
cv::Point_<T> MxArray::toPoint_() const
{
	if (!isNumeric() || numel()!=2)
		mexErrMsgIdAndTxt("mexopencv:error","MxArray is not Point");
	return cv::Point_<T>(at<T>(0),at<T>(1));
}

/** Convert MxArray to Point3_<T>
 */
template <typename T>
cv::Point3_<T> MxArray::toPoint3_() const
{
	if (!isNumeric() || numel()!=3)
		mexErrMsgIdAndTxt("mexopencv:error","MxArray is not Point");
	return cv::Point3_<T>(at<T>(0),at<T>(1),at<T>(2));
}

/** Convert MxArray to Size_<T>
 */
template <typename T>
cv::Size_<T> MxArray::toSize_() const
{
	if (!isNumeric() || numel()!=2)
		mexErrMsgIdAndTxt("mexopencv:error","MxArray is incompatible to cv::Size");
	return cv::Size_<T>(at<T>(0),at<T>(1));
}

/** Convert MxArray to Rect_<T>
 * @return cv::Rect_<T> value
 */
template <typename T>
cv::Rect_<T> MxArray::toRect_() const
{
	if (!isNumeric() || numel()!=4)
		mexErrMsgIdAndTxt("mexopencv:error","MxArray is incompatible to cv::Rect");
	return cv::Rect_<T>(at<T>(0),at<T>(1),at<T>(2),at<T>(3));
}

/** Convert MxArray to Scalar_<T>
 * @return cv::Scalar_<T> value
 */
template <typename T>
cv::Scalar_<T> MxArray::toScalar_() const
{
	int n = numel();
	if (!isNumeric() || n < 1 || 4 < n)
		mexErrMsgIdAndTxt("mexopencv:error","MxArray is incompatible to cv::Scalar");
	switch (n) {
		case 1: return cv::Scalar_<T>(at<T>(0));
		case 2: return cv::Scalar_<T>(at<T>(0),at<T>(1));
		case 3: return cv::Scalar_<T>(at<T>(0),at<T>(1),at<T>(2));
		case 4: return cv::Scalar_<T>(at<T>(0),at<T>(1),at<T>(2),at<T>(3));
	}
}

/** Convert MxArray to std::vector<T>
 * @return std::vector<T> value
 */
template <typename T>
std::vector<T> MxArray::toStdVector() const
{
	int n = numel();
	std::vector<T> v(n);
	if (isCell()) {
		for (int i=0; i<n; ++i)
			v[i] = MxArray(mxGetCell(p_, i)).at<T>(0);
	}
	else if (isNumeric()) {
		for (int i=0; i<n; ++i)
			v[i] = at<T>(i);
	}
	return v;
}

/** Template for element accessor
 * @return value of the element at index
 */
template <typename T>
const T MxArray::at(mwIndex index) const
{
	if (!p_ || numel() <= index)
		mexErrMsgIdAndTxt("mexopencv:error","Accessing invalid range");
	switch (classID()) {
		case mxCHAR_CLASS:
			return static_cast<T>(*(mxGetChars(p_)+index));
		case mxDOUBLE_CLASS:
			return static_cast<T>(*(mxGetPr(p_)+index));
		case mxINT8_CLASS:
			return static_cast<T>(*(reinterpret_cast<int8_t*>(mxGetData(p_))+index));
		case mxUINT8_CLASS:
			return static_cast<T>(*(reinterpret_cast<uint8_t*>(mxGetData(p_))+index));
		case mxINT16_CLASS:
			return static_cast<T>(*(reinterpret_cast<int16_t*>(mxGetData(p_))+index));
		case mxUINT16_CLASS:
			return static_cast<T>(*(reinterpret_cast<uint16_t*>(mxGetData(p_))+index));
		case mxINT32_CLASS:
			return static_cast<T>(*(reinterpret_cast<int32_t*>(mxGetData(p_))+index));
		case mxUINT32_CLASS:
			return static_cast<T>(*(reinterpret_cast<uint32_t*>(mxGetData(p_))+index));
		case mxINT64_CLASS:
			return static_cast<T>(*(reinterpret_cast<int64_t*>(mxGetData(p_))+index));
		case mxUINT64_CLASS:
			return static_cast<T>(*(reinterpret_cast<uint64_t*>(mxGetData(p_))+index));
		case mxSINGLE_CLASS:
			return static_cast<T>(*(reinterpret_cast<float*>(mxGetData(p_))+index));
		case mxLOGICAL_CLASS:
			return static_cast<T>(*(mxGetLogicals(p_)+index));
		case mxCELL_CLASS:
		case mxSTRUCT_CLASS:
		case mxFUNCTION_CLASS:
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

/// Field names of RotatedRect
extern const char *cv_rotated_rect_fields[3];
/// Field names of TermCriteria
extern const char *cv_term_criteria_fields[3];
/// Field names of Moments
extern const char *cv_moments_fields[10];
/// Field names of KeyPoint
extern const char *cv_keypoint_fields[6];
/// Field names of DMatch
extern const char *cv_dmatch_fields[4];

#endif
