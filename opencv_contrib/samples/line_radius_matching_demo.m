%% Line descriptors radius matching demo
% This example shows the functionalities of radius matching.
%
% Sources:
%
% * <https://github.com/opencv/opencv_contrib/blob/3.1.0/modules/line_descriptor/samples/radius_matching.cpp>
%

%% Querying internal database
% The |cv.BynaryDescriptorMatcher| class, owns an internal database that can
% be populated with descriptors extracted from different images and queried
% using one of the modalities described in previous section. Population of
% internal dataset can be done using the |add| function; such function
% doesn't directly add new data to database, but it just stores it them
% locally. The real update happens when function |train| is invoked or when
% any querying function is executed, since each of them invokes train before
% querying. When queried, internal database not only returns required
% descriptors, but, for every returned match, it is able to tell which image
% matched descriptor was extracted from. An example of internal dataset usage
% is described in the following code; after adding locally new descriptors,
% a radius search is invoked. This provokes local data to be transferred to
% dataset, which, in turn, is then queried.
%

%% Images
images = {
    fullfile(mexopencv.root(),'test','stuff.jpg')
    fullfile(mexopencv.root(),'test','blox.jpg')
    fullfile(mexopencv.root(),'test','books_left.jpg')
    fullfile(mexopencv.root(),'test','books_right.jpg')
    fullfile(mexopencv.root(),'test','detect_blob.png')
};

%% Detect and Compute

% create a BinaryDescriptor object
bd = cv.BinaryDescriptor();

% compute keylines and descriptors
descriptorsMat = cell(size(images));
lines = cell(size(images));
for i=1:numel(images)
    % load image
    img = cv.imread(images{i}, 'Grayscale',true);

    % compute lines and descriptors
    [lines{i}, descriptorsMat{i}] = bd.detectAndCompute(img);
end
display(lines)
display(descriptorsMat)

%% Query
% compose a queries matrix
queries = zeros(0, size(descriptorsMat{1},2));
for i=1:numel(descriptorsMat)
    if size(descriptorsMat{i},1) >= 5
        queries = [queries; descriptorsMat{i}(1:5,:)];
    else
        queries = [queries; descriptorsMat{i}];
    end
end
fprintf('Query matrix of %d descriptors\n', size(queries,1));
fprintf('Total taining descriptions: %d\n', ...
    sum(cellfun(@(d)size(d,1), descriptorsMat, 'UniformOutput',true)));

%% Radius match

% create a BinaryDescriptorMatcher object
bdm = cv.BinaryDescriptorMatcher();

% populate matcher
bdm.add(descriptorsMat);

% compute matches
matches = bdm.radiusMatch(queries, 30)
fprintf('Found %d matches\n', numel(matches));

for i=1:numel(matches)
    for j=1:numel(matches{i})
        fprintf('  match: %3d <-> %3d = %g\n', ...
            matches{i}(j).queryIdx, matches{i}(j).trainIdx, ...
            matches{i}(j).distance);
    end
end
