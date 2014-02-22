/** MxArray and ConstMap declaration.
 * @file MxArray.hpp
 * @author Kota Yamaguchi
 * @date 2012
 */
#ifndef __MXARRAY_HPP__
#define __MXARRAY_HPP__

#include <functional>
#include <map>
#include <stdint.h>
#include <string>
#include "mex.h"
#include "opencv2/opencv.hpp"

/** Type traits for mxArray.
 */
template <typename T>
struct MxTypes {
    static const mxClassID type = mxUNKNOWN_CLASS;
};

/** int8_t traits.
 */
template<> struct MxTypes<int8_t>
{
    static const mxClassID type = mxINT8_CLASS;
};

/** uint8_t traits.
 */
template<> struct MxTypes<uint8_t>
{
    static const mxClassID type = mxUINT8_CLASS;
};

/** int16_t traits.
 */
template<> struct MxTypes<int16_t>
{
    static const mxClassID type = mxINT16_CLASS;
};

/** uint16_t traits.
 */
template<> struct MxTypes<uint16_t>
{
    static const mxClassID type = mxUINT16_CLASS;
};

/** int32_t traits.
 */
template<> struct MxTypes<int32_t>
{
    static const mxClassID type = mxINT32_CLASS;
};

/** uint32_t traits.
 */
template<> struct MxTypes<uint32_t>
{
    static const mxClassID type = mxUINT32_CLASS;
};

/** int64_t traits.
 */
template<> struct MxTypes<int64_t>
{
    static const mxClassID type = mxINT64_CLASS;
};

/** uint64_t traits.
 */
template<> struct MxTypes<uint64_t>
{
    static const mxClassID type = mxUINT64_CLASS;
};

/** float traits.
 */
template<> struct MxTypes<float>
{
    static const mxClassID type = mxSINGLE_CLASS;
};

/** double traits.
 */
template<> struct MxTypes<double>
{
    static const mxClassID type = mxDOUBLE_CLASS;
};

/** char traits.
 */
template<> struct MxTypes<char>
{
    static const mxClassID type = mxCHAR_CLASS;
};

/** bool traits.
 */
template<> struct MxTypes<bool>
{
    static const mxClassID type = mxLOGICAL_CLASS;
};

/** mxArray object wrapper for data conversion and manipulation.
 */
