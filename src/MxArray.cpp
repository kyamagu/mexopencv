/** Implementation of MxArray.
 * @file MxArray.cpp
 * @author Kota Yamaguchi
 * @date 2012
 */
#include "MxArray.hpp"

namespace {

/// Field names for cv::Moments.
const char *cv_moments_fields[24] = {
    "m00", "m10", "m01", "m20", "m11", "m02","m30", "m21", "m12", "m03",
    "mu20", "mu11", "mu02", "mu30", "mu21", "mu12", "mu03",
    "nu20", "nu11", "nu02", "nu30", "nu21", "nu12", "nu03"};
/// Field names for cv::RotatedRect.
const char *cv_rotated_rect_fields[3] = {"center", "size", "angle"};
/// Field names for cv::TermCriteria.
const char *cv_term_criteria_fields[3] = {"type", "maxCount", "epsilon"};
/// Field names for cv::KeyPoint.
const char *cv_keypoint_fields[6] = {"pt", "size", "angle", "response",
                                     "octave", "class_id"};
/// Field names for cv::DMatch.
const char *cv_dmatch_fields[4] = {"queryIdx", "trainIdx", "imgIdx",
                                   "distance"};

/** Translates data type definition used in MATLAB to that of OpenCV.
 * @param classid data type of MATLAB's mxArray. e.g., \c mxDOUBLE_CLASS.
 * @return OpenCV's data type. e.g., \c CV_8U.
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

/** Translates data type definition used in OpenCV to that of MATLAB.
 * @param depth data depth of OpenCV's Mat class. e.g., \c CV_32F.
 * @return data type of MATLAB's mxArray. e.g., \c mxDOUBLE_CLASS.
 */
const ConstMap<int,mxClassID> ClassIDOf = ConstMap<int,mxClassID>
    (CV_64F,    mxDOUBLE_CLASS)
    (CV_32F,    mxSINGLE_CLASS)
    (CV_8S,     mxINT8_CLASS)
    (CV_8U,     mxUINT8_CLASS)
    (CV_16S,    mxINT16_CLASS)
    (CV_16U,    mxUINT16_CLASS)
    (CV_32S,    mxINT32_CLASS);

/** Comparison operator for sparse matrix elements.
 * This functor sorts SparseMat nodes in column-major order.
 * Only meant to be used on arrays with 2 dimensions.
 */
struct CompareSparseMatNode {
    /// Comparison functor
    bool operator () (const cv::SparseMat::Node* rhs,
                      const cv::SparseMat::Node* lhs) const
    {
        // sort by column, then by row
        if (rhs->idx[1] < lhs->idx[1])
            return true;
        if (rhs->idx[1] == lhs->idx[1] && rhs->idx[0] < lhs->idx[0])
            return true;
        return false;
    }
};

/// Inverse TermCriteria type map for option processing.
const ConstMap<int, std::string> InvTermCritType = ConstMap<int, std::string>
    (cv::TermCriteria::COUNT,                       "Count")
    (cv::TermCriteria::EPS,                         "EPS")
    (cv::TermCriteria::COUNT+cv::TermCriteria::EPS, "Count+EPS");

/// TermCriteria type map for option processing.
const ConstMap<std::string, int> TermCritType = ConstMap<std::string, int>
    ("Count",     cv::TermCriteria::COUNT)
    ("EPS",       cv::TermCriteria::EPS)
    ("Count+EPS", cv::TermCriteria::COUNT+cv::TermCriteria::EPS);

}  // anonymous namespace

MxArray& MxArray::operator=(const MxArray& rhs)
{
    if (this != &rhs)
        this->p_ = rhs.p_;
    return *this;
}

MxArray::MxArray(const int i)
    : p_(mxCreateDoubleScalar(static_cast<double>(i)))
{
    if (!p_)
        mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
}

MxArray::MxArray(const double d)
    : p_(mxCreateDoubleScalar(d))
{
    if (!p_)
        mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
}

MxArray::MxArray(const bool b)
    : p_(mxCreateLogicalScalar(b))
{
    if (!p_)
        mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
}

MxArray::MxArray(const std::string& s)
    : p_(mxCreateString(s.c_str()))
{
    if (!p_)
        mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
}

