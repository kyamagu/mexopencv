%INFERBBOX  Post-process DNN object detection model predictions
%
%     detections = cv.InferBbox(delta_bbox, class_scores, conf_scores);
%     detections = cv.InferBbox(..., 'OptionName',optionValue, ...);
%
% ## Input
% * **delta_bbox** Blob containing relative coordinates of bounding boxes.
% * **class_scores** Blob containing the probability values of each class.
% * **conf_scores** Blob containing the confidence scores.
%
% ## Output
% * __detections__ Struct-array which holds the final detections of the model.
%   Each structure holds the details pertaining to a single bounding box:
%   * __bbox__ bounding box of the form `[xmin, ymin, xmax, ymax]`
%   * **class_idx** class index.
%   * **label_name** class label.
%   * **class_prob** probability value.
%
% ## Options
% * __Threshold__ threshold to filter the bounding boxes. default 0.8
%
% This function is used with Convolutional Neural Networks for detecting
% objects in an image.
%
% See also: cv.Net
%
