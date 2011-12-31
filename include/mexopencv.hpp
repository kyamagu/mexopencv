/**
 * @file mexopencv.hpp
 * @brief MxArray and global constant definitions
 * @author Kota Yamaguchi
 * @date 2011
 */
#ifndef __MEXOPENCV_HPP__
#define __MEXOPENCV_HPP__

#include "MxArray.hpp"

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

/** KernelType map for option processing
 */
const ConstMap<std::string,int> KernelType = ConstMap<std::string,int>
	("General",		cv::KERNEL_GENERAL)
	("Symmetrical",	cv::KERNEL_SYMMETRICAL)
	("Asymmetrical",cv::KERNEL_ASYMMETRICAL)
	("Smooth",		cv::KERNEL_SMOOTH)
	("Integer",		cv::KERNEL_INTEGER);

/** Type map for morphological operation for option processing
 */
const ConstMap<std::string,int> MorphType = ConstMap<std::string,int>
	("Erode",	cv::MORPH_ERODE)
	("Dilate",	cv::MORPH_DILATE)
	("Open",	cv::MORPH_OPEN)
	("Close",	cv::MORPH_CLOSE)
	("Gradient",cv::MORPH_GRADIENT)
	("Tophat",	cv::MORPH_TOPHAT)
	("Blackhat",cv::MORPH_BLACKHAT);

/** Shape map for morphological operation for option processing
 */
const ConstMap<std::string,int> MorphShape = ConstMap<std::string,int>
	("Rect",	cv::MORPH_RECT)
	("Cross",	cv::MORPH_CROSS)
	("Ellipse",	cv::MORPH_ELLIPSE);

/** Interpolation type map for option processing
 */
const ConstMap<std::string,int> InterType = ConstMap<std::string,int>
	("Nearest",	cv::INTER_NEAREST) 	//!< nearest neighbor interpolation
	("Linear",	cv::INTER_LINEAR) 	//!< bilinear interpolation
	("Cubic",	cv::INTER_CUBIC) 	//!< bicubic interpolation
	("Area",	cv::INTER_AREA) 	//!< area-based (or super) interpolation
	("Lanczos4",cv::INTER_LANCZOS4) //!< Lanczos interpolation over 8x8 neighborhood
	("Max",		cv::INTER_MAX)
	("WarpInverseMap",	cv::WARP_INVERSE_MAP);

/** Thresholding type map for option processing
 */
const ConstMap<std::string,int> ThreshType = ConstMap<std::string,int>
	("Binary",		cv::THRESH_BINARY)
	("BinaryInv",	cv::THRESH_BINARY_INV)
	("Trunc",		cv::THRESH_TRUNC)
	("ToZero",		cv::THRESH_TOZERO)
	("ToZeroInv",	cv::THRESH_TOZERO_INV)
	("Mask",		cv::THRESH_MASK)
    ("Otsu",		cv::THRESH_OTSU);

/** Adaptive thresholding type map for option processing
 */
const ConstMap<std::string,int> AdaptiveThreshType = ConstMap<std::string,int>
	("Mean",	cv::ADAPTIVE_THRESH_MEAN_C)
	("Gaussian",cv::ADAPTIVE_THRESH_GAUSSIAN_C);

/** GrabCut algorithm types for option processing
 */
const ConstMap<std::string,int> GrabCutType = ConstMap<std::string,int>
	("Rect",cv::GC_INIT_WITH_RECT)
	("Mask",cv::GC_INIT_WITH_MASK)
	("Eval",cv::GC_EVAL);

/** Inpainting algorithm types for option processing
 */
const ConstMap<std::string,int> InpaintType = ConstMap<std::string,int>
	("NS",		cv::INPAINT_NS)
	("Telea",	cv::INPAINT_TELEA);

/** Color conversion types for option processing
 */
