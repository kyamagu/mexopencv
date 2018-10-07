/**
 * @file Dataset_.cpp
 * @brief mex interface for cv::datasets::Dataset
 * @ingroup datasets
 * @author Amro
 * @date 2016
 */
#include "mexopencv.hpp"
#include "opencv2/datasets/dataset.hpp"
#include "opencv2/datasets/util.hpp"
#include "opencv2/datasets/ar_hmdb.hpp"
#include "opencv2/datasets/ar_sports.hpp"
#include "opencv2/datasets/fr_adience.hpp"
#include "opencv2/datasets/fr_lfw.hpp"
#include "opencv2/datasets/gr_chalearn.hpp"
#include "opencv2/datasets/gr_skig.hpp"
#include "opencv2/datasets/hpe_humaneva.hpp"
#include "opencv2/datasets/hpe_parse.hpp"
#include "opencv2/datasets/ir_affine.hpp"
#include "opencv2/datasets/ir_robot.hpp"
#include "opencv2/datasets/is_bsds.hpp"
#include "opencv2/datasets/is_weizmann.hpp"
#include "opencv2/datasets/msm_epfl.hpp"
#include "opencv2/datasets/msm_middlebury.hpp"
#include "opencv2/datasets/or_imagenet.hpp"
#include "opencv2/datasets/or_mnist.hpp"
#include "opencv2/datasets/or_pascal.hpp"
#include "opencv2/datasets/or_sun.hpp"
#include "opencv2/datasets/pd_caltech.hpp"
#include "opencv2/datasets/pd_inria.hpp"
#include "opencv2/datasets/slam_kitti.hpp"
#include "opencv2/datasets/slam_tumindoor.hpp"
#include "opencv2/datasets/tr_chars.hpp"
#include "opencv2/datasets/tr_icdar.hpp"
#include "opencv2/datasets/tr_svt.hpp"
#include "opencv2/datasets/track_vot.hpp"
#include "opencv2/datasets/track_alov.hpp"
#include <typeinfo>
using namespace std;
using namespace cv;
using namespace cv::datasets;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<Dataset> > obj_;

/// map for cv::datasets::genderType enum values
const ConstMap<int,string> GenderTypeInvMap = ConstMap<int,string>
    (cv::datasets::male,   "Male")
    (cv::datasets::female, "Female")
    (cv::datasets::none,   "None");

/// map for cv::datasets::actionType enum values
const ConstMap<int,string> ActionTypeInvMap = ConstMap<int,string>
    (cv::datasets::circle,     "Circle")
    (cv::datasets::triangle,   "Triangle")
    (cv::datasets::updown,     "Updown")
    (cv::datasets::rightleft,  "Rightleft")
    (cv::datasets::wave,       "Wave")
    (cv::datasets::z,          "Z")
    (cv::datasets::cross,      "Cross")
    (cv::datasets::comehere,   "Comehere")
    (cv::datasets::turnaround, "Turnaround")
    (cv::datasets::pat,        "Pat");

/// map for cv::datasets::poseType enum values
const ConstMap<int,string> PoseTypeInvMap = ConstMap<int,string>
    (cv::datasets::fist,  "Fist")
    (cv::datasets::index, "Index")
    (cv::datasets::flat,  "Flat");

/// map for cv::datasets::illuminationType enum values
const ConstMap<int,string> IlluminationTypeInvMap = ConstMap<int,string>
    (cv::datasets::light, "Light")
    (cv::datasets::dark,  "Dark");

/// map for cv::datasets::backgroundType enum values
const ConstMap<int,string> BackgroundTypeInvMap = ConstMap<int,string>
    (cv::datasets::woodenBoard,         "WoodenBoard")
    (cv::datasets::whitePaper,          "WhitePaper")
    (cv::datasets::paperWithCharacters, "PaperWithCharacters");

/// map for cv::datasets::datasetType enum values
const ConstMap<int,string> DatasetTypeInvMap = ConstMap<int,string>
    (cv::datasets::humaneva_1, "Humaneva1")
    (cv::datasets::humaneva_2, "Humaneva2");

/// map for cv::datasets::sampleType enum values
const ConstMap<int,string> SampleTypeInvMap = ConstMap<int,string>
    (cv::datasets::POS, "Pos")
    (cv::datasets::NEG, "Neg");

/// map for cv::datasets::imageType enum values
const ConstMap<int,string> ImageTypeInvMap = ConstMap<int,string>
    (cv::datasets::LEFT,    "Left")
    (cv::datasets::RIGHT,   "Right")
    (cv::datasets::LADYBUG, "Ladybug");