class MxArray
{
  public:
    /** MxArray constructor from mxArray*.
     * @param arr mxArray pointer given by mexFunction.
     */
    MxArray(const mxArray *arr) : p_(arr) {}
    /** Copy constructor.
     * @param arr Another MxArray.
     */
    MxArray(const MxArray& arr) : p_(arr.p_) {}
    /** Assignment operator.
     */
    MxArray& operator=(const MxArray& rhs);
    /** MxArray constructor from int.
     * @param i int value.
     */
    explicit MxArray(const int i);
    /** MxArray constructor from double.
     * @param d double value.
     */
    explicit MxArray(const double d);
    /** MxArray constructor from bool.
     * @param b bool value.
     */
    explicit MxArray(const bool b);
    /** MxArray constructor from std::string.
     * @param s reference to a string value.
     */
    explicit MxArray(const std::string& s);
    /** Convert cv::Mat to MxArray.
     * @param mat cv::Mat object.
     * @param classid classid of mxArray. e.g., mxDOUBLE_CLASS. When
     *                mxUNKNOWN_CLASS is specified, classid will be
     *                automatically determined from the type of cv::Mat.
     *                default: mxUNKNOWN_CLASS.
     * @param transpose Optional transposition to the return value so that rows
     *                  and columns of the 2D Mat are mapped to the 2nd and 1st
     *                  dimensions in MxArray, respectively. This does not
     *                  apply the N-D array conversion. default true.
     * @return MxArray object.
     *
     * Convert cv::Mat object to an MxArray. When the cv::Mat object is 2D, the
     * width, height, and channels are mapped to the first, second, and third
     * dimensions of the MxArray unless transpose flag is set to false. When
     * the cv::Mat object is N-D, (dim 1, dim 2,...dim N, channels) are mapped
     * to (dim 2, dim 1, ..., dim N, dim N+1), respectively.
     *
     * Example:
     * @code
     * cv::Mat x(120, 90, CV_8UC3, Scalar(0));
     * mxArray* plhs[0] = MxArray(x);
     * @endcode
     */
    explicit MxArray(const cv::Mat& mat,
                     mxClassID classid=mxUNKNOWN_CLASS,
                     bool transpose=true);
    /** Convert float cv::SparseMat to MxArray.
     * @param mat cv::SparseMat object.
     * @return MxArray object.
     */
    explicit MxArray(const cv::SparseMat& mat);
    /** Convert cv::Moments to MxArray.
     * @param m cv::Moments object.
     * @return MxArray object.
     */
    explicit MxArray(const cv::Moments& m);
    /** Convert cv::KeyPoint to MxArray.
     * @param p cv::KeyPoint object.
     * @return MxArray object.
     */
    explicit MxArray(const cv::KeyPoint& p);
    /** Convert cv::DMatch to MxArray.
     * @param m cv::DMatch object.
     * @return MxArray object.
     */
    explicit MxArray(const cv::DMatch& m);
    /** Convert cv::RotatedRect to MxArray.
     * @param m cv::RotatedRect object.
     * @return MxArray object.
     */
    explicit MxArray(const cv::RotatedRect& m);
    /** Convert cv::TermCriteria to MxArray.
     * @param t cv::TermCriteria object.
     * @return MxArray object.
     */
    explicit MxArray(const cv::TermCriteria& t);
    /** MxArray constructor from vector<T>. Make a numeric or cell array.
     * @param v vector of type T.
     */
    template <typename T> explicit MxArray(const std::vector<T>& v) {
        fromVector<T>(v);
    }
    /** MxArray constructor from cv::Point_<T>.
     * @param p cv::Point_<T> object.
     * @return two-element numeric MxArray.
     */
    template <typename T> explicit MxArray(const cv::Point_<T>& p);
    /** MxArray constructor from cv::Point3_<T>.
     * @param p cv::Point3_<T> object.
     * @return three-element numeric MxArray.
     */
    template <typename T> explicit MxArray(const cv::Point3_<T>& p);
    /** MxArray constructor from cv::Size_<T>.
     * @return two-element numeric MxArray.
     */
    template <typename T> explicit MxArray(const cv::Size_<T>& s);
    /** MxArray constructor from cv::Rect_<T>.
     * @return four-element numeric MxArray [x, y, width, height].
     */
    template <typename T> explicit MxArray(const cv::Rect_<T>& r);
    /** MxArray constructor from cv::Scalar_<T>.
     * @return four-element numeric MxArray.
     */
    template <typename T> explicit MxArray(const cv::Scalar_<T>& s);
    /** Generic constructor for a struct array.
     * @param fields field names.
     * @param nfields number of field names.
     * @param m size of the first dimension.
     * @param n size of the second dimension.
     *
     * Example:
     * @code
     * const char* fields[] = {"field1", "field2"};
     * MxArray m(fields, 2);
     * m.set("field1", 1);
     * m.set("field2", "field2 value");
     * @endcode
     */
    MxArray(const char**fields, int nfields, int m=1, int n=1);
    /** Destructor. This does not free the underlying mxArray*.
     */
    virtual ~MxArray() {}
    /** Create a new cell array.
     * @param m Number of rows.
     * @param n Number of cols.
     */
    static inline MxArray Cell(int m=1, int n=1)
    {
        return MxArray(mxCreateCellMatrix(m,n));
    }
    /** Create a new struct array.
     * @param fields Field names.
     * @param nfields Number of fields.
     * @param m Number of rows.
     * @param n Number of cols.
     */
    static inline MxArray Struct(const char**fields=NULL,
                                 int nfields=0,
                                 int m=1,
                                 int n=1)
    {
        return MxArray(mxCreateStructMatrix(m, n, nfields, fields));
    }
    /** Clone mxArray. This allocates new mxArray*.
     * @return MxArray object.
     */
    MxArray clone() { return MxArray(mxDuplicateArray(p_)); }
    /** Destroy allocated mxArray. Use this to destroy a temporary mxArray not
     *  to be used in matlab.
     * @return newly allocated MxArray object.
     */
    void destroy() { mxDestroyArray(const_cast<mxArray*>(p_)); }
    /** Implicit conversion to const mxArray*.
     * @return const mxArray* pointer.
     */
    operator const mxArray*() const { return p_; };
    /** Implicit conversion to mxArray*. Be careful that this internally cast
     *  away mxArray* constness.
     * @return mxArray* pointer.
     */
    operator mxArray*() const { return const_cast<mxArray*>(p_); };
    /** Convert MxArray to int.
     * @return int value.
     */
    int toInt() const;
    /** Convert MxArray to double.
     * @return double value.
     */
    double toDouble() const;
    /** Convert MxArray to bool.
     * @return bool value.
     */
    bool toBool() const;
    /** Convert MxArray to std::string.
     * @return std::string value.
     */
    std::string toString() const;
    /** Convert MxArray to cv::Mat.
     * @param depth depth of cv::Mat. e.g., CV_8U, CV_32F.  When CV_USERTYPE1
     *                is specified, depth will be automatically determined from
     *                the classid of the MxArray. default: CV_USERTYPE1.
     * @param transpose Optional transposition to the return value so that rows
     *                  and columns of the 2D Mat are mapped to the 2nd and 1st
     *                  dimensions in MxArray, respectively. This does not
     *                  apply the N-D array conversion. default true.
     * @return cv::Mat object.
     *
     * Convert a MxArray object to a cv::Mat object. When the dimensionality of
     * the MxArray is more than 2, the last dimension will be mapped to the
     * channels of the cv::Mat. Also, if the resulting cv::Mat is 2D, the 1st
     * and 2nd dimensions of the MxArray are mapped to rows and columns of the
     * cv::Mat unless transpose flag is false. That is, when MxArray is 3D,
     * (dim 1, dim 2, dim 3) are mapped to (cols, rows, channels) of the
     * cv::Mat by default, whereas if MxArray is more than 4D, (dim 1, dim 2,
     * ..., dim N-1, dim N) are mapped to (dim 2, dim 1, ..., dim N-1,
     * channels) of the cv::Mat, respectively.
     *
     * Example:
     * @code
     * cv::Mat x(MxArray(prhs[0]).toMat());
     * @endcode
     */
    cv::Mat toMat(int depth=CV_USRTYPE1, bool transpose=true) const;
    /** Convert MxArray to a single-channel cv::Mat.
     * @param depth depth of cv::Mat. e.g., CV_8U, CV_32F.  When CV_USERTYPE1
     *              is specified, depth will be automatically determined from
     *              the the classid of the MxArray. default: CV_USERTYPE1.
     * @param transpose Optional transposition to the return value so that rows
     *                  and columns of the 2D Mat are mapped to the 2nd and 1st
     *                  dimensions in MxArray, respectively. This does not
     *                  apply the N-D array conversion. default true.
     * @return const cv::Mat object.
     *
     * Convert a MxArray object to a single-channel cv::Mat object. If the
     * MxArray is 2D, the 1st and 2nd dimensions of the MxArray are mapped to
     * rows and columns of the cv::Mat unless transpose flag is false. If the
     * MxArray is more than 3D, the 1st and 2nd dimensions of the MxArray are
     * mapped to 2nd and 1st dimensions of the cv::Mat. That is, when MxArray
     * is 2D, (dim 1, dim 2) are mapped to (cols, rows) of the cv::Mat by
     * default, whereas if MxArray is more than 3D, (dim 1, dim 2, dim 3, ...,
     * dim N) are mapped to (dim 2, dim 1, dim 3, ..., dim N) of the cv::Mat,
     * respectively.
     *
     * Example:
     * @code
     * cv::Mat x(MxArray(prhs[0]).toMatND());
     * @endcode
     */
    cv::MatND toMatND(int depth=CV_USRTYPE1, bool transpose=true) const;
    /** Convert double sparse MxArray to float cv::SparseMat.
     * @return cv::SparseMat object.
     */
    cv::SparseMat toSparseMat() const;
    /** Convert MxArray to cv::Moments.
     * @param index index of the struct array.
     * @return cv::Moments.
     */
    cv::Moments toMoments(mwIndex index=0) const;
    /** Convert MxArray to cv::KeyPoint.
     * @param index index of the struct array.
     * @return cv::KeyPoint.
     */
    cv::KeyPoint toKeyPoint(mwIndex index=0) const;
    /** Convert MxArray to cv::DMatch.
     * @param index index of the struct array.
     * @return cv::DMatch.
     */
    cv::DMatch toDMatch(mwIndex index=0) const;
    /** Convert MxArray to cv::Range.
     * @return cv::Range.
     */
    cv::Range toRange() const;
    /** Convert MxArray to cv::TermCriteria.
     * @param index index of the struct array.
     * @return cv::TermCriteria.
     */
    cv::TermCriteria toTermCriteria(mwIndex index=0) const;
    /** Convert MxArray to Point_<T>.
     * @return cv::Point_<T> value.
     */
    template <typename T> cv::Point_<T> toPoint_() const;
    /** Convert MxArray to Point3_<T>.
     * @return cv::Poin3_<T> value.
     */
    template <typename T> cv::Point3_<T> toPoint3_() const;
    /** Convert MxArray to Size_<T>.
     * @return cv::Size_<T> value.
     */
    template <typename T> cv::Size_<T> toSize_() const;
    /** Convert MxArray to Rect_<T>.
     * @return cv::Rect_<T> value.
     */
    template <typename T> cv::Rect_<T> toRect_() const;
    /** Convert MxArray to Scalar_<T>.
     * @return cv::Scalar_<T> value.
     */
    template <typename T> cv::Scalar_<T> toScalar_() const;
    /** Convert MxArray to std::vector<T> for a primitive type.
     * @return std::vector<T> value.
     *
     * The method is intended for conversion to a raw numeric vector such
     * as std::vector<int> or std::vector<double>. Example:
     *
     * @code
     * MxArray numArray(prhs[0]);
     * vector<double> vd = numArray.toVector<double>();
     * @endcode
     */
    template <typename T> std::vector<T> toVector() const;
    /** Convert MxArray to std::vector<T> by a specified conversion method.
     * @param f member function of MxArray (e.g., &MxArray::toMat,
     *          &MxArray::toInt).
     * @return std::vector<T> value.
     *
     * The method constructs std::vector<T> by applying conversion method f to
     * each cell array element. This is similar to std::transform function. An
     * example usage is shown below:
     *
     * @code
     * MxArray cellArray(prhs[0]);
     * const_mem_fun_ref_t<Point3i,MxArray> converter(&MxArray::toPoint3_<int>);
     * vector<Point3i> v = cellArray.toVector(converter);
     * @endcode
     */
    template <typename T>
    std::vector<T> toVector(std::const_mem_fun_ref_t<T, MxArray> f) const;
    /** Alias to toPoint_<int>.
     */
    inline cv::Point toPoint() const { return toPoint_<int>(); }
    /** Alias to toPoint_<float>.
     */
    inline cv::Point2f toPoint2f() const { return toPoint_<float>(); }
    /** Alias to toPoint3_<float>.
     */
    inline cv::Point3f toPoint3f() const { return toPoint3_<float>(); }
    /** Alias to toSize_<int>.
     */
    inline cv::Size toSize() const { return toSize_<int>(); }
    /** Alias to toRect_<int>.
     */
    inline cv::Rect toRect() const { return toRect_<int>(); }
    /** Alias to toScalar_<double>
     */
    inline cv::Scalar toScalar() const { return toScalar_<double>(); }   