#if CV_MINOR_VERSION >= 3
const ConstMap<std::string,int> ColorConv = ConstMap<std::string,int>
	("BGR2BGRA",		cv::COLOR_BGR2BGRA)
	("RGB2RGBA",		cv::COLOR_RGB2RGBA)
	("BGRA2BGR",		cv::COLOR_BGRA2BGR)
	("RGBA2RGB",		cv::COLOR_RGBA2RGB)
	("BGR2RGBA",		cv::COLOR_BGR2RGBA)
	("RGB2BGRA",		cv::COLOR_RGB2BGRA)
	("RGBA2BGR",		cv::COLOR_RGBA2BGR)
	("BGRA2RGB",		cv::COLOR_BGRA2RGB)
	("BGR2RGB",			cv::COLOR_BGR2RGB)
	("RGB2BGR",			cv::COLOR_RGB2BGR)
	("BGRA2RGBA",		cv::COLOR_BGRA2RGBA)
	("RGBA2BGRA",		cv::COLOR_RGBA2BGRA)
	("BGR2GRAY",		cv::COLOR_BGR2GRAY)
	("RGB2GRAY",		cv::COLOR_RGB2GRAY)
	("GRAY2BGR",		cv::COLOR_GRAY2BGR)
	("GRAY2RGB",		cv::COLOR_GRAY2RGB)
	("GRAY2BGRA",		cv::COLOR_GRAY2BGRA)
	("GRAY2RGBA",		cv::COLOR_GRAY2RGBA)
	("BGRA2GRAY",		cv::COLOR_BGRA2GRAY)
	("RGBA2GRAY",		cv::COLOR_RGBA2GRAY)
	("BGR2BGR565",		cv::COLOR_BGR2BGR565)
	("RGB2BGR565",		cv::COLOR_RGB2BGR565)
	("BGR5652BGR",		cv::COLOR_BGR5652BGR)
	("BGR5652RGB",		cv::COLOR_BGR5652RGB)
	("BGRA2BGR565",		cv::COLOR_BGRA2BGR565)
	("RGBA2BGR565",		cv::COLOR_RGBA2BGR565)
	("BGR5652BGRA",		cv::COLOR_BGR5652BGRA)
	("BGR5652RGBA",		cv::COLOR_BGR5652RGBA)
	("GRAY2BGR565",		cv::COLOR_GRAY2BGR565)
	("BGR5652GRAY",		cv::COLOR_BGR5652GRAY)
	("BGR2BGR555",		cv::COLOR_BGR2BGR555)
	("RGB2BGR555",		cv::COLOR_RGB2BGR555)
	("BGR5552BGR",		cv::COLOR_BGR5552BGR)
	("BGR5552RGB",		cv::COLOR_BGR5552RGB)
	("BGRA2BGR555",		cv::COLOR_BGRA2BGR555)
	("RGBA2BGR555",		cv::COLOR_RGBA2BGR555)
	("BGR5552BGRA",		cv::COLOR_BGR5552BGRA)
	("BGR5552RGBA",		cv::COLOR_BGR5552RGBA)
	("GRAY2BGR555",		cv::COLOR_GRAY2BGR555)
	("BGR5552GRAY",		cv::COLOR_BGR5552GRAY)
	("BGR2XYZ",			cv::COLOR_BGR2XYZ)
	("RGB2XYZ",			cv::COLOR_RGB2XYZ)
	("XYZ2BGR",			cv::COLOR_XYZ2BGR)
	("XYZ2RGB",			cv::COLOR_XYZ2RGB)
	("BGR2YCrCb",		cv::COLOR_BGR2YCrCb)
	("RGB2YCrCb",		cv::COLOR_RGB2YCrCb)
	("YCrCb2BGR",		cv::COLOR_YCrCb2BGR)
	("YCrCb2RGB",		cv::COLOR_YCrCb2RGB)
	("BGR2HSV",			cv::COLOR_BGR2HSV)
	("RGB2HSV",			cv::COLOR_RGB2HSV)
	("BGR2Lab",			cv::COLOR_BGR2Lab)
	("RGB2Lab",			cv::COLOR_RGB2Lab)
	("BayerBG2BGR",		cv::COLOR_BayerBG2BGR)
	("BayerGB2BGR",		cv::COLOR_BayerGB2BGR)
	("BayerRG2BGR",		cv::COLOR_BayerRG2BGR)
	("BayerGR2BGR",		cv::COLOR_BayerGR2BGR)
	("BayerBG2RGB",		cv::COLOR_BayerBG2RGB)
	("BayerGB2RGB",		cv::COLOR_BayerGB2RGB)
	("BayerRG2RGB",		cv::COLOR_BayerRG2RGB)
	("BayerGR2RGB",		cv::COLOR_BayerGR2RGB)
	("BGR2Luv",			cv::COLOR_BGR2Luv)
	("RGB2Luv",			cv::COLOR_RGB2Luv)
	("BGR2HLS",			cv::COLOR_BGR2HLS)
	("RGB2HLS",			cv::COLOR_RGB2HLS)
	("HSV2BGR",			cv::COLOR_HSV2BGR)
	("HSV2RGB",			cv::COLOR_HSV2RGB)
	("Lab2BGR",			cv::COLOR_Lab2BGR)
	("Lab2RGB",			cv::COLOR_Lab2RGB)
	("Luv2BGR",			cv::COLOR_Luv2BGR)
	("Luv2RGB",			cv::COLOR_Luv2RGB)
	("HLS2BGR",			cv::COLOR_HLS2BGR)
	("HLS2RGB",			cv::COLOR_HLS2RGB)
	("BayerBG2BGR_VNG", cv::COLOR_BayerBG2BGR_VNG)
	("BayerGB2BGR_VNG", cv::COLOR_BayerGB2BGR_VNG)
	("BayerRG2BGR_VNG", cv::COLOR_BayerRG2BGR_VNG)
	("BayerGR2BGR_VNG", cv::COLOR_BayerGR2BGR_VNG)
	("BayerBG2RGB_VNG", cv::COLOR_BayerBG2RGB_VNG)
	("BayerGB2RGB_VNG", cv::COLOR_BayerGB2RGB_VNG)
	("BayerRG2RGB_VNG", cv::COLOR_BayerRG2RGB_VNG)
	("BayerGR2RGB_VNG", cv::COLOR_BayerGR2RGB_VNG)
	("BGR2HSV_FULL",	cv::COLOR_BGR2HSV_FULL)
	("RGB2HSV_FULL",	cv::COLOR_RGB2HSV_FULL)
	("BGR2HLS_FULL",	cv::COLOR_BGR2HLS_FULL)
	("RGB2HLS_FULL",	cv::COLOR_RGB2HLS_FULL)
	("HSV2BGR_FULL",	cv::COLOR_HSV2BGR_FULL)
	("HSV2RGB_FULL",	cv::COLOR_HSV2RGB_FULL)
	("HLS2BGR_FULL",	cv::COLOR_HLS2BGR_FULL)
	("HLS2RGB_FULL",	cv::COLOR_HLS2RGB_FULL)
	("LBGR2Lab",		cv::COLOR_LBGR2Lab)
	("LRGB2Lab",		cv::COLOR_LRGB2Lab)
	("LBGR2Luv",		cv::COLOR_LBGR2Luv)
	("LRGB2Luv",		cv::COLOR_LRGB2Luv)
	("Lab2LBGR",		cv::COLOR_Lab2LBGR)
	("Lab2LRGB",		cv::COLOR_Lab2LRGB)
	("Luv2LBGR",		cv::COLOR_Luv2LBGR)
	("Luv2LRGB",		cv::COLOR_Luv2LRGB)
	("BGR2YUV",			cv::COLOR_BGR2YUV)
	("RGB2YUV",			cv::COLOR_RGB2YUV)
	("YUV2BGR",			cv::COLOR_YUV2BGR)
	("YUV2RGB",			cv::COLOR_YUV2RGB)
	("BayerBG2GRAY",	cv::COLOR_BayerBG2GRAY)
	("BayerGB2GRAY",	cv::COLOR_BayerGB2GRAY)
	("BayerRG2GRAY",	cv::COLOR_BayerRG2GRAY)
	("BayerGR2GRAY",	cv::COLOR_BayerGR2GRAY)
	("YUV420i2RGB",		cv::COLOR_YUV420i2RGB)
	("YUV420i2BGR",		cv::COLOR_YUV420i2BGR)
	("YUV420sp2RGB",	cv::COLOR_YUV420sp2RGB)
	("YUV420sp2BGR",	cv::COLOR_YUV420sp2BGR)
	("COLORCVT_MAX",	cv::COLOR_COLORCVT_MAX);