/// helper function used in GR_chalearnObj conversion
MxArray toStruct(const vector<groundTruth>& groundTruths)
{
    const char *fields[] = {"gestureID", "initialFrame", "lastFrame"};
    MxArray s = MxArray::Struct(fields, 3, 1, groundTruths.size());
    for (mwIndex i = 0; i < groundTruths.size(); ++i) {
        s.set("gestureID",    groundTruths[i].gestureID,    i);
        s.set("initialFrame", groundTruths[i].initialFrame, i);
        s.set("lastFrame",    groundTruths[i].lastFrame,    i);
    }
    return s;
}

/// helper function used in GR_chalearnObj conversion
MxArray toStruct(const skeleton& skel)
{
    const char *fields[] = {"Wx", "Wy", "Wz", "Rx", "Ry", "Rz", "Rw",
        "Px", "Py"};
    MxArray s = MxArray::Struct(fields, 9, 1, 20);
    for (mwIndex i = 0; i < 20; ++i) {
        s.set("Wx", skel.s[i].Wx, i);
        s.set("Wy", skel.s[i].Wy, i);
        s.set("Wz", skel.s[i].Wz, i);
        s.set("Rx", skel.s[i].Rx, i);
        s.set("Ry", skel.s[i].Ry, i);
        s.set("Rz", skel.s[i].Rz, i);
        s.set("Rw", skel.s[i].Rw, i);
        s.set("Px", skel.s[i].Px, i);
        s.set("Py", skel.s[i].Py, i);
    }
    return s;
}

/// helper function used in IR_robotObj conversion
MxArray toStruct(const vector<cameraPos>& pos)
{
    const char *fields[] = {"images"};
    MxArray s = MxArray::Struct(fields, 1, 1, pos.size());
    for (mwIndex i = 0; i < pos.size(); ++i) {
        s.set("images", pos[i].images, i);
    }
    return s;
}

/// helper function used in MSM_epflObj conversion
MxArray toStruct(const cameraParam& camera)
{
    const char *fields[] = {"mat1", "mat2", "mat3", "mat4", "imageWidth",
        "imageHeight"};
    MxArray s = MxArray::Struct(fields, 6);
    s.set("mat1",        camera.mat1);
    s.set("mat2",        vector<double>(camera.mat2, camera.mat2 + 3));
    s.set("mat3",        camera.mat3);
    s.set("mat4",        vector<double>(camera.mat4, camera.mat4 + 3));
    s.set("imageWidth",  camera.imageWidth);
    s.set("imageHeight", camera.imageHeight);
    return s;
}

/// helper function used in OR_pascalObj conversion
MxArray toStruct(const vector<PascalPart>& parts)
{
    const char *fields[] = {"name", "xmin", "ymin", "xmax", "ymax"};
    MxArray s = MxArray::Struct(fields, 5, 1, parts.size());
    for (mwIndex i = 0; i < parts.size(); ++i) {
        s.set("name", parts[i].name, i);
        s.set("xmin", parts[i].xmin, i);
        s.set("ymin", parts[i].ymin, i);
        s.set("xmax", parts[i].xmax, i);
        s.set("ymax", parts[i].ymax, i);
    }
    return s;
}

/// helper function used in OR_pascalObj conversion
MxArray toStruct(const vector<PascalObj>& objects)
{
    const char *fields[] = {"name", "xmin", "ymin", "xmax", "ymax",
        "pose", "truncated", "difficult", "occluded", "parts"};
    MxArray s = MxArray::Struct(fields, 10, 1, objects.size());
    for (mwIndex i = 0; i < objects.size(); ++i) {
        s.set("name",      objects[i].name,            i);
        s.set("xmin",      objects[i].xmin,            i);
        s.set("ymin",      objects[i].ymin,            i);
        s.set("xmax",      objects[i].xmax,            i);
        s.set("ymax",      objects[i].ymax,            i);
        s.set("pose",      objects[i].pose,            i);
        s.set("truncated", objects[i].truncated,       i);
        s.set("difficult", objects[i].difficult,       i);
        s.set("occluded",  objects[i].occluded,        i);
        s.set("parts",     toStruct(objects[i].parts), i);
    }
    return s;
}

/// helper function used in SLAM_kittiObj conversion
MxArray toStruct(const vector<pose>& poses)
{
    const char *fields[] = {"elem"};
    MxArray s = MxArray::Struct(fields, 1, 1, poses.size());
    for (mwIndex i = 0; i < poses.size(); ++i) {
        s.set("elem", vector<double>(poses[i].elem, poses[i].elem + 12), i);
    }
    return s;
}

/// helper function used in TR_icdarObj conversion
MxArray toStruct(const vector<word>& words)
{
    const char *fields[] = {"value", "height", "width", "x", "y"};
    MxArray s = MxArray::Struct(fields, 5, 1, words.size());
    for (mwIndex i = 0; i < words.size(); ++i) {
        s.set("value",  words[i].value,  i);
        s.set("height", words[i].height, i);
        s.set("width",  words[i].width,  i);
        s.set("x",      words[i].x,      i);
        s.set("y",      words[i].y,      i);
    }
    return s;
}

