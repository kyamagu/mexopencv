/**
 * @file Retina_.cpp
 * @brief mex interface for cv::bioinspired::Retina
 * @ingroup bioinspired
 * @author Amro
 * @date 2016
 */
#include "mexopencv.hpp"
#include "opencv2/bioinspired.hpp"
using namespace std;
using namespace cv;
using namespace cv::bioinspired;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<Retina> > obj_;

/// Retina color sampling methods
const ConstMap<string,int> RetinaColorSampMap = ConstMap<string,int>
    ("Random",   cv::bioinspired::RETINA_COLOR_RANDOM)
    ("Diagonal", cv::bioinspired::RETINA_COLOR_DIAGONAL)
    ("Bayer",    cv::bioinspired::RETINA_COLOR_BAYER);

/** Create an instance of Retina using options in arguments
 * @param[in] first iterator at the beginning of the vector range
 * @param[in] last iterator at the end of the vector range
 * @return smart pointer to created Retina
 */
Ptr<Retina> create_Retina(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk(len>=1 && (len%2)==1);
    Size inputSize(first->toSize()); ++first;
    bool colorMode = true;
    int colorSamplingMethod = cv::bioinspired::RETINA_COLOR_BAYER;
    bool useRetinaLogSampling = false;
    float reductionFactor = 1.0f;
    float samplingStrength = 10.0f;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "ColorMode")
            colorMode = val.toBool();
        else if (key == "ColorSamplingMethod")
            colorSamplingMethod = RetinaColorSampMap[val.toString()];
        else if (key == "UseRetinaLogSampling")
            useRetinaLogSampling = val.toBool();
        else if (key == "ReductionFactor")
            reductionFactor = val.toFloat();
        else if (key == "SamplingStrength")
            samplingStrength = val.toFloat();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return Retina::create(inputSize, colorMode, colorSamplingMethod,
        useRetinaLogSampling, reductionFactor, samplingStrength);
}

/** Create an instance of OPLandIplParvoParameters using options in arguments
 * @param[in,out] OPLandIplParvo OPLandIplParvoParameters struct to fill
 * @param[in] first iterator at the beginning of the vector range
 * @param[in] last iterator at the end of the vector range
 */
void createOPLandIplParvoParameters(
    RetinaParameters::OPLandIplParvoParameters &OPLandIplParvo,
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "ColorMode")
            OPLandIplParvo.colorMode = val.toBool();
        else if (key == "NormaliseOutput")
            OPLandIplParvo.normaliseOutput = val.toBool();
        else if (key == "PhotoreceptorsLocalAdaptationSensitivity")
            OPLandIplParvo.photoreceptorsLocalAdaptationSensitivity = val.toFloat();
        else if (key == "PhotoreceptorsTemporalConstant")
            OPLandIplParvo.photoreceptorsTemporalConstant = val.toFloat();
        else if (key == "PhotoreceptorsSpatialConstant")
            OPLandIplParvo.photoreceptorsSpatialConstant = val.toFloat();
        else if (key == "HorizontalCellsGain")
            OPLandIplParvo.horizontalCellsGain = val.toFloat();
        else if (key == "HCellsTemporalConstant")
            OPLandIplParvo.hcellsTemporalConstant = val.toFloat();
        else if (key == "HCellsSpatialConstant")
            OPLandIplParvo.hcellsSpatialConstant = val.toFloat();
        else if (key == "GanglionCellsSensitivity")
            OPLandIplParvo.ganglionCellsSensitivity = val.toFloat();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
}

/** Create an instance of IplMagnoParameters using options in arguments
 * @param[in,out] IplMagno IplMagnoParameters struct to fill
 * @param[in] first iterator at the beginning of the vector range
 * @param[in] last iterator at the end of the vector range
 */