    /** Class ID of mxArray.
     */
    inline mxClassID classID() const { return mxGetClassID(p_); }
    /** Class name of mxArray.
     */
    inline const std::string className() const
    {
        return std::string(mxGetClassName(p_));
    }
    /** Number of elements in an array.
     */
    inline mwSize numel() const { return mxGetNumberOfElements(p_); }
    /** Number of dimensions.
     */
    inline mwSize ndims() const { return mxGetNumberOfDimensions(p_); }
    /** Array of each dimension.
     */
    inline const mwSize* dims() const { return mxGetDimensions(p_); };
    /** Number of rows in an array.
     */
    inline mwSize rows() const { return mxGetM(p_); }
    /** Number of columns in an array.
     */
    inline mwSize cols() const { return mxGetN(p_); }
    /** Number of fields in a struct array.
     */
    inline int nfields() const { return mxGetNumberOfFields(p_); }
    /** Get field name of a struct array.
     * @param index index of the struct array.
     * @return std::string.
     */
    std::string fieldname(int index=0) const;
    /** Get field names of a struct array.
     * @return std::string.
     */
    std::vector<std::string> fieldnames() const;
    /** Number of elements in IR, PR, and PI arrays.
     */
    inline mwSize nzmax() const { return mxGetNzmax(p_); }
    /** Offset from first element to desired element.
     * @param i index of the first dimension of the array.
     * @param j index of the second dimension of the array.
     * @return linear offset of the specified subscript index.
     */
    mwIndex subs(mwIndex i, mwIndex j=0) const;
    /** Offset from first element to desired element.
     * @param si subscript index of the array.
     * @return linear offset of the specified subscript index.
     */
    mwIndex subs(const std::vector<mwIndex>& si) const;
    /** Determine whether input is cell array.
     */
    inline bool isCell() const { return mxIsCell(p_); }
    /** Determine whether input is string array.
     */
    inline bool isChar() const { return mxIsChar(p_); }
    /** Determine whether array is member of specified class.
     */
    inline bool isClass(std::string s) const
    {
        return mxIsClass(p_, s.c_str());
    }
    /** Determine whether data is complex.
     */
    inline bool isComplex() const { return mxIsComplex(p_); }
    /** Determine whether mxArray represents data as double-precision,
     * floating-point numbers.
     */
    inline bool isDouble() const { return mxIsDouble(p_); }
    /** Determine whether array is empty.
     */
    inline bool isEmpty() const { return mxIsEmpty(p_); }
    /** Determine whether input is finite.
     */
    static inline bool isFinite(double d) { return mxIsFinite(d); }
    /** Determine whether array was copied from MATLAB global workspace.
     */
    inline bool isFromGlobalWS() const { return mxIsFromGlobalWS(p_); };
    /** Determine whether input is infinite.
     */
    static inline bool isInf(double d) { return mxIsInf(d); }
    /** Determine whether array represents data as signed 8-bit integers.
     */
    inline bool isInt8() const { return mxIsInt8(p_); }
    /** Determine whether array represents data as signed 16-bit integers.
     */
    inline bool isInt16() const { return mxIsInt16(p_); }
    /** Determine whether array represents data as signed 32-bit integers.
     */
    inline bool isInt32() const { return mxIsInt32(p_); }
    /** Determine whether array represents data as signed 64-bit integers.
     */
    inline bool isInt64() const { return mxIsInt64(p_); }
    /** Determine whether array is of type mxLogical.
     */
    inline bool isLogical() const { return mxIsLogical(p_); }
    /** Determine whether scalar array is of type mxLogical.
     */
    inline bool isLogicalScalar() const { return mxIsLogicalScalar(p_); }
    /** Determine whether scalar array of type mxLogical is true.
     */
    inline bool isLogicalScalarTrue() const
    {
        return mxIsLogicalScalarTrue(p_);
    }
    /** Determine whether array is numeric.
     */
    inline bool isNumeric() const { return mxIsNumeric(p_); }
    /** Determine whether array represents data as single-precision,
     * floating-point numbers.
     */
    inline bool isSingle() const { return mxIsSingle(p_); }
    /** Determine whether input is sparse array.
     */
    inline bool isSparse() const { return mxIsSparse(p_); }
    /** Determine whether input is structure array.
     */
    inline bool isStruct() const { return mxIsStruct(p_); }
    /** Determine whether array represents data as unsigned 8-bit integers.
     */
    inline bool isUint8() const { return mxIsUint8(p_); }
    /** Determine whether array represents data as unsigned 16-bit integers.
     */
    inline bool isUint16() const { return mxIsUint16(p_); }
    /** Determine whether array represents data as unsigned 32-bit integers.
     */
    inline bool isUint32() const { return mxIsUint32(p_); }
    /** Determine whether array represents data as unsigned 64-bit integers.
     */
    inline bool isUint64() const { return mxIsUint64(p_); }
    /** Determine whether a struct array has a specified field.
     */
    bool isField(const std::string& fieldName, mwIndex index=0) const
    {
        return isStruct() &&
               mxGetField(p_, index, fieldName.c_str()) != NULL;
    }
    /** Template for element accessor.
     * @param index index of the array element.
     * @return value of the element at index.
     *
     * Example:
     * @code
     * MxArray m(prhs[0]);
     * double d = m.at<double>(0);
     * @endcode
     */
    template <typename T> T at(mwIndex index) const;
    /** Template for element accessor.
     * @param i index of the first dimension.
     * @param j index of the second dimension.
     * @return value of the element at (i,j).
     */
    template <typename T> T at(mwIndex i, mwIndex j) const;
    /** Template for element accessor.
     * @param si subscript index of the element.
     * @return value of the element at subscript index.
     */
    template <typename T> T at(const std::vector<mwIndex>& si) const;
    /** Struct element accessor.
     * @param fieldName field name of the struct array.
     * @param index index of the struct array.
     * @return value of the element at the specified field.
     */
    MxArray at(const std::string& fieldName, mwIndex index=0) const;
    /** Template for element write accessor.
     * @param index offset of the array element.
     * @param value value of the field.
     */
    template <typename T> void set(mwIndex index, const T& value);
    /** Template for element write accessor.
     * @param i index of the first dimension of the array element.
     * @param j index of the first dimension of the array element.
     * @param value value of the field.
     */
    template <typename T> void set(mwIndex i, mwIndex j, const T& value);
    /** Template for element write accessor.
     * @param si subscript index of the element.
     * @param value value of the field.
     */
    template <typename T> void set(const std::vector<mwIndex>& si,
                                   const T& value);
    /** Template for struct element write accessor.
     * @param fieldName field name of the struct array.
     * @param value value of the field.
     * @param index linear index of the struct array element.
     */
    template <typename T> void set(const std::string& fieldName,
                                   const T& value,
                                   mwIndex index=0);
    /** Determine whether input is NaN (Not-a-Number).
     */
    static inline bool isNaN(double d) { return mxIsNaN(d); }
    /** Value of infinity.
     */
    static inline double Inf() { return mxGetInf(); }
    /** Value of NaN (Not-a-Number).
     */
    static inline double NaN() { return mxGetNaN(); }
    /** Value of EPS.
     */
    static inline double Eps() { return mxGetEps(); }
  private:
    /** Internal std::vector converter.
     */
    template <typename T>
    void fromVector(const std::vector<T>& v);
    /** mxArray c object.
     */
    const mxArray* p_;
};

/** std::map wrapper with one-line initialization and lookup method.
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
            mexErrMsgIdAndTxt("mexopencv:error", "Value not found");
        return (*it).second;
    }
  private:
    std::map<T, U> m_;
};

template <typename T>
void MxArray::fromVector(const std::vector<T>& v)
{
    if (MxTypes<T>::type == mxUNKNOWN_CLASS) {
        p_ = mxCreateCellMatrix(1, v.size());
        if (!p_)
            mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
        for (int i = 0; i < v.size(); ++i)
            mxSetCell(const_cast<mxArray*>(p_), i, MxArray(v[i]));
    } else {
        p_ = mxCreateNumericMatrix(1, v.size(), MxTypes<T>::type, mxREAL);
        if (!p_)
            mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
        std::copy(v.begin(), v.end(), reinterpret_cast<T*>(mxGetData(p_)));
    }
}

template <typename T>
MxArray::MxArray(const cv::Point_<T>& p) :
    p_(mxCreateNumericMatrix(1, 2, mxDOUBLE_CLASS,mxREAL))
{
    if (!p_)
        mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
    double *x = mxGetPr(p_);
    x[0] = p.x;
    x[1] = p.y;
}

template <typename T>
MxArray::MxArray(const cv::Point3_<T>& p) :
    p_(mxCreateNumericMatrix(1, 3, mxDOUBLE_CLASS,mxREAL))
{
    if (!p_)
        mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
    double *x = mxGetPr(p_);
    x[0] = p.x;
    x[1] = p.y;
    x[2] = p.z;
}

template <typename T>
MxArray::MxArray(const cv::Size_<T>& s) :
    p_(mxCreateNumericMatrix(1, 2, mxDOUBLE_CLASS, mxREAL))
{
    if (!p_)
        mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
    double *x = mxGetPr(p_);
    x[0] = s.width;
    x[1] = s.height;
}

template <typename T>
MxArray::MxArray(const cv::Rect_<T>& r) :
    p_(mxCreateNumericMatrix(1, 4, mxDOUBLE_CLASS,mxREAL))
{
    if (!p_)
        mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
    double *x = mxGetPr(p_);
    x[0] = r.x;
    x[1] = r.y;
    x[2] = r.width;
    x[3] = r.height;
}

template <typename T>
MxArray::MxArray(const cv::Scalar_<T>& s) :
    p_(mxCreateNumericMatrix(1, 4, mxDOUBLE_CLASS,mxREAL))
{
    if (!p_)
        mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
    double *x = mxGetPr(p_);
    x[0] = s[0];
    x[1] = s[1];
    x[2] = s[2];
    x[3] = s[3];
}

template <typename T>
cv::Point_<T> MxArray::toPoint_() const
{
    if (!isNumeric() || numel()!=2)
        mexErrMsgIdAndTxt("mexopencv:error", "MxArray is not a Point");
    return cv::Point_<T>(at<T>(0), at<T>(1));
}

template <typename T>
cv::Point3_<T> MxArray::toPoint3_() const
{
    if (!isNumeric() || numel()!=3)
        mexErrMsgIdAndTxt("mexopencv:error", "MxArray is not a Point");
    return cv::Point3_<T>(at<T>(0), at<T>(1), at<T>(2));
}

template <typename T>
cv::Size_<T> MxArray::toSize_() const
{
    if (!isNumeric() || numel()!=2)
        mexErrMsgIdAndTxt("mexopencv:error",
                          "MxArray is incompatible to cv::Size");
    return cv::Size_<T>(at<T>(0), at<T>(1));
}

template <typename T>
cv::Rect_<T> MxArray::toRect_() const
{
    if (!isNumeric() || numel()!=4)
        mexErrMsgIdAndTxt("mexopencv:error",
                          "MxArray is incompatible to cv::Rect");
    return cv::Rect_<T>(at<T>(0), at<T>(1), at<T>(2), at<T>(3));
}

template <typename T>
cv::Scalar_<T> MxArray::toScalar_() const
{
    int n = numel();
    if (!isNumeric() || n < 1 || 4 < n)
        mexErrMsgIdAndTxt("mexopencv:error",
                          "MxArray is incompatible to cv::Scalar");
    switch (n)
    {
        case 1: return cv::Scalar_<T>(at<T>(0));
        case 2: return cv::Scalar_<T>(at<T>(0), at<T>(1));
        case 3: return cv::Scalar_<T>(at<T>(0), at<T>(1), at<T>(2));
        case 4: return cv::Scalar_<T>(at<T>(0), at<T>(1), at<T>(2), at<T>(3));
    }
    return cv::Scalar_<T>();
}

template <typename T>
std::vector<T> MxArray::toVector() const
{
    int n = numel();
    std::vector<T> vt(n);
    if (isNumeric())
        for (int i = 0; i < n; ++i)
            vt[i] = at<T>(i);
    else if (isCell())
        for (int i = 0; i < n; ++i)
            vt[i] = MxArray(mxGetCell(p_, i)).at<T>(0);
    else
        mexErrMsgIdAndTxt("mexopencv:error", "Cannot convert to std::vector");
    return vt;
}

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

template <typename T>
T MxArray::at(mwIndex index) const
{
    if (!p_ || numel() <= index)
        mexErrMsgIdAndTxt("mexopencv:error", "Accessing invalid range");
    switch (classID())
    {
        case mxCHAR_CLASS:
            return static_cast<T>(*(mxGetChars(p_)+index));
        case mxDOUBLE_CLASS:
            return static_cast<T>(*(mxGetPr(p_)+index));
        case mxINT8_CLASS:
            return static_cast<T>(
                *(reinterpret_cast<int8_t*>(mxGetData(p_))+index));
        case mxUINT8_CLASS:
            return static_cast<T>(
                *(reinterpret_cast<uint8_t*>(mxGetData(p_))+index));
        case mxINT16_CLASS:
            return static_cast<T>(
                *(reinterpret_cast<int16_t*>(mxGetData(p_))+index));
        case mxUINT16_CLASS:
            return static_cast<T>(
                *(reinterpret_cast<uint16_t*>(mxGetData(p_))+index));
        case mxINT32_CLASS:
            return static_cast<T>(
                *(reinterpret_cast<int32_t*>(mxGetData(p_))+index));
        case mxUINT32_CLASS:
            return static_cast<T>(
                *(reinterpret_cast<uint32_t*>(mxGetData(p_))+index));
        case mxINT64_CLASS:
            return static_cast<T>(
                *(reinterpret_cast<int64_t*>(mxGetData(p_))+index));
        case mxUINT64_CLASS:
            return static_cast<T>(
                *(reinterpret_cast<uint64_t*>(mxGetData(p_))+index));
        case mxSINGLE_CLASS:
            return static_cast<T>(
                *(reinterpret_cast<float*>(mxGetData(p_))+index));
        case mxLOGICAL_CLASS:
            return static_cast<T>(*(mxGetLogicals(p_)+index));
        case mxCELL_CLASS:
        case mxSTRUCT_CLASS:
        case mxFUNCTION_CLASS:
        default:
            mexErrMsgIdAndTxt("mexopencv:error", "MxArray is not primitive");
            return static_cast<T>(0);
    }
}

template <typename T>
T MxArray::at(mwIndex i, mwIndex j) const
{
    return at<T>(subs(i,j));
}

template <typename T>
T MxArray::at(const std::vector<mwIndex>& si) const
{
    return at<T>(subs(si));
}

template <typename T>
void MxArray::set(mwIndex index, const T& value)
{
    if (numel() <= index)
        mexErrMsgIdAndTxt("mexopencv:error", "Accessing invalid range");
    switch (classID())
    {
        case mxCHAR_CLASS:
            *(mxGetChars(p_)+index) = static_cast<mxChar>(value); break;
        case mxDOUBLE_CLASS:
            *(mxGetPr(p_)+index) = static_cast<double>(value); break;
        case mxINT8_CLASS:
            *(reinterpret_cast<int8_t*>(mxGetData(p_))+index) =
                static_cast<int8_t>(value); break;
        case mxUINT8_CLASS:
            *(reinterpret_cast<uint8_t*>(mxGetData(p_))+index) =
                static_cast<uint8_t>(value); break;
        case mxINT16_CLASS:
            *(reinterpret_cast<int16_t*>(mxGetData(p_))+index) =
                static_cast<int16_t>(value); break;
        case mxUINT16_CLASS:
            *(reinterpret_cast<uint16_t*>(mxGetData(p_))+index) =
                static_cast<uint16_t>(value); break;
        case mxINT32_CLASS:
            *(reinterpret_cast<int32_t*>(mxGetData(p_))+index) =
                static_cast<int32_t>(value); break;
        case mxUINT32_CLASS:
            *(reinterpret_cast<uint32_t*>(mxGetData(p_))+index) =
                static_cast<uint32_t>(value); break;
        case mxINT64_CLASS:
            *(reinterpret_cast<int64_t*>(mxGetData(p_))+index) =
                static_cast<int64_t>(value); break;
        case mxUINT64_CLASS:
            *(reinterpret_cast<uint64_t*>(mxGetData(p_))+index) =
                static_cast<uint64_t>(value); break;
        case mxSINGLE_CLASS:
            *(reinterpret_cast<float*>(mxGetData(p_))+index) =
                static_cast<float>(value); break;
        case mxLOGICAL_CLASS:
            *(mxGetLogicals(p_)+index) = static_cast<mxLogical>(value); break;
        case mxCELL_CLASS:
            mxSetCell(const_cast<mxArray*>(p_), index, MxArray(value)); break;
        case mxSTRUCT_CLASS:
        case mxFUNCTION_CLASS:
        default:
            mexErrMsgIdAndTxt("mexopencv:error", "MxArray type is not valid");
    }
}

template <typename T>
void MxArray::set(mwIndex i, mwIndex j, const T& value)
{
    set<T>(subs(i,j),value);
}

template <typename T>
void MxArray::set(const std::vector<mwIndex>& si, const T& value)
{
    set<T>(subs(si),value);
}

template <typename T>
void MxArray::set(const std::string& fieldName, const T& value, mwIndex index)
{
    if (!isStruct())
        mexErrMsgIdAndTxt("mexopencv:error", "MxArray is not struct");
    if (!isField(fieldName))
    {
        if (mxAddField(const_cast<mxArray*>(p_), fieldName.c_str())<0)
            mexErrMsgIdAndTxt("mexopencv:error",
                              "Failed to create a field '%s'",
                              fieldName.c_str());
    }
    mxSetField(const_cast<mxArray*>(p_), index, fieldName.c_str(),
               static_cast<mxArray*>(MxArray(value)));
}

/** Specialization for vector<char> construction.
 */
