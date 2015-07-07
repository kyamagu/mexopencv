/** Implementation of MxArray.
 * @file MxArray.cpp
 * @author Kota Yamaguchi
 * @date 2012
 */
#include "MxArray.hpp"

namespace {

/// Field names for cv::Moments.
const char *cv_moments_fields[10] = {"m00", "m10", "m01", "m20", "m11", "m02",
                                     "m30", "m21", "m12", "m03"};
/// Field names for cv::RotatedRect.
const char *cv_rotated_rect_fields[3] = {"center", "size", "angle"};
/// Field names for cv::TermCriteria.
const char *cv_term_criteria_fields[3] = {"type", "maxCount", "epsilon"};
/// Field names for cv::Keypoint.
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
 */
struct CompareSparseMatNode {
    /// Comparison functor
    bool operator () (const cv::SparseMat::Node* rhs,
                      const cv::SparseMat::Node* lhs) const
    {
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
    d.push_back(nchannels);
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

MxArray::MxArray(const cv::SparseMat& mat)
{
    if (mat.dims() != 2 || mat.type() != CV_32FC1)
        mexErrMsgIdAndTxt("mexopencv:error", "Not a 2D float sparse matrix");
    // Create a sparse array.
    const mwSize nnz = mat.nzcount();
    p_ = mxCreateSparse(mat.size(0), mat.size(1), nnz, mxREAL);
    if (!p_)
        mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
    // Sort nodes before we put elems into mxArray.
    std::vector<const cv::SparseMat::Node*> nodes;
    nodes.reserve(nnz);
    for (cv::SparseMatConstIterator it = mat.begin(); it != mat.end(); ++it)
        nodes.push_back(it.node());
    std::sort(nodes.begin(), nodes.end(), CompareSparseMatNode());
    // Copy data.
    mwIndex *ir = mxGetIr(p_);
    mwIndex *jc = mxGetJc(p_);
    double *pr = mxGetPr(p_);
    if (!ir || !jc || !pr)
        mexErrMsgIdAndTxt("mexopencv:error", "Null pointer error");
    mwIndex i = 0;
    jc[0] = 0;
    for (std::vector<const cv::SparseMat::Node*>::const_iterator
         it = nodes.begin(); it != nodes.end(); ++it)
    {
        const mwIndex row = (*it)->idx[0], col = (*it)->idx[1];
        ir[i] = row;
        jc[col+1] = i+1;
        pr[i] = static_cast<double>(mat.value<float>(*it));
        ++i;
    }
}

MxArray::MxArray(const cv::Moments& m)
    : p_(mxCreateStructMatrix(1, 1, 10, cv_moments_fields))
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
    // Create cv::Mat object (of the specified depth), equivalent to mxArray
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
    }
    // Merge channels back into one cv::Mat array
    cv::merge(channels, mat);
    // transpose cv::Mat if needed
    if (mat.dims==2 && transpose)
        mat = mat.t();
    return mat;
}

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
        mat = mat.t();
    return mat;
}

cv::SparseMat MxArray::toSparseMat() const
{
    // Check if it's sparse.
    if (!isSparse() || !isDouble())
        mexErrMsgIdAndTxt("mexopencv:error", "MxArray is not sparse");
    // Create cv::SparseMat.
    const mwSize m = mxGetM(p_), n = mxGetN(p_);
    const int dims[] = {m, n};
    cv::SparseMat mat(2, dims, CV_32F);
    // Copy data.
    const mwIndex *ir = mxGetIr(p_);
    const mwIndex *jc = mxGetJc(p_);
    const double *pr = mxGetPr(p_);
    if (!ir || !jc || !pr)
         mexErrMsgIdAndTxt("mexopencv:error", "Null pointer error");
    for (mwIndex j=0; j<n; ++j) {
        const mwIndex start = jc[j], end = jc[j + 1] - 1;
        // (row,col) <= val.
        for (mwIndex i = start; i <= end; ++i)
            mat.ref<float>(ir[i], j) = static_cast<float>(pr[i]);
    }
    return mat;
}

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
    const mwIndex si[] = {i, j};
    return mxCalcSingleSubscript(p_, 2, si);
}

mwIndex MxArray::subs(const std::vector<mwIndex>& si) const
{
    return mxCalcSingleSubscript(p_, si.size(), (!si.empty() ? &si[0] : NULL));
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