#if 0
// - works for multi-channel arrays, but doesnt work for ND-arrays because
// cv::split is broken for mat.dims>2, http://code.opencv.org/issues/4426.
// Even if cv::split was fixed, we still need to get
// the order of dimensions right for ND-array (row to column major order)
// (the std::swap below only gets it right for 2D arrays).
// - There's another bug regarding multi-channel arrays where mat.channels()
// is limited because of cv::transpose, which is only implemented for a number
// of cases, and asserts that mat.elementSize() <= 32
// (elementSize = sizeof(depth)*nchannels), so for mat.depth()==CV_8U we can
// go up to 32 channels, but for mat.depth()==CV_64F we can only go up to a
// maximum of 4 channels (8*4 == 32)
MxArray::MxArray(const cv::Mat& mat, mxClassID classid, bool transpose)
{
    // handle special case of empty input Mat by creating an empty array
    classid = (classid == mxUNKNOWN_CLASS) ? ClassIDOf[mat.depth()] : classid;
    if (mat.empty()) {
        p_ = mxCreateNumericMatrix(0, 0, classid, mxREAL);
        if (!p_)
            mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
        return;
    }
    // transpose cv::Mat if needed
    cv::Mat input(mat);
    if (input.dims == 2 && transpose)
        input = input.t();
    // Create a new mxArray (of the specified classID) equivalent to cv::Mat
    const mwSize nchannels = input.channels();
    const int* dims_ = input.size;
    std::vector<mwSize> d(dims_, dims_ + input.dims);
    d.push_back(nchannels); // mxCreate* ignores trailing singleton dimensions
    std::swap(d[0], d[1]);
    if (classid == mxLOGICAL_CLASS) {
        // OpenCV's logical true is any nonzero, while MATLAB's true is 1.
        cv::compare(input, 0, input, cv::CMP_NE);
        input.setTo(1, input);
        p_ = mxCreateLogicalArray(d.size(), &d[0]);
    }
    else
        p_ = mxCreateNumericArray(d.size(), &d[0], classid, mxREAL);
    if (!p_)
        mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
    // split input cv::Mat into several single-channel arrays
    std::vector<cv::Mat> channels;
    channels.reserve(nchannels);
    cv::split(input, channels);
    // Copy each channel from Mat to mxArray (converting to specified classid),
    // as in: p_(:,:,i) <- cast_to_classid_type(channels[i])
    std::vector<mwSize> si(d.size(), 0);               // subscript index
    const int type = CV_MAKETYPE(DepthOf[classid], 1); // destination type
    for (mwIndex i = 0; i < nchannels; ++i) {
        si[si.size() - 1] = i;                   // last dim is a channel index
        void *ptr = reinterpret_cast<void*>(
            reinterpret_cast<size_t>(mxGetData(p_)) +
            mxGetElementSize(p_) * subs(si));    // ptr to i-th channel data
        cv::Mat m(input.dims, dims_, type, ptr); // only creates Mat header
        channels[i].convertTo(m, type);          // Write to mxArray through m
    }
}
#else
// works for any cv::Mat/cv::MatND (any combination of channels and dimensions)
MxArray::MxArray(const cv::Mat& mat, mxClassID classid, bool)
{
    // determine classID of output array
    classid = (classid == mxUNKNOWN_CLASS) ? ClassIDOf[mat.depth()] : classid;

    // handle special case of empty input Mat by returning 0x0 array
    if (mat.empty()) {
        // TODO: maybe return empty array of same dimensions 0x1, 1x0x2, ...
        p_ = mxCreateNumericMatrix(0, 0, classid, mxREAL);
        if (!p_)
            mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
        return;
    }

    // Create output mxArray (of specified type), equivalent to the input Mat
    const mwSize cn = mat.channels();
    const mwSize len = mat.total() * cn;
    std::vector<mwSize> sz(mat.size.p, mat.size.p + mat.dims);
    if (cn > 1)
        sz.push_back(cn);  // channels is treated as another dimension
    std::reverse(sz.begin(), sz.end());  // row vs. column major order
    if (classid == mxLOGICAL_CLASS)
        p_ = mxCreateLogicalArray(sz.size(), &sz[0]);
    else
        p_ = mxCreateNumericArray(sz.size(), &sz[0], classid, mxREAL);
    if (!p_)
        mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");

    // fill output with values from input Mat
    // (linearized as a 1D-vector, both dimensions and channels)
    {
        // wrap destination data using a cv::Mat
        const int type = CV_MAKETYPE(DepthOf[classid], 1); // destination type
        cv::Mat m(len, 1, type, mxGetData(p_));  // only creates Mat header

        // copy flattened input to output array (converting to specified type)
        const cv::Mat mat0(len, 1, mat.depth(), mat.data); // no data copying
        if (classid == mxLOGICAL_CLASS) {
            // OpenCV's logical true is any nonzero, while MATLAB's true is 1
            cv::compare(mat0, 0, m, cv::CMP_NE); // values either 0 or 255
            m.setTo(1, m);  // values either 0 or 1 (CV_8U)
        }
        else
            mat0.convertTo(m, type);
    }

    // rearrange dimensions of mxArray by calling PERMUTE from MATLAB. We want
    // to convert from row-major order (C-style, last dim changes fastest) to a
    // column-major order (MATLAB-style, first dim changes fastest). This will
    // handle all cases of cv::Mat as multi-channels and/or multi-dimensions.
    std::vector<double> order;
    order.reserve(sz.size());
    for (int i=sz.size(); i>0; i--)
        order.push_back(i);

    // CALL: out = permute(in, ndims(in):-1:1)
    mxArray *lhs, *rhs[2];
    rhs[0] = const_cast<mxArray*>(p_);
    rhs[1] = MxArray(order);
    lhs = NULL;              // new data copy will be returned
    if (mexCallMATLAB(1, &lhs, 2, rhs, "permute") != 0)
        mexErrMsgIdAndTxt("mexopencv:error", "Error calling permute");
    p_ = lhs;
    mxDestroyArray(rhs[0]);  // discard old copy
    mxDestroyArray(rhs[1]);
    CV_DbgAssert(!isNull() && classID()==classid && numel()==len);
}
#endif

MxArray::MxArray(const cv::SparseMat& mat)
{
    // MATLAB only supports 2D sparse arrays of class double
    if (mat.dims() != 2 || mat.type() != CV_32FC1)
        mexErrMsgIdAndTxt("mexopencv:error", "Not a 2D float sparse matrix");
    // Create a sparse array, and get pointers to data (PR, IR, JC)
    const mwSize m = mat.size(0), n = mat.size(1), nnz = mat.nzcount();
    p_ = mxCreateSparse(m, n, nnz, mxREAL);
    if (!p_)
        mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
    mwIndex *ir = mxGetIr(p_);  // array of length nzmax
    mwIndex *jc = mxGetJc(p_);  // array of length n+1
    double *pr = mxGetPr(p_);   // array of length nzmax
    if (!ir || !jc || !pr)
        mexErrMsgIdAndTxt("mexopencv:error", "Null pointer error");
    // collect SparseMat nodes. They are enumerated semi-randomly
    // (iterator returns them in an order based on their index hash)
    std::vector<const cv::SparseMat::Node*> nodes;
    nodes.reserve(nnz);
    for (cv::SparseMat::const_iterator it = mat.begin(); it != mat.end(); ++it)
        nodes.push_back(it.node());
    // sort the nodes in a column-major order before we put elems into mxArray
    std::sort(nodes.begin(), nodes.end(), CompareSparseMatNode());
    // Copy data by converting from (row,col,val) triplets to CSC format
    jc[0] = 0;
    for (mwIndex i = 0; i < nodes.size(); ++i) {
        const mwIndex row = nodes[i]->idx[0], col = nodes[i]->idx[1];
        ir[i] = row;
        jc[col+1] = i+1;
        pr[i] = static_cast<double>(mat.value<float>(nodes[i]));
    }
    // fill indices in JC array where columns were empty and had no values
    for (mwIndex i = 1; i < n+1; ++i) {
        if (jc[i] == 0)
            jc[i] = jc[i-1];
    }
}

MxArray::MxArray(const cv::Moments& m)
    : p_(mxCreateStructMatrix(1, 1, 24, cv_moments_fields))
{
    if (!p_)
        mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
    set("m00",  m.m00);
    set("m10",  m.m10);
    set("m01",  m.m01);
    set("m20",  m.m20);
    set("m11",  m.m11);
    set("m02",  m.m02);
    set("m30",  m.m30);
    set("m12",  m.m12);
    set("m21",  m.m21);
    set("m03",  m.m03);
    set("mu20", m.mu20);
    set("mu11", m.mu11);
    set("mu02", m.mu02);
    set("mu30", m.mu30);
    set("mu21", m.mu21);
    set("mu12", m.mu12);
    set("mu03", m.mu03);
    set("nu20", m.nu20);
    set("nu11", m.nu11);
    set("nu02", m.nu02);
    set("nu30", m.nu30);
    set("nu21", m.nu21);
    set("nu12", m.nu12);
    set("nu03", m.nu03);
}

MxArray::MxArray(const cv::KeyPoint& p)
    : p_(mxCreateStructMatrix(1, 1, 6, cv_keypoint_fields))
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

template<>
void MxArray::fromVector(const std::vector<char>& v)
{
    const mwSize size[] = {1, v.size()};
    p_ = mxCreateCharArray(2, size);
    if (!p_)
        mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
    std::copy(v.begin(), v.end(), mxGetChars(p_));
}

template<>
void MxArray::fromVector(const std::vector<bool>& v)
{
    p_ = mxCreateLogicalMatrix(1, v.size());
    if (!p_)
        mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
    std::copy(v.begin(), v.end(), mxGetLogicals(p_));
}

template <>
MxArray::MxArray(const std::vector<cv::KeyPoint>& v)
    : p_(mxCreateStructMatrix(1, v.size(), 6, cv_keypoint_fields))
{
    if (!p_)
        mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
    for (mwIndex i = 0; i < v.size(); ++i) {
        set("pt",       v[i].pt,       i);
        set("size",     v[i].size,     i);
        set("angle",    v[i].angle,    i);
        set("response", v[i].response, i);
        set("octave",   v[i].octave,   i);
        set("class_id", v[i].class_id, i);
    }
}

MxArray::MxArray(const cv::DMatch& m)
    : p_(mxCreateStructMatrix(1, 1, 4, cv_keypoint_fields))
{
    if (!p_)
        mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
    set("queryIdx", m.queryIdx);
    set("trainIdx", m.trainIdx);
    set("imgIdx",   m.imgIdx);
    set("distance", m.distance);
}

