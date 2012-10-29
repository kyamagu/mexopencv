/**
 * @file MxArray.cpp
 * @brief Implemenation of MxArray
 * @author Kota Yamaguchi
 * @date 2012
 */
#include "MxArray.hpp"

namespace { // Local namespace

/// Field names for cv::Moments
const char *cv_moments_fields[10] = {"m00", "m10", "m01", "m20", "m11", "m02",
                                     "m30", "m21", "m12", "m03"};
/// Field names for cv::RotatedRect
const char *cv_rotated_rect_fields[3] = {"center", "size", "angle"};
/// Field names for cv::TermCriteria
const char *cv_term_criteria_fields[3] = {"type", "maxCount", "epsilon"};
/// Field names for cv::Keypoint
const char *cv_keypoint_fields[6] = {"pt", "size", "angle", "response",
                                     "octave", "class_id"};
/// Field names for cv::DMatch
const char *cv_dmatch_fields[4] = {"queryIdx", "trainIdx", "imgIdx",
                                   "distance"};

/**
 * Translates data type definition used in OpenCV to that of Matlab
 * @param classid data type of matlab's mxArray. e.g., mxDOUBLE_CLASS
 * @return opencv's data type. e.g., CV_8U
 */
const ConstMap<mxClassID, int> DepthOf = ConstMap<mxClassID, int>
    (mxDOUBLE_CLASS,   CV_64F)
    (mxSINGLE_CLASS,   CV_32F)
    (mxINT8_CLASS,     CV_8S)
    (mxUINT8_CLASS,    CV_8U)
    (mxINT16_CLASS,    CV_16S)
    (mxUINT16_CLASS,   CV_16U)
    (mxINT32_CLASS,    CV_32S)
    (mxUINT32_CLASS,   CV_32S)
    (mxLOGICAL_CLASS,  CV_8U);

/**
 * Translates data type definition used in Matlab to that of OpenCV
 * @param depth data depth of opencv's Mat class. e.g., CV_32F
 * @return data type of matlab's mxArray. e.g., mxDOUBLE_CLASS
 */
const ConstMap<int,mxClassID> ClassIDOf = ConstMap<int,mxClassID>
    (CV_64F,    mxDOUBLE_CLASS)
    (CV_32F,    mxSINGLE_CLASS)
    (CV_8S,     mxINT8_CLASS)
    (CV_8U,     mxUINT8_CLASS)
    (CV_16S,    mxINT16_CLASS)
    (CV_16U,    mxUINT16_CLASS)
    (CV_32S,    mxINT32_CLASS);

/** Comparison operator for sparse matrix elements
 */
struct CompareSparseMatNode {
    bool operator () (const cv::SparseMat::Node* rhs,
                      const cv::SparseMat::Node* lhs)
    {
        if (rhs->idx[1] < lhs->idx[1]) // column index
            return true;
        if (rhs->idx[0] < lhs->idx[0]) // row index
            return true;
        return false;
    }
};

/** InvTermCritType map for option processing
 */
const ConstMap<int, std::string> InvTermCritType = ConstMap<int, std::string>
    (cv::TermCriteria::COUNT, "Count")
    (cv::TermCriteria::EPS,   "EPS")
    (cv::TermCriteria::COUNT+cv::TermCriteria::EPS, "Count+EPS");

/** TermCritType map for option processing
 */
const ConstMap<std::string, int> TermCritType = ConstMap<std::string, int>
    ("Count",     cv::TermCriteria::COUNT)
    ("EPS",       cv::TermCriteria::EPS)
    ("Count+EPS", cv::TermCriteria::COUNT+cv::TermCriteria::EPS);

}  // Local namespace

/** MxArray constructor from mxArray*
 * @param arr mxArray pointer given by mexFunction
 */
MxArray::MxArray(const mxArray *arr) : p_(arr) {}

/** MxArray constructor from double
 * @param d double value
 */
MxArray::MxArray(const double d) : p_(mxCreateDoubleScalar(d))
{
    if (!p_)
        mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
}

