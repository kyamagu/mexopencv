/**
 * @file TextDetectorCNN_.cpp
 * @brief mex interface for cv::text::TextDetectorCNN
 * @ingroup text
 * @author Amro
 * @date 2018
 */
#include "mexopencv.hpp"
#include "opencv2/text.hpp"
using namespace std;
using namespace cv;
using namespace cv::text;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<TextDetectorCNN> > obj_;
}

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
    nargchk(nrhs>=2 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());

    // constructor call
    if (method == "new") {
        nargchk(nrhs>=4 && (nrhs%2)==0 && nlhs<=1);
        vector<Size> detectionSizes(1, Size(300, 300));
        for (int i=4; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "DetectionSizes")
                detectionSizes = rhs[i+1].toVector<Size>();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        string modelArchFilename(rhs[2].toString()),
            modelWeightsFilename(rhs[3].toString());
        obj_[++last_id] = TextDetectorCNN::create(
            modelArchFilename, modelWeightsFilename, detectionSizes);
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }

    // Big operation switch
    Ptr<TextDetectorCNN> obj = obj_[id];
    if (obj.empty())
        mexErrMsgIdAndTxt("mexopencv:error", "Object not found id=%d", id);
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
        mexUnlock();
    }
    else if (method == "detect") {
        nargchk(nrhs==3 && nlhs<=2);
        Mat inputImage(rhs[2].toMat(CV_8U));
        vector<Rect> bbox;
        vector<float> confidence;
        obj->detect(inputImage, bbox, confidence);
        plhs[0] = MxArray(bbox);
        if (nlhs > 1)
            plhs[1] = MxArray(confidence);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