template <>
MxArray::MxArray(const std::vector<cv::DMatch>& v)
    : p_(mxCreateStructMatrix(1, v.size(), 4, cv_dmatch_fields))
{
    if (!p_)
        mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
    for (mwIndex i = 0; i < v.size(); ++i) {
        set("queryIdx", v[i].queryIdx, i);
        set("trainIdx", v[i].trainIdx, i);
        set("imgIdx",   v[i].imgIdx,   i);
        set("distance", v[i].distance, i);
    }
}

MxArray::MxArray(const cv::RotatedRect& r)
    : p_(mxCreateStructMatrix(1, 1, 3, cv_rotated_rect_fields))
{
    if (!p_)
        mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
    set("center", r.center);
    set("size",   r.size);
    set("angle",  r.angle);
}

template <>
MxArray::MxArray(const std::vector<cv::RotatedRect>& v)
    : p_(mxCreateStructMatrix(1, v.size(), 3, cv_rotated_rect_fields))
{
    if (!p_)
        mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
    for (mwIndex i = 0; i < v.size(); ++i) {
        set("center", v[i].center, i);
        set("size",   v[i].size,   i);
        set("angle",  v[i].angle,  i);
    }
}

MxArray::MxArray(const cv::TermCriteria& t)
    : p_(mxCreateStructMatrix(1, 1, 3, cv_term_criteria_fields))
{
    if (!p_)
        mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
    set("type",     InvTermCritType[t.type]);
    set("maxCount", t.maxCount);
    set("epsilon",  t.epsilon);
}

MxArray MxArray::clone() const
{
    mxArray *pm = mxDuplicateArray(p_);
    if (!pm)
        mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
    return MxArray(pm);
}

int MxArray::toInt() const
{
    if (numel() != 1)
        mexErrMsgIdAndTxt("mexopencv:error", "MxArray is not a scalar");
    return at<int>(0);
}

double MxArray::toDouble() const
{
    if (numel() != 1)
        mexErrMsgIdAndTxt("mexopencv:error", "MxArray is not a scalar");
    return at<double>(0);
}

float MxArray::toFloat() const
{
    if (numel() != 1)
        mexErrMsgIdAndTxt("mexopencv:error", "MxArray is not a scalar");
    return at<float>(0);
}

bool MxArray::toBool() const
{
    if (numel() != 1)
        mexErrMsgIdAndTxt("mexopencv:error", "MxArray is not a scalar");
    return at<bool>(0);
}

std::string MxArray::toString() const
{
    if (!isChar())
        mexErrMsgIdAndTxt("mexopencv:error", "MxArray not of type char");
    char *pc = mxArrayToString(p_);
    if (!pc)
        mexErrMsgIdAndTxt("mexopencv:error", "Null pointer error");
    std::string s(pc);
    mxFree(pc);
    return s;
}

cv::Mat MxArray::toMat(int depth, bool transpose) const
{
    CV_Assert(isNumeric() || isLogical() || isChar());

    // the rest of this function works fine for 2D and 3D arrays, but for
    // higher ND-arrays the order of dimensions is not right (the std::swap
    // below is only intended for 2d array).
    // So instead we use MxArray::toMatND on the input ND-array and then
    // convert the last dimension of the MatND into channels.
    if (ndims() > 3) {
        cv::Mat matnd(toMatND(depth, transpose));  // ND-array, 1-channel
        CV_DbgAssert(matnd.isContinuous() && matnd.dims == ndims() && matnd.channels() == 1);
        std::vector<int> d(matnd.size.p, matnd.size.p + matnd.dims);
        const int cn = d.back();
        const int type = CV_MAKETYPE(matnd.depth(), cn);
        CV_Assert(cn <= CV_CN_MAX);
/*
        // straightforward implementation, unfortunately it throws an
        // exception that ND-array reshape is not yet implemented.
        //TODO: this was fixed in master after 3.0.0:
        // https://github.com/Itseez/opencv/pull/4212
        return matnd.reshape(cn, d.size()-1, &d[0]);
*/
/*
        // an alternative implementation, but it creates a temp copy
        cv::Mat mat(d.size()-1, &d[0], type, matnd.data);
        return mat.clone();
*/
///*
        // another hacky implementation, works without creating a temp copy
        const cv::Mat mat(d.size()-1, &d[0], type, matnd.data); // header only
        // Mat::reshape leaves an extra singleton dimension at the end (e.g
        // 5x4x3x2 1-ch -> 5x4x3x1 2-cn) but it correctly sets cn in the flags
        matnd = matnd.reshape(cn, 0);
        // this fixes the number of dimensions (sorta like SQUEEZE)
        matnd.copySize(mat);  // dims reduced and size/step pointers reallocated
        return matnd;
//*/
    }

    // Create cv::Mat object (of the specified depth), equivalent to mxArray.
    // At this point we create either a 2-dim with 1-channel mat, or a 2-dim
    // with multi-channels mat. Multi-dims case is handled above.
    std::vector<int> d(dims(), dims()+ndims());
    const mwSize ndims = (d.size()>2) ? d.size()-1 : d.size();
    const mwSize nchannels = (d.size()>2) ? d.back() : 1;
    depth = (depth == CV_USRTYPE1) ? DepthOf[classID()] : depth;
    std::swap(d[0], d[1]);
    cv::Mat mat(ndims, &d[0], CV_MAKETYPE(depth, nchannels));
    // Copy each channel from mxArray to Mat (converting to specified depth),
    // as in: channels[i] <- cast_to_mat_depth(p_(:,:,i))
    std::vector<cv::Mat> channels(nchannels);
    std::vector<mwSize> si(d.size(), 0);                 // subscript index
    const int type = CV_MAKETYPE(DepthOf[classID()], 1); // Source type
    for (mwIndex i = 0; i<nchannels; ++i) {
        si[si.size() - 1] = i;                   // last dim is a channel idx
        void *pd = reinterpret_cast<void*>(
            reinterpret_cast<size_t>(mxGetData(p_)) +
            mxGetElementSize(p_)*subs(si));      // ptr to i-th channel data
        const cv::Mat m(ndims, &d[0], type, pd); // only creates Mat headers
        // Read from mxArray through m, writing into channels[i]
        m.convertTo(channels[i], CV_MAKETYPE(depth, 1));
        // transpose cv::Mat if needed. We do this inside the loop on each 2d
        // 1-cn slice to avoid cv::transpose limitation on number of channels
        if (transpose)
            cv::transpose(channels[i], channels[i]);  // in-place transpose
    }
    // Merge channels back into one cv::Mat array
    // (Note that unlike cv::split, cv::merge works for all cases of dims/cn)
    cv::merge(channels, mat);
    return mat;
}