/// helper function used in TR_svtObj conversion
MxArray toStruct(const vector<tag>& tags)
{
    const char *fields[] = {"value", "height", "width", "x", "y"};
    MxArray s = MxArray::Struct(fields, 5, 1, tags.size());
    for (mwIndex i = 0; i < tags.size(); ++i) {
        s.set("value",  tags[i].value,  i);
        s.set("height", tags[i].height, i);
        s.set("width",  tags[i].width,  i);
        s.set("x",      tags[i].x,      i);
        s.set("y",      tags[i].y,      i);
    }
    return s;
}

/** Convert AR_hmdb objects to struct array
 * @param objs vector of object pointers
 * @return struct-array MxArray object
 */
MxArray toStruct_AR_hmdb(const vector<Ptr<Object> >& objs)
{
    const char *fields[] = {"id", "name", "videoName"};
    MxArray s = MxArray::Struct(fields, 3, 1, objs.size());
    for (mwIndex i = 0; i < objs.size(); ++i) {
        Ptr<AR_hmdbObj> obj = objs[i].staticCast<AR_hmdbObj>();
        s.set("id",        obj->id,        i);
        s.set("name",      obj->name,      i);
        s.set("videoName", obj->videoName, i);
    }
    return s;
}

/** Convert AR_sports objects to struct array
 * @param objs vector of object pointers
 * @return struct-array MxArray object
 */
MxArray toStruct_AR_sports(const vector<Ptr<Object> >& objs)
{
    const char *fields[] = {"videoUrl", "labels"};
    MxArray s = MxArray::Struct(fields, 2, 1, objs.size());
    for (mwIndex i = 0; i < objs.size(); ++i) {
        Ptr<AR_sportsObj> obj = objs[i].staticCast<AR_sportsObj>();
        s.set("videoUrl", obj->videoUrl, i);
        s.set("labels",   obj->labels,   i);
    }
    return s;
}

/** Convert FR_adience objects to struct array
 * @param objs vector of object pointers
 * @return struct-array MxArray object
 */
MxArray toStruct_FR_adience(const vector<Ptr<Object> >& objs)
{
    const char *fields[] = {"user_id", "original_image", "face_id", "age",
        "gender", "x", "y", "dx", "dy", "tilt_ang", "fiducial_yaw_angle",
        "fiducial_score"};
    MxArray s = MxArray::Struct(fields, 12, 1, objs.size());
    for (mwIndex i = 0; i < objs.size(); ++i) {
        Ptr<FR_adienceObj> obj = objs[i].staticCast<FR_adienceObj>();
        s.set("user_id",            obj->user_id,                  i);
        s.set("original_image",     obj->original_image,           i);
        s.set("face_id",            obj->face_id,                  i);
        s.set("age",                obj->age,                      i);
        s.set("gender",             GenderTypeInvMap[obj->gender], i);
        s.set("x",                  obj->x,                        i);
        s.set("y",                  obj->y,                        i);
        s.set("dx",                 obj->dx,                       i);
        s.set("dy",                 obj->dy,                       i);
        s.set("tilt_ang",           obj->tilt_ang,                 i);
        s.set("fiducial_yaw_angle", obj->fiducial_yaw_angle,       i);
        s.set("fiducial_score",     obj->fiducial_score,           i);
    }
    return s;
}

/** Convert FR_lfw objects to struct array
 * @param objs vector of object pointers
 * @return struct-array MxArray object
 */
MxArray toStruct_FR_lfw(const vector<Ptr<Object> >& objs)
{
    const char *fields[] = {"image1", "image2", "same"};
    MxArray s = MxArray::Struct(fields, 3, 1, objs.size());
    for (mwIndex i = 0; i < objs.size(); ++i) {
        Ptr<FR_lfwObj> obj = objs[i].staticCast<FR_lfwObj>();
        s.set("image1", obj->image1, i);
        s.set("image2", obj->image2, i);
        s.set("same",   obj->same,   i);
    }
    return s;
}

/** Convert GR_chalearn objects to struct array
 * @param objs vector of object pointers
 * @return struct-array MxArray object
 */
MxArray toStruct_GR_chalearn(const vector<Ptr<Object> >& objs)
{
    const char *fields[] = {"name", "nameColor", "nameDepth", "nameUser",
        "numFrames", "fps", "depth", "groundTruths", "skeletons"};
    MxArray s = MxArray::Struct(fields, 9, 1, objs.size());
    for (mwIndex i = 0; i < objs.size(); ++i) {
        Ptr<GR_chalearnObj> obj = objs[i].staticCast<GR_chalearnObj>();
        s.set("name",          obj->name,                   i);
        s.set("nameColor",     obj->nameColor,              i);
        s.set("nameDepth",     obj->nameDepth,              i);
        s.set("nameUser",      obj->nameUser,               i);
        s.set("numFrames",     obj->numFrames,              i);
        s.set("fps",           obj->fps,                    i);
        s.set("depth",         obj->depth,                  i);
        s.set("groundTruths",  toStruct(obj->groundTruths), i);
        {
            MxArray c = MxArray::Cell(1, obj->skeletons.size());
            for (mwIndex j = 0; j < obj->skeletons.size(); ++j)
                c.set(j, toStruct(obj->skeletons[j]));
            s.set("skeletons", c,                           i);
        }
    }
    return s;
}

