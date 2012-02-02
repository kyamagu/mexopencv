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
		mexErrMsgIdAndTxt("mexopencv:error","MxArray is not cell");
	return MxArray(mxGetCell(p_,index));
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
		for (int i=0; i<n; ++i)
			v.push_back(MxArray(mxGetCell(p_, i)));
		return v;
	}
	else
		return std::vector<MxArray>(1,*this);
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
	return toVector(std::const_mem_fun_ref_t<std::string,MxArray>(&MxArray::toString));
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
	for (std::vector<MxArray>::iterator it=v.begin(); it<v.end(); ++it)
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
	return toVector(std::const_mem_fun_ref_t<cv::Point,MxArray>(&MxArray::toPoint));
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
	return toVector(std::const_mem_fun_ref_t<cv::Point2f,MxArray>(&MxArray::toPoint2f));
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
	return toVector(std::const_mem_fun_ref_t<cv::Point3f,MxArray>(&MxArray::toPoint3f));
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
		for (int i=0; i<n; ++i)
			v.push_back(at<MxArray>(i).toKeyPoint());
	else if (isStruct())
		for (int i=0; i<n; ++i)
			v.push_back(toKeyPoint(i));
	else
		mexErrMsgIdAndTxt("mexopencv:error","MxArray unable to convert to std::vector");
	return v;
}

#if CV_MINOR_VERSION >= 2
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
		for (int i=0; i<n; ++i)
			v.push_back(at<MxArray>(i).toDMatch());
	else if (isStruct())
		for (int i=0; i<n; ++i)
			v.push_back(toDMatch(i));
	else
		mexErrMsgIdAndTxt("mexopencv:error","MxArray unable to convert to std::vector");
	return v;
}
#endif

#endif