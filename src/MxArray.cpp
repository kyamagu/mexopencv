/**
 * @file MxArray.cpp
 * @brief Implemenation of data converters and utilities
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "MxArray.hpp"
using namespace cv;

// Local namescope
namespace {
/**
 * Translates data type definition used in OpenCV to that of Matlab
 * @param classid data type of matlab's mxArray. e.g., mxDOUBLE_CLASS
 * @return opencv's data type. e.g., CV_8U
 */
const ConstMap<mxClassID,int> DepthOf = ConstMap<mxClassID,int>
    (mxDOUBLE_CLASS,	CV_64F)
    (mxSINGLE_CLASS,	CV_32F)
    (mxINT8_CLASS,		CV_8S)
    (mxUINT8_CLASS,		CV_8U)
    (mxINT16_CLASS,		CV_16S)
    (mxUINT16_CLASS,	CV_16U)
    (mxINT32_CLASS,		CV_32S)
    (mxUINT32_CLASS,	CV_32S)
    (mxLOGICAL_CLASS,	CV_8U);

/**
 * Translates data type definition used in Matlab to that of OpenCV
 * @param depth data depth of opencv's Mat class. e.g., CV_32F
 * @return data type of matlab's mxArray. e.g., mxDOUBLE_CLASS
 */
const ConstMap<int,mxClassID> ClassIDOf = ConstMap<int,mxClassID>
    (CV_64F,	mxDOUBLE_CLASS)
    (CV_32F,	mxSINGLE_CLASS)
    (CV_8S,		mxINT8_CLASS)
    (CV_8U,		mxUINT8_CLASS)
    (CV_16S,	mxINT16_CLASS)
    (CV_16U,	mxUINT16_CLASS)
    (CV_32S,	mxINT32_CLASS);
}

/** Convert MxArray to scalar primitive type T
 */
template <typename T>
T MxArray::value() const
{
	if (numel()!=1)
		mexErrMsgIdAndTxt("mexopencv:error","MxArray is not a scalar value");
	if (!(isNumeric()||isChar()||isLogical()))
		mexErrMsgIdAndTxt("mexopencv:error","MxArray is not primitive type");
	return static_cast<T>(mxGetScalar(p_));
};


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
		mexErrMsgIdAndTxt("mexopencv:error","Allocation error");
}

/** MxArray constructor from int
 * @param i int value
 */
MxArray::MxArray(const int i) : p_(mxCreateDoubleScalar(static_cast<double>(i)))
{
	if (!p_)
		mexErrMsgIdAndTxt("mexopencv:error","Allocation error");
}

/** MxArray constructor from bool
 * @param b bool value
 */
MxArray::MxArray(const bool b) : p_(mxCreateLogicalScalar(b))
{
	if (!p_)
		mexErrMsgIdAndTxt("mexopencv:error","Allocation error");
}

/** MxArray constructor from std::string
 * @param s reference to a string value
 */
MxArray::MxArray(const std::string& s) : p_(mxCreateString(s.c_str()))
{
	if (!p_)
		mexErrMsgIdAndTxt("mexopencv:error","Allocation error");
}

