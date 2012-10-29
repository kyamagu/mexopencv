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
    ("BGR2BGRA",        CV_BGR2BGRA)
    ("RGB2RGBA",        CV_RGB2RGBA)
    ("BGRA2BGR",        CV_BGRA2BGR)
    ("RGBA2RGB",        CV_RGBA2RGB)
    ("BGR2RGBA",        CV_BGR2RGBA)
    ("RGB2BGRA",        CV_RGB2BGRA)
    ("RGBA2BGR",        CV_RGBA2BGR)
    ("BGRA2RGB",        CV_BGRA2RGB)
    ("BGR2RGB",            CV_BGR2RGB)
    ("RGB2BGR",            CV_RGB2BGR)
    ("BGRA2RGBA",        CV_BGRA2RGBA)
    ("RGBA2BGRA",        CV_RGBA2BGRA)
    ("BGR2GRAY",        CV_BGR2GRAY)
    ("RGB2GRAY",        CV_RGB2GRAY)
    ("GRAY2BGR",        CV_GRAY2BGR)
    ("GRAY2RGB",        CV_GRAY2RGB)
    ("GRAY2BGRA",        CV_GRAY2BGRA)
    ("GRAY2RGBA",        CV_GRAY2RGBA)
    ("BGRA2GRAY",        CV_BGRA2GRAY)
    ("RGBA2GRAY",        CV_RGBA2GRAY)
    ("BGR2BGR565",        CV_BGR2BGR565)
    ("RGB2BGR565",        CV_RGB2BGR565)
    ("BGR5652BGR",        CV_BGR5652BGR)
    ("BGR5652RGB",        CV_BGR5652RGB)
    ("BGRA2BGR565",        CV_BGRA2BGR565)
    ("RGBA2BGR565",        CV_RGBA2BGR565)
    ("BGR5652BGRA",        CV_BGR5652BGRA)
    ("BGR5652RGBA",        CV_BGR5652RGBA)
    ("GRAY2BGR565",        CV_GRAY2BGR565)
    ("BGR5652GRAY",        CV_BGR5652GRAY)
    ("BGR2BGR555",        CV_BGR2BGR555)
    ("RGB2BGR555",        CV_RGB2BGR555)
    ("BGR5552BGR",        CV_BGR5552BGR)
    ("BGR5552RGB",        CV_BGR5552RGB)
    ("BGRA2BGR555",        CV_BGRA2BGR555)
    ("RGBA2BGR555",        CV_RGBA2BGR555)
    ("BGR5552BGRA",        CV_BGR5552BGRA)
    ("BGR5552RGBA",        CV_BGR5552RGBA)
    ("GRAY2BGR555",        CV_GRAY2BGR555)
    ("BGR5552GRAY",        CV_BGR5552GRAY)
    ("BGR2XYZ",            CV_BGR2XYZ)
    ("RGB2XYZ",            CV_RGB2XYZ)
    ("XYZ2BGR",            CV_XYZ2BGR)
    ("XYZ2RGB",            CV_XYZ2RGB)
    ("BGR2YCrCb",        CV_BGR2YCrCb)
    ("RGB2YCrCb",        CV_RGB2YCrCb)
    ("YCrCb2BGR",        CV_YCrCb2BGR)
    ("YCrCb2RGB",        CV_YCrCb2RGB)
    ("BGR2HSV",            CV_BGR2HSV)
    ("RGB2HSV",            CV_RGB2HSV)
    ("BGR2Lab",            CV_BGR2Lab)
    ("RGB2Lab",            CV_RGB2Lab)
    ("BayerBG2BGR",        CV_BayerBG2BGR)
    ("BayerGB2BGR",        CV_BayerGB2BGR)
    ("BayerRG2BGR",        CV_BayerRG2BGR)
    ("BayerGR2BGR",        CV_BayerGR2BGR)
    ("BayerBG2RGB",        CV_BayerBG2RGB)
    ("BayerGB2RGB",        CV_BayerGB2RGB)
    ("BayerRG2RGB",        CV_BayerRG2RGB)
    ("BayerGR2RGB",        CV_BayerGR2RGB)
    ("BGR2Luv",            CV_BGR2Luv)
    ("RGB2Luv",            CV_RGB2Luv)
    ("BGR2HLS",            CV_BGR2HLS)
    ("RGB2HLS",            CV_RGB2HLS)
    ("HSV2BGR",            CV_HSV2BGR)
    ("HSV2RGB",            CV_HSV2RGB)
    ("Lab2BGR",            CV_Lab2BGR)
    ("Lab2RGB",            CV_Lab2RGB)
    ("Luv2BGR",            CV_Luv2BGR)
    ("Luv2RGB",            CV_Luv2RGB)
    ("HLS2BGR",            CV_HLS2BGR)
    ("HLS2RGB",            CV_HLS2RGB)
    ("COLORCVT_MAX",    CV_COLORCVT_MAX);

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
