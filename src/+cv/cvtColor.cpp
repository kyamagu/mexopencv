/**
 * @file cvtColor.cpp
 * @brief mex interface for cvtColor
 * @author Kota Yamaguchi
 * @date 2012
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

/** Color conversion types for option processing
 */
const ConstMap<std::string,int> ColorConv = ConstMap<std::string,int>
    ("BGR2BGRA",        cv::COLOR_BGR2BGRA)
    ("RGB2RGBA",        cv::COLOR_RGB2RGBA)
    ("BGRA2BGR",        cv::COLOR_BGRA2BGR)
    ("RGBA2RGB",        cv::COLOR_RGBA2RGB)
    ("BGR2RGBA",        cv::COLOR_BGR2RGBA)
    ("RGB2BGRA",        cv::COLOR_RGB2BGRA)
    ("RGBA2BGR",        cv::COLOR_RGBA2BGR)
    ("BGRA2RGB",        cv::COLOR_BGRA2RGB)
    ("BGR2RGB",            cv::COLOR_BGR2RGB)
    ("RGB2BGR",            cv::COLOR_RGB2BGR)
    ("BGRA2RGBA",        cv::COLOR_BGRA2RGBA)
    ("RGBA2BGRA",        cv::COLOR_RGBA2BGRA)
    ("BGR2GRAY",        cv::COLOR_BGR2GRAY)
    ("RGB2GRAY",        cv::COLOR_RGB2GRAY)
    ("GRAY2BGR",        cv::COLOR_GRAY2BGR)
    ("GRAY2RGB",        cv::COLOR_GRAY2RGB)
    ("GRAY2BGRA",        cv::COLOR_GRAY2BGRA)
    ("GRAY2RGBA",        cv::COLOR_GRAY2RGBA)
    ("BGRA2GRAY",        cv::COLOR_BGRA2GRAY)
    ("RGBA2GRAY",        cv::COLOR_RGBA2GRAY)
    ("BGR2BGR565",        cv::COLOR_BGR2BGR565)
    ("RGB2BGR565",        cv::COLOR_RGB2BGR565)
    ("BGR5652BGR",        cv::COLOR_BGR5652BGR)
    ("BGR5652RGB",        cv::COLOR_BGR5652RGB)
    ("BGRA2BGR565",        cv::COLOR_BGRA2BGR565)
    ("RGBA2BGR565",        cv::COLOR_RGBA2BGR565)
    ("BGR5652BGRA",        cv::COLOR_BGR5652BGRA)
    ("BGR5652RGBA",        cv::COLOR_BGR5652RGBA)
    ("GRAY2BGR565",        cv::COLOR_GRAY2BGR565)
    ("BGR5652GRAY",        cv::COLOR_BGR5652GRAY)
    ("BGR2BGR555",        cv::COLOR_BGR2BGR555)
    ("RGB2BGR555",        cv::COLOR_RGB2BGR555)
    ("BGR5552BGR",        cv::COLOR_BGR5552BGR)
    ("BGR5552RGB",        cv::COLOR_BGR5552RGB)
    ("BGRA2BGR555",        cv::COLOR_BGRA2BGR555)
    ("RGBA2BGR555",        cv::COLOR_RGBA2BGR555)
    ("BGR5552BGRA",        cv::COLOR_BGR5552BGRA)
    ("BGR5552RGBA",        cv::COLOR_BGR5552RGBA)
    ("GRAY2BGR555",        cv::COLOR_GRAY2BGR555)
    ("BGR5552GRAY",        cv::COLOR_BGR5552GRAY)
    ("BGR2XYZ",            cv::COLOR_BGR2XYZ)
    ("RGB2XYZ",            cv::COLOR_RGB2XYZ)
    ("XYZ2BGR",            cv::COLOR_XYZ2BGR)
    ("XYZ2RGB",            cv::COLOR_XYZ2RGB)
    ("BGR2YCrCb",        cv::COLOR_BGR2YCrCb)
    ("RGB2YCrCb",        cv::COLOR_RGB2YCrCb)
    ("YCrCb2BGR",        cv::COLOR_YCrCb2BGR)
    ("YCrCb2RGB",        cv::COLOR_YCrCb2RGB)
    ("BGR2HSV",            cv::COLOR_BGR2HSV)
    ("RGB2HSV",            cv::COLOR_RGB2HSV)
    ("BGR2Lab",            cv::COLOR_BGR2Lab)
    ("RGB2Lab",            cv::COLOR_RGB2Lab)
    ("BayerBG2BGR",        cv::COLOR_BayerBG2BGR)
    ("BayerGB2BGR",        cv::COLOR_BayerGB2BGR)
    ("BayerRG2BGR",        cv::COLOR_BayerRG2BGR)
    ("BayerGR2BGR",        cv::COLOR_BayerGR2BGR)
    ("BayerBG2RGB",        cv::COLOR_BayerBG2RGB)
    ("BayerGB2RGB",        cv::COLOR_BayerGB2RGB)
    ("BayerRG2RGB",        cv::COLOR_BayerRG2RGB)
    ("BayerGR2RGB",        cv::COLOR_BayerGR2RGB)
    ("BGR2Luv",            cv::COLOR_BGR2Luv)
    ("RGB2Luv",            cv::COLOR_RGB2Luv)
    ("BGR2HLS",            cv::COLOR_BGR2HLS)
    ("RGB2HLS",            cv::COLOR_RGB2HLS)
    ("HSV2BGR",            cv::COLOR_HSV2BGR)
    ("HSV2RGB",            cv::COLOR_HSV2RGB)
    ("Lab2BGR",            cv::COLOR_Lab2BGR)
    ("Lab2RGB",            cv::COLOR_Lab2RGB)
    ("Luv2BGR",            cv::COLOR_Luv2BGR)
    ("Luv2RGB",            cv::COLOR_Luv2RGB)
    ("HLS2BGR",            cv::COLOR_HLS2BGR)
    ("HLS2RGB",            cv::COLOR_HLS2RGB)
    ("BayerBG2BGR_VNG", cv::COLOR_BayerBG2BGR_VNG)
    ("BayerGB2BGR_VNG", cv::COLOR_BayerGB2BGR_VNG)
    ("BayerRG2BGR_VNG", cv::COLOR_BayerRG2BGR_VNG)
    ("BayerGR2BGR_VNG", cv::COLOR_BayerGR2BGR_VNG)
    ("BayerBG2RGB_VNG", cv::COLOR_BayerBG2RGB_VNG)
    ("BayerGB2RGB_VNG", cv::COLOR_BayerGB2RGB_VNG)
    ("BayerRG2RGB_VNG", cv::COLOR_BayerRG2RGB_VNG)
    ("BayerGR2RGB_VNG", cv::COLOR_BayerGR2RGB_VNG)
    ("BGR2HSV_FULL",    cv::COLOR_BGR2HSV_FULL)
    ("RGB2HSV_FULL",    cv::COLOR_RGB2HSV_FULL)
    ("BGR2HLS_FULL",    cv::COLOR_BGR2HLS_FULL)
    ("RGB2HLS_FULL",    cv::COLOR_RGB2HLS_FULL)
    ("HSV2BGR_FULL",    cv::COLOR_HSV2BGR_FULL)
    ("HSV2RGB_FULL",    cv::COLOR_HSV2RGB_FULL)
    ("HLS2BGR_FULL",    cv::COLOR_HLS2BGR_FULL)
    ("HLS2RGB_FULL",    cv::COLOR_HLS2RGB_FULL)
    ("LBGR2Lab",        cv::COLOR_LBGR2Lab)
    ("LRGB2Lab",        cv::COLOR_LRGB2Lab)
    ("LBGR2Luv",        cv::COLOR_LBGR2Luv)
    ("LRGB2Luv",        cv::COLOR_LRGB2Luv)
    ("Lab2LBGR",        cv::COLOR_Lab2LBGR)
    ("Lab2LRGB",        cv::COLOR_Lab2LRGB)
    ("Luv2LBGR",        cv::COLOR_Luv2LBGR)
    ("Luv2LRGB",        cv::COLOR_Luv2LRGB)
    ("BGR2YUV",            cv::COLOR_BGR2YUV)
    ("RGB2YUV",            cv::COLOR_RGB2YUV)
    ("YUV2BGR",            cv::COLOR_YUV2BGR)
    ("YUV2RGB",            cv::COLOR_YUV2RGB)
    ("BayerBG2GRAY",    cv::COLOR_BayerBG2GRAY)
    ("BayerGB2GRAY",    cv::COLOR_BayerGB2GRAY)
    ("BayerRG2GRAY",    cv::COLOR_BayerRG2GRAY)
    ("BayerGR2GRAY",    cv::COLOR_BayerGR2GRAY)
    //YUV 4:2:0 formats family
    ("YUV2RGB_NV12", cv::COLOR_YUV2RGB_NV12)
    ("YUV2BGR_NV12", cv::COLOR_YUV2BGR_NV12)    
    ("YUV2RGB_NV21", cv::COLOR_YUV2RGB_NV21)
    ("YUV2BGR_NV21", cv::COLOR_YUV2BGR_NV21)
    ("YUV420sp2RGB", cv::COLOR_YUV420sp2RGB)
    ("YUV420sp2BGR", cv::COLOR_YUV420sp2BGR)

    ("YUV2RGBA_NV12", cv::COLOR_YUV2RGBA_NV12)
    ("YUV2BGRA_NV12", cv::COLOR_YUV2BGRA_NV12)
    ("YUV2RGBA_NV21", cv::COLOR_YUV2RGBA_NV21)
    ("YUV2BGRA_NV21", cv::COLOR_YUV2BGRA_NV21)
    ("YUV420sp2RGBA", cv::COLOR_YUV420sp2RGBA)
    ("YUV420sp2BGRA", cv::COLOR_YUV420sp2BGRA)
    
    ("YUV2RGB_YV12", cv::COLOR_YUV2RGB_YV12)
    ("YUV2BGR_YV12", cv::COLOR_YUV2BGR_YV12)
    ("YUV2RGB_IYUV", cv::COLOR_YUV2RGB_IYUV)
    ("YUV2BGR_IYUV", cv::COLOR_YUV2BGR_IYUV)
    ("YUV2RGB_I420", cv::COLOR_YUV2RGB_I420)
    ("YUV2BGR_I420", cv::COLOR_YUV2BGR_I420)
    ("YUV420p2RGB", cv::COLOR_YUV420p2RGB)
    ("YUV420p2BGR", cv::COLOR_YUV420p2BGR)
    
    ("YUV2RGBA_YV12", cv::COLOR_YUV2RGBA_YV12)
    ("YUV2BGRA_YV12", cv::COLOR_YUV2BGRA_YV12)
    ("YUV2RGBA_IYUV", cv::COLOR_YUV2RGBA_IYUV)
    ("YUV2BGRA_IYUV", cv::COLOR_YUV2BGRA_IYUV)
    ("YUV2RGBA_I420", cv::COLOR_YUV2RGBA_I420)
    ("YUV2BGRA_I420", cv::COLOR_YUV2BGRA_I420)
    ("YUV420p2RGBA", cv::COLOR_YUV420p2RGBA)
    ("YUV420p2BGRA", cv::COLOR_YUV420p2BGRA)
    
    ("YUV2GRAY_420", cv::COLOR_YUV2GRAY_420)
    ("YUV2GRAY_NV21", cv::COLOR_YUV2GRAY_NV21)
    ("YUV2GRAY_NV12", cv::COLOR_YUV2GRAY_NV12)
    ("YUV2GRAY_YV12", cv::COLOR_YUV2GRAY_YV12)
    ("YUV2GRAY_IYUV", cv::COLOR_YUV2GRAY_IYUV)
    ("YUV2GRAY_I420", cv::COLOR_YUV2GRAY_I420)
    ("YUV420sp2GRAY", cv::COLOR_YUV420sp2GRAY)
    ("YUV420p2GRAY", cv::COLOR_YUV420p2GRAY)
    
    //YUV 4:2:2 formats family
    ("YUV2RGB_UYVY", cv::COLOR_YUV2RGB_UYVY)
    ("YUV2BGR_UYVY", cv::COLOR_YUV2BGR_UYVY)
    //("YUV2RGB_VYUY",COLOR_YUV2RGB_VYUY)
    //("YUV2BGR_VYUY",COLOR_YUV2BGR_VYUY)
    ("YUV2RGB_Y422", cv::COLOR_YUV2RGB_Y422)
    ("YUV2BGR_Y422", cv::COLOR_YUV2BGR_Y422)
    ("YUV2RGB_UYNV", cv::COLOR_YUV2RGB_UYNV)
    ("YUV2BGR_UYNV", cv::COLOR_YUV2BGR_UYNV)
    
    ("YUV2RGBA_UYVY", cv::COLOR_YUV2RGBA_UYVY)
    ("YUV2BGRA_UYVY", cv::COLOR_YUV2BGRA_UYVY)
    //("YUV2RGBA_VYUY",COLOR_YUV2RGBA_VYUY)
    //("YUV2BGRA_VYUY",COLOR_YUV2BGRA_VYUY)
    ("YUV2RGBA_Y422", cv::COLOR_YUV2RGBA_Y422)
    ("YUV2BGRA_Y422", cv::COLOR_YUV2BGRA_Y422)
    ("YUV2RGBA_UYNV", cv::COLOR_YUV2RGBA_UYNV)
    ("YUV2BGRA_UYNV", cv::COLOR_YUV2BGRA_UYNV)
    
    ("YUV2RGB_YUY2", cv::COLOR_YUV2RGB_YUY2)
    ("YUV2BGR_YUY2", cv::COLOR_YUV2BGR_YUY2)
    ("YUV2RGB_YVYU", cv::COLOR_YUV2RGB_YVYU)
    ("YUV2BGR_YVYU", cv::COLOR_YUV2BGR_YVYU)
    ("YUV2RGB_YUYV", cv::COLOR_YUV2RGB_YUYV)
    ("YUV2BGR_YUYV", cv::COLOR_YUV2BGR_YUYV)
    ("YUV2RGB_YUNV", cv::COLOR_YUV2RGB_YUNV)
    ("YUV2BGR_YUNV", cv::COLOR_YUV2BGR_YUNV)
    
    ("YUV2RGBA_YUY2", cv::COLOR_YUV2RGBA_YUY2)
    ("YUV2BGRA_YUY2", cv::COLOR_YUV2BGRA_YUY2)
    ("YUV2RGBA_YVYU", cv::COLOR_YUV2RGBA_YVYU)
    ("YUV2BGRA_YVYU", cv::COLOR_YUV2BGRA_YVYU)
    ("YUV2RGBA_YUYV", cv::COLOR_YUV2RGBA_YUYV)
    ("YUV2BGRA_YUYV", cv::COLOR_YUV2BGRA_YUYV)
    ("YUV2RGBA_YUNV", cv::COLOR_YUV2RGBA_YUNV)
    ("YUV2BGRA_YUNV", cv::COLOR_YUV2BGRA_YUNV)
    
    ("YUV2GRAY_UYVY", cv::COLOR_YUV2GRAY_UYVY)
    ("YUV2GRAY_YUY2", cv::COLOR_YUV2GRAY_YUY2)
    //("YUV2GRAY_VYUY",COLOR_YUV2GRAY_VYUY)
    ("YUV2GRAY_Y422", cv::COLOR_YUV2GRAY_Y422)
    ("YUV2GRAY_UYNV", cv::COLOR_YUV2GRAY_UYNV)
    ("YUV2GRAY_YVYU", cv::COLOR_YUV2GRAY_YVYU)
    ("YUV2GRAY_YUYV", cv::COLOR_YUV2GRAY_YUYV)
    ("YUV2GRAY_YUNV", cv::COLOR_YUV2GRAY_YUNV)
    
    ("COLORCVT_MAX",COLOR_COLORCVT_MAX);

/**
 * Main entry called from Matlab
 * @param nlhs number of left-hand-side arguments
 * @param plhs pointers to mxArrays in the left-hand-side
 * @param nrhs number of right-hand-side arguments
 * @param prhs pointers to mxArrays in the right-hand-side
 */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    // Check the number of arguments
    if (nrhs<2 || ((nrhs%2)!=0) || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    
    // Option processing
    int dstCn = 0;
    for (int i=2; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="DstCn")
            dstCn = rhs[i+1].toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    
    // Process
    Mat src(rhs[0].toMat()), dst;
    int code = ColorConv[rhs[1].toString()];
    cvtColor(src, dst, code, dstCn);
    plhs[0] = MxArray(dst);
}
