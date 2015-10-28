/**
 * @file DAISY_.cpp
 * @brief mex interface for cv::xfeatures2d::DAISY
 * @ingroup xfeatures2d
 * @author Amro
 * @date 2015
 */
#include <typeinfo>
#include "mexopencv.hpp"
#include "mexopencv_features2d.hpp"
#include "opencv2/xfeatures2d.hpp"
using namespace std;
using namespace cv;
using namespace cv::xfeatures2d;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<DAISY> > obj_;
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

    // Constructor is called. Create a new object from argument
    if (method == "new") {
        nargchk(nrhs>=2 && nlhs<=1);
        obj_[++last_id] = createDAISY(rhs.begin() + 2, rhs.end());
        plhs[0] = MxArray(last_id);
        return;
    }

    // Big operation switch
    Ptr<DAISY> obj = obj_[id];
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
    }
    else if (method == "typeid") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(string(typeid(*obj).name()));
    }
    else if (method == "clear") {
        nargchk(nrhs==2 && nlhs==0);
        obj->clear();
    }
    else if (method == "load") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs==0);
        string objname;
        bool loadFromString = false;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "ObjName")
                objname = rhs[i+1].toString();
            else if (key == "FromString")
                loadFromString = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        obj_[id] = (loadFromString ?
            Algorithm::loadFromString<DAISY>(rhs[2].toString(), objname) :
            Algorithm::load<DAISY>(rhs[2].toString(), objname));
    }
    else if (method == "save") {
        nargchk(nrhs==3 && nlhs==0);
        obj->save(rhs[2].toString());
    }
    else if (method == "empty") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->empty());
    }
    else if (method == "getDefaultName") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->getDefaultName());
    }
    else if (method == "defaultNorm") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(NormTypeInv[obj->defaultNorm()]);
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
        nargchk(nrhs==4 && nlhs<=2);
        if (rhs[2].isNumeric()) {  // first variant that accepts an image
            Mat image(rhs[2].toMat(rhs[2].isSingle() ? CV_32F : CV_8U)),
                descriptors;
            vector<KeyPoint> keypoints(rhs[3].toVector<KeyPoint>());
            obj->compute(image, keypoints, descriptors);
            plhs[0] = MxArray(descriptors);
            if (nlhs > 1)
                plhs[1] = MxArray(keypoints);
        }
        else if (rhs[2].isCell()) { // second variant that accepts an image set
            //vector<Mat> images(rhs[2].toVector<Mat>());
            vector<Mat> images, descriptors;
            {
                vector<MxArray> arr(rhs[2].toVector<MxArray>());
                images.reserve(arr.size());
                for (vector<MxArray>::const_iterator it = arr.begin(); it != arr.end(); ++it)
                    images.push_back(it->toMat(it->isSingle() ? CV_32F : CV_8U));
            }
            vector<vector<KeyPoint> > keypoints(rhs[3].toVector(
                const_mem_fun_ref_t<vector<KeyPoint>, MxArray>(
                &MxArray::toVector<KeyPoint>)));
            obj->compute(images, keypoints, descriptors);
            plhs[0] = MxArray(descriptors);
            if (nlhs > 1)
                plhs[1] = MxArray(keypoints);
        }
        else
            mexErrMsgIdAndTxt("mexopencv:error", "Invalid arguments");
    }
    else if (method == "compute_all") {
        nargchk((nrhs==3 || nrhs==4) && nlhs<=1);
        Mat image(rhs[2].toMat(rhs[2].isSingle() ? CV_32F : CV_8U)),
            descriptors;
        if (nrhs == 4) {
            Rect roi(rhs[3].toRect());
            obj->compute(image, roi, descriptors);
        }
        else
            obj->compute(image, descriptors);
        plhs[0] = MxArray(descriptors);
    }
    else if (method == "GetDescriptor") {
        nargchk(nrhs>=5 && (nrhs%2)==1 && nlhs<=2);
        double y = rhs[2].toDouble(),
               x = rhs[3].toDouble();
        int orientation = rhs[4].toInt();
        bool unnormalized = false;
        bool useHomography = false;
        Matx33d H;
        for (int i=5; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="Unnormalized")
                unnormalized = rhs[i+1].toBool();
            else if (key=="H") {
                H = rhs[i+1].toMatx<double,3,3>();
                useHomography = true;
            }
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        vector<float> descriptor(obj->descriptorSize());
        bool ret = true;
        if (unnormalized) {
            if (useHomography)
                ret = obj->GetUnnormalizedDescriptor(y, x, orientation,
                    &descriptor[0], H.val);
            else
                obj->GetUnnormalizedDescriptor(y, x, orientation,
                    &descriptor[0]);
        }
        else {
            if (useHomography)
                ret = obj->GetDescriptor(y, x, orientation,
                    &descriptor[0], H.val);
            else
                obj->GetDescriptor(y, x, orientation, &descriptor[0]);
        }
        plhs[0] = MxArray(descriptor);
        if (nlhs>1)
            plhs[1] = MxArray(ret);
    }
    //else if (method == "detect")
    //else if (method == "detectAndCompute")
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s",method.c_str());
}