/** MxArray constructor from int
 * @param i int value
 */
MxArray::MxArray(const int i)
    : p_(mxCreateDoubleScalar(static_cast<double>(i)))
{
    if (!p_)
        mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
}

/** MxArray constructor from bool
 * @param b bool value
 */
MxArray::MxArray(const bool b) : p_(mxCreateLogicalScalar(b))
{
    if (!p_)
        mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
}

/** MxArray constructor from std::string
 * @param s reference to a string value
 */
MxArray::MxArray(const std::string& s) : p_(mxCreateString(s.c_str()))
{
    if (!p_)
        mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
}

/**
 * Convert cv::Mat to MxArray
 * @param mat cv::Mat object
 * @param classid classid of mxArray. e.g., mxDOUBLE_CLASS. When
 *                mxUNKNOWN_CLASS is specified, classid will be automatically
 *                determined from the type of cv::Mat. default: mxUNKNOWN_CLASS
 * @param transpose Optional transposition to the return value so that rows and
 *                  columns of the 2D Mat are mapped to the 2nd and 1st
 *                  dimensions in MxArray, respectively. This does not apply
 *                  the N-D array conversion. default true.
 * @return MxArray object
 *
 * Convert cv::Mat object to an MxArray. When the cv::Mat object is 2D, the
 * width, height, and channels are mapped to the first, second, and third
 * dimensions of the MxArray unless transpose flag is set to false. When the
 * cv::Mat object is N-D, (dim 1, dim 2,...dim N, channels) are mapped to (dim
 * 2, dim 1, ..., dim N, dim N+1), respectively.
 *
 * Example:
 * @code
 * cv::Mat x(120, 90, CV_8UC3, Scalar(0));
 * mxArray* plhs[0] = MxArray(x);
 * @endcode
 *
 */
MxArray::MxArray(const cv::Mat& mat, mxClassID classid, bool transpose)
{
    if (mat.empty()) {
        p_ = mxCreateNumericArray(0, 0, mxDOUBLE_CLASS, mxREAL);
        if (!p_)
            mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
        return;
    }
    cv::Mat input = (mat.dims == 2 && transpose) ? mat.t() : mat;
    // Create a new mxArray
    const int nchannels = input.channels();
    const int* dims_ = input.size;
    std::vector<mwSize> d(dims_, dims_ + input.dims);
    d.push_back(nchannels);
    classid = (classid == mxUNKNOWN_CLASS)
        ? ClassIDOf[input.depth()] : classid;
    std::swap(d[0], d[1]);
    if (classid == mxLOGICAL_CLASS) {
        // OpenCV's logical true is any nonzero while matlab's true is 1
        cv::compare(input, 0, input, cv::CMP_NE);
        input.setTo(1, input);
        p_ = mxCreateLogicalArray(d.size(), &d[0]);
    }
    else {
        p_ = mxCreateNumericArray(d.size(), &d[0], classid, mxREAL);
    }
    if (!p_)
        mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
    // Copy each channel
    std::vector<cv::Mat> channels;
    split(input, channels);
    std::vector<mwSize> si(d.size(), 0); // subscript index
    int type = CV_MAKETYPE(DepthOf[classid], 1); // destination type
    for (int i = 0; i < nchannels; ++i) {
        si[si.size() - 1] = i; // last dim is a channel index
        void *ptr = reinterpret_cast<void*>(
                reinterpret_cast<size_t>(mxGetData(p_)) +
                mxGetElementSize(p_) * subs(si));
        cv::Mat m(input.dims, dims_, type, ptr);
        channels[i].convertTo(m, type); // Write to mxArray through m
    }
}

/**
 * Convert float cv::SparseMat to MxArray
 * @param mat cv::SparseMat object
 * @return MxArray object
 */