/**
 * Convert cv::Mat to MxArray
 * @param mat cv::Mat object
 * @param classid classid of mxArray. e.g., mxDOUBLE_CLASS. When mxUNKNOWN_CLASS
 *                is specified, classid will be automatically determined from
 *                the type of cv::Mat. default: mxUNKNOWN_CLASS
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
	const cv::Mat& rm = (mat.dims==2 && transpose) ? cv::Mat(mat.t()) : mat;
	
	// Create a new mxArray
	int nchannels = rm.channels();
	const int* dims_ = rm.size;
	vector<mwSize> d(dims_,dims_+rm.dims);
	d.push_back(nchannels);
	classid = (classid == mxUNKNOWN_CLASS) ? ClassIDOf[rm.depth()] : classid;
	std::swap(d[0],d[1]);
	p_ = mxCreateNumericArray(d.size(),&d[0],classid,mxREAL);
	if (!p_)
		mexErrMsgIdAndTxt("mexopencv:error","Allocation error");
	
	// Copy each channel
	std::vector<cv::Mat> mv;
	cv::split(rm,mv);
	std::vector<mwSize> si(d.size(),0);      // subscript index
	int type = CV_MAKETYPE(DepthOf[classid],1); // destination type
	for (int i = 0; i < nchannels; ++i) {
		si[rm.dims] = i; // last dim is a channel index
		void *ptr = reinterpret_cast<void*>(
				reinterpret_cast<size_t>(mxGetData(p_))+
				mxGetElementSize(p_)*subs(si));
		cv::Mat m(rm.dims,dims_,type,ptr);
		mv[i].convertTo(m,type); // Write to mxArray through m
	}
}

namespace {
struct compareSparseMatNode_ {
	bool operator () (const SparseMat::Node* rhs, const SparseMat::Node* lhs)
	{
		if (rhs->idx[1] < lhs->idx[1]) // column index
			return true;
		if (rhs->idx[0] < lhs->idx[0]) // row index
			return true;
		return false;
	}
} compareSparseMatNode;
}

/**
 * Convert float cv::SparseMat to MxArray
 * @param mat cv::SparseMat object
 * @return MxArray object
 */
MxArray::MxArray(const cv::SparseMat& mat)
{
	if (mat.dims() != 2)
		mexErrMsgIdAndTxt("mexopencv:error","cv::Mat is not 2D");
	if (mat.type() != CV_32FC1)
		mexErrMsgIdAndTxt("mexopencv:error","cv::Mat is not float");
	
	// Create sparse array
	int m = mat.size(0), n = mat.size(1), nnz = mat.nzcount();
	p_ = mxCreateSparse(m, n, nnz, mxREAL);
	if (!p_)
		mexErrMsgIdAndTxt("mexopencv:error","Allocation error");
	mwIndex *ir = mxGetIr(p_);
	mwIndex *jc = mxGetJc(p_);
	if (ir==NULL || jc==NULL)
		mexErrMsgIdAndTxt("mexopencv:error","Unknown error");

	// Sort nodes before we put elems into mxArray
	vector<const SparseMat::Node*> nodes;
	nodes.reserve(nnz);
	for (SparseMatConstIterator it = mat.begin(); it != mat.end(); ++it)
		nodes.push_back(it.node());
	sort(nodes.begin(),nodes.end(),compareSparseMatNode);

	// Copy data
	double *pr = mxGetPr(p_);
	int i = 0;
	jc[0] = 0;
	for (vector<const SparseMat::Node*>::const_iterator it = nodes.begin();
		 it != nodes.end(); ++it)
	{
		mwIndex row = (*it)->idx[0], col = (*it)->idx[1];
		ir[i] = row;
		jc[col+1] = i+1;
		pr[i] = static_cast<double>(mat.value<float>(*it));
		++i;
	}
}

/**
 * Convert cv::KeyPoint to MxArray
 * @param mat cv::KeyPoint object
 * @return MxArray object
 */
MxArray::MxArray(const cv::KeyPoint& p) :
	p_(mxCreateStructMatrix(1,1,6,cv_keypoint_fields))
{
	if (!p_)
		mexErrMsgIdAndTxt("mexopencv:error","Allocation error");
	mxSetField(const_cast<mxArray*>(p_),0,"pt",      MxArray(p.pt));
	mxSetField(const_cast<mxArray*>(p_),0,"size",    MxArray(p.size));
	mxSetField(const_cast<mxArray*>(p_),0,"angle",   MxArray(p.angle));
	mxSetField(const_cast<mxArray*>(p_),0,"response",MxArray(p.response));
	mxSetField(const_cast<mxArray*>(p_),0,"octave",  MxArray(p.octave));
	mxSetField(const_cast<mxArray*>(p_),0,"class_id",MxArray(p.class_id));
}
const char *cv_keypoint_fields[6] = {"pt", "size", "angle", "response", "octave", "class_id"};

/**
 * Convert cv::KeyPoint to MxArray
 * @param mat cv::KeyPoint object
 * @return MxArray object
 */