#else
const ConstMap<std::string,int> ColorConv = ConstMap<std::string,int>
	("BGR2BGRA",		cv::CV_BGR2BGRA)
	("RGB2RGBA",		cv::CV_RGB2RGBA)
	("BGRA2BGR",		cv::CV_BGRA2BGR)
	("RGBA2RGB",		cv::CV_RGBA2RGB)
	("BGR2RGBA",		cv::CV_BGR2RGBA)
	("RGB2BGRA",		cv::CV_RGB2BGRA)
	("RGBA2BGR",		cv::CV_RGBA2BGR)
	("BGRA2RGB",		cv::CV_BGRA2RGB)
	("BGR2RGB",			cv::CV_BGR2RGB)
	("RGB2BGR",			cv::CV_RGB2BGR)
	("BGRA2RGBA",		cv::CV_BGRA2RGBA)
	("RGBA2BGRA",		cv::CV_RGBA2BGRA)
	("BGR2GRAY",		cv::CV_BGR2GRAY)
	("RGB2GRAY",		cv::CV_RGB2GRAY)
	("GRAY2BGR",		cv::CV_GRAY2BGR)
	("GRAY2RGB",		cv::CV_GRAY2RGB)
	("GRAY2BGRA",		cv::CV_GRAY2BGRA)
	("GRAY2RGBA",		cv::CV_GRAY2RGBA)
	("BGRA2GRAY",		cv::CV_BGRA2GRAY)
	("RGBA2GRAY",		cv::CV_RGBA2GRAY)
	("BGR2BGR565",		cv::CV_BGR2BGR565)
	("RGB2BGR565",		cv::CV_RGB2BGR565)
	("BGR5652BGR",		cv::CV_BGR5652BGR)
	("BGR5652RGB",		cv::CV_BGR5652RGB)
	("BGRA2BGR565",		cv::CV_BGRA2BGR565)
	("RGBA2BGR565",		cv::CV_RGBA2BGR565)
	("BGR5652BGRA",		cv::CV_BGR5652BGRA)
	("BGR5652RGBA",		cv::CV_BGR5652RGBA)
	("GRAY2BGR565",		cv::CV_GRAY2BGR565)
	("BGR5652GRAY",		cv::CV_BGR5652GRAY)
	("BGR2BGR555",		cv::CV_BGR2BGR555)
	("RGB2BGR555",		cv::CV_RGB2BGR555)
	("BGR5552BGR",		cv::CV_BGR5552BGR)
	("BGR5552RGB",		cv::CV_BGR5552RGB)
	("BGRA2BGR555",		cv::CV_BGRA2BGR555)
	("RGBA2BGR555",		cv::CV_RGBA2BGR555)
	("BGR5552BGRA",		cv::CV_BGR5552BGRA)
	("BGR5552RGBA",		cv::CV_BGR5552RGBA)
	("GRAY2BGR555",		cv::CV_GRAY2BGR555)
	("BGR5552GRAY",		cv::CV_BGR5552GRAY)
	("BGR2XYZ",			cv::CV_BGR2XYZ)
	("RGB2XYZ",			cv::CV_RGB2XYZ)
	("XYZ2BGR",			cv::CV_XYZ2BGR)
	("XYZ2RGB",			cv::CV_XYZ2RGB)
	("BGR2YCrCb",		cv::CV_BGR2YCrCb)
	("RGB2YCrCb",		cv::CV_RGB2YCrCb)
	("YCrCb2BGR",		cv::CV_YCrCb2BGR)
	("YCrCb2RGB",		cv::CV_YCrCb2RGB)
	("BGR2HSV",			cv::CV_BGR2HSV)
	("RGB2HSV",			cv::CV_RGB2HSV)
	("BGR2Lab",			cv::CV_BGR2Lab)
	("RGB2Lab",			cv::CV_RGB2Lab)
	("BayerBG2BGR",		cv::CV_BayerBG2BGR)
	("BayerGB2BGR",		cv::CV_BayerGB2BGR)
	("BayerRG2BGR",		cv::CV_BayerRG2BGR)
	("BayerGR2BGR",		cv::CV_BayerGR2BGR)
	("BayerBG2RGB",		cv::CV_BayerBG2RGB)
	("BayerGB2RGB",		cv::CV_BayerGB2RGB)
	("BayerRG2RGB",		cv::CV_BayerRG2RGB)
	("BayerGR2RGB",		cv::CV_BayerGR2RGB)
	("BGR2Luv",			cv::CV_BGR2Luv)
	("RGB2Luv",			cv::CV_RGB2Luv)
	("BGR2HLS",			cv::CV_BGR2HLS)
	("RGB2HLS",			cv::CV_RGB2HLS)
	("HSV2BGR",			cv::CV_HSV2BGR)
	("HSV2RGB",			cv::CV_HSV2RGB)
	("Lab2BGR",			cv::CV_Lab2BGR)
	("Lab2RGB",			cv::CV_Lab2RGB)
	("Luv2BGR",			cv::CV_Luv2BGR)
	("Luv2RGB",			cv::CV_Luv2RGB)
	("HLS2BGR",			cv::CV_HLS2BGR)
	("HLS2RGB",			cv::CV_HLS2RGB)
	("BayerBG2BGR_VNG", cv::CV_BayerBG2BGR_VNG)
	("BayerGB2BGR_VNG", cv::CV_BayerGB2BGR_VNG)
	("BayerRG2BGR_VNG", cv::CV_BayerRG2BGR_VNG)
	("BayerGR2BGR_VNG", cv::CV_BayerGR2BGR_VNG)
	("BayerBG2RGB_VNG", cv::CV_BayerBG2RGB_VNG)
	("BayerGB2RGB_VNG", cv::CV_BayerGB2RGB_VNG)
	("BayerRG2RGB_VNG", cv::CV_BayerRG2RGB_VNG)
	("BayerGR2RGB_VNG", cv::CV_BayerGR2RGB_VNG)
	("BGR2HSV_FULL",	cv::CV_BGR2HSV_FULL)
	("RGB2HSV_FULL",	cv::CV_RGB2HSV_FULL)
	("BGR2HLS_FULL",	cv::CV_BGR2HLS_FULL)
	("RGB2HLS_FULL",	cv::CV_RGB2HLS_FULL)
	("HSV2BGR_FULL",	cv::CV_HSV2BGR_FULL)
	("HSV2RGB_FULL",	cv::CV_HSV2RGB_FULL)
	("HLS2BGR_FULL",	cv::CV_HLS2BGR_FULL)
	("HLS2RGB_FULL",	cv::CV_HLS2RGB_FULL)
	("LBGR2Lab",		cv::CV_LBGR2Lab)
	("LRGB2Lab",		cv::CV_LRGB2Lab)
	("LBGR2Luv",		cv::CV_LBGR2Luv)
	("LRGB2Luv",		cv::CV_LRGB2Luv)
	("Lab2LBGR",		cv::CV_Lab2LBGR)
	("Lab2LRGB",		cv::CV_Lab2LRGB)
	("Luv2LBGR",		cv::CV_Luv2LBGR)
	("Luv2LRGB",		cv::CV_Luv2LRGB)
	("BGR2YUV",			cv::CV_BGR2YUV)
	("RGB2YUV",			cv::CV_RGB2YUV)
	("YUV2BGR",			cv::CV_YUV2BGR)
	("YUV2RGB",			cv::CV_YUV2RGB)
	("BayerBG2GRAY",	cv::CV_BayerBG2GRAY)
	("BayerGB2GRAY",	cv::CV_BayerGB2GRAY)
	("BayerRG2GRAY",	cv::CV_BayerRG2GRAY)
	("BayerGR2GRAY",	cv::CV_BayerGR2GRAY)
	("YUV420i2RGB",		cv::CV_YUV420i2RGB)
	("YUV420i2BGR",		cv::CV_YUV420i2BGR)
	("YUV420sp2RGB",	cv::CV_YUV420sp2RGB)
	("YUV420sp2BGR",	cv::CV_YUV420sp2BGR)
	("COLORCVT_MAX",	cv::CV_COLORCVT_MAX);
#endif

/** Mode of the contour retrieval algorithm for option processing
 */
const ConstMap<std::string,int> ContourMode = ConstMap<std::string,int>
	("External",cv::RETR_EXTERNAL)	//!< retrieve only the most external (top-level) contours
	("List",	cv::RETR_LIST)		//!< retrieve all the contours without any hierarchical information
	("CComp",	cv::RETR_CCOMP)		//!< retrieve the connected components (that can possibly be nested)
	("Tree",	cv::RETR_TREE); 	//!< retrieve all the contours and the whole hierarchy

/** Type of the contour approximation algorithm for option processing
 */
const ConstMap<std::string,int> ContourType = ConstMap<std::string,int>
	("None",		cv::CHAIN_APPROX_NONE)
	("Simple",		cv::CHAIN_APPROX_SIMPLE)
	("TC89_L1",		cv::CHAIN_APPROX_TC89_L1)
	("TC89_KCOS",	cv::CHAIN_APPROX_TC89_KCOS);

#endif