template<>
void MxArray::fromVector(const std::vector<char>& v);

/** Specialization for vector<bool> construction.
 */
template<>
void MxArray::fromVector(const std::vector<bool>& v);

/** MxArray constructor from vector<DMatch>. Make a cell array.
 * @param v vector of type DMatch.
 */
template <> MxArray::MxArray(const std::vector<cv::DMatch>& v);

/** MxArray constructor from vector<KeyPoint>. Make a cell array.
 * @param v vector of KeyPoint.
 */
template <> MxArray::MxArray(const std::vector<cv::KeyPoint>& v);

/** Cell element accessor.
 * @param index index of the cell array.
 * @return MxArray of the element at index.
 *
 * Example:
 * @code
 * MxArray cellArray(prhs[0]);
 * MxArray m = cellArray.at<MxArray>(0);
 * @endcode
 */
template <> MxArray MxArray::at(mwIndex index) const;

/** Template for element write accessor.
 * @param index offset of the array element.
 * @param value value of the field.
 */
template <> void MxArray::set(mwIndex index, const MxArray& value);

/** Convert MxArray to std::vector<MxArray>.
 * @return std::vector<MxArray> value.
 *
 * Example:
 * @code
 * MxArray cellArray(prhs[0]);
 * vector<MxArray> v = cellArray.toVector<MxArray>();
 * @endcode
 */
