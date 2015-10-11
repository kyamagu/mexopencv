/**
 * @file imreadmulti.cpp
 * @brief mex interface for cv::imreadmulti
 * @ingroup imgcodecs
 * @author Amro
 * @date 2015
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

/**
 * Main entry called from Matlab
 * @param nlhs number of left-hand-side arguments
 * @param plhs pointers to mxArrays in the left-hand-side
 * @param nrhs number of right-hand-side arguments
 * @param prhs pointers to mxArrays in the right-hand-side
 */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    // Check the number of arguments
    nargchk(nrhs>=1 && (nrhs%2)==1 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs + nrhs);

    // Option processing
    bool unchanged = false,
         anydepth = false,
         anycolor = true,
         grayscale = false,
         color = false,
         gdal = false;
    int flags0 = 0;
    bool override = false;
    bool flip = true;
    for (int i=1; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "Flags") {
            flags0 = rhs[i+1].toInt();
            override = true;
        }
        else if (key == "Unchanged")
            unchanged = rhs[i+1].toBool();
        else if (key == "AnyDepth")
            anydepth = rhs[i+1].toBool();
        else if (key == "AnyColor")
            anycolor = rhs[i+1].toBool();
        else if (key == "Grayscale") {
            grayscale = rhs[i+1].toBool();
            color = !grayscale;
            anycolor = false;
        }
        else if (key == "Color") {
            color = rhs[i+1].toBool();
            grayscale = !color;
            anycolor = false;
        }
        else if (key == "GDAL")
            gdal = rhs[i+1].toBool();
        else if (key == "FlipChannels")
            flip = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    int flags = 0;
    if (override) {
        // explicitly specified int flags
        flags = flags0;
    }
    else if (unchanged) {
        // depth and cn as is (as determined by decoder).
        // This is the only way to load alpha channel if present
        flags = cv::IMREAD_UNCHANGED;
    }
    else {
        // use GDAL as decoder
        flags |= (gdal ? IMREAD_LOAD_GDAL : 0);
        // depth as is, otherwise CV_8U
        flags |= (anydepth ? IMREAD_ANYDEPTH : 0);
        // channels as is (if gray then cn=1, else cn=3 [BGR])
        flags |= (anycolor ? IMREAD_ANYCOLOR :
            // otherwise explicitly either cn = 3 or cn = 1
            (color ? IMREAD_COLOR : IMREAD_GRAYSCALE));
    }

    // Process
    string filename(rhs[0].toString());
    vector<Mat> imgs;
    bool status = imreadmulti(filename, imgs, flags);
    if (!status)
        mexErrMsgIdAndTxt("mexopencv:error", "imreadmulti failed");
    for (vector<Mat>::iterator it = imgs.begin(); it != imgs.end(); ++it) {
        if ((*it).data == NULL)
            mexErrMsgIdAndTxt("mexopencv:error", "imreadmulti failed");
        if (flip && (it->channels() == 3 || it->channels() == 4)) {
            // OpenCV's default is BGR/BGRA while MATLAB's is RGB/RGBA
            cvtColor(*it, *it, (it->channels()==3 ?
                cv::COLOR_BGR2RGB : cv::COLOR_BGRA2RGBA));
        }
    }
    plhs[0] = MxArray(imgs);
}