/** Convert GR_skig objects to struct array
 * @param objs vector of object pointers
 * @return struct-array MxArray object
 */
MxArray toStruct_GR_skig(const vector<Ptr<Object> >& objs)
{
    const char *fields[] = {"rgb", "dep", "person", "background",
        "illumination", "pose", "type"};
    MxArray s = MxArray::Struct(fields, 7, 1, objs.size());
    for (mwIndex i = 0; i < objs.size(); ++i) {
        Ptr<GR_skigObj> obj = objs[i].staticCast<GR_skigObj>();
        s.set("rgb",          obj->rgb,                                  i);
        s.set("dep",          obj->dep,                                  i);
        s.set("person",       int(obj->person),                          i);
        s.set("background",   BackgroundTypeInvMap[obj->background],     i);
        s.set("illumination", IlluminationTypeInvMap[obj->illumination], i);
        s.set("pose",         PoseTypeInvMap[obj->pose],                 i);
        s.set("type",         ActionTypeInvMap[obj->type],               i);
    }
    return s;
}

/** Convert HPE_humaneva objects to struct array
 * @param objs vector of object pointers
 * @return struct-array MxArray object
 */
MxArray toStruct_HPE_humaneva(const vector<Ptr<Object> >& objs)
{
    const char *fields[] = {"person", "action", "type1", "type2", "ofs",
        "fileName", "imageNames"};
    MxArray s = MxArray::Struct(fields, 7, 1, objs.size());
    for (mwIndex i = 0; i < objs.size(); ++i) {
        Ptr<HPE_humanevaObj> obj = objs[i].staticCast<HPE_humanevaObj>();
        s.set("person",     int(obj->person),              i);
        s.set("action",     obj->action,                   i);
        s.set("type1",      DatasetTypeInvMap[obj->type1], i);
        s.set("type2",      obj->type2,                    i);
        s.set("ofs",        obj->ofs,                      i);
        s.set("fileName",   obj->fileName,                 i);
        s.set("imageNames", obj->imageNames,               i);
    }
    return s;
}

/** Convert HPE_parse objects to struct array
 * @param objs vector of object pointers
 * @return struct-array MxArray object
 */
MxArray toStruct_HPE_parse(const vector<Ptr<Object> >& objs)
{
    const char *fields[] = {"name"};
    MxArray s = MxArray::Struct(fields, 1, 1, objs.size());
    for (mwIndex i = 0; i < objs.size(); ++i) {
        Ptr<HPE_parseObj> obj = objs[i].staticCast<HPE_parseObj>();
        s.set("name", obj->name, i);
    }
    return s;
}

/** Convert IR_affine objects to struct array
 * @param objs vector of object pointers
 * @return struct-array MxArray object
 */
MxArray toStruct_IR_affine(const vector<Ptr<Object> >& objs)
{
    const char *fields[] = {"imageName", "mat"};
    MxArray s = MxArray::Struct(fields, 2, 1, objs.size());
    for (mwIndex i = 0; i < objs.size(); ++i) {
        Ptr<IR_affineObj> obj = objs[i].staticCast<IR_affineObj>();
        s.set("imageName", obj->imageName, i);
        s.set("mat",       obj->mat,       i);
    }
    return s;
}

/** Convert IR_robot objects to struct array
 * @param objs vector of object pointers
 * @return struct-array MxArray object
 */
MxArray toStruct_IR_robot(const vector<Ptr<Object> >& objs)
{
    const char *fields[] = {"name", "pos"};
    MxArray s = MxArray::Struct(fields, 2, 1, objs.size());
    for (mwIndex i = 0; i < objs.size(); ++i) {
        Ptr<IR_robotObj> obj = objs[i].staticCast<IR_robotObj>();
        s.set("name", obj->name,          i);
        s.set("pos",  toStruct(obj->pos), i);
    }
    return s;
}

/** Convert IS_bsds objects to struct array
 * @param objs vector of object pointers
 * @return struct-array MxArray object
 */
MxArray toStruct_IS_bsds(const vector<Ptr<Object> >& objs)
{
    const char *fields[] = {"name"};
    MxArray s = MxArray::Struct(fields, 1, 1, objs.size());
    for (mwIndex i = 0; i < objs.size(); ++i) {
        Ptr<IS_bsdsObj> obj = objs[i].staticCast<IS_bsdsObj>();
        s.set("name", obj->name, i);
    }
    return s;
}