MxArray::MxArray(const cv::SparseMat& mat)
{
    if (mat.dims() != 2)
        mexErrMsgIdAndTxt("mexopencv:error", "cv::Mat is not 2D");
    if (mat.type() != CV_32FC1)
        mexErrMsgIdAndTxt("mexopencv:error", "cv::Mat is not float");
    
    // Create sparse array
    int m = mat.size(0), n = mat.size(1), nnz = mat.nzcount();
    p_ = mxCreateSparse(m, n, nnz, mxREAL);
    if (!p_)
        mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
    mwIndex *ir = mxGetIr(p_);
    mwIndex *jc = mxGetJc(p_);
    if (ir == NULL || jc == NULL)
        mexErrMsgIdAndTxt("mexopencv:error", "Unknown error");

    // Sort nodes before we put elems into mxArray
    std::vector<const cv::SparseMat::Node*> nodes;
    nodes.reserve(nnz);
    for (cv::SparseMatConstIterator it = mat.begin(); it != mat.end(); ++it)
        nodes.push_back(it.node());
    std::sort(nodes.begin(), nodes.end(), CompareSparseMatNode());

    // Copy data
    double *pr = mxGetPr(p_);
    int i = 0;
    jc[0] = 0;
    for (std::vector<const cv::SparseMat::Node*>::const_iterator
         it = nodes.begin(); it != nodes.end(); ++it)
    {
        mwIndex row = (*it)->idx[0], col = (*it)->idx[1];
        ir[i] = row;
        jc[col+1] = i+1;
        pr[i] = static_cast<double>(mat.value<float>(*it));
        ++i;
    }
}

/**
 * Convert cv::Moments to MxArray
 * @param m cv::Moments object
 * @return MxArray object
 */
MxArray::MxArray(const cv::Moments& m) :
    p_(mxCreateStructMatrix(1, 1, 10, cv_moments_fields))
{
    if (!p_)
        mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
    set("m00", m.m00);
    set("m10", m.m10);
    set("m01", m.m01);
    set("m20", m.m20);
    set("m11", m.m11);
    set("m02", m.m02);
    set("m30", m.m30);
    set("m12", m.m12);
    set("m21", m.m21);
    set("m03", m.m03);
}

/**
 * Convert cv::KeyPoint to MxArray
 * @param p cv::KeyPoint object
 * @return MxArray object
 */
MxArray::MxArray(const cv::KeyPoint& p) :
    p_(mxCreateStructMatrix(1, 1, 6, cv_keypoint_fields))
{
    if (!p_)
        mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
    set("pt",       p.pt);
    set("size",     p.size);
    set("angle",    p.angle);
    set("response", p.response);
    set("octave",   p.octave);
    set("class_id", p.class_id);
}

/** MxArray constructor from vector<KeyPoint>. Make a cell array.
 * @param v vector of KeyPoint
 */
MxArray::MxArray(const std::vector<cv::KeyPoint>& v) :
    p_(mxCreateStructMatrix(1, v.size(), 6, cv_keypoint_fields))
{
    if (!p_)
        mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
    for (size_t i = 0; i < v.size(); ++i) {
        set("pt",       v[i].pt,       i);
        set("size",     v[i].size,     i);
        set("angle",    v[i].angle,    i);
        set("response", v[i].response, i);
        set("octave",   v[i].octave,   i);
        set("class_id", v[i].class_id, i);
    }
}

/**
 * Convert cv::DMatch to MxArray
 * @param m cv::DMatch object
 * @return MxArray object
 */
MxArray::MxArray(const cv::DMatch& m) :
    p_(mxCreateStructMatrix(1, 1, 4, cv_keypoint_fields))
{
    if (!p_)
        mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
    set("queryIdx", m.queryIdx);
    set("trainIdx", m.trainIdx);
    set("imgIdx",   m.imgIdx);
    set("distance", m.distance);
}

/** MxArray constructor from vector<T>. Make a cell array.
 * @param v vector of type T
 */
