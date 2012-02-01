/**
 * @file mexopencv.hpp
 * @brief MxArray and global constant definitions
 * @author Kota Yamaguchi
 * @date 2011
 *
 * The header file for a Matlab mex function that uses OpenCV library.
 * The file includes definition of MxArray class that converts between mxArray
 * and a couple of std:: and cv:: data types including cv::Mat.
 */
#ifndef __MEXOPENCV_HPP__
#define __MEXOPENCV_HPP__

#include "MxArray.hpp"

// Global constants

/** BorderType map for option processing
 */
const ConstMap<std::string,int> BorderType = ConstMap<std::string,int>
	("Replicate",	cv::BORDER_REPLICATE)
	("Constant",	cv::BORDER_CONSTANT)
	("Reflect",		cv::BORDER_REFLECT)
	("Wrap",		cv::BORDER_WRAP)
	("Reflect101",	cv::BORDER_REFLECT_101)
	("Transparent",	cv::BORDER_TRANSPARENT)
	("Default",		cv::BORDER_DEFAULT)
	("Isolated",	cv::BORDER_ISOLATED);

/** Interpolation type map for option processing
 */
const ConstMap<std::string,int> InterType = ConstMap<std::string,int>
	("Nearest",	cv::INTER_NEAREST) 	//!< nearest neighbor interpolation
	("Linear",	cv::INTER_LINEAR) 	//!< bilinear interpolation
	("Cubic",	cv::INTER_CUBIC) 	//!< bicubic interpolation
	("Area",	cv::INTER_AREA) 	//!< area-based (or super) interpolation
	("Lanczos4",cv::INTER_LANCZOS4) //!< Lanczos interpolation over 8x8 neighborhood
	("Max",		cv::INTER_MAX);
	//("WarpInverseMap",	cv::WARP_INVERSE_MAP);

/** Thresholding type map for option processing
 */
const ConstMap<std::string,int> ThreshType = ConstMap<std::string,int>
	("Binary",		cv::THRESH_BINARY)
	("BinaryInv",	cv::THRESH_BINARY_INV)
	("Trunc",		cv::THRESH_TRUNC)
	("ToZero",		cv::THRESH_TOZERO)
	("ToZeroInv",	cv::THRESH_TOZERO_INV)
	("Mask",		cv::THRESH_MASK);
    //("Otsu",		cv::THRESH_OTSU);

/** Distance types for Distance Transform and M-estimators
 */
const ConstMap<std::string,int> DistType = ConstMap<std::string,int>
    ("User",	CV_DIST_USER)
    ("L1",		CV_DIST_L1)
    ("L2",		CV_DIST_L2)
    ("C",		CV_DIST_C)
    ("L12",		CV_DIST_L12)
    ("Fair",	CV_DIST_FAIR)
    ("Welsch",	CV_DIST_WELSCH)
    ("Huber",	CV_DIST_HUBER);

/** Convert MxArray to std::vector<MxArray>
 * @return std::vector<MxArray> value
 */
template <>
std::vector<MxArray> MxArray::toStdVector() const
{
	int n = numel();
	if (isCell()) {
		std::vector<MxArray> v(n,MxArray(static_cast<mxArray*>(NULL)));
		for (int i=0; i<n; ++i)
			v[i] = MxArray(mxGetCell(p_, i));
		return v;
	}
	else
		return std::vector<MxArray>(1,*this);
}

/** Convert MxArray to std::vector<std::string>
 * @return std::vector<std::string> value
 */
template <>
std::vector<std::string> MxArray::toStdVector() const
{
	int n = numel();
	if (isCell()) {
		std::vector<std::string> v(n);
		for (int i=0; i<n; ++i)
			v[i] = MxArray(mxGetCell(p_, i)).toString();
		return v;
	}
	else if (isChar())
		return std::vector<std::string>(1,this->toString());
	else
		mexErrMsgIdAndTxt("mexopencv:error","MxArray unable to convert to std::vector");
		
}

/** Convert MxArray to std::vector<cv::Mat>
 * @return std::vector<cv::Mat> value
 */
template <>
std::vector<cv::Mat> MxArray::toStdVector() const
{
	int n = numel();
	if (isCell()) {
		std::vector<cv::Mat> v(n);
		for (int i=0; i<n; ++i)
			v[i] = MxArray(mxGetCell(p_, i)).toMat();
		return v;
	}
	else if (isNumeric())
		return std::vector<cv::Mat>(1,this->toMat());
	else
		mexErrMsgIdAndTxt("mexopencv:error","MxArray unable to convert to std::vector");
}

/** Convert MxArray to std::vector<Point>
 * @return std::vector<Point> value
 */
