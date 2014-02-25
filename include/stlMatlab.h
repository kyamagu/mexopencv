#include "mex.h"
#include <vector>
#include <array>

#ifndef __STLMATLAB_H__
#define __STLMATLAB_H__



typedef struct mxCell_tag {} mxCell;
typedef struct mxNumeric_tag {} mxNumeric;
typedef struct mxString_tag {} mxString;
typedef struct mxBool_tag {} mxBool;
typedef struct mxArray_tag {} mxArray;
typedef struct mxCVArray_tag {} mxCVArray;

/** Type traits for mxArray.
*/
template <typename T>
struct MxTypes {
    typedef mxCell array_type;
    static const mxClassID type = mxUNKNOWN_CLASS;
};

/** int8_t traits.
*/
template<> struct MxTypes<int8_t>
{
    typedef mxNumeric array_type;
    static const mxClassID type = mxINT8_CLASS;
};

/** uint8_t traits.
*/
template<> struct MxTypes<uint8_t>
{
    typedef mxNumeric array_type;
    static const mxClassID type = mxUINT8_CLASS;
};

/** int16_t traits.
*/
template<> struct MxTypes<int16_t>
{
    typedef mxNumeric array_type;
    static const mxClassID type = mxINT16_CLASS;
};

/** uint16_t traits.
*/
template<> struct MxTypes<uint16_t>
{
    typedef mxNumeric array_type;
    static const mxClassID type = mxUINT16_CLASS;
};

/** int32_t traits.
*/
template<> struct MxTypes<int32_t>
{
    typedef mxNumeric array_type;
    static const mxClassID type = mxINT32_CLASS;
};

/** uint32_t traits.
*/
template<> struct MxTypes<uint32_t>
{
    typedef mxNumeric array_type;
    static const mxClassID type = mxUINT32_CLASS;
};

/** int64_t traits.
*/
template<> struct MxTypes<int64_t>
{
    typedef mxNumeric array_type;
    static const mxClassID type = mxINT64_CLASS;
};

/** uint64_t traits.
*/
template<> struct MxTypes<uint64_t>
{
    typedef mxNumeric array_type;
    static const mxClassID type = mxUINT64_CLASS;
};

/** float traits.
*/
template<> struct MxTypes<float>
{
    typedef mxNumeric array_type;
    static const mxClassID type = mxSINGLE_CLASS;
};

/** double traits.
*/
template<> struct MxTypes<double>
{
    typedef mxNumeric array_type;
    static const mxClassID type = mxDOUBLE_CLASS;
};

/** char traits.
*/
template<> struct MxTypes<char>
{
    typedef mxString array_type;
    static const mxClassID type = mxCHAR_CLASS;
};

/** bool traits.
*/
template<> struct MxTypes<bool>
{
    typedef mxBool array_type;
    static const mxClassID type = mxLOGICAL_CLASS;
};

/** array traits
 */
template<typename T,std::wint_t N> struct MxTypes < std::array<T,N> >
{
    static const mxClassID type = mxUNKNOWN_CLASS;
    typedef mxArray array_type;
	typedef T elemtype;
	static const int elemN = N;
};




/** Internal std::vector converter.
*/
template <typename type,typename T>
struct STLtransfer{
static mxArray* fromVector(const std::vector<T>& v);
};

template <typename T>
struct STLtransfer<mxArray,T>
{
	static mxArray* fromVector (const std::vector<T>& v)
	{
        mxArray* p_ = mxCreateNumericMatrix(v.size(),v[0].size() , MxTypes<MxTypes<T>::elemtype>::type , mxREAL );//pixel are save in rows
        //std::copy(&v[0][0]  ,   &v[v.size()-1][v[0].size()]  ,  reinterpret_cast<MxTypes<T>::elemtype*>(mxGetData(p_)));
		memcpy(reinterpret_cast<MxTypes<T>::elemtype*>(mxGetData(p_))  ,  reinterpret_cast<void*>(const_cast<MxTypes<T>::elemtype*>(&v[0][0]))   ,  sizeof(MxTypes<T>::elemtype) * v.size() * v[0].size()  );
		return p_;
	}
};



template <typename T>
struct STLtransfer<mxCell,T>
{
	static mxArray* fromVector (const std::vector<T>& v)
	{
         mxArray* p_ = mxCreateCellMatrix(1, v.size());
        if (!p_)
            mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
        for (int i = 0; i < v.size(); ++i)
            mxSetCell(const_cast<mxArray*>(p_), i, MxArray(v[i]));
		return p_;
	}
};

template <typename T>
struct STLtransfer<mxNumeric,T>
{
	static mxArray* fromVector (const std::vector<T>& v)
	{
        mxArray* p_ = mxCreateNumericMatrix(1, v.size(), MxTypes<T>::type, mxREAL);
        if (!p_)
            mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
        std::copy(v.begin(), v.end(), reinterpret_cast<T*>(mxGetData(p_)));
		return p_;
	}
};

template <typename T>
struct STLtransfer<mxString,T>
{
	static mxArray* fromVector (const std::vector<T>& v)
	{
    mwSize size[] = {1, v.size()};
    mxArray* p_ = mxCreateCharArray(2, size);
    if (!p_)
        mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
    std::copy(v.begin(), v.end(), mxGetChars(p_));
	return p_;
	}
};

template <typename T>
struct STLtransfer<mxBool,T>
{
	static mxArray* fromVector (const std::vector<bool>& v)
	{
    mxArray* p_ = mxCreateLogicalMatrix(1, v.size());
    if (!p_)
        mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
    std::copy(v.begin(), v.end(), mxGetLogicals(p_));
	return p_;
	}
};


#endif