template <> std::vector<MxArray> MxArray::toVector() const;

/** Convert MxArray to std::vector<std::string>.
 * @return std::vector<std::string> value.
 *
 * Example:
 * @code
 * MxArray cellArray(prhs[0]);
 * vector<string> v = cellArray.toVector<string>();
 * @endcode
 */
template <> std::vector<std::string> MxArray::toVector() const;

/** Convert MxArray to std::vector<cv::Mat>.
 * @return std::vector<cv::Mat> value.
 *
 * Example:
 * @code
 * MxArray cellArray(prhs[0]);
 * vector<Mat> v = cellArray.toVector<Mat>();
 * @endcode
 */
template <> std::vector<cv::Mat> MxArray::toVector() const;

/** Convert MxArray to std::vector<Point>.
 * @return std::vector<Point> value.
 *
 * Example:
 * @code
 * MxArray cellArray(prhs[0]);
 * vector<Point> v = cellArray.toVector<Point>();
 * @endcode
 */
template <> std::vector<cv::Point> MxArray::toVector() const;

/** Convert MxArray to std::vector<Point2f>.
 * @return std::vector<Point2f> value.
 *
 * Example:
 * @code
 * MxArray cellArray(prhs[0]);
 * vector<Point2f> v = cellArray.toVector<Point2f>();
 * @endcode
 */
template <> std::vector<cv::Point2f> MxArray::toVector() const;

/** Convert MxArray to std::vector<Point3f>.
 * @return std::vector<Point3f> value.
 *
 * Example:
 * @code
 * MxArray cellArray(prhs[0]);
 * vector<Point3f> v = cellArray.toVector<Point3f>();
 * @endcode
 */
template <> std::vector<cv::Point3f> MxArray::toVector() const;

/** Convert MxArray to std::vector<cv::KeyPoint>.
 * @return std::vector<cv::KeyPoint> value.
 *
 * Example:
 * @code
 * MxArray structArray(prhs[0]);
 * vector<KeyPoint> v = structArray.toVector<KeyPoint>();
 * @endcode
 */
template <> std::vector<cv::KeyPoint> MxArray::toVector() const;

/** Convert MxArray to std::vector<cv::DMatch>.
 * @return std::vector<cv::DMatch> value.
 *
 * Example:
 * @code
 * MxArray structArray(prhs[0]);
 * vector<DMatch> v = structArray.toVector<DMatch>();
 * @endcode
 */
template <> std::vector<cv::DMatch> MxArray::toVector() const;

#endif // __MXARRAY_HPP__