template <>
std::vector<cv::Point> MxArray::toStdVector() const
{
	int n = numel();
	if (isCell()) {
		std::vector<cv::Point> v(n);
		for (int i=0; i<n; ++i)
			v[i] = MxArray(mxGetCell(p_, i)).toPoint();
		return v;
	}
	else if (isNumeric())
		return std::vector<cv::Point>(1,this->toPoint());
	else
		mexErrMsgIdAndTxt("mexopencv:error","MxArray unable to convert to std::vector");
}

/** Convert MxArray to std::vector<Point2f>
 * @return std::vector<Point2f> value
 */
template <>
std::vector<cv::Point2f> MxArray::toStdVector() const
{
	int n = numel();
	if (isCell()) {
		std::vector<cv::Point2f> v(n);
		for (int i=0; i<n; ++i)
			v[i] = MxArray(mxGetCell(p_, i)).toPoint_<float>();
		return v;
	}
	else if (isNumeric())
		return std::vector<cv::Point2f>(1,this->toPoint_<float>());
	else
		mexErrMsgIdAndTxt("mexopencv:error","MxArray unable to convert to std::vector");
}

/** Convert MxArray to std::vector<Point3f>
 * @return std::vector<Point3f> value
 */
template <>
std::vector<cv::Point3f> MxArray::toStdVector() const
{
	int n = numel();
	if (isCell()) {
		std::vector<cv::Point3f> v(n);
		for (int i=0; i<n; ++i)
			v[i] = MxArray(mxGetCell(p_, i)).toPoint3_<float>();
		return v;
	}
	else if (isNumeric())
		return std::vector<cv::Point3f>(1,this->toPoint3_<float>());
	else
		mexErrMsgIdAndTxt("mexopencv:error","MxArray unable to convert to std::vector");
}

/** Convert MxArray to std::vector<cv::Mat>
 * @return std::vector<cv::Mat> value
 */
template <>
std::vector<cv::KeyPoint> MxArray::toStdVector() const
{
	int n = numel();
	std::vector<cv::KeyPoint> v(n);
	if (isCell())
		for (int i=0; i<n; ++i)
			v[i] = MxArray(mxGetCell(p_, i)).toKeyPoint();
	else if (isStruct())
		for (int i=0; i<n; ++i)
			v[i] = toKeyPoint(i);
	else
		mexErrMsgIdAndTxt("mexopencv:error","MxArray unable to convert to std::vector");
	return v;
}

/** MxArray constructor from vector<T>. Make a cell array.
 * @param v vector of type T
 */
template <>
MxArray::MxArray(const std::vector<cv::KeyPoint>& v) :
	p_(mxCreateStructMatrix(1,v.size(),6,cv_keypoint_fields))
{
	if (!p_)
		mexErrMsgIdAndTxt("mexopencv:error","Allocation error");
	for (int i = 0; i < v.size(); ++i) {
		mxSetField(const_cast<mxArray*>(p_),i,"pt",      MxArray(v[i].pt));
		mxSetField(const_cast<mxArray*>(p_),i,"size",    MxArray(v[i].size));
		mxSetField(const_cast<mxArray*>(p_),i,"angle",   MxArray(v[i].angle));
		mxSetField(const_cast<mxArray*>(p_),i,"response",MxArray(v[i].response));
		mxSetField(const_cast<mxArray*>(p_),i,"octave",  MxArray(v[i].octave));
		mxSetField(const_cast<mxArray*>(p_),i,"class_id",MxArray(v[i].class_id));
	}
}

#if CV_MINOR_VERSION >= 2
/** Convert MxArray to std::vector<cv::DMatch>
 * @return std::vector<cv::DMatch> value
 */
template <>
std::vector<cv::DMatch> MxArray::toStdVector() const
{
	int n = numel();
	std::vector<cv::DMatch> v(n);
	if (isCell())
		for (int i=0; i<n; ++i)
			v[i] = MxArray(mxGetCell(p_, i)).toDMatch();
	else if (isStruct())
		for (int i=0; i<n; ++i)
			v[i] = toDMatch(i);
	else
		mexErrMsgIdAndTxt("mexopencv:error","MxArray unable to convert to std::vector");
	return v;
}

/** MxArray constructor from vector<T>. Make a cell array.
 * @param v vector of type T
 */
template <>
MxArray::MxArray(const std::vector<cv::DMatch>& v) :
	p_(mxCreateStructMatrix(1,v.size(),4,cv_dmatch_fields))
{
	if (!p_)
		mexErrMsgIdAndTxt("mexopencv:error","Allocation error");
	for (int i = 0; i < v.size(); ++i) {
		mxSetField(const_cast<mxArray*>(p_),i,"queryIdx", MxArray(v[i].queryIdx));
		mxSetField(const_cast<mxArray*>(p_),i,"trainIdx", MxArray(v[i].trainIdx));
		mxSetField(const_cast<mxArray*>(p_),i,"imgIdx",   MxArray(v[i].imgIdx));
		mxSetField(const_cast<mxArray*>(p_),i,"distance", MxArray(v[i].distance));
	}
}
#endif

#endif