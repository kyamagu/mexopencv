/**
 * @file ShapeContextDistanceExtractor_.cpp
 * @brief mex interface for cv::ShapeContextDistanceExtractor
 * @ingroup shape
 * @author Amro
 * @date 2015
 */
#include "mexopencv.hpp"
#include "mexopencv_shape.hpp"
#include "opencv2/shape.hpp"
using namespace std;
using namespace cv;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<ShapeContextDistanceExtractor> > obj_;
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
        obj_[++last_id] = create_ShapeContextDistanceExtractor(
            rhs.begin() + 2, rhs.end());
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }

    // Big operation switch
    Ptr<ShapeContextDistanceExtractor> obj = obj_[id];
    if (obj.empty())
        mexErrMsgIdAndTxt("mexopencv:error", "Object not found id=%d", id);
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
        mexUnlock();
    }
    else if (method == "clear") {
        nargchk(nrhs==2 && nlhs==0);
        obj->clear();
    }
    else if (method == "load") {
        nargchk(nrhs>=3 && (nrhs%2)!=0 && nlhs==0);
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
        /*
        obj_[id] = (loadFromString ?
            Algorithm::loadFromString<ShapeContextDistanceExtractor>(rhs[2].toString(), objname) :
            Algorithm::load<ShapeContextDistanceExtractor>(rhs[2].toString(), objname));
        */
        ///*
        // HACK: workaround for missing ShapeContextDistanceExtractor::create()
        FileStorage fs(rhs[2].toString(), FileStorage::READ +
            (loadFromString ? FileStorage::MEMORY : 0));
        if (!fs.isOpened())
            mexErrMsgIdAndTxt("mexopencv:error", "Failed to open file");
        FileNode fn(objname.empty() ? fs.getFirstTopLevelNode() : fs[objname]);
        if (fn.empty())
            mexErrMsgIdAndTxt("mexopencv:error", "Failed to get node");
        obj->read(fn);
        //*/
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
    else if (method == "computeDistance") {
        nargchk(nrhs==4 && nlhs<=1);
        float dist = 0;
        if (rhs[2].isNumeric() && rhs[3].isNumeric()) {
            // contours expected as 1xNx2
            Mat contour1(rhs[2].toMat(CV_32F).reshape(2,1)),
                contour2(rhs[3].toMat(CV_32F).reshape(2,1));
            dist = obj->computeDistance(contour1, contour2);
        }
        else if (rhs[2].isCell() && rhs[3].isCell()) {
            vector<Point2f> contour1(rhs[2].toVector<Point2f>()),
                            contour2(rhs[3].toVector<Point2f>());
            dist = obj->computeDistance(contour1, contour2);
        }
        else
            mexErrMsgIdAndTxt("mexopencv:error", "Invalid contour argument");
        plhs[0] = MxArray(dist);
    }
    else if (method == "setImages") {
        nargchk(nrhs==4 && nlhs==0);
        Mat image1(rhs[2].toMat(CV_8U)),
            image2(rhs[3].toMat(CV_8U));
        obj->setImages(image1, image2);
    }
    else if (method == "setCostExtractor") {
        nargchk(nrhs>=3 && nlhs==0);
        Ptr<HistogramCostExtractor> comparer = create_HistogramCostExtractor(
            rhs[2].toString(), rhs.begin() + 3, rhs.end());
        obj->setCostExtractor(comparer);
    }
    else if (method == "setTransformAlgorithm") {
        nargchk(nrhs>=3 && nlhs==0);
        Ptr<ShapeTransformer> transformer = create_ShapeTransformer(
            rhs[2].toString(), rhs.begin() + 3, rhs.end());
        obj->setTransformAlgorithm(transformer);
    }
    else if (method == "getImages") {
        nargchk(nrhs==2 && nlhs<=2);
        Mat image1, image2;
        obj->getImages(image1, image2);
        plhs[0] = MxArray(image1);
        if (nlhs > 1)
            plhs[1] = MxArray(image2);
    }
    else if (method == "getCostExtractor") {
        nargchk(nrhs==2 && nlhs<=1);
        Ptr<HistogramCostExtractor> comparer = obj->getCostExtractor();
        plhs[0] = toStruct(comparer);
    }
    else if (method == "getTransformAlgorithm") {
        nargchk(nrhs==2 && nlhs<=1);
        Ptr<ShapeTransformer> transformer = obj->getTransformAlgorithm();
        plhs[0] = toStruct(transformer);
    }
    else if (method == "get") {
        nargchk(nrhs==3 && nlhs<=1);
        string prop(rhs[2].toString());
        if (prop == "AngularBins")
            plhs[0] = MxArray(obj->getAngularBins());
        else if (prop == "RadialBins")
            plhs[0] = MxArray(obj->getRadialBins());
        else if (prop == "InnerRadius")
            plhs[0] = MxArray(obj->getInnerRadius());
        else if (prop == "OuterRadius")
            plhs[0] = MxArray(obj->getOuterRadius());
        else if (prop == "RotationInvariant")
            plhs[0] = MxArray(obj->getRotationInvariant());
        else if (prop == "ShapeContextWeight")
            plhs[0] = MxArray(obj->getShapeContextWeight());
        else if (prop == "ImageAppearanceWeight")
            plhs[0] = MxArray(obj->getImageAppearanceWeight());
        else if (prop == "BendingEnergyWeight")
            plhs[0] = MxArray(obj->getBendingEnergyWeight());
        else if (prop == "Iterations")
            plhs[0] = MxArray(obj->getIterations());
        else if (prop == "StdDev")
            plhs[0] = MxArray(obj->getStdDev());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        if (prop == "AngularBins")
            obj->setAngularBins(rhs[3].toInt());
        else if (prop == "RadialBins")
            obj->setRadialBins(rhs[3].toInt());
        else if (prop == "InnerRadius")
            obj->setInnerRadius(rhs[3].toFloat());
        else if (prop == "OuterRadius")
            obj->setOuterRadius(rhs[3].toFloat());
        else if (prop == "RotationInvariant")
            obj->setRotationInvariant(rhs[3].toBool());
        else if (prop == "ShapeContextWeight")
            obj->setShapeContextWeight(rhs[3].toFloat());
        else if (prop == "ImageAppearanceWeight")
            obj->setImageAppearanceWeight(rhs[3].toFloat());
        else if (prop == "BendingEnergyWeight")
            obj->setBendingEnergyWeight(rhs[3].toFloat());
        else if (prop == "Iterations")
            obj->setIterations(rhs[3].toInt());
        else if (prop == "StdDev")
            obj->setStdDev(rhs[3].toFloat());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