/** Convert IS_weizmann objects to struct array
 * @param objs vector of object pointers
 * @return struct-array MxArray object
 */
MxArray toStruct_IS_weizmann(const vector<Ptr<Object> >& objs)
{
    const char *fields[] = {"imageName", "srcBw", "srcColor", "humanSeg"};
    MxArray s = MxArray::Struct(fields, 4, 1, objs.size());
    for (mwIndex i = 0; i < objs.size(); ++i) {
        Ptr<IS_weizmannObj> obj = objs[i].staticCast<IS_weizmannObj>();
        s.set("imageName", obj->imageName, i);
        s.set("srcBw",     obj->srcBw,     i);
        s.set("srcColor",  obj->srcColor,  i);
        s.set("humanSeg",  obj->humanSeg,  i);
    }
    return s;
}

/** Convert MSM_epfl objects to struct array
 * @param objs vector of object pointers
 * @return struct-array MxArray object
 */
MxArray toStruct_MSM_epfl(const vector<Ptr<Object> >& objs)
{
    const char *fields[] = {"imageName", "bounding", "p", "camera"};
    MxArray s = MxArray::Struct(fields, 4, 1, objs.size());
    for (mwIndex i = 0; i < objs.size(); ++i) {
        Ptr<MSM_epflObj> obj = objs[i].staticCast<MSM_epflObj>();
        s.set("imageName", obj->imageName,        i);
        s.set("bounding",  obj->bounding,         i);
        s.set("p",         obj->p,                i);
        s.set("camera",    toStruct(obj->camera), i);
    }
    return s;
}

/** Convert MSM_middlebury objects to struct array
 * @param objs vector of object pointers
 * @return struct-array MxArray object
 */
MxArray toStruct_MSM_middlebury(const vector<Ptr<Object> >& objs)
{
    const char *fields[] = {"imageName", "k", "r", "t"};
    MxArray s = MxArray::Struct(fields, 4, 1, objs.size());
    for (mwIndex i = 0; i < objs.size(); ++i) {
        Ptr<MSM_middleburyObj> obj = objs[i].staticCast<MSM_middleburyObj>();
        s.set("imageName", obj->imageName,                     i);
        s.set("k",         obj->k,                             i);
        s.set("r",         obj->r,                             i);
        s.set("t",         vector<double>(obj->t, obj->t + 3), i);
    }
    return s;
}

/** Convert OR_imagenet objects to struct array
 * @param objs vector of object pointers
 * @return struct-array MxArray object
 */
MxArray toStruct_OR_imagenet(const vector<Ptr<Object> >& objs)
{
    const char *fields[] = {"id", "image"};
    MxArray s = MxArray::Struct(fields, 2, 1, objs.size());
    for (mwIndex i = 0; i < objs.size(); ++i) {
        Ptr<OR_imagenetObj> obj = objs[i].staticCast<OR_imagenetObj>();
        s.set("id",    obj->id,    i);
        s.set("image", obj->image, i);
    }
    return s;
}

/** Convert OR_mnist objects to struct array
 * @param objs vector of object pointers
 * @return struct-array MxArray object
 */
MxArray toStruct_OR_mnist(const vector<Ptr<Object> >& objs)
{
    const char *fields[] = {"label", "image"};
    MxArray s = MxArray::Struct(fields, 2, 1, objs.size());
    for (mwIndex i = 0; i < objs.size(); ++i) {
        Ptr<OR_mnistObj> obj = objs[i].staticCast<OR_mnistObj>();
        s.set("label", int(obj->label), i);
        s.set("image", obj->image,      i);
    }
    return s;
}

/** Convert OR_pascal objects to struct array
 * @param objs vector of object pointers
 * @return struct-array MxArray object
 */
MxArray toStruct_OR_pascal(const vector<Ptr<Object> >& objs)
{
    const char *fields[] = {"filename", "width", "height", "depth", "objects"};
    MxArray s = MxArray::Struct(fields, 5, 1, objs.size());
    for (mwIndex i = 0; i < objs.size(); ++i) {
        Ptr<OR_pascalObj> obj = objs[i].staticCast<OR_pascalObj>();
        s.set("filename", obj->filename,          i);
        s.set("width",    obj->width,             i);
        s.set("height",   obj->height,            i);
        s.set("depth",    obj->depth,             i);
        s.set("objects",  toStruct(obj->objects), i);
    }
    return s;
}

/** Convert OR_sun objects to struct array
 * @param objs vector of object pointers
 * @return struct-array MxArray object
 */
MxArray toStruct_OR_sun(const vector<Ptr<Object> >& objs)
{
    const char *fields[] = {"label", "name"};
    MxArray s = MxArray::Struct(fields, 2, 1, objs.size());
    for (mwIndex i = 0; i < objs.size(); ++i) {
        Ptr<OR_sunObj> obj = objs[i].staticCast<OR_sunObj>();
        s.set("label", obj->label, i);
        s.set("name",  obj->name,  i);
    }
    return s;
}