MxArray::MxArray(const std::vector<cv::DMatch>& v) :
    p_(mxCreateStructMatrix(1, v.size(), 4, cv_dmatch_fields))
{
    if (!p_)
        mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
    for (size_t i = 0; i < v.size(); ++i) {
        set("queryIdx", v[i].queryIdx, i);
        set("trainIdx", v[i].trainIdx, i);
        set("imgIdx",   v[i].imgIdx,   i);
        set("distance", v[i].distance, i);
    }
}

/** Convert cv::RotatedRect to MxArray
 * @param m cv::RotatedRect object
 * @return MxArray object
 */
MxArray::MxArray(const cv::RotatedRect& m) :
    p_(mxCreateStructMatrix(1, 1, 3, cv_rotated_rect_fields))
{
    if (!p_)
        mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
    set("center", m.center);
    set("size",   m.size);
    set("angle",  m.angle);
}

/** Convert cv::TermCriteria to MxArray
 * @param t cv::TermCriteria object
 * @return MxArray object
 */
MxArray::MxArray(const cv::TermCriteria& t) :
    p_(mxCreateStructMatrix(1, 1, 3, cv_term_criteria_fields))
{
    if (!p_)
        mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
    set("type",     InvTermCritType[t.type]);
    set("maxCount", t.maxCount);
    set("epsilon",  t.epsilon);
}

/** Generic constructor for a struct array
 * @param fields field names
 * @param nfields number of field names
 * @param m size of the first dimension
 * @param n size of the second dimension
 *
 * Example:
 * @code
 * const char* fields[] = {"field1", "field2"};
 * MxArray m(fields, 2);
 * m.set("field1", 1);
 * m.set("field2", "field2 value");
 * @endcode
 */
MxArray::MxArray(const char** fields, int nfields, int m, int n) :
    p_(mxCreateStructMatrix(m, n, nfields, fields))
{
    if (!p_)
        mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
}

/** Convert MxArray to cv::Mat
 * @param depth depth of cv::Mat. e.g., CV_8U, CV_32F.  When CV_USERTYPE1 is
 *                specified, depth will be automatically determined from the
 *                the classid of the MxArray. default: CV_USERTYPE1
 * @param transpose Optional transposition to the return value so that rows and
 *                  columns of the 2D Mat are mapped to the 2nd and 1st
 *                  dimensions in MxArray, respectively. This does not apply
 *                  the N-D array conversion. default true.
 * @return cv::Mat object
 *
 * Convert a MxArray object to a cv::Mat object. When the dimensionality of the
 * MxArray is more than 2, the last dimension will be mapped to the channels of
 * the cv::Mat. Also, if the resulting cv::Mat is 2D, the 1st and 2nd
 * dimensions of the MxArray are mapped to rows and columns of the cv::Mat
 * unless transpose flag is false. That is, when MxArray is 3D, (dim 1, dim 2,
 * dim 3) are mapped to (cols, rows, channels) of the cv::Mat by default,
 * whereas if MxArray is more than 4D, (dim 1, dim 2, ..., dim N-1, dim N) are
 * mapped to (dim 2, dim 1, ..., dim N-1, channels) of the cv::Mat,
 * respectively.
 *
 * Example:
 * @code
 * cv::Mat x(MxArray(prhs[0]).toMat());
 * @endcode
 *
 */
cv::Mat MxArray::toMat(int depth, bool transpose) const
{
    // Create cv::Mat object
    std::vector<int> d(dims(), dims()+ndims());
    int ndims = (d.size()>2) ? d.size()-1 : d.size();
    int nchannels = (d.size()>2) ? *(d.end()-1) : 1;
    depth = (depth==CV_USRTYPE1) ? DepthOf[classID()] : depth;
    std::swap(d[0], d[1]);
    cv::Mat mat(ndims, &d[0], CV_MAKETYPE(depth, nchannels));
    
    // Copy each channel
    std::vector<cv::Mat> channels(nchannels);
    std::vector<mwSize> si(d.size(), 0); // subscript index
    int type = CV_MAKETYPE(DepthOf[classID()], 1); // Source type
    for (int i = 0; i<nchannels; ++i) {
        si[d.size()-1] = i;
        void *pd = reinterpret_cast<void*>(
                reinterpret_cast<size_t>(mxGetData(p_))+
                mxGetElementSize(p_)*subs(si));
        cv::Mat m(ndims, &d[0], type, pd);
        // Read from mxArray through m
        m.convertTo(channels[i], CV_MAKETYPE(depth, 1));
    }
    cv::merge(channels, mat);
    return (mat.dims==2 && transpose) ? cv::Mat(mat.t()) : mat;
}

/**
 * Convert MxArray to single-channel cv::Mat
 * @param depth depth of cv::Mat. e.g., CV_8U, CV_32F.  When CV_USERTYPE1 is
 *                specified, depth will be automatically determined from the
 *                the classid of the MxArray. default: CV_USERTYPE1
 * @param transpose Optional transposition to the return value so that rows and
 *                  columns of the 2D Mat are mapped to the 2nd and 1st
 *                  dimensions in MxArray, respectively. This does not apply
 *                  the N-D array conversion. default true.
 * @return const cv::Mat object
 *
 * Convert a MxArray object to a single-channel cv::Mat object. If the MxArray
 * is 2D, the 1st and 2nd dimensions of the MxArray are mapped to rows and
 * columns of the cv::Mat unless transpose flag is false. If the MxArray is
 * more than 3D, the 1st and 2nd dimensions of the MxArray are mapped to 2nd
 * and 1st dimensions of the cv::Mat. That is, when MxArray is 2D, (dim 1, dim
 * 2) are mapped to (cols, rows) of the cv::Mat by default, whereas if MxArray
 * is more than 3D, (dim 1, dim 2, dim 3, ..., dim N) are mapped to (dim 2, dim
 * 1, dim 3, ..., dim N) of the cv::Mat, respectively.
 *
 * Example:
 * @code
 * cv::Mat x(MxArray(prhs[0]).toMatND());
 * @endcode
 */
cv::MatND MxArray::toMatND(int depth, bool transpose) const
{
    // Create cv::Mat object
    std::vector<int> d(dims(), dims()+ndims());
    std::swap(d[0], d[1]);
    cv::MatND m(ndims(), &d[0], CV_MAKETYPE(DepthOf[classID()], 1),
                mxGetData(p_));
    // Copy
    cv::MatND mat;
    depth = (depth==CV_USRTYPE1) ? CV_MAKETYPE(DepthOf[classID()], 1) : depth;
    m.convertTo(mat, CV_MAKETYPE(depth, 1));
    return (mat.dims==2 && transpose) ? cv::Mat(mat.t()) : mat;
}

/** Convert MxArray to int
 * @return int value
 */
int MxArray::toInt() const {
    if (numel() != 1)
        mexErrMsgIdAndTxt("mexopencv:error", "MxArray is not a scalar");
    return at<int>(0);
}

/** Convert MxArray to double
 * @return double value
 */
double MxArray::toDouble() const {
    if (numel() != 1)
        mexErrMsgIdAndTxt("mexopencv:error", "MxArray is not a scalar");
    return at<double>(0);
}

/** Convert MxArray to bool
 * @return bool value
 */
bool MxArray::toBool() const {
    if (numel() != 1)
        mexErrMsgIdAndTxt("mexopencv:error", "MxArray is not a scalar");
    return at<bool>(0);
}

/** Convert MxArray to std::string
 * @return std::string value
 */
std::string MxArray::toString() const
{
    if (!isChar())
        mexErrMsgIdAndTxt("mexopencv:error", "MxArray not of type char");
    char *pc = mxArrayToString(p_);
    std::string s(pc);
    mxFree(pc);
    return s;
}

/**
 * Convert MxArray to float cv::SparseMat
 * @return cv::SparseMat object
 */