MxArray::MxArray(const cv::DMatch& m) :
	p_(mxCreateStructMatrix(1,1,4,cv_keypoint_fields))
{
	if (!p_)
		mexErrMsgIdAndTxt("mexopencv:error","Allocation error");
	mxSetField(const_cast<mxArray*>(p_),0,"queryIdx", MxArray(m.queryIdx));
	mxSetField(const_cast<mxArray*>(p_),0,"trainIdx", MxArray(m.trainIdx));
	mxSetField(const_cast<mxArray*>(p_),0,"imgIdx",   MxArray(m.imgIdx));
	mxSetField(const_cast<mxArray*>(p_),0,"distance", MxArray(m.distance));
}
const char *cv_dmatch_fields[6] = {"queryIdx","trainIdx","imgIdx","distance"};

/**
 * Convert MxArray to cv::Mat
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
 * the cv::Mat. Also, if the resulting cv::Mat is 2D, the 1st and 2nd dimensions
 * of the MxArray are mapped to rows and columns of the cv::Mat unless transpose
 * flag is false. That is, when MxArray is 3D, (dim 1, dim 2, dim 3) are mapped
 * to (cols, rows, channels) of the cv::Mat by default, whereas if MxArray is
 * more than 4D, (dim 1, dim 2, ..., dim N-1, dim N) are mapped to (dim 2, dim
 * 1, ..., dim N-1, channels) of the cv::Mat, respectively.
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
	vector<int> d(dims(),dims()+ndims());
	int ndims = (d.size()>2) ? d.size()-1 : d.size();
	int nchannels = (d.size()>2) ? *(d.end()-1) : 1;
	depth = (depth==CV_USRTYPE1) ? DepthOf[classID()] : depth;
	std::swap(d[0],d[1]);
	cv::Mat mat(ndims,&d[0],CV_MAKETYPE(depth,nchannels));
	
	// Copy each channel
	std::vector<cv::Mat> mv(nchannels);
	std::vector<mwSize> si(d.size(),0); // subscript index
	int type = CV_MAKETYPE(DepthOf[classID()],1); // Source type
	for (int i = 0; i<nchannels; ++i) {
		si[d.size()-1] = i;
		void *pd = reinterpret_cast<void*>(
				reinterpret_cast<size_t>(mxGetData(p_))+
				mxGetElementSize(p_)*subs(si));
		cv::Mat m(ndims,&d[0],type,pd);
		m.convertTo(mv[i],CV_MAKETYPE(depth,1)); // Read from mxArray through m
	}
	cv::merge(mv,mat);
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
 * columns of the cv::Mat unless transpose flag is false. If the MxArray is more
 * than 3D, the 1st and 2nd dimensions of the MxArray are mapped to 2nd and 1st
 * dimensions of the cv::Mat. That is, when MxArray is 2D, (dim 1, dim 2) are
 * mapped to (cols, rows) of the cv::Mat by default, whereas if MxArray is
 * more than 3D, (dim 1, dim 2, dim 3, ..., dim N) are mapped to (dim 2, dim
 * 1, dim 3, ..., dim N) of the cv::Mat, respectively.
 *
 * Example:
 * @code
 * cv::Mat x(MxArray(prhs[0]).toMatND());
 * @endcode
 */
cv::Mat MxArray::toMatND(int depth, bool transpose) const
{
	// Create cv::Mat object
	std::vector<int> d(dims(),dims()+ndims());
	std::swap(d[0],d[1]);
	cv::Mat m(ndims(),&d[0],CV_MAKETYPE(DepthOf[classID()],1),mxGetData(p_));
	
	// Copy
	cv::Mat mat;
	depth = (depth==CV_USRTYPE1) ? CV_MAKETYPE(DepthOf[classID()],1) : depth;
	m.convertTo(mat,CV_MAKETYPE(depth,1));
	
	return (mat.dims==2 && transpose) ? cv::Mat(mat.t()) : mat;
}

/** Convert MxArray to scalar double
 * @return int value
 */
int MxArray::toInt() const { return value<int>(); }

/** Convert MxArray to scalar int
 * @return double value
 */
double MxArray::toDouble() const { return value<double>(); }

/** Convert MxArray to scalar int
 * @return double value
 */
bool MxArray::toBool() const { return value<bool>(); }

/** Convert MxArray to std::string
 * @return std::string value
 */