#if 0
// works for 2D, but for ND-arrays the dimensions are not arranged correctly
cv::MatND MxArray::toMatND(int depth, bool transpose) const
{
    // Create cv::MatND object (of the specified depth), equivalent to mxArray
    std::vector<int> d(dims(), dims()+ndims());
    std::swap(d[0], d[1]);
    depth = (depth == CV_USRTYPE1) ? DepthOf[classID()] : depth;
    cv::MatND mat(d.size(), &d[0], CV_MAKETYPE(depth, 1));
    // Copy from mxArray to cv::MatND (converting to specified depth)
    const int type = CV_MAKETYPE(DepthOf[classID()], 1);     // source type
    const cv::MatND m(d.size(), &d[0], type, mxGetData(p_)); // only Mat header
    // Read from mxArray through m, writing into mat
    m.convertTo(mat, CV_MAKETYPE(depth, 1));
    // transpose cv::MatND if needed
    if (mat.dims==2 && transpose)
        cv::transpose(mat, mat);  // in-place transpose
    return mat;
}
#else
// works for any number of dimensions
cv::MatND MxArray::toMatND(int depth, bool) const
{
    CV_Assert(isNumeric() || isLogical() || isChar());
    CV_Assert(ndims() <= CV_MAX_DIM);

    // rearrange ND-array from MATLAB-style (column-major order, first dim
    // changes fastest) to C-style (row-major order, last dim changes fastest)
    // by calling PERMUTE from MATLAB.
    std::vector<double> order;
    order.reserve(ndims());
    for (int i=ndims(); i>0; i--)
        order.push_back(i);

    // CALL: out = permute(in, ndims(in):-1:1)
    mxArray *lhs, *rhs[2];
    rhs[0] = const_cast<mxArray*>(p_);
    rhs[1] = MxArray(order);
    lhs = NULL;    // new data copy will be returned
    if (mexCallMATLAB(1, &lhs, 2, rhs, "permute") != 0)
        mexErrMsgIdAndTxt("mexopencv:error", "Error calling permute");
    mxDestroyArray(rhs[1]);
    CV_DbgAssert(lhs!=NULL && mxGetClassID(lhs)==classID() &&
        mxGetNumberOfElements(lhs)==numel());

    // Create output cv::MatND object of the specified depth, and of same size
    // as mxArray. This is a single-channel multi-dimensional array.
    std::vector<int> d(dims(), dims() + ndims());
    depth = (depth == CV_USRTYPE1) ? DepthOf[classID()] : depth;
    cv::MatND mat(d.size(), &d[0], CV_MAKETYPE(depth, 1));

    // Copy data from mxArray to cv::MatND (converting to specified depth)
    {
        // wrap source data using a cv::Mat (only creates header, data shared)
        const int type = CV_MAKETYPE(DepthOf[classID()], 1);  // source type
        const cv::MatND m(d.size(), &d[0], type, mxGetData(lhs));

        // Read from mxArray through m, writing into mat
        m.convertTo(mat, CV_MAKETYPE(depth, 1));
    }

    // clean temporary copy, and return result
    mxDestroyArray(lhs);
    return mat;
}
#endif

