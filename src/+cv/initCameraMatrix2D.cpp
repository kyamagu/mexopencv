/**
 * @file initCameraMatrix2D.cpp
 * @brief mex interface for initCameraMatrix2D
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
    if (nrhs<3 || ((nrhs%2)!=1) || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    vector<vector<Point3f> > objectPoints = MxArrayToVecVecPt3<float>(rhs[0]);
    vector<vector<Point2f> > imagePoints = MxArrayToVecVecPt<float>(rhs[1]);
    Size imageSize = rhs[2].toSize();
    double aspectRatio=1;
    for (int i=3; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="AspectRatio")
            aspectRatio = rhs[i+1].toDouble();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    
    // Process
    Mat m = initCameraMatrix2D(objectPoints, imagePoints, imageSize, aspectRatio);
    plhs[0] = MxArray(m);
}