/** Convert PD_caltech objects to struct array
 * @param objs vector of object pointers
 * @return struct-array MxArray object
 */
MxArray toStruct_PD_caltech(const vector<Ptr<Object> >& objs)
{
    const char *fields[] = {"name", "imageNames"};
    MxArray s = MxArray::Struct(fields, 2, 1, objs.size());
    for (mwIndex i = 0; i < objs.size(); ++i) {
        Ptr<PD_caltechObj> obj = objs[i].staticCast<PD_caltechObj>();
        s.set("name",       obj->name,       i);
        s.set("imageNames", obj->imageNames, i);
    }
    return s;
}

/** Convert PD_inria objects to struct array
 * @param objs vector of object pointers
 * @return struct-array MxArray object
 */
MxArray toStruct_PD_inria(const vector<Ptr<Object> >& objs)
{
    const char *fields[] = {"filename", "sType", "width", "height", "depth",
        "bndboxes"};
    MxArray s = MxArray::Struct(fields, 6, 1, objs.size());
    for (mwIndex i = 0; i < objs.size(); ++i) {
        Ptr<PD_inriaObj> obj = objs[i].staticCast<PD_inriaObj>();
        s.set("filename", obj->filename,                i);
        s.set("sType",    SampleTypeInvMap[obj->sType], i);
        s.set("width",    obj->width,                   i);
        s.set("height",   obj->height,                  i);
        s.set("depth",    obj->depth,                   i);
        s.set("bndboxes", obj->bndboxes,                i);
    }
    return s;
}

/** Convert SLAM_kitti objects to struct array
 * @param objs vector of object pointers
 * @return struct-array MxArray object
 */
MxArray toStruct_SLAM_kitti(const vector<Ptr<Object> >& objs)
{
    const char *fields[] = {"name", "images", "velodyne", "times", "p",
        "posesArray"};
    MxArray s = MxArray::Struct(fields, 6, 1, objs.size());
    for (mwIndex i = 0; i < objs.size(); ++i) {
        Ptr<SLAM_kittiObj> obj = objs[i].staticCast<SLAM_kittiObj>();
        s.set("name",       obj->name,                 i);
        {
            MxArray c = MxArray::Cell(1,4);
            for (mwIndex j = 0; j < 4; ++j)
                c.set(j, MxArray(obj->images[j]));
            s.set("images", c,                         i);
        }
        s.set("velodyne",   obj->velodyne,             i);
        s.set("times",      obj->times,                i);
        {
            MxArray c = MxArray::Cell(1,4);
            for (mwIndex j = 0; j < 4; ++j)
                c.set(j, MxArray(obj->p[j]));
            s.set("p",      c,                         i);
        }
        s.set("posesArray", toStruct(obj->posesArray), i);
    }
    return s;
}

/** Convert SLAM_tumindoor objects to struct array
 * @param objs vector of object pointers
 * @return struct-array MxArray object
 */
MxArray toStruct_SLAM_tumindoor(const vector<Ptr<Object> >& objs)
{
    const char *fields[] = {"name", "transformMat", "type"};
    MxArray s = MxArray::Struct(fields, 3, 1, objs.size());
    for (mwIndex i = 0; i < objs.size(); ++i) {
        Ptr<SLAM_tumindoorObj> obj = objs[i].staticCast<SLAM_tumindoorObj>();
        s.set("name",         obj->name,                  i);
        s.set("transformMat", obj->transformMat,          i);
        s.set("type",         ImageTypeInvMap[obj->type], i);
    }
    return s;
}

/** Convert TR_chars objects to struct array
 * @param objs vector of object pointers
 * @return struct-array MxArray object
 */
MxArray toStruct_TR_chars(const vector<Ptr<Object> >& objs)
{
    const char *fields[] = {"imgName", "label"};
    MxArray s = MxArray::Struct(fields, 2, 1, objs.size());
    for (mwIndex i = 0; i < objs.size(); ++i) {
        Ptr<TR_charsObj> obj = objs[i].staticCast<TR_charsObj>();
        s.set("imgName", obj->imgName, i);
        s.set("label",   obj->label,   i);
    }
    return s;
}

/** Convert TR_icdar objects to struct array
 * @param objs vector of object pointers
 * @return struct-array MxArray object
 */
MxArray toStruct_TR_icdar(const vector<Ptr<Object> >& objs)
{
    const char *fields[] = {"fileName", "lex100", "lexFull", "words"};
    MxArray s = MxArray::Struct(fields, 4, 1, objs.size());
    for (mwIndex i = 0; i < objs.size(); ++i) {
        Ptr<TR_icdarObj> obj = objs[i].staticCast<TR_icdarObj>();
        s.set("fileName", obj->fileName,        i);
        s.set("lex100",   obj->lex100,          i);
        s.set("lexFull",  obj->lexFull,         i);
        s.set("words",    toStruct(obj->words), i);
    }
    return s;
}

