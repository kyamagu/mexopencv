/**
 * @file MxArray.hpp
 * @brief MxArray and ConstMap declaration
 * @author Kota Yamaguchi
 * @date 2012
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
#include <functional>

/** mxArray object wrapper for conversion and manipulation
 */
class MxArray {
	public:
		MxArray(const mxArray *arr);
		/// Copy constructor
		MxArray(const MxArray& arr) : p_(arr.p_) {}
		/// Assignment operator
		MxArray& operator= (const MxArray& rhs) {
			if (this != &rhs)
				this->p_ = rhs.p_;
			return *this;
		}
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
		explicit MxArray(const std::vector<cv::KeyPoint>& p);
#if CV_MINOR_VERSION >= 2
		explicit MxArray(const cv::DMatch& m);
		explicit MxArray(const std::vector<cv::DMatch>& m);
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
		MxArray(const char**fields, int nfields, int m=1, int n=1);
		
		/// Create a new cell array
		/// @param m Number of rows
		/// @param n Number of cols
		static inline MxArray Cell(int m=1, int n=1) {
			return MxArray(mxCreateCellMatrix(m,n));
		}
		/// Create a new struct array
		/// @param fields Field names
		/// @param nfields Number of fields
		/// @param m Number of rows
		/// @param n Number of cols
		static inline MxArray Struct(const char**fields=NULL, int nfields=0, int m=1, int n=1) {
			return MxArray(mxCreateStructMatrix(m,n,nfields,fields));
		}
		/// Clone mxArray
		MxArray clone() { return MxArray(mxDuplicateArray(p_)); }
		/// Destroy allocated mxArray
		void destroy() { mxDestroyArray(const_cast<mxArray*>(p_)); }
		
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
		template <typename T> std::vector<T> toVector() const;
		template <typename T>
		std::vector<T> toVector(std::const_mem_fun_ref_t<T,MxArray> f) const;
		
		/// Alias to toPoint_<int>
		inline cv::Point toPoint() const { return toPoint_<int>(); }
		/// Alias to toPoint_<float>
		inline cv::Point2f toPoint2f() const { return toPoint_<float>(); }
		/// Alias to toPoint3_<float>
		inline cv::Point3f toPoint3f() const { return toPoint3_<float>(); }
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
		/// Number of rows in an array
		inline mwSize rows() const { return mxGetM(p_); }
		/// Number of columns in an array
		inline mwSize cols() const { return mxGetN(p_); }
		/// Number of fields in a struct array
		inline int nfields() const { return mxGetNumberOfFields(p_); }
		std::string fieldname(int index=0) const;
		std::vector<std::string> fieldnames() const;
		/// Number of elements in IR, PR, and PI arrays
		inline mwSize nzmax() const { return mxGetNzmax(p_); }
		mwIndex subs(mwIndex i, mwIndex j=0) const;
		mwIndex subs(const std::vector<mwIndex>& si) const;
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
		/// Determine whether a struct array has a specified field
		bool isField(const std::string& fieldName, mwIndex index=0) const {
			return isStruct() && mxGetField(p_, index, fieldName.c_str())!=NULL;
		}
		
		// Element accessor
		
		template <typename T> T at(mwIndex index) const;
		template <typename T> inline T at(mwIndex i, mwIndex j) const;
		template <typename T> inline T at(const std::vector<mwIndex>& si) const;
		MxArray at(const std::string& fieldName, mwIndex index=0) const;
		template <typename T> void set(mwIndex index, const T& value);
		template <typename T> inline void set(mwIndex i, mwIndex j, const T& value);
		template <typename T> inline void set(const std::vector<mwIndex>& si, const T& value);
		template <typename T> void set(const std::string& fieldName, const T& value, mwIndex index=0);
		
		// CONSTANT
		/// Value of infinity
		static inline double Inf() { return mxGetInf(); }
		/// Value of NaN (Not-a-Number)
		static inline double NaN() { return mxGetNaN(); }
		/// Value of EPS
		static inline double Eps() { return mxGetEps(); }
	private:
		/// Pointer to the mxArray
		const mxArray* p_;
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

/** Convert MxArray to std::vector<T> for a primitive type
 * @return std::vector<T> value
 *
 * The method is intended for conversion to a raw numeric vector such
 * as std::vector<int> or std::vector<double>. Example:
 *
 * @code
 * MxArray numArray(prhs[0]);
 * vector<double> vd = numArray.toVector<double>();
 * @endcode
 */
template <typename T>
std::vector<T> MxArray::toVector() const
{
	int n = numel();
	std::vector<T> vt(n);
	if (isNumeric())
		for (int i=0; i<n; ++i)
			vt[i] = at<T>(i);
	else if (isCell())
		for (int i=0; i<n; ++i)
			vt[i] = MxArray(mxGetCell(p_, i)).at<T>(0);
	else
		mexErrMsgIdAndTxt("mexopencv:error","Cannot convert to std::vector");
	return vt;
}

/** Convert MxArray to std::vector<T> by a specified conversion method
 * @param f member function of MxArray (e.g., &MxArray::toMat, &MxArray::toInt)
 * @return std::vector<T> value
 *
 * The method constructs std::vector<T> by applying conversion method f to each
 * cell array element. This is similar to std::transform function. The example
 * usage is shown below:
 *
 * @code
 * MxArray cellArray(prhs[0]);
 * const_mem_fun_ref_t<Point3i,MxArray> converter(&MxArray::toPoint3_<int>);
 * vector<Point3i> v = cellArray.toVector(converter);
 * @endcode
 */
template <typename T>
std::vector<T> MxArray::toVector(std::const_mem_fun_ref_t<T,MxArray> f) const
{
	std::vector<MxArray> v = toVector<MxArray>();
	std::vector<T> vt;
	vt.reserve(v.size());
	for (std::vector<MxArray>::iterator it=v.begin(); it<v.end(); ++it)
		vt.push_back(f(*it));
	return vt;
}

/** Template for element accessor
 * @param index index of the array element
 * @return value of the element at index
 *
 * Example:
 * @code
 * MxArray m(prhs[0]);
 * double d = m.at<double>(0);
 * @endcode
 */
template <typename T>
T MxArray::at(mwIndex index) const
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
			return static_cast<T>(0);
	}
}

