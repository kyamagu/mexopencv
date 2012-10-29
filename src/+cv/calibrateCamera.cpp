/**
 * @file calibrateCamera.cpp
 * @brief mex interface for calibrateCamera
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

/// Conversion to vector<vector<Point_<T> > >
template <typename T>
vector<vector<Point_<T> > > MxArrayToVecVecPt(MxArray& arr)
{
    vector<MxArray> va = arr.toVector<MxArray>();
    vector<vector<Point_<T> > > vvp;
    vvp.reserve(va.size());
    for (vector<MxArray>::iterator it=va.begin(); it<va.end(); ++it)
    {
        vector<MxArray> v = (*it).toVector<MxArray>();
        vector<Point_<T> > vp;
        vp.reserve(v.size());
        for (vector<MxArray>::iterator jt=v.begin(); jt<v.end(); ++jt)
            vp.push_back((*jt).toPoint_<T>());
        vvp.push_back(vp);
    }
    return vvp;
}

/// Conversion to vector<vector<Point3_<T> > >
template <typename T>
vector<vector<Point3_<T> > > MxArrayToVecVecPt3(MxArray& arr)
{
    vector<MxArray> va = arr.toVector<MxArray>();
    vector<vector<Point3_<T> > > vvp;
    vvp.reserve(va.size());
    for (vector<MxArray>::iterator it=va.begin(); it<va.end(); ++it)
    {
        vector<MxArray> v = (*it).toVector<MxArray>();
        vector<Point3_<T> > vp;
        vp.reserve(v.size());
        for (vector<MxArray>::iterator jt=v.begin(); jt<v.end(); ++jt)
            vp.push_back((*jt).toPoint3_<T>());
        vvp.push_back(vp);
    }
    return vvp;
}


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
    if (nrhs<3 || ((nrhs%2)!=1) || nlhs>5)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    
    vector<vector<Point3f> > objectPoints = MxArrayToVecVecPt3<float>(rhs[0]);
    vector<vector<Point2f> > imagePoints = MxArrayToVecVecPt<float>(rhs[1]);
    Size imageSize = rhs[2].toSize();
    Mat cameraMatrix = Mat::eye(3,3,CV_32FC1);
    Mat distCoeffs;
    vector<Mat> rvecs;
    vector<Mat> tvecs;
    
    // Option processing
    int flags=0;
    for (int i=3; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="CameraMatrix")
            cameraMatrix = rhs[i+1].toMat(CV_32F);
        else if (key=="DistCoeffs")
            distCoeffs = rhs[i+1].toMat(CV_32F);
        else if (key=="UseIntrinsicGuess" && rhs[i+1].toBool())
            flags |= CV_CALIB_USE_INTRINSIC_GUESS;
        else if (key=="FixPrincipalPoint" && rhs[i+1].toBool())
            flags |= CV_CALIB_FIX_PRINCIPAL_POINT;
        else if (key=="FixAspectRatio" && rhs[i+1].toBool())
            flags |= CV_CALIB_FIX_ASPECT_RATIO;
        else if (key=="ZeroTangentDist" && rhs[i+1].toBool())
            flags |= CV_CALIB_ZERO_TANGENT_DIST;
        else if (key=="FixK1" && rhs[i+1].toBool())
            flags |= CV_CALIB_FIX_K1;
        else if (key=="FixK2" && rhs[i+1].toBool())
            flags |= CV_CALIB_FIX_K2;
        else if (key=="FixK3" && rhs[i+1].toBool())
            flags |= CV_CALIB_FIX_K3;
        else if (key=="FixK4" && rhs[i+1].toBool())
            flags |= CV_CALIB_FIX_K4;
        else if (key=="FixK5" && rhs[i+1].toBool())
            flags |= CV_CALIB_FIX_K5;
        else if (key=="FixK6" && rhs[i+1].toBool())
            flags |= CV_CALIB_FIX_K6;
        else if (key=="RationalModel" && rhs[i+1].toBool())
            flags |= CV_CALIB_RATIONAL_MODEL;
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    
    // Process
    double d = calibrateCamera(objectPoints, imagePoints, imageSize,
        cameraMatrix, distCoeffs, rvecs, tvecs, flags);
    plhs[0] = MxArray(cameraMatrix);
    if (nlhs>1)
        plhs[1] = MxArray(distCoeffs);
    if (nlhs>2)
        plhs[2] = MxArray(d);
    if (nlhs>3)
        plhs[3] = MxArray(rvecs);
    if (nlhs>4)
        plhs[4] = MxArray(tvecs);
}