void createIplMagnoParameters(
    RetinaParameters::IplMagnoParameters &IplMagno,
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "NormaliseOutput")
            IplMagno.normaliseOutput = val.toBool();
        else if (key == "ParasolCellsBeta")
            IplMagno.parasolCells_beta = val.toFloat();
        else if (key == "ParasolCellsTau")
            IplMagno.parasolCells_tau = val.toFloat();
        else if (key == "ParasolCellsK")
            IplMagno.parasolCells_k = val.toFloat();
        else if (key == "AmacrinCellsTemporalCutFrequency")
            IplMagno.amacrinCellsTemporalCutFrequency = val.toFloat();
        else if (key == "V0CompressionParameter")
            IplMagno.V0CompressionParameter = val.toFloat();
        else if (key == "LocalAdaptintegrationTau")
            IplMagno.localAdaptintegration_tau = val.toFloat();
        else if (key == "LocalAdaptintegrationK")
            IplMagno.localAdaptintegration_k = val.toFloat();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
}

/** Create an instance of RetinaParameters using options in arguments
 * @param[in,out] params RetinaParameters struct to fill
 * @param[in] first iterator at the beginning of the vector range
 * @param[in] last iterator at the end of the vector range
 */
void createRetinaParameters(
    RetinaParameters &params,
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    for (; first != last; first += 2) {
        string key(first->toString());
        vector<MxArray> val((first + 1)->toVector<MxArray>());
        if (key == "OPLandIplParvo") {
            createOPLandIplParvoParameters(params.OPLandIplParvo,
                val.begin(), val.end());
        }
        else if (key == "IplMagno") {
            createIplMagnoParameters(params.IplMagno,
                val.begin(), val.end());
        }
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
}

/** Convert Parvocellular parameters to scalar struct
 * @param[in] params instance of OPLandIplParvoParameters
 * @return scalar struct MxArray object
 */
MxArray toStruct(const RetinaParameters::OPLandIplParvoParameters &params)
{
    const char *fields[] = {"ColorMode", "NormaliseOutput",
        "PhotoreceptorsLocalAdaptationSensitivity",
        "PhotoreceptorsTemporalConstant", "PhotoreceptorsSpatialConstant",
        "HorizontalCellsGain", "HCellsTemporalConstant",
        "HCellsSpatialConstant", "GanglionCellsSensitivity"};
    MxArray s = MxArray::Struct(fields, 9);
    s.set("ColorMode",                                params.colorMode);
    s.set("NormaliseOutput",                          params.normaliseOutput);
    s.set("PhotoreceptorsLocalAdaptationSensitivity", params.photoreceptorsLocalAdaptationSensitivity);
    s.set("PhotoreceptorsTemporalConstant",           params.photoreceptorsTemporalConstant);
    s.set("PhotoreceptorsSpatialConstant",            params.photoreceptorsSpatialConstant);
    s.set("HorizontalCellsGain",                      params.horizontalCellsGain);
    s.set("HCellsTemporalConstant",                   params.hcellsTemporalConstant);
    s.set("HCellsSpatialConstant",                    params.hcellsSpatialConstant);
    s.set("GanglionCellsSensitivity",                 params.ganglionCellsSensitivity);
    return s;
}

/** Convert Magnocellular parameters to scalar struct
 * @param[in] params instance of IplMagnoParameters
 * @return scalar struct MxArray object
 */
MxArray toStruct(const RetinaParameters::IplMagnoParameters &params)
{
    const char *fields[] = {"NormaliseOutput", "ParasolCellsBeta",
        "ParasolCellsTau", "ParasolCellsK",
        "AmacrinCellsTemporalCutFrequency", "V0CompressionParameter",
        "LocalAdaptintegrationTau", "LocalAdaptintegrationK"};
    MxArray s = MxArray::Struct(fields, 8);
    s.set("NormaliseOutput",                  params.normaliseOutput);
    s.set("ParasolCellsBeta",                 params.parasolCells_beta);
    s.set("ParasolCellsTau",                  params.parasolCells_tau);
    s.set("ParasolCellsK",                    params.parasolCells_k);
    s.set("AmacrinCellsTemporalCutFrequency", params.amacrinCellsTemporalCutFrequency);
    s.set("V0CompressionParameter",           params.V0CompressionParameter);
    s.set("LocalAdaptintegrationTau",         params.localAdaptintegration_tau);
    s.set("LocalAdaptintegrationK",           params.localAdaptintegration_k);
    return s;
}

/** Convert retina model parameters to scalar struct
 * @param[in] params instance of RetinaParameters
 * @return scalar struct MxArray object
 */
MxArray toStruct(const RetinaParameters &params)
{
    const char *fields[] = {"OPLandIplParvo", "IplMagno"};
    MxArray s = MxArray::Struct(fields, 2);
    s.set("OPLandIplParvo", toStruct(params.OPLandIplParvo));
    s.set("IplMagno",       toStruct(params.IplMagno));
    return s;
}
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
    nargchk(nrhs>=2 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());

    // Constructor is called. Create a new object from argument
    if (method == "new") {
        nargchk(nrhs>=2 && nlhs<=1);
        obj_[++last_id] = create_Retina(rhs.begin() + 2, rhs.end());
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }

    // Big operation switch
    Ptr<Retina> obj = obj_[id];
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
        /*
        obj_[id] = (loadFromString ?
            Algorithm::loadFromString<Retina>(rhs[2].toString(), objname) :
            Algorithm::load<Retina>(rhs[2].toString(), objname));
        */
        ///*
        // HACK: workaround for missing Retina::create()
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
    else if (method == "getInputSize") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->getInputSize());
    }
    else if (method == "getOutputSize") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->getOutputSize());
    }
    else if (method == "setup") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs==0);
        string retinaParameterFile(rhs[2].toString());
        bool applyDefaultSetupOnFailure = true;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "ApplyDefaultSetupOnFailure")
                applyDefaultSetupOnFailure = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        obj->setup(retinaParameterFile, applyDefaultSetupOnFailure);
    }
    else if (method == "setupParameters") {
        nargchk(nrhs>=2 && nlhs==0);
        RetinaParameters newParameters;
        createRetinaParameters(newParameters, rhs.begin() + 2, rhs.end());
        obj->setup(newParameters);
    }
    else if (method == "setupOPLandIPLParvoChannel") {
        nargchk(nrhs>=2 && nlhs==0);
        RetinaParameters::OPLandIplParvoParameters params;
        params.colorMode = true;
        params.normaliseOutput = true;
        params.photoreceptorsLocalAdaptationSensitivity = 0.7f;
        params.photoreceptorsTemporalConstant = 0.5f;
        params.photoreceptorsSpatialConstant = 0.53f;
        params.horizontalCellsGain = 0.f;
        params.hcellsTemporalConstant = 1.f;
        params.hcellsSpatialConstant = 7.f;
        params.ganglionCellsSensitivity = 0.7f;
        createOPLandIplParvoParameters(params, rhs.begin() + 2, rhs.end());
        obj->setupOPLandIPLParvoChannel(
            params.colorMode,
            params.normaliseOutput,
            params.photoreceptorsLocalAdaptationSensitivity,
            params.photoreceptorsTemporalConstant,
            params.photoreceptorsSpatialConstant,
            params.horizontalCellsGain,
            params.hcellsTemporalConstant,
            params.hcellsSpatialConstant,
            params.ganglionCellsSensitivity);
    }
    else if (method == "setupIPLMagnoChannel") {
        nargchk(nrhs>=2 && nlhs==0);
        RetinaParameters::IplMagnoParameters params;
        params.normaliseOutput = true;
        params.parasolCells_beta = 0.f;
        params.parasolCells_tau = 0.f;
        params.parasolCells_k = 7.f;
        params.amacrinCellsTemporalCutFrequency = 1.2f;
        params.V0CompressionParameter = 0.95f;
        params.localAdaptintegration_tau = 0.f;
        params.localAdaptintegration_k = 7.f;
        createIplMagnoParameters(params, rhs.begin() + 2, rhs.end());
        obj->setupIPLMagnoChannel(
            params.normaliseOutput,
            params.parasolCells_beta,
            params.parasolCells_tau,
            params.parasolCells_k,
            params.amacrinCellsTemporalCutFrequency,
            params.V0CompressionParameter,
            params.localAdaptintegration_tau,
            params.localAdaptintegration_k);
    }
    else if (method == "getParameters") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = toStruct(obj->getParameters());
    }
    else if (method == "printSetup") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->printSetup());
    }
    else if (method == "write") {
        nargchk(nrhs==3 && nlhs<=1);
        string fname(rhs[2].toString());
        if (nlhs > 0) {
            FileStorage fs(fname, FileStorage::WRITE + FileStorage::MEMORY);
            if (!fs.isOpened())
                mexErrMsgIdAndTxt("mexopencv:error", "Failed to open file");
            obj->write(fs);
            plhs[0] = MxArray(fs.releaseAndGetString());
        }
        else
            obj->write(fname);
    }
    else if (method == "run") {
        nargchk(nrhs==3 && nlhs==0);
        Mat inputImage(rhs[2].toMat(CV_32F));
        obj->run(inputImage);
    }
    else if (method == "applyFastToneMapping") {
        nargchk(nrhs==3 && nlhs<=1);
        Mat inputImage(rhs[2].toMat(CV_32F)),
            outputToneMappedImage;
        obj->applyFastToneMapping(inputImage, outputToneMappedImage);
        plhs[0] = MxArray(outputToneMappedImage);
    }
    else if (method == "getParvo") {
        nargchk(nrhs==2 && nlhs<=1);
        Mat retinaOutput_parvo;
        obj->getParvo(retinaOutput_parvo);
        plhs[0] = MxArray(retinaOutput_parvo);
    }
    else if (method == "getParvoRAW") {
        nargchk(nrhs==2 && nlhs<=1);
        Mat retinaOutput_parvo;
        obj->getParvoRAW(retinaOutput_parvo);
        plhs[0] = MxArray(retinaOutput_parvo);
    }
    else if (method == "getParvoRAW2") {
        nargchk(nrhs==2 && nlhs<=1);
        Mat retinaOutput_parvo(obj->getParvoRAW());
        plhs[0] = MxArray(retinaOutput_parvo);
    }
    else if (method == "getMagno") {
        nargchk(nrhs==2 && nlhs<=1);
        Mat retinaOutput_magno;
        obj->getMagno(retinaOutput_magno);
        plhs[0] = MxArray(retinaOutput_magno);
    }
    else if (method == "getMagnoRAW") {
        nargchk(nrhs==2 && nlhs<=1);
        Mat retinaOutput_magno;
        obj->getMagnoRAW(retinaOutput_magno);
        plhs[0] = MxArray(retinaOutput_magno);
    }
    else if (method == "getMagnoRAW2") {
        nargchk(nrhs==2 && nlhs<=1);
        Mat retinaOutput_magno(obj->getMagnoRAW());
        plhs[0] = MxArray(retinaOutput_magno);
    }
    else if (method == "setColorSaturation") {
        nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs==0);
        bool saturateColors = true;
        float colorSaturationValue = 4.0f;
        for (int i=2; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "SaturateColors")
                saturateColors = rhs[i+1].toBool();
            else if (key == "ColorSaturationValue")
                colorSaturationValue = rhs[i+1].toFloat();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        obj->setColorSaturation(saturateColors, colorSaturationValue);
    }
    else if (method == "clearBuffers") {
        nargchk(nrhs==2 && nlhs==0);
        obj->clearBuffers();
    }
    else if (method == "activateMovingContoursProcessing") {
        nargchk(nrhs==3 && nlhs==0);
        bool activate = rhs[2].toBool();
        obj->activateMovingContoursProcessing(activate);
    }
    else if (method == "activateContoursProcessing") {
        nargchk(nrhs==3 && nlhs==0);
        bool activate = rhs[2].toBool();
        obj->activateContoursProcessing(activate);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
