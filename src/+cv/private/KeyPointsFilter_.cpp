/**
 * @file KeyPointsFilter_.cpp
 * @brief mex interface for cv::KeyPointsFilter
 * @ingroup features2d
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
    nargchk(nrhs>=1 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    string method(rhs[0].toString());

    // Operation switch
    if (method == "removeDuplicated") {
        nargchk(nrhs==2 && nlhs<=1);
        vector<KeyPoint> keypoints(rhs[1].toVector<KeyPoint>());
        KeyPointsFilter::removeDuplicated(keypoints);
        plhs[0] = MxArray(keypoints);
    }
    else if (method == "retainBest") {
        nargchk(nrhs==3 && nlhs<=1);
        vector<KeyPoint> keypoints(rhs[1].toVector<KeyPoint>());
        int npoints = rhs[2].toInt();
        KeyPointsFilter::retainBest(keypoints, npoints);
        plhs[0] = MxArray(keypoints);
    }
    else if (method == "runByImageBorder") {
        nargchk(nrhs==4 && nlhs<=1);
        vector<KeyPoint> keypoints(rhs[1].toVector<KeyPoint>());
        Size imageSize(rhs[2].toSize());
        int borderSize = rhs[3].toInt();
        KeyPointsFilter::runByImageBorder(keypoints, imageSize, borderSize);
        plhs[0] = MxArray(keypoints);
    }
    else if (method == "runByKeypointSize") {
        nargchk((nrhs==3 || nrhs==4) && nlhs<=1);
        vector<KeyPoint> keypoints(rhs[1].toVector<KeyPoint>());
        float minSize = rhs[2].toFloat();
        float maxSize = (nrhs==4) ? rhs[3].toFloat() : FLT_MAX;
        KeyPointsFilter::runByKeypointSize(keypoints, minSize, maxSize);
        plhs[0] = MxArray(keypoints);
    }
    else if (method == "runByPixelsMask") {
        nargchk(nrhs==3 && nlhs<=1);
        vector<KeyPoint> keypoints(rhs[1].toVector<KeyPoint>());
        Mat mask(rhs[2].toMat(CV_8U));
        KeyPointsFilter::runByPixelsMask(keypoints, mask);
        plhs[0] = MxArray(keypoints);
    }
    else if (method == "convertToPoints") {
        nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);
        vector<int> keypointIndexes;
        for (int i=2; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "Indices")
                keypointIndexes = rhs[i+1].toVector<int>();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        vector<KeyPoint> keypoints(rhs[1].toVector<KeyPoint>());
        vector<Point2f> points2f;
        KeyPoint::convert(keypoints, points2f, keypointIndexes);
        plhs[0] = MxArray(points2f);
    }
    else if (method == "convertFromPoints") {
        nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);
        float size = 1.0f;
        float response = 1.0f;
        int octave = 1;
        int class_id = -1;
        for (int i=2; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "Size")
                size = rhs[i+1].toFloat();
            else if (key == "Response")
                response = rhs[i+1].toFloat();
            else if (key == "Octave")
                octave = rhs[i+1].toInt();
            else if (key == "ClassId")
                class_id = rhs[i+1].toInt();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        vector<Point2f> points2f(rhs[1].toVector<Point2f>());
        vector<KeyPoint> keypoints;
        KeyPoint::convert(points2f, keypoints,
            size, response, octave, class_id);
        plhs[0] = MxArray(keypoints);
    }
    else if (method == "overlap") {
        nargchk(nrhs==3 && nlhs<=1);
        KeyPoint kp1 = rhs[1].toKeyPoint(),
                 kp2 = rhs[2].toKeyPoint();
        float ovrl = KeyPoint::overlap(kp1, kp2);
        plhs[0] = MxArray(ovrl);
    }
    else if (method == "hash") {
        nargchk(nrhs==2 && nlhs<=1);
        KeyPoint kp = rhs[1].toKeyPoint();
        size_t val = kp.hash();
        //plhs[0] = MxArray(val);
        plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
        {
            uint64_t *data = reinterpret_cast<uint64_t*>(mxGetData(plhs[0]));
            data[0] = static_cast<uint64_t>(val);
        }
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