std::string MxArray::toString() const
{
	if (!isChar())
		mexErrMsgIdAndTxt("mexopencv:error","MxArray not of type char");
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
		mexErrMsgIdAndTxt("mexopencv:error","MxArray is not sparse");		
	mwIndex *ir = mxGetIr(p_);
	mwIndex *jc = mxGetJc(p_);
	if (ir==NULL || jc==NULL)
		mexErrMsgIdAndTxt("mexopencv:error","Unknown error");
	
	// Create cv::SparseMat
	int m = mxGetM(p_), n = mxGetN(p_);
	int dims[] = {m, n};
	SparseMat mat(2, dims, CV_32F);
	
	// Copy data
	double *pr = mxGetPr(p_);
	for (mwIndex j=0; j<n; ++j) {
		mwIndex start = jc[j], end = jc[j+1]-1;
		for (mwIndex i=start; i<=end; ++i)
			mat.ref<float>(ir[i],j) = static_cast<float>(pr[i]); // (row,col) <= val
	}
	return mat;
}

/** Convert MxArray to cv::KeyPoint
 * @return cv::KeyPoint
 */
cv::KeyPoint MxArray::toKeyPoint(mwIndex index) const
{
	if (!isStruct())
		mexErrMsgIdAndTxt("mexopencv:error","MxArray is not struct");
	if (index < 0 || numel() <= index)
		mexErrMsgIdAndTxt("mexopencv:error","Out of range in struct array");
	mxArray* pm;
	if (!(pm=mxGetField(p_,index,"pt")))
		mexErrMsgIdAndTxt("mexopencv:error","Struct incompatible to KeyPoint");
	Point2f _pt = MxArray(pm).toPoint_<float>();
	if (!(pm=mxGetField(p_,index,"size")))
		mexErrMsgIdAndTxt("mexopencv:error","Struct incompatible to KeyPoint");
	float _size = MxArray(pm).toDouble();
	float _angle = (pm=mxGetField(p_,index,"angle")) ?       MxArray(pm).toDouble() : -1;
	float _response = (pm=mxGetField(p_,index,"response")) ? MxArray(pm).toDouble() : 0;
	int _octave = (pm=mxGetField(p_,index,"octave")) ?       MxArray(pm).toInt() : 0;
	int _class_id = (pm=mxGetField(p_,index,"class_id")) ?   MxArray(pm).toInt() : -1;
	return cv::KeyPoint(_pt,_size,_angle,_response,_octave,_class_id);
}

/** Convert MxArray to cv::DMatch
 * @return cv::DMatch
 */
cv::DMatch MxArray::toDMatch(mwIndex index) const
{
	if (!isStruct())
		mexErrMsgIdAndTxt("mexopencv:error","MxArray is not struct");
	if (index < 0 || numel() <= index)
		mexErrMsgIdAndTxt("mexopencv:error","Out of range in struct array");
	mxArray* pm;
	cv::DMatch dmatch;
	if (pm=mxGetField(p_,index,"queryIdx"))
		dmatch.queryIdx = MxArray(pm).toInt();
	if (pm=mxGetField(p_,index,"trainIdx"))
		dmatch.trainIdx = MxArray(pm).toInt();
	if (pm=mxGetField(p_,index,"imgIdx"))
		dmatch.imgIdx = MxArray(pm).toInt();
	if (pm=mxGetField(p_,index,"distance"))
		dmatch.distance = MxArray(pm).toDouble();
	return dmatch;
}

/** Offset from first element to desired element
 * @return linear offset of the specified subscript index
 */
mwIndex MxArray::subs(mwIndex i, mwIndex j) const
{
	if (i < 0 || i >= rows() || j < 0 || j >= cols())
		mexErrMsgIdAndTxt("mexopencv:error","Subscript out of range");
	mwIndex s[] = {i,j};
	return mxCalcSingleSubscript(p_, 2, s);
}

/** Offset from first element to desired element
 * @return linear offset of the specified subscript index
 */
mwIndex MxArray::subs(std::vector<mwIndex>& si) const
{
	return mxCalcSingleSubscript(p_, si.size(), &si[0]);
}
