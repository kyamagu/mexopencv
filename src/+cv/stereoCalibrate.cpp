/**
 * @file stereoCalibrate.cpp
 * @brief mex interface for stereoCalibrate
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

/// Field names for struct
const char* _fieldnames[] = {"cameraMatrix1", "distCoeffs1", "cameraMatrix2",
    "distCoeffs2", "R", "T", "E", "F", "d"};
/// Create a struct
mxArray* valueStruct(const Mat& cameraMatrix1, const Mat& distCoeffs1,
    const Mat& cameraMatrix2, const Mat& distCoeffs2, const Mat& R,
    const Mat& T, const Mat& E, const Mat& F, const double& d)
{
    mxArray* p = mxCreateStructMatrix(1,1,9,_fieldnames);
    if (!p)
        mexErrMsgIdAndTxt("mexopencv:error","Allocation error");
    mxSetField(p,0,"cameraMatrix1",MxArray(cameraMatrix1));
    mxSetField(p,0,"distCoeffs1",MxArray(distCoeffs1));
    mxSetField(p,0,"cameraMatrix2",MxArray(cameraMatrix2));
    mxSetField(p,0,"distCoeffs2",MxArray(distCoeffs2));
    mxSetField(p,0,"R",MxArray(R));
    mxSetField(p,0,"T",MxArray(T));
    mxSetField(p,0,"E",MxArray(E));
    mxSetField(p,0,"F",MxArray(F));
    mxSetField(p,0,"d",MxArray(d));
    return p;
}

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
    if (nrhs<4 || ((nrhs%2)!=0) || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    
    vector<vector<Point3f> > objectPoints = MxArrayToVecVecPt3<float>(rhs[0]);
    vector<vector<Point2f> > imagePoints1 = MxArrayToVecVecPt<float>(rhs[1]);
    vector<vector<Point2f> > imagePoints2 = MxArrayToVecVecPt<float>(rhs[2]);
    Size imageSize = rhs[3].toSize();
    Mat cameraMatrix1 = Mat::eye(3,3,CV_32FC1), distCoeffs1;
    Mat cameraMatrix2 = Mat::eye(3,3,CV_32FC1), distCoeffs2;
    TermCriteria termCrit(TermCriteria::COUNT+TermCriteria::EPS, 30, 1e-6);
    bool fixIntrinsic=true;
    bool useIntrinsicGuess=false;
    bool fixPrincipalPoint=false;
    bool fixFocalLength=false;
    bool fixAspectRatio=false;
    bool sameFocalLength=false;
    bool zeroTangentDist=false;
    bool fixK1=false;
    bool fixK2=false;
    bool fixK3=false;
    bool fixK4=false;
    bool fixK5=false;
    bool fixK6=false;
    bool calibRationalModel=false;    
    // Option processing
    for (int i=4; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="CameraMatrix1")
            cameraMatrix1 = rhs[i+1].toMat(CV_32F);
        else if (key=="DistCoeffs1")
            distCoeffs1 = rhs[i+1].toMat(CV_32F);
        else if (key=="CameraMatrix2")
            cameraMatrix2 = rhs[i+1].toMat(CV_32F);
        else if (key=="DistCoeffs2")
            distCoeffs2 = rhs[i+1].toMat(CV_32F);
        else if (key=="TermCrit")
            termCrit = rhs[i+1].toTermCriteria();
        else if (key=="FixIntrinsic")
            fixIntrinsic = rhs[i+1].toBool();
        else if (key=="UseIntrinsicGuess")
            useIntrinsicGuess = rhs[i+1].toBool();
        else if (key=="FixPrincipalPoint")
            fixPrincipalPoint = rhs[i+1].toBool();
        else if (key=="FixFocalLength")
            fixFocalLength = rhs[i+1].toBool();
        else if (key=="FixAspectRatio")
            fixAspectRatio = rhs[i+1].toBool();
        else if (key=="SameFocalLength")
            sameFocalLength = rhs[i+1].toBool();
        else if (key=="ZeroTangentDist")
            zeroTangentDist = rhs[i+1].toBool();
        else if (key=="FixK1")
            fixK1 = rhs[i+1].toBool();
        else if (key=="FixK2")
            fixK2 = rhs[i+1].toBool();
        else if (key=="FixK3")
            fixK3 = rhs[i+1].toBool();
        else if (key=="FixK4")
            fixK4 = rhs[i+1].toBool();
        else if (key=="FixK5")
            fixK5 = rhs[i+1].toBool();
        else if (key=="FixK6")
            fixK6 = rhs[i+1].toBool();
        else if (key=="RationalModel")
            calibRationalModel = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    int flags = ((fixIntrinsic) ? CV_CALIB_FIX_INTRINSIC : 0) |
        ((useIntrinsicGuess) ? CV_CALIB_USE_INTRINSIC_GUESS : 0) |
        ((fixPrincipalPoint) ? CV_CALIB_FIX_PRINCIPAL_POINT : 0) |
        ((fixFocalLength) ? CV_CALIB_FIX_FOCAL_LENGTH : 0) |
        ((fixAspectRatio) ? CV_CALIB_FIX_ASPECT_RATIO : 0) |
        ((sameFocalLength) ? CV_CALIB_SAME_FOCAL_LENGTH : 0) |
        ((zeroTangentDist) ? CV_CALIB_ZERO_TANGENT_DIST : 0) |
        ((fixK1) ? CV_CALIB_FIX_K1 : 0) |
        ((fixK2) ? CV_CALIB_FIX_K2 : 0) |
        ((fixK3) ? CV_CALIB_FIX_K3 : 0) |
        ((fixK4) ? CV_CALIB_FIX_K4 : 0) |
        ((fixK5) ? CV_CALIB_FIX_K5 : 0) |
        ((fixK6) ? CV_CALIB_FIX_K6 : 0) |
        ((calibRationalModel) ? CV_CALIB_RATIONAL_MODEL : 0);
    
    // Process
    Mat R, T, E, F;
    double d = stereoCalibrate(objectPoints, imagePoints1, imagePoints2,
        cameraMatrix1, distCoeffs1, cameraMatrix2, distCoeffs2,
        imageSize, R, T, E, F, termCrit, flags);
    plhs[0] = valueStruct(cameraMatrix1, distCoeffs1, cameraMatrix2,
        distCoeffs2, R, T, E, F, d);
}