/** Convert TR_svt objects to struct array
 * @param objs vector of object pointers
 * @return struct-array MxArray object
 */
MxArray toStruct_TR_svt(const vector<Ptr<Object> >& objs)
{
    const char *fields[] = {"fileName", "lex", "tags"};
    MxArray s = MxArray::Struct(fields, 3, 1, objs.size());
    for (mwIndex i = 0; i < objs.size(); ++i) {
        Ptr<TR_svtObj> obj = objs[i].staticCast<TR_svtObj>();
        s.set("fileName", obj->fileName,       i);
        s.set("lex",      obj->lex,            i);
        s.set("tags",     toStruct(obj->tags), i);
    }
    return s;
}

/** Convert TRACK_vot objects to struct array
 * @param objs vector of object pointers
 * @return struct-array MxArray object
 */
MxArray toStruct_TRACK_vot(const vector<Ptr<Object> >& objs)
{
    const char *fields[] = {"id", "imagePath", "gtbb"};
    MxArray s = MxArray::Struct(fields, 3, 1, objs.size());
    for (mwIndex i = 0; i < objs.size(); ++i) {
        Ptr<TRACK_votObj> obj = objs[i].staticCast<TRACK_votObj>();
        s.set("id",        obj->id,        i);
        s.set("imagePath", obj->imagePath, i);
        s.set("gtbb",      obj->gtbb,      i);
    }
    return s;
}

/** Convert TRACK_alov objects to struct array
 * @param objs vector of object pointers
 * @return struct-array MxArray object
 */
MxArray toStruct_TRACK_alov(const vector<Ptr<Object> >& objs)
{
    const char *fields[] = {"id", "imagePath", "gtbb"};
    MxArray s = MxArray::Struct(fields, 3, 1, objs.size());
    for (mwIndex i = 0; i < objs.size(); ++i) {
        Ptr<TRACK_alovObj> obj = objs[i].staticCast<TRACK_alovObj>();
        s.set("id",        obj->id,        i);
        s.set("imagePath", obj->imagePath, i);
        s.set("gtbb",      obj->gtbb,      i);
    }
    return s;
}

/** Convert objects to struct array
 * @param objs vector of object pointers
 * @param klass dataset class
 * @return struct-array MxArray object
 */
MxArray toStruct(const vector<Ptr<Object> >& objs, const string& klass)
{
    if (klass == "AR_hmdb")
        return toStruct_AR_hmdb(objs);
    else if (klass == "AR_sports")
        return toStruct_AR_sports(objs);
    else if (klass == "FR_adience")
        return toStruct_FR_adience(objs);
    else if (klass == "FR_lfw")
        return toStruct_FR_lfw(objs);
    else if (klass == "GR_chalearn")
        return toStruct_GR_chalearn(objs);
    else if (klass == "GR_skig")
        return toStruct_GR_skig(objs);
    else if (klass == "HPE_humaneva")
        return toStruct_HPE_humaneva(objs);
    else if (klass == "HPE_parse")
        return toStruct_HPE_parse(objs);
    else if (klass == "IR_affine")
        return toStruct_IR_affine(objs);
    else if (klass == "IR_robot")
        return toStruct_IR_robot(objs);
    else if (klass == "IS_bsds")
        return toStruct_IS_bsds(objs);
    else if (klass == "IS_weizmann")
        return toStruct_IS_weizmann(objs);
    else if (klass == "MSM_epfl")
        return toStruct_MSM_epfl(objs);
    else if (klass == "MSM_middlebury")
        return toStruct_MSM_middlebury(objs);
    else if (klass == "OR_imagenet")
        return toStruct_OR_imagenet(objs);
    else if (klass == "OR_mnist")
        return toStruct_OR_mnist(objs);
    else if (klass == "OR_pascal")
        return toStruct_OR_pascal(objs);
    else if (klass == "OR_sun")
        return toStruct_OR_sun(objs);
    else if (klass == "PD_caltech")
        return toStruct_PD_caltech(objs);
    else if (klass == "PD_inria")
        return toStruct_PD_inria(objs);
    else if (klass == "SLAM_kitti")
        return toStruct_SLAM_kitti(objs);
    else if (klass == "SLAM_tumindoor")
        return toStruct_SLAM_tumindoor(objs);
    else if (klass == "TR_chars")
        return toStruct_TR_chars(objs);
    else if (klass == "TR_icdar")
        return toStruct_TR_icdar(objs);
    else if (klass == "TR_svt")
        return toStruct_TR_svt(objs);
    else if (klass == "TRACK_vot")
        return toStruct_TRACK_vot(objs);
    else if (klass == "TRACK_alov")
        return toStruct_TRACK_alov(objs);
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized dataset class %s",klass.c_str());
}

