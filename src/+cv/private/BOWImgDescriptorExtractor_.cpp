/**
 * @file BOWImgDescriptorExtractor_.cpp
 * @brief mex interface for cv::BOWImgDescriptorExtractor
 * @ingroup features2d
 * @author Kota Yamaguchi
 * @author Amro
 * @date 2012, 2015
 */
#include "mexopencv.hpp"
#include "mexopencv_features2d.hpp"
using namespace std;
using namespace cv;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<BOWImgDescriptorExtractor> > obj_;
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
    nargchk(nrhs>=2 && nlhs<=3);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());

    // Constructor is called. Create a new object from argument
    if (method == "new") {
        nargchk(nrhs==4 && nlhs<=1);
        // extractor
        Ptr<DescriptorExtractor> extractor;
        if (rhs[2].isChar())
            extractor = createDescriptorExtractor(
                rhs[2].toString(), rhs.end(), rhs.end());
        else if (rhs[2].isCell() && rhs[2].numel() >= 2) {
            vector<MxArray> args(rhs[2].toVector<MxArray>());
            extractor = createDescriptorExtractor(
                args[0].toString(), args.begin() + 1, args.end());
        }
        else
            mexErrMsgIdAndTxt("mexopencv:error", "Invalid arguments");
        // matcher
        Ptr<DescriptorMatcher> matcher;
        if (rhs[3].isChar())
            matcher = createDescriptorMatcher(
                rhs[3].toString(), rhs.end(), rhs.end());
        else if (rhs[3].isCell() && rhs[3].numel() >= 2) {
            vector<MxArray> args(rhs[3].toVector<MxArray>());
            matcher = createDescriptorMatcher(
                args[0].toString(), args.begin() + 1, args.end());
        }
        else
            mexErrMsgIdAndTxt("mexopencv:error", "Invalid arguments");
        obj_[++last_id] = makePtr<BOWImgDescriptorExtractor>(
            extractor, matcher);
        plhs[0] = MxArray(last_id);
        return;
    }

    // Big operation switch
    Ptr<BOWImgDescriptorExtractor> obj = obj_[id];
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
    }
    else if (method == "descriptorSize") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->descriptorSize());
    }
    else if (method == "descriptorType") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(ClassNameInvMap[obj->descriptorType()]);
    }
    else if (method == "compute") {
        nargchk(nrhs==4 && nlhs<=3);
        Mat image(rhs[2].toMat(CV_8U)),
            imgDescriptor, descriptors;
        vector<KeyPoint> keypoints(rhs[3].toVector<KeyPoint>());
        vector<vector<int> > pointIdxsOfClusters;
        obj->compute(image, keypoints, imgDescriptor,
            (nlhs>1 ? &pointIdxsOfClusters : NULL),
            (nlhs>2 ? &descriptors : NULL));
        plhs[0] = MxArray(imgDescriptor);
        if (nrhs>1)
            plhs[1] = MxArray(pointIdxsOfClusters);
        if (nrhs>2)
            plhs[2] = MxArray(descriptors);
    }
    else if (method == "compute1") {
        nargchk(nrhs==3 && nlhs<=2);
        Mat keypointDescriptors(rhs[2].toMat(rhs[2].isUint8() ? CV_8U : CV_32F)),
            imgDescriptor;
        vector<vector<int> > pointIdxsOfClusters;
        obj->compute(keypointDescriptors, imgDescriptor,
            (nlhs>1 ? &pointIdxsOfClusters : NULL));
        plhs[0] = MxArray(imgDescriptor);
        if (nrhs>1)
            plhs[1] = MxArray(pointIdxsOfClusters);
    }
    else if (method == "compute2") {
        nargchk(nrhs==4 && nlhs<=1);
        Mat image(rhs[2].toMat(CV_8U)),
            imgDescriptor;
        vector<KeyPoint> keypoints(rhs[3].toVector<KeyPoint>());
        obj->compute2(image, keypoints, imgDescriptor);
        plhs[0] = MxArray(imgDescriptor);
    }
    else if (method == "get") {
        nargchk(nrhs==3 && nlhs<=1);
        string prop(rhs[2].toString());
        if (prop == "Vocabulary")
            plhs[0] = MxArray(obj->getVocabulary());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        if (prop == "Vocabulary")
            obj->setVocabulary(rhs[3].toMat(rhs[3].isUint8() ? CV_8U : CV_32F));
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
