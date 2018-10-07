/**
 * @file Stitcher_.cpp
 * @brief mex interface for cv::Stitcher
 * @ingroup stitching
 * @author Amro
 * @date 2016
 */
#include "mexopencv.hpp"
#include "mexopencv_stitching.hpp"
#include "opencv2/stitching.hpp"
using namespace std;
using namespace cv;
using namespace cv::detail;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<Stitcher> > obj_;

/// compositing resolution types
const ConstMap<string, int> ComposeResolMap = ConstMap<string, int>
    ("Orig", cv::Stitcher::ORIG_RESOL);

/// stitching mode types
const ConstMap<string, Stitcher::Mode> ModesMap = ConstMap<string, Stitcher::Mode>
    ("Panorama", cv::Stitcher::PANORAMA)
    ("Scans",    cv::Stitcher::SCANS);
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
        nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);
        Stitcher::Mode mode = cv::Stitcher::PANORAMA;
        bool try_use_gpu = false;
        for (int i=2; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "Mode")
                mode = ModesMap[rhs[i+1].toString()];
            else if (key == "TryUseGPU")
                try_use_gpu = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        obj_[++last_id] = Stitcher::create(mode, try_use_gpu);
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }

    // Big operation switch
    Ptr<Stitcher> obj = obj_[id];
    if (obj.empty())
        mexErrMsgIdAndTxt("mexopencv:error", "Object not found id=%d", id);
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
        mexUnlock();
    }
    else if (method == "stitch") {
        nargchk((nrhs==3 || nrhs==4) && nlhs<=2);
        vector<Mat> images(rhs[2].toVector<Mat>());
        Mat pano;
        Stitcher::Status status;
        if (nrhs == 4) {
            //vector<vector<Rect> > rois(rhs[3].toVector<vector<Rect>>());
            vector<vector<Rect> > rois(rhs[3].toVector(
                const_mem_fun_ref_t<vector<Rect>, MxArray>(
                    &MxArray::toVector<Rect>)));
            status = obj->stitch(images, rois, pano);
        }
        else
            status = obj->stitch(images, pano);
        if (nlhs > 1)
            plhs[1] = MxArray(StitcherStatusInvMap[status]);
        else if (status != cv::Stitcher::OK)
            mexErrMsgIdAndTxt("mexopencv:error",
                "Stitcher error: %s", StitcherStatusInvMap[status].c_str());
        plhs[0] = MxArray(pano);
    }
    else if (method == "estimateTransform") {
        nargchk((nrhs==3 || nrhs==4) && nlhs<=1);
        vector<Mat> images(rhs[2].toVector<Mat>());
        Mat pano;
        Stitcher::Status status;
        if (nrhs == 4) {
            //vector<vector<Rect> > rois(rhs[3].toVector<vector<Rect>>());
            vector<vector<Rect> > rois(rhs[3].toVector(
                const_mem_fun_ref_t<vector<Rect>, MxArray>(
                    &MxArray::toVector<Rect>)));
            status = obj->estimateTransform(images, rois);
        }
        else
            status = obj->estimateTransform(images);
        if (nlhs > 0)
            plhs[0] = MxArray(StitcherStatusInvMap[status]);
        else if (status != cv::Stitcher::OK)
            mexErrMsgIdAndTxt("mexopencv:error",
                "Stitcher error: %s", StitcherStatusInvMap[status].c_str());
    }
    else if (method == "composePanorama") {
        nargchk((nrhs==2 || nrhs==3) && nlhs<=2);
        Mat pano;
        Stitcher::Status status;
        if (nrhs == 3) {
            vector<Mat> images(rhs[2].toVector<Mat>());
            status = obj->composePanorama(images, pano);
        }
        else
            status = obj->composePanorama(pano);
        if (nlhs > 1)
            plhs[1] = MxArray(StitcherStatusInvMap[status]);
        else if (status != cv::Stitcher::OK)
            mexErrMsgIdAndTxt("mexopencv:error",
                "Stitcher error: %s", StitcherStatusInvMap[status].c_str());
        plhs[0] = MxArray(pano);
    }
    else if (method == "setFeaturesFinder") {
        nargchk(nrhs>=3 && nlhs==0);
        Ptr<FeaturesFinder> p = createFeaturesFinder(
            rhs[2].toString(), rhs.begin() + 3, rhs.end());
        obj->setFeaturesFinder(p);
    }
    else if (method == "setFeaturesMatcher") {
        nargchk(nrhs>=3 && nlhs==0);
        Ptr<FeaturesMatcher> p = createFeaturesMatcher(
            rhs[2].toString(), rhs.begin() + 3, rhs.end());
        obj->setFeaturesMatcher(p);
    }
    /*
    else if (method == "setEstimator") {
        nargchk(nrhs>=3 && nlhs==0);
        Ptr<Estimator> p = createEstimator(
            rhs[2].toString(), rhs.begin() + 3, rhs.end());
        obj->setEstimator(p);
    }
    */
    else if (method == "setBundleAdjuster") {
        nargchk(nrhs>=3 && nlhs==0);
        Ptr<BundleAdjusterBase> p = createBundleAdjusterBase(
            rhs[2].toString(), rhs.begin() + 3, rhs.end());
        obj->setBundleAdjuster(p);
    }
    else if (method == "setWarper") {
        nargchk(nrhs>=3 && nlhs==0);
        Ptr<WarperCreator> p = createWarperCreator(
            rhs[2].toString(), rhs.begin() + 3, rhs.end());
        obj->setWarper(p);
    }
    else if (method == "setExposureCompensator") {
        nargchk(nrhs>=3 && nlhs==0);
        Ptr<ExposureCompensator> p = createExposureCompensator(
            rhs[2].toString(), rhs.begin() + 3, rhs.end());
        obj->setExposureCompensator(p);
    }
    else if (method == "setSeamFinder") {
        nargchk(nrhs>=3 && nlhs==0);
        Ptr<SeamFinder> p = createSeamFinder(
            rhs[2].toString(), rhs.begin() + 3, rhs.end());
        obj->setSeamFinder(p);
    }
    else if (method == "setBlender") {
        nargchk(nrhs>=3 && nlhs==0);
        Ptr<Blender> p = createBlender(
            rhs[2].toString(), rhs.begin() + 3, rhs.end());
        obj->setBlender(p);
    }
    else if (method == "getFeaturesFinder") {
        nargchk(nrhs==2 && nlhs<=1);
        const Ptr<FeaturesFinder> p = obj->featuresFinder();
        plhs[0] = toStruct(p);
    }
    else if (method == "getFeaturesMatcher") {
        nargchk(nrhs==2 && nlhs<=1);
        const Ptr<FeaturesMatcher> p = obj->featuresMatcher();
        plhs[0] = toStruct(p);
    }
    /*
    else if (method == "getEstimator") {
        nargchk(nrhs==2 && nlhs<=1);
        const Ptr<Estimator> p = obj->estimator();
        plhs[0] = toStruct(p);
    }
    */
    else if (method == "getBundleAdjuster") {
        nargchk(nrhs==2 && nlhs<=1);
        const Ptr<BundleAdjusterBase> p = obj->bundleAdjuster();
        plhs[0] = toStruct(p);
    }
    else if (method == "getWarper") {
        nargchk(nrhs==2 && nlhs<=1);
        const Ptr<WarperCreator> p = obj->warper();
        plhs[0] = toStruct(p);
    }
    else if (method == "getExposureCompensator") {
        nargchk(nrhs==2 && nlhs<=1);
        const Ptr<ExposureCompensator> p = obj->exposureCompensator();
        plhs[0] = toStruct(p);
    }
    else if (method == "getSeamFinder") {
        nargchk(nrhs==2 && nlhs<=1);
        const Ptr<SeamFinder> p = obj->seamFinder();
        plhs[0] = toStruct(p);
    }
    else if (method == "getBlender") {
        nargchk(nrhs==2 && nlhs<=1);
        const Ptr<Blender> p = obj->blender();
        plhs[0] = toStruct(p);
    }
    else if (method == "component") {
        nargchk(nrhs==2 && nlhs<=1);
        vector<int> indices(obj->component());
        plhs[0] = MxArray(indices);
    }
    else if (method == "cameras") {
        nargchk(nrhs==2 && nlhs<=1);
        vector<CameraParams> params(obj->cameras());
        plhs[0] = toStruct(params);
    }
    else if (method == "workScale") {
        nargchk(nrhs==2 && nlhs<=1);
        double wscale = obj->workScale();
        plhs[0] = MxArray(wscale);
    }
    else if (method == "getMatchingMask") {
        nargchk(nrhs==2 && nlhs<=1);
        Mat mask(obj->matchingMask().getMat(ACCESS_READ));
        plhs[0] = MxArray(mask);
    }
    else if (method == "setMatchingMask") {
        nargchk(nrhs==3 && nlhs==0);
        Mat mask(rhs[2].toMat(CV_8U));
        obj->setMatchingMask(mask.getUMat(ACCESS_READ));
    }
    else if (method == "get") {
        nargchk(nrhs==3 && nlhs<=1);
        string prop(rhs[2].toString());
        if (prop == "RegistrationResol")
            plhs[0] = MxArray(obj->registrationResol());
        else if (prop == "SeamEstimationResol")
            plhs[0] = MxArray(obj->seamEstimationResol());
        else if (prop == "CompositingResol")
            plhs[0] = MxArray(obj->compositingResol());
        else if (prop == "PanoConfidenceThresh")
            plhs[0] = MxArray(obj->panoConfidenceThresh());
        else if (prop == "WaveCorrection")
            plhs[0] = MxArray(obj->waveCorrection());
        else if (prop == "WaveCorrectKind")
            plhs[0] = MxArray(WaveCorrectionInvMap[obj->waveCorrectKind()]);
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        if (prop == "RegistrationResol")
            obj->setRegistrationResol(rhs[3].toDouble());
        else if (prop == "SeamEstimationResol")
            obj->setSeamEstimationResol(rhs[3].toDouble());
        else if (prop == "CompositingResol")
            obj->setCompositingResol(rhs[3].isChar() ?
                ComposeResolMap[rhs[3].toString()] : rhs[3].toDouble());
        else if (prop == "PanoConfidenceThresh")
            obj->setPanoConfidenceThresh(rhs[3].toDouble());
        else if (prop == "WaveCorrection")
            obj->setWaveCorrection(rhs[3].toBool());
        else if (prop == "WaveCorrectKind")
            obj->setWaveCorrectKind(WaveCorrectionMap[rhs[3].toString()]);
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