cv::SparseMat MxArray::toSparseMat() const
{
    // Check if it's sparse
    if (!isSparse() || !isDouble())
        mexErrMsgIdAndTxt("mexopencv:error", "MxArray is not sparse");        
    mwIndex *ir = mxGetIr(p_);
    mwIndex *jc = mxGetJc(p_);
    if (ir == NULL || jc == NULL)
        mexErrMsgIdAndTxt("mexopencv:error", "Unknown error");
    
    // Create cv::SparseMat
    int m = mxGetM(p_), n = mxGetN(p_);
    int dims[] = {m, n};
    cv::SparseMat mat(2, dims, CV_32F);
    
    // Copy data
    double *pr = mxGetPr(p_);
    for (int j=0; j<n; ++j) {
        mwIndex start = jc[j], end = jc[j + 1] - 1;
        // (row,col) <= val
        for (mwIndex i = start; i <= end; ++i)
            mat.ref<float>(ir[i], j) = static_cast<float>(pr[i]);
    }
    return mat;
}

/** Convert MxArray to cv::Moments
 * @param index index of the struct array
 * @return cv::Moments
 */
cv::Moments MxArray::toMoments(mwIndex index) const
{
    return cv::Moments(
        (isField("m00")) ? at("m00", index).toDouble() : 0,
        (isField("m10")) ? at("m10", index).toDouble() : 0,
        (isField("m01")) ? at("m01", index).toDouble() : 0,
        (isField("m20")) ? at("m20", index).toDouble() : 0,
        (isField("m11")) ? at("m11", index).toDouble() : 0,
        (isField("m02")) ? at("m02", index).toDouble() : 0,
        (isField("m30")) ? at("m30", index).toDouble() : 0,
        (isField("m12")) ? at("m12", index).toDouble() : 0,
        (isField("m21")) ? at("m21", index).toDouble() : 0,
        (isField("m03")) ? at("m03", index).toDouble() : 0
    );
}

/** Convert MxArray to cv::KeyPoint
 * @param index index of the struct array
 * @return cv::KeyPoint
 */
cv::KeyPoint MxArray::toKeyPoint(mwIndex index) const
{
    return cv::KeyPoint(
        at("pt",   index).toPoint2f(),
        at("size", index).toDouble(),
        (isField("angle"))    ? at("angle",    index).toDouble() : -1,
        (isField("response")) ? at("response", index).toDouble() :  0,
        (isField("octave"))   ? at("octave",   index).toInt()    :  0,
        (isField("class_id")) ? at("class_id", index).toInt()    : -1
    );
}

/** Convert MxArray to cv::DMatch
 * @param index index of the struct array
 * @return cv::DMatch
 */
cv::DMatch MxArray::toDMatch(mwIndex index) const
{
    return cv::DMatch(
        (isField("queryIdx")) ? at("queryIdx", index).toInt()    : 0,
        (isField("trainIdx")) ? at("trainIdx", index).toInt()    : 0,
        (isField("imgIdx"))   ? at("imgIdx",   index).toInt()    : 0,
        (isField("distance")) ? at("distance", index).toDouble() : 0
    );
}

/** Convert MxArray to cv::Range
 * @return cv::Range
 */
cv::Range MxArray::toRange() const
{
    cv::Range r;
    if (isNumeric() && numel()==2)
        r = cv::Range(at<int>(0), at<int>(1));
    else if (isChar() && toString()==":")
        r = cv::Range::all();
    else
        mexErrMsgIdAndTxt("mexopencv:error", "Invalid range value");
    return r;
}

/** Convert MxArray to cv::TermCriteria
 * @param index index of the struct array
 * @return cv::TermCriteria
 */
cv::TermCriteria MxArray::toTermCriteria(mwIndex index) const
{
    MxArray _type(at("type", index));
    return cv::TermCriteria(
        (_type.isChar()) ? TermCritType[_type.toString()] : _type.toInt(),
        at("maxCount", index).toInt(),
        at("epsilon", index).toDouble()
    );
}

/** Get field name of a struct array
 * @param index index of the struct array
 * @return std::string
 */