cv::SparseMat MxArray::toSparseMat() const
{
    // Check if it's sparse.
    if (!isSparse() || !isDouble() || isComplex())
        mexErrMsgIdAndTxt("mexopencv:error", "MxArray is not real double sparse");
    // Create cv::SparseMat.
    const mwSize m = mxGetM(p_), n = mxGetN(p_);
    const int dims[] = {m, n};
    cv::SparseMat mat(2, dims, CV_32F);
    // Copy data by converting from CSC format to (row,col,val) triplets
    const mwIndex *ir = mxGetIr(p_);  // array of length nzmax
    const mwIndex *jc = mxGetJc(p_);  // array of length n+1
    const double *pr = mxGetPr(p_);   // array of length nzmax
    if (!ir || !jc || !pr)
         mexErrMsgIdAndTxt("mexopencv:error", "Null pointer error");
    for (mwIndex j = 0; j < n; ++j) {
        // JC contains indices into PR and IR of the first non-zero value in a column
        const mwIndex start = jc[j], end = jc[j+1];
        for (mwIndex i = start; i < end; ++i)
            // mat(row,col) = val
            mat.ref<float>(ir[i], j) = static_cast<float>(pr[i]);
    }
    return mat;
}

cv::Moments MxArray::toMoments(mwIndex index) const
{
    // the muXX and nuXX are computed from mXX
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

cv::KeyPoint MxArray::toKeyPoint(mwIndex index) const
{
    return cv::KeyPoint(
        at("pt",   index).toPoint2f(),
        at("size", index).toFloat(),
        (isField("angle"))    ? at("angle",    index).toFloat()  : -1,
        (isField("response")) ? at("response", index).toFloat()  :  0,
        (isField("octave"))   ? at("octave",   index).toInt()    :  0,
        (isField("class_id")) ? at("class_id", index).toInt()    : -1
    );
}

cv::DMatch MxArray::toDMatch(mwIndex index) const
{
    return cv::DMatch(
        (isField("queryIdx")) ? at("queryIdx", index).toInt()    : 0,
        (isField("trainIdx")) ? at("trainIdx", index).toInt()    : 0,
        (isField("imgIdx"))   ? at("imgIdx",   index).toInt()    : 0,
        (isField("distance")) ? at("distance", index).toFloat()  : 0
    );
}

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

cv::RotatedRect MxArray::toRotatedRect(mwIndex index) const
{
    cv::RotatedRect rr;
    if (isField("center")) rr.center = at("center", index).toPoint_<float>();
    if (isField("size"))   rr.size   = at("size",   index).toSize_<float>();
    if (isField("angle"))  rr.angle  = at("angle",  index).toFloat();
    return rr;
}

cv::TermCriteria MxArray::toTermCriteria(mwIndex index) const
{
    const MxArray _type(at("type", index));
    return cv::TermCriteria(
        (_type.isChar()) ? TermCritType[_type.toString()] : _type.toInt(),
        at("maxCount", index).toInt(),
        at("epsilon", index).toDouble()
    );
}

std::string MxArray::fieldname(int fieldnumber) const
{
    if (!isStruct())
        mexErrMsgIdAndTxt("mexopencv:error", "MxArray is not struct");
    const char *fname = mxGetFieldNameByNumber(p_, fieldnumber);
    if (!fname)
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to get field name at %d\n", fieldnumber);
    return std::string(fname);
}

std::vector<std::string> MxArray::fieldnames() const
{
    if (!isStruct())
        mexErrMsgIdAndTxt("mexopencv:error", "MxArray is not a struct array");
    const mwSize n = nfields();
    std::vector<std::string> v;
    v.reserve(n);
    for (mwIndex i = 0; i < n; ++i)
        v.push_back(fieldname(i));
    return v;
}

mwIndex MxArray::subs(mwIndex i, mwIndex j) const
{
    if (i >= rows() || j >= cols())
        mexErrMsgIdAndTxt("mexopencv:error", "Subscript out of range");
    mwIndex si[] = {i, j};
    return mxCalcSingleSubscript(p_, 2, si);
}

mwIndex MxArray::subs(const std::vector<mwIndex>& si) const
{
    std::vector<mwIndex> v(si);
    return mxCalcSingleSubscript(p_, si.size(), (!v.empty() ? &v[0] : NULL));
}

MxArray MxArray::at(const std::string& fieldName, mwIndex index) const
{
    if (!isStruct())
        mexErrMsgIdAndTxt("mexopencv:error", "MxArray is not struct");
    if (numel() <= index)
        mexErrMsgIdAndTxt("mexopencv:error", "Index out of range");
    const mxArray* pm = mxGetField(p_, index, fieldName.c_str());
    if (!pm)
        mexErrMsgIdAndTxt("mexopencv:error",
            "Field '%s' doesn't exist", fieldName.c_str());
    return MxArray(pm);
}

template <>
MxArray MxArray::at(mwIndex index) const
{
    if (!isCell())
        mexErrMsgIdAndTxt("mexopencv:error", "MxArray is not cell");
    if (numel() <= index)
        mexErrMsgIdAndTxt("mexopencv:error", "Index out of range");
    return MxArray(mxGetCell(p_, index));
}

template <>
void MxArray::set(mwIndex index, const MxArray& value)
{
    if (!isCell())
        mexErrMsgIdAndTxt("mexopencv:error", "MxArray is not cell");
    if (numel() <= index)
        mexErrMsgIdAndTxt("mexopencv:error", "Index out of range");
    mxSetCell(const_cast<mxArray*>(p_), index, static_cast<mxArray*>(value));
}

template <>
std::vector<MxArray> MxArray::toVector() const
{
    std::vector<MxArray> v;
    if (isCell()) {
        const mwSize n = numel();
        v.reserve(n);
        for (mwIndex i = 0; i < n; ++i)
            //v.push_back(at<MxArray>(i));
            v.push_back(MxArray(mxGetCell(p_, i)));
    }
    else
        v.push_back(*this);
    return v;
}

template <>
std::vector<std::string> MxArray::toVector() const
{
    return toVector(
        std::const_mem_fun_ref_t<std::string,MxArray>(&MxArray::toString));
}

template <>
std::vector<cv::Mat> MxArray::toVector() const
{
    const std::vector<MxArray> v(toVector<MxArray>());
    std::vector<cv::Mat> vm;
    vm.reserve(v.size());
    for (std::vector<MxArray>::const_iterator it = v.begin(); it != v.end(); ++it)
        vm.push_back((*it).toMat());
    return vm;
}

template <>
std::vector<cv::Point> MxArray::toVector() const
{
    if (isNumeric()) {
        std::vector<cv::Point> vp;
        if (numel() == 2)
            vp.push_back(toPoint());
        else
            toMat(CV_32S).reshape(2, 0).copyTo(vp);
        return vp;
    }
    else {
        return toVector(
            std::const_mem_fun_ref_t<cv::Point, MxArray>(
                &MxArray::toPoint_<int>));
    }
}

template <>
std::vector<cv::Point2f> MxArray::toVector() const
{
    if (isNumeric()) {
        std::vector<cv::Point2f> vp;
        if (numel() == 2)
            vp.push_back(toPoint2f());
        else
            toMat(CV_32F).reshape(2, 0).copyTo(vp);
        return vp;
    }
    else {
        return toVector(
            std::const_mem_fun_ref_t<cv::Point2f, MxArray>(
                &MxArray::toPoint_<float>));
    }
}

template <>
std::vector<cv::Point2d> MxArray::toVector() const
{
    if (isNumeric()) {
        std::vector<cv::Point2d> vp;
        if (numel() == 2)
            vp.push_back(toPoint_<double>());
        else
            toMat(CV_64F).reshape(2, 0).copyTo(vp);
        return vp;
    }
    else {
        return toVector(
            std::const_mem_fun_ref_t<cv::Point2d, MxArray>(
                &MxArray::toPoint_<double>));
    }
}

template <>
std::vector<cv::Point3i> MxArray::toVector() const
{
    if (isNumeric()) {
        std::vector<cv::Point3i> vp;
        if (numel() == 3)
            vp.push_back(toPoint3_<int>());
        else
            toMat(CV_32S).reshape(3, 0).copyTo(vp);
        return vp;
    }
    else {
        return toVector(
            std::const_mem_fun_ref_t<cv::Point3i, MxArray>(
                &MxArray::toPoint3_<int>));
    }
}

template <>
std::vector<cv::Point3f> MxArray::toVector() const
{
    if (isNumeric()) {
        std::vector<cv::Point3f> vp;
        if (numel() == 3)
            vp.push_back(toPoint3f());
        else
            toMat(CV_32F).reshape(3, 0).copyTo(vp);
        return vp;
    }
    else {
        return toVector(
            std::const_mem_fun_ref_t<cv::Point3f, MxArray>(
                &MxArray::toPoint3_<float>));
    }
}

template <>
std::vector<cv::Point3d> MxArray::toVector() const
{
    if (isNumeric()) {
        std::vector<cv::Point3d> vp;
        if (numel() == 3)
            vp.push_back(toPoint3_<double>());
        else
            toMat(CV_64F).reshape(3, 0).copyTo(vp);
        return vp;
    }
    else {
        return toVector(
            std::const_mem_fun_ref_t<cv::Point3d, MxArray>(
                &MxArray::toPoint3_<double>));
    }
}

template <>
std::vector<cv::Size> MxArray::toVector() const
{
    if (isNumeric()) {
        std::vector<cv::Size> vs;
        if (numel() == 2)
            vs.push_back(toSize());
        else
            toMat(CV_32S).reshape(2, 0).copyTo(vs);
        return vs;
    }
    else {
        return toVector(
            std::const_mem_fun_ref_t<cv::Size, MxArray>(&MxArray::toSize));
    }
}

template <>
std::vector<cv::Rect> MxArray::toVector() const
{
    if (isNumeric()) {
        std::vector<cv::Rect> vr;
        if (numel() == 4)
            vr.push_back(toRect());
        else
            toMat(CV_32S).reshape(4, 0).copyTo(vr);
        return vr;
    }
    else {
        return toVector(
            std::const_mem_fun_ref_t<cv::Rect, MxArray>(&MxArray::toRect));
    }
}

template <>
std::vector<cv::Vec2i> MxArray::toVector() const
{
    if (isNumeric()) {
        std::vector<cv::Vec2i> vv;
        if (numel() == 2)
            vv.push_back(toVec<int,2>());
        else
            toMat(CV_32S).reshape(2, 0).copyTo(vv);
        return vv;
    }
    else {
        return toVector(
            std::const_mem_fun_ref_t<cv::Vec2i, MxArray>(
                &MxArray::toVec<int,2>));
    }
}

template <>
std::vector<cv::Vec2f> MxArray::toVector() const
{
    if (isNumeric()) {
        std::vector<cv::Vec2f> vv;
        if (numel() == 2)
            vv.push_back(toVec<float,2>());
        else
            toMat(CV_32F).reshape(2, 0).copyTo(vv);
        return vv;
    }
    else {
        return toVector(
            std::const_mem_fun_ref_t<cv::Vec2f, MxArray>(
                &MxArray::toVec<float,2>));
    }
}

template <>
std::vector<cv::Vec3i> MxArray::toVector() const
{
    if (isNumeric()) {
        std::vector<cv::Vec3i> vv;
        if (numel() == 3)
            vv.push_back(toVec<int,3>());
        else
            toMat(CV_32S).reshape(3, 0).copyTo(vv);
        return vv;
    }
    else {
        return toVector(
            std::const_mem_fun_ref_t<cv::Vec3i, MxArray>(
                &MxArray::toVec<int,3>));
    }
}

template <>
std::vector<cv::Vec3f> MxArray::toVector() const
{
    if (isNumeric()) {
        std::vector<cv::Vec3f> vv;
        if (numel() == 3)
            vv.push_back(toVec<float,3>());
        else
            toMat(CV_32F).reshape(3, 0).copyTo(vv);
        return vv;
    }
    else {
        return toVector(
            std::const_mem_fun_ref_t<cv::Vec3f, MxArray>(
                &MxArray::toVec<float,3>));
    }
}

template <>
std::vector<cv::Vec4i> MxArray::toVector() const
{
    if (isNumeric()) {
        std::vector<cv::Vec4i> vv;
        if (numel() == 4)
            vv.push_back(toVec<int,4>());
        else
            toMat(CV_32S).reshape(4, 0).copyTo(vv);
        return vv;
    }
    else {
        return toVector(
            std::const_mem_fun_ref_t<cv::Vec4i, MxArray>(
                &MxArray::toVec<int,4>));
    }
}

template <>
std::vector<cv::Vec4f> MxArray::toVector() const
{
    if (isNumeric()) {
        std::vector<cv::Vec4f> vv;
        if (numel() == 4)
            vv.push_back(toVec<float,4>());
        else
            toMat(CV_32F).reshape(4, 0).copyTo(vv);
        return vv;
    }
    else {
        return toVector(
            std::const_mem_fun_ref_t<cv::Vec4f, MxArray>(
                &MxArray::toVec<float,4>));
    }
}

template <>
std::vector<cv::RotatedRect> MxArray::toVector() const
{
    const mwSize n = numel();
    std::vector<cv::RotatedRect> v;
    v.reserve(n);
    if (isCell())
        for (mwIndex i = 0; i < n; ++i)
            v.push_back(at<MxArray>(i).toRotatedRect());
    else if (isStruct())
        for (mwIndex i = 0; i < n; ++i)
            v.push_back(toRotatedRect(i));
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "MxArray unable to convert to std::vector<cv::RotatedRect>");
    return v;
}

template <>
std::vector<cv::KeyPoint> MxArray::toVector() const
{
    const mwSize n = numel();
    std::vector<cv::KeyPoint> v;
    v.reserve(n);
    if (isCell())
        for (mwIndex i = 0; i < n; ++i)
            v.push_back(at<MxArray>(i).toKeyPoint());
    else if (isStruct())
        for (mwIndex i = 0; i < n; ++i)
            v.push_back(toKeyPoint(i));
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "MxArray unable to convert to std::vector<cv::KeyPoint>");
    return v;
}

template <>
std::vector<cv::DMatch> MxArray::toVector() const
{
    const mwSize n = numel();
    std::vector<cv::DMatch> v;
    v.reserve(n);
    if (isCell())
        for (mwIndex i = 0; i < n; ++i)
            v.push_back(at<MxArray>(i).toDMatch());
    else if (isStruct())
        for (mwIndex i = 0; i < n; ++i)
            v.push_back(toDMatch(i));
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "MxArray unable to convert to std::vector<cv::DMatch>");
    return v;
}