/** Create an instance of Dataset of specified type
 * @param type database type.
 * @return smart pointer to created Dataset
 */
Ptr<Dataset> create_Dataset(const string& type)
{
    Ptr<Dataset> p;
    if (type == "AR_hmdb")
        p = AR_hmdb::create();
    else if (type == "AR_sports")
        p = AR_sports::create();
    else if (type == "FR_adience")
        p = FR_adience::create();
    else if (type == "FR_lfw")
        p = FR_lfw::create();
    else if (type == "GR_chalearn")
        p = GR_chalearn::create();
    else if (type == "GR_skig")
        p = GR_skig::create();
    else if (type == "HPE_humaneva")
        p = HPE_humaneva::create();
    else if (type == "HPE_parse")
        p = HPE_parse::create();
    else if (type == "IR_affine")
        p = IR_affine::create();
    else if (type == "IR_robot")
        p = IR_robot::create();
    else if (type == "IS_bsds")
        p = IS_bsds::create();
    else if (type == "IS_weizmann")
        p = IS_weizmann::create();
    else if (type == "MSM_epfl")
        p = MSM_epfl::create();
    else if (type == "MSM_middlebury")
        p = MSM_middlebury::create();
    else if (type == "OR_imagenet")
        p = OR_imagenet::create();
    else if (type == "OR_mnist")
        p = OR_mnist::create();
    else if (type == "OR_pascal")
        p = OR_pascal::create();
    else if (type == "OR_sun")
        p = OR_sun::create();
    else if (type == "PD_caltech")
        p = PD_caltech::create();
    else if (type == "PD_inria")
        p = PD_inria::create();
    else if (type == "SLAM_kitti")
        p = SLAM_kitti::create();
    else if (type == "SLAM_tumindoor")
        p = SLAM_tumindoor::create();
    else if (type == "TR_chars")
        p = TR_chars::create();
    else if (type == "TR_icdar")
        p = TR_icdar::create();
    else if (type == "TR_svt")
        p = TR_svt::create();
    else if (type == "TRACK_vot")
        p = TRACK_vot::create();
    else if (type == "TRACK_alov")
        p = TRACK_alov::create();
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized dataset %s",type.c_str());
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error", "Failed to create Dataset");
    return p;
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
    nargchk(nrhs>=3 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());
    string klass(rhs[2].toString());

    // Constructor is called. Create a new object from argument
    if (method == "new") {
        nargchk(nrhs==3 && nlhs<=1);
        obj_[++last_id] = create_Dataset(klass);
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }
    // static methods calls
    else if (method == "createDirectory") {
        nargchk(nrhs==4 && nlhs==0);
        string path(rhs[3].toString());
        cv::datasets::createDirectory(path);
        return;
    }
    else if (method == "getDirList") {
        nargchk(nrhs==4 && nlhs<=1);
        string dirName(rhs[3].toString());
        vector<string> fileNames;
        cv::datasets::getDirList(dirName, fileNames);
        plhs[0] = MxArray(fileNames);
        return;
    }
    else if (method == "split") {
        nargchk(nrhs==5 && nlhs<=1);
        string s(rhs[3].toString());
        char delim = (!rhs[4].isEmpty()) ? rhs[4].toString()[0] : ' ';
        vector<string> elems;
        cv::datasets::split(s, elems, delim);
        plhs[0] = MxArray(elems);
        return;
    }

    // Big operation switch
    Ptr<Dataset> obj = obj_[id];
    if (obj.empty())
        mexErrMsgIdAndTxt("mexopencv:error", "Object not found id=%d", id);
    if (method == "delete") {
        nargchk(nrhs==3 && nlhs==0);
        obj_.erase(id);
        mexUnlock();
    }
    else if (method == "typeid") {
        nargchk(nrhs==3 && nlhs<=1);
        plhs[0] = MxArray(string(typeid(*obj).name()));
    }
    else if (method == "load") {
        nargchk(nrhs==4 && nlhs==0);
        obj->load(rhs[3].toString());
    }
    else if (method == "getNumSplits") {
        nargchk(nrhs==3 && nlhs<=1);
        plhs[0] = MxArray(obj->getNumSplits());
    }
    else if (method == "getTrain") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=1);
        int splitNum = 0;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "SplitNum")
                splitNum = rhs[i+1].toInt();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        plhs[0] = toStruct(obj->getTrain(splitNum), klass);
    }
    else if (method == "getTest") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=1);
        int splitNum = 0;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "SplitNum")
                splitNum = rhs[i+1].toInt();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        plhs[0] = toStruct(obj->getTest(splitNum), klass);
    }
    else if (method == "getValidation") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=1);
        int splitNum = 0;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "SplitNum")
                splitNum = rhs[i+1].toInt();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        plhs[0] = toStruct(obj->getValidation(splitNum), klass);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s",method.c_str());
}
