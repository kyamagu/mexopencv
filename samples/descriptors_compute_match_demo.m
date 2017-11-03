%% Detect, Compute, and Match Descriptors
% This program demonstrates how to detect, compute, and match descriptors
% using various algorithms: ORB, BRISK, and AKAZE.
%
% Sources:
%
% * <https://github.com/opencv/opencv/blob/3.2.0/samples/cpp/matchmethod_orb_akaze_brisk.cpp>
%

%%
% load a pair of grayscale images
img1 = cv.imread(fullfile(mexopencv.root(),'test','basketball1.png'), 'Grayscale',true);
img2 = cv.imread(fullfile(mexopencv.root(),'test','basketball2.png'), 'Grayscale',true);

%%
% descriptors we are going to detect and compute
features = {'AKAZEUpright', 'AKAZE', 'KAZE', 'ORB', 'BRISK'};
if true
    features = [features, 'SIFT', 'SURF'];  % xfeatures2d from opencv_contrib
end

%%
% algorithms used to match descriptors
matchers = strcat('BruteForce', {'', '-L1', '-Hamming', '-Hamming(2)'});

%%
% descriptors loop
D = nan(numel(features), numel(matchers));
for i=1:numel(features)
    % create Feature2D object
    switch features{i}
        case 'AKAZEUpright'
            b = cv.AKAZE('DescriptorType','KAZEUpright');
        case 'AKAZE'
            b = cv.AKAZE();
        case 'KAZE'
            b = cv.KAZE();
        case 'ORB'
            b = cv.ORB();
        case 'BRISK'
            b = cv.BRISK();
        case 'SIFT'
            b = cv.SIFT();
        case 'SURF'
            b = cv.SURF();
    end

    % detect and compute descriptors in both images
    [kpts1, desc1] = b.detectAndCompute(img1);
    [kpts2, desc2] = b.detectAndCompute(img2);

    % matchers loop
    for j=1:numel(matchers)
        % create DescriptorMatcher object
        m = cv.DescriptorMatcher(matchers{j});

        % warn about invalid combinations of descriptors and matchers
        valid = true;
        mHam = ~isempty(strfind(matchers{j}, 'Hamming'));
        bHam = ~isempty(strfind(b.defaultNorm(), 'Hamming'));
        if mHam && (~bHam || strcmp(b.descriptorType, 'single'))
            fprintf(2, 'Hamming distance only for binary descriptors\n');
            if mexopencv.isOctave()
                %HACK: avoid unhandled C++ expections, they can crash Octave!
                valid = false;
            end
        end
        if ~mHam && bHam
            fprintf(2, 'L1 or L2 distance not for binary descriptors\n');
        end

        fprintf('%s + %s:\n', features{i}, matchers{j});
        fprintf(' %d keypoints in img1\n', numel(kpts1));
        fprintf(' %d keypoints in img2\n', numel(kpts2));
        try
            % match descriptors
            assert(valid);
            matches = m.match(desc1, desc2);
            fprintf(' %d matches\n', numel(matches));

            % save matches to file
            fname = sprintf('%s_%s.yml', features{i}, matchers{j});
            fname = fullfile(tempdir(), fname);
            cv.FileStorage(fname, struct('Matches',matches));

            % Keep only best 30 matches to have a nice drawing (sorted by dist)
            [~,ord] = sort([matches.distance]);
            ord(31:end) = [];
            matches = matches(ord);

            % pretty print matches
            if ~mexopencv.isOctave()
                t = struct2table(matches);
                t.imgIdx = [];
                display(t)
            else
                %HACK: no tables in Octave
                t = cat(1, matches.distance);
                display(t)
            end

            % draw matches and show result
            out = cv.drawMatches(img1, kpts1, img2, kpts2, matches);
            figure, imshow(out)
            title(sprintf('%s + %s', features{i}, matchers{j}))

            % compute total distances between keypoint matches
            pts1 = cat(1, kpts1([matches.queryIdx]+1).pt);
            pts2 = cat(1, kpts2([matches.trainIdx]+1).pt);
            D(i,j) = sum(sqrt(sum((pts1 - pts2).^2, 2)));
            fprintf(' %f total error\n', D(i,j));
        catch ME
            fprintf(' matching failed\n');
            %warning(getReport(ME))
        end
        fprintf('%s\n', repmat('-',1,80));
    end
end

%%
% Cumulative distances between matched keypoint
% for different matchers and feature detectors
if ~mexopencv.isOctave()
    t = array2table(D, 'RowNames',features, ...
        'VariableNames',regexprep(matchers,'\W',''));
    display(t)
else
    %HACK: no tables in Octave
    display(D)
end
