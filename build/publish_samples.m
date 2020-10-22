%% Keep this script in path, then go to mexopencv folder
addpath(pwd);
cd ..
addpath(pwd);

%% Add all dnn networks
if exist('dnn.zip', 'file')
    %unzip('dnn.zip', 'test');
end

%%
% No need to add open_contrib because we copied it into +cv
% addpath(fullfile(pwd, 'open_contrib'))
addpath(pwd)
%% Publish samples
publish_files = dir(fullfile(pwd, 'samples', '*.m'));
addpath(fullfile(pwd, 'samples'));

no_compile = {'asift_demo', 'calibration_capture_demo', ...
    'create_mask_ipt_demo', 'dbt_face_detection_demo', ...
    'dnn_face_detector', 'dnn_object_detection_demo', ...
    'face_eyes_detect_demo', 'facedetect', 'fback_demo', ...
    'feature_homography_track_demo', 'gausian_median_blur_bilateral_filter', ...
    'inpaint_demo', 'kalman_demo', 'knn_demo', ...
    'lk_homography_demo', 'lk_track_demo', 'lsd_lines_demo', ...
    'lucas_kanade_demo', 'mosse_demo', 'mouse_and_match_demo', ...
    'mser_demo', 'non_local_means_demo', 'opt_flow_demo', ...
    'peopledetect_demo', 'phase_corr_demo', 'planar_tracker_demo', ...
    'plane_ar_demo', 'plane_tracker_demo', 'polar_transforms_demo', ...
    'pyrlk_optical_flow_demo', 'segment_objects_demo', 'smiledetect_demo', ...
    'super_resolution_demo', 'synth_video_demo', 'thresholding_demo', ...
    'turing_patterns_demo', 'tvl1_optical_flow_demo', 'video_write_demo', ...
    'watershed_segmentation_demo', 'dnn_face_recognition', 'camshift_track_demo'};

for f_idx = 1:length(publish_files)
    
    fname = fullfile(publish_files(f_idx).folder, publish_files(f_idx).name);
    [~, f, ~] = fileparts(fname);
    if ismember(f, no_compile) || endsWith(f, '_gui')
        execute_script = false;
    else
        execute_script = true;
    end
    
    fprintf('%s (run %d) ... ',fname, execute_script);
    try
        close all
        publish(fname, 'evalCode', execute_script);
        fprintf('Done.\n');
    catch me
        fprintf('Error.\n');
        
        if execute_script
            publish(fname, 'evalCode', false); 
        end
    end
end

rmpath(fullfile(pwd, 'samples'));
%% Publish opencv_contrib/samples

publish_files = dir(fullfile(pwd, 'opencv_contrib', 'samples', '*.m'));
addpath(fullfile(pwd, 'opencv_contrib', 'samples'));

no_compile = {'aruco_calibrate_camera_charuco_demo', 'aruco_calibrate_camera_demo', ...
    'aruco_detect_board_charuco_demo', 'aruco_detect_board_demo', ...
    'aruco_detect_diamonds_demo', 'aruco_detect_markers_demo', 'BackgroundSubtractorDemo', ...
    'bgsegm_synthetic_seq_demo', 'computeSaliency_demo', 'dnn_img_classify_demo', ...
    'dnn_objdetect_demo', 'face_swapping_demo', 'facemark_aam_train_demo', ...
    'facemark_kazemi_detect_img_demo', 'facemark_kazemi_detect_vid_demo', ...
    'facemark_kazemi_train_config_demo', 'facemark_kazemi_train_demo', ...
    'facemark_kazemi_train2_demo', 'facemark_lbf_fitting_demo', 'facemark_lbf_train_demo', ...
    'facerec_demo', 'fld_lines_demo', 'gms_matcher_vid_demo', ...
    'line_extraction_demo', 'line_matching_demo', 'line_radius_matching_demo', ...
    'retina_demo', 'SIFT_detector', 'textboxes_demo', 'textboxes_dnn_demo'};
    
for f_idx = 1:length(publish_files)
    
    fname = fullfile(publish_files(f_idx).folder, publish_files(f_idx).name);
    [~, f, ~] = fileparts(fname);
    if ismember(f, no_compile) || endsWith(f, '_gui')
        execute_script = false;
    else
        execute_script = true;
    end
    
    fprintf('%s (run %d) ... ',fname, execute_script);
    try
        close all
        publish(fname, 'evalCode', execute_script);
        fprintf('Done.\n');
    catch me
        fprintf('Error.\n');
        
        if execute_script
            publish(fname, 'evalCode', false); 
        end
    end
end

rmpath(fullfile(pwd, 'opencv_contrib', 'samples'))

%% Add searchable DB
builddocsearchdb(fullfile(pwd, 'doc'));