std::string MxArray::fieldname(int index) const
{
    const char *f = mxGetFieldNameByNumber(p_, index);
    if (!f)
        mexErrMsgIdAndTxt("mexopencv:error",
                          "Failed to get field name at %d\n", index);
    return std::string(f);
}

/** Get field names of a struct array
 * @return std::string
 */
std::vector<std::string> MxArray::fieldnames() const
{
    if (!isStruct())
        mexErrMsgIdAndTxt("mexopencv:error", "MxArray is not a struct array");
    int n = nfields();
    std::vector<std::string> v;
    v.reserve(n);
    for (int i = 0; i < n; ++i)
        v.push_back(fieldname(i));
    return v;
}

/** Offset from first element to desired element
 * @param i index of the first dimension of the array
 * @param j index of the second dimension of the array
 * @return linear offset of the specified subscript index
 */
mwIndex MxArray::subs(mwIndex i, mwIndex j) const
{
    if (i < 0 || i >= rows() || j < 0 || j >= cols())
        mexErrMsgIdAndTxt("mexopencv:error", "Subscript out of range");
    mwIndex s[] = {i, j};
    return mxCalcSingleSubscript(p_, 2, s);
}

/** Offset from first element to desired element
 * @param si subscript index of the array
 * @return linear offset of the specified subscript index
 */
mwIndex MxArray::subs(const std::vector<mwIndex>& si) const
{
    return mxCalcSingleSubscript(p_, si.size(), &si[0]);
}

/** Struct element accessor
 * @param fieldName field name of the struct array
 * @param index index of the struct array
 * @return value of the element at the specified field
 */
MxArray MxArray::at(const std::string& fieldName, mwIndex index) const
{
    if (!isStruct())
        mexErrMsgIdAndTxt("mexopencv:error", "MxArray is not struct");
    if (index < 0 || numel() <= index)
        mexErrMsgIdAndTxt("mexopencv:error", "Out of range in struct array");
    mxArray* pm = mxGetField(p_, index, fieldName.c_str());
    if (!pm)
        mexErrMsgIdAndTxt("mexopencv:error", "Field '%s' doesn't exist",
            fieldName.c_str());
    return MxArray(pm);
}

// Template specializations

/** Cell element accessor
 * @param index index of the cell array
 * @return MxArray of the element at index
 *
 * Example:
 * @code
 * MxArray cellArray(prhs[0]);
 * MxArray m = cellArray.at<MxArray>(0);
 * @endcode
 */
template <>
MxArray MxArray::at(mwIndex index) const
{
    if (!isCell())
        mexErrMsgIdAndTxt("mexopencv:error", "MxArray is not cell");
    return MxArray(mxGetCell(p_, index));
}

/** Template for element write accessor
 * @param index offset of the array element
 * @param value value of the field
 */
template <>
void MxArray::set(mwIndex index, const MxArray& value)
{
    if (index < 0 || numel() <= index)
        mexErrMsgIdAndTxt("mexopencv:error", "Accessing invalid range");
    if (!isCell())
        mexErrMsgIdAndTxt("mexopencv:error", "Not cell array");
    mxSetCell(const_cast<mxArray*>(p_), index, value);
}

/** Convert MxArray to std::vector<MxArray>
 * @return std::vector<MxArray> value
 *
 * Example:
 * @code
 * MxArray cellArray(prhs[0]);
 * vector<MxArray> v = cellArray.toVector<MxArray>();
 * @endcode
 */
template <>
std::vector<MxArray> MxArray::toVector() const
{
    if (isCell()) {
        int n = numel();
        std::vector<MxArray> v;
        v.reserve(n);
        for (int i = 0; i < n; ++i)
            v.push_back(MxArray(mxGetCell(p_, i)));
        return v;
    }
    else
        return std::vector<MxArray>(1, *this);
}

/** Convert MxArray to std::vector<std::string>
 * @return std::vector<std::string> value
 *
 * Example:
 * @code
 * MxArray cellArray(prhs[0]);
 * vector<string> v = cellArray.toVector<string>();
 * @endcode
 */