/** Template for element accessor
 * @param i index of the first dimension
 * @param j index of the second dimension
 * @return value of the element at (i,j)
 */
template <typename T>
T MxArray::at(mwIndex i, mwIndex j) const
{
	return at<T>(subs(i,j));
}

/** Template for element accessor
 * @param si subscript index of the element
 * @return value of the element at subscript index
 */
template <typename T>
T MxArray::at(const std::vector<mwIndex>& si) const
{
	return at<T>(subs(si));
}

/** Template for element write accessor
 * @param index offset of the array element
 * @param value value of the field
 */
template <typename T>
void MxArray::set(mwIndex index, const T& value)
{
	if (index < 0 || numel() <= index)
		mexErrMsgIdAndTxt("mexopencv:error","Accessing invalid range");
	switch (classID()) {
		case mxCHAR_CLASS:
			*(mxGetChars(p_)+index) = static_cast<mxChar>(value); break;
		case mxDOUBLE_CLASS:
			*(mxGetPr(p_)+index) = static_cast<double>(value); break;
		case mxINT8_CLASS:
			*(reinterpret_cast<int8_t*>(mxGetData(p_))+index) = static_cast<int8_t>(value); break;
		case mxUINT8_CLASS:
			*(reinterpret_cast<uint8_t*>(mxGetData(p_))+index) = static_cast<uint8_t>(value); break;
		case mxINT16_CLASS:
			*(reinterpret_cast<int16_t*>(mxGetData(p_))+index) = static_cast<int16_t>(value); break;
		case mxUINT16_CLASS:
			*(reinterpret_cast<uint16_t*>(mxGetData(p_))+index) = static_cast<uint16_t>(value); break;
		case mxINT32_CLASS:
			*(reinterpret_cast<int32_t*>(mxGetData(p_))+index) = static_cast<int32_t>(value); break;
		case mxUINT32_CLASS:
			*(reinterpret_cast<uint32_t*>(mxGetData(p_))+index) = static_cast<uint32_t>(value); break;
		case mxINT64_CLASS:
			*(reinterpret_cast<int64_t*>(mxGetData(p_))+index) = static_cast<int64_t>(value); break;
		case mxUINT64_CLASS:
			*(reinterpret_cast<uint64_t*>(mxGetData(p_))+index) = static_cast<uint64_t>(value); break;
		case mxSINGLE_CLASS:
			*(reinterpret_cast<float*>(mxGetData(p_))+index) = static_cast<float>(value); break;
		case mxLOGICAL_CLASS:
			*(mxGetLogicals(p_)+index) = static_cast<mxLogical>(value); break;
		case mxCELL_CLASS:
			mxSetCell(const_cast<mxArray*>(p_), index, MxArray(value)); break;
		case mxSTRUCT_CLASS:
		case mxFUNCTION_CLASS:
		default:
			mexErrMsgIdAndTxt("mexopencv:error","MxArray type is not valid");
	}
}

/** Template for element write accessor
 * @param i index of the first dimension of the array element
 * @param j index of the first dimension of the array element
 * @param value value of the field
 */
template <typename T>
void MxArray::set(mwIndex i, mwIndex j, const T& value)
{
	set<T>(subs(i,j),value);
}

/** Template for element write accessor
 * @param si subscript index of the element
 * @param value value of the field
 */
template <typename T>
void MxArray::set(const std::vector<mwIndex>& si, const T& value)
{
	set<T>(subs(si),value);
}

/** Template for struct element write accessor
 * @param fieldName field name of the struct array
 * @param value value of the field
 * @param index linear index of the struct array element
 */
template <typename T>
void MxArray::set(const std::string& fieldName, const T& value, mwIndex index)
{
	if (!isStruct())
		mexErrMsgIdAndTxt("mexopencv:error","MxArray is not struct");
	if (!isField(fieldName)) {
		if (mxAddField(const_cast<mxArray*>(p_), fieldName.c_str())<0)
			mexErrMsgIdAndTxt("mexopencv:error","Failed to create a field '%s'", fieldName.c_str());
	}
	mxSetField(const_cast<mxArray*>(p_),index,fieldName.c_str(), MxArray(value));
}

// Template specializations
template <> MxArray MxArray::at(mwIndex index) const;
template <> void MxArray::set(mwIndex index, const MxArray& value);
template <> std::vector<MxArray> MxArray::toVector() const;
template <> std::vector<std::string> MxArray::toVector() const;
template <> std::vector<cv::Mat> MxArray::toVector() const;
template <> std::vector<cv::Point> MxArray::toVector() const;
template <> std::vector<cv::Point2f> MxArray::toVector() const;
template <> std::vector<cv::Point3f> MxArray::toVector() const;
template <> std::vector<MxArray> MxArray::toVector() const;
template <> std::vector<cv::KeyPoint> MxArray::toVector() const;
#if CV_MINOR_VERSION >= 2
template <> std::vector<cv::DMatch> MxArray::toVector() const;
#endif

#endif