template <>
std::vector<std::string> MxArray::toVector() const
{
    return toVector(
        std::const_mem_fun_ref_t<std::string,MxArray>(&MxArray::toString));
}

/** Convert MxArray to std::vector<cv::Mat>
 * @return std::vector<cv::Mat> value
 *
 * Example:
 * @code
 * MxArray cellArray(prhs[0]);
 * vector<Mat> v = cellArray.toVector<Mat>();
 * @endcode
 */
template <>
std::vector<cv::Mat> MxArray::toVector() const
{
    std::vector<MxArray> v(toVector<MxArray>());
    std::vector<cv::Mat> vm;
    vm.reserve(v.size());
    for (std::vector<MxArray>::iterator it = v.begin(); it < v.end(); ++it)
        vm.push_back((*it).toMat());
    return vm;
}

/** Convert MxArray to std::vector<Point>
 * @return std::vector<Point> value
 *
 * Example:
 * @code
 * MxArray cellArray(prhs[0]);
 * vector<Point> v = cellArray.toVector<Point>();
 * @endcode
 */
template <>
std::vector<cv::Point> MxArray::toVector() const
{
    return toVector(
        std::const_mem_fun_ref_t<cv::Point, MxArray>(&MxArray::toPoint));
}

/** Convert MxArray to std::vector<Point2f>
 * @return std::vector<Point2f> value
 *
 * Example:
 * @code
 * MxArray cellArray(prhs[0]);
 * vector<Point2f> v = cellArray.toVector<Point2f>();
 * @endcode
 */
template <>
std::vector<cv::Point2f> MxArray::toVector() const
{
    return toVector(
        std::const_mem_fun_ref_t<cv::Point2f, MxArray>(&MxArray::toPoint2f));
}

/** Convert MxArray to std::vector<Point3f>
 * @return std::vector<Point3f> value
 *
 * Example:
 * @code
 * MxArray cellArray(prhs[0]);
 * vector<Point3f> v = cellArray.toVector<Point3f>();
 * @endcode
 */
template <>
std::vector<cv::Point3f> MxArray::toVector() const
{
    return toVector(
        std::const_mem_fun_ref_t<cv::Point3f, MxArray>(&MxArray::toPoint3f));
}

/** Convert MxArray to std::vector<cv::KeyPoint>
 * @return std::vector<cv::KeyPoint> value
 *
 * Example:
 * @code
 * MxArray structArray(prhs[0]);
 * vector<KeyPoint> v = structArray.toVector<KeyPoint>();
 * @endcode
 */
template <>
std::vector<cv::KeyPoint> MxArray::toVector() const
{
    int n = numel();
    std::vector<cv::KeyPoint> v;
    v.reserve(n);
    if (isCell())
        for (int i = 0; i < n; ++i)
            v.push_back(at<MxArray>(i).toKeyPoint());
    else if (isStruct())
        for (int i = 0; i < n; ++i)
            v.push_back(toKeyPoint(i));
    else
        mexErrMsgIdAndTxt("mexopencv:error",
                          "MxArray unable to convert to std::vector");
    return v;
}

/** Convert MxArray to std::vector<cv::DMatch>
 * @return std::vector<cv::DMatch> value
 *
 * Example:
 * @code
 * MxArray structArray(prhs[0]);
 * vector<DMatch> v = structArray.toVector<DMatch>();
 * @endcode
 */
template <>
std::vector<cv::DMatch> MxArray::toVector() const
{
    int n = numel();
    std::vector<cv::DMatch> v;
    v.reserve(n);
    if (isCell())
        for (int i = 0; i < n; ++i)
            v.push_back(at<MxArray>(i).toDMatch());
    else if (isStruct())
        for (int i = 0; i < n; ++i)
            v.push_back(toDMatch(i));
    else
        mexErrMsgIdAndTxt("mexopencv:error",
                          "MxArray unable to convert to std::vector");
    return v;
}
