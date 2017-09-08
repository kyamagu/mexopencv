function [pkg, filenames] = MavenDownload(varargin)
    %MAVENDOWNLOAD  Downloads JAR artifacts from Maven Central
    %
    %     pkg = MavenDownload(groupId, artifactId)
    %     pkg = MavenDownload(..., 'OptionName',optionValue, ...)
    %     [pkg, filenames] = MavenDownload(...)
    %
    % ## Input
    % * __groupId__ group Id (organization name), may be empty if there is no
    %   ambiguity.
    % * __artifactId__ artifact Id (module name).
    %
    % ## Options
    % * __Version__ (optional) package version. If not specified, the
    %   latest version is requested.
    % * __SkipDependencies__ Decide if dependencies should not be processed.
    %   Default false.
    % * __Download__ Decide if packages should be downloaded. Default true.
    % * __Verbose__ Verbosity messages. Default true.
    % * __OutDir__ Directory where to place downloaded JAR files. By default,
    %   the current directory is used.
    %
    % ## Output
    % * __pkg__ struct describing the package and its dependencies
    % * __filenames__ Full paths to downloaded JAR files.
    %
    % This is a poor man's implementation of a Java package manager.
    % It searches the [Maven Central Repository](http://search.maven.org/)
    % and downloads a package JAR file and its dependencies.
    %
    % The Maven REST API is documented [here](http://search.maven.org/#api).
    %
    % ## Example
    %
    %     MavenDownload('org.jsoup', 'jsoup', 'OutDir','jsoup')
    %     MavenDownload('org.commonjava.googlecode.markdown4j', 'markdown4j', 'OutDir','markdown4j')
    %     MavenDownload('org.markdownj', 'markdownj-core', 'OutDir','markdownj')
    %     MavenDownload('org.tautua.markdownpapers', 'markdownpapers-core', 'OutDir','markdownpapers')
    %     MavenDownload('org.pegdown', 'pegdown', 'OutDir','pegdown')
    %     MavenDownload('com.github.rjeschke', 'txtmark', 'OutDir','txtmark')
    %     MavenDownload('com.atlassian.commonmark', 'commonmark', 'OutDir','commonmark-java')
    %     MavenDownload('com.atlassian.commonmark', 'commonmark-ext-gfm-tables', 'OutDir','commonmark-java')
    %
    % See also: webread, websave, urlencode, jsondecode
    %

    % parse inputs
    nargoutchk(0,2);
    opts = parse_options(varargin{:});

    % find requested package
    pkg = struct();
    pkg.groupId = opts.groupId;
    pkg.artifactId = opts.artifactId;
    pkg.version = opts.version;

    % search for latest version if none specified
    if isempty(pkg.groupId) || isempty(pkg.version)
        pkg = package_search(pkg, opts);
    end

    % find dependencies
    if ~opts.SkipDependencies
        pkg = package_dependencies(pkg, opts);
    end

    % download JAR files (including all dependencies)
    if opts.Download
        filenames = package_download(pkg, opts);
    end
end

function opts = parse_options(varargin)
    %PARSE_OPTIONS  Help function to parse function inputs

    % helper function to validate true/false arguments
    isbool = @(x) isscalar(x) && (islogical(x) || isnumeric(x));

    p = inputParser();
    p.addRequired('groupId', @ischar);
    p.addRequired('artifactId', @(x) ischar(x) && ~isempty(x));
    p.addParameter('version', '', @ischar);
    p.addParameter('SkipDependencies', false, isbool);
    p.addParameter('Download', true, isbool);
    p.addParameter('Verbose', true, isbool);
    p.addParameter('OutDir', '', @ischar);
    p.parse(varargin{:});

    opts = p.Results;
    opts.SkipDependencies = logical(opts.SkipDependencies);
    opts.Download = logical(opts.Download);
    opts.Verbose = logical(opts.Verbose);
end

function pkg = package_search(pkg, opts)
    %PACKAGE_SEARCH  Search for package from Maven by artifact Id

    % search by artifact id
    if opts.Verbose, disp(['Searching... ' pkg.artifactId]); end
    url = 'http://search.maven.org/solrsearch/select';
    query = {'q',sprintf('a:"%s"',pkg.artifactId), 'rows',5, 'wt','json'};
    data = webread(url, query{:}, weboptions('ContentType','json'));

    % check number of results
    assert(~isempty(data), 'No data received');
    res = data.response;
    if res.numFound == 0
        error('mexopencv:err', ...
            'artifactId = "%s" was not found', pkg.artifactId);
    elseif res.numFound > 1 && isempty(pkg.groupId)
        %disp({res.docs.g})
        error('mexopencv:err', ...
            'Ambiguous artifactId = "%s", specify groupId', pkg.artifactId);
    end

    % match groupId if specified
    idx = 1;
    if ~isempty(pkg.groupId)
        g = {res.docs.g};
        if res.numFound > 1
            [~,idx] = ismember(validatestring(pkg.groupId, g), g);
        else
            assert(strcmp(pkg.groupId, g{1}), ...
                'groupId = "%s" does not match "%s"', pkg.groupId, g{1});
        end
    end

    % unique project name
    pkg.groupId = res.docs(idx).g;
    pkg.artifactId = res.docs(idx).a;
    if isempty(pkg.version)
        pkg.version = res.docs(idx).latestVersion;
    end
end

function pkg = package_dependencies(pkg, opts)
    %PACKAGE_DEPENDENCIES  Fill package dependencies

    %TODO: cache dependencies to avoid fetching same POM multiple times
    %TODO: cyclic dependencies

    % fetch POM XML file
    fpath = package_filepath(pkg, '.pom');
    if opts.Verbose, disp(['Fetching... ' fpath]); end
    url = 'http://search.maven.org/remotecontent';
    query = {'filepath',fpath};
    pom = webread(url, query{:}, weboptions('ContentType','xmldom'));

    % parse it for dependencies (and transitive dependencies)
    pkg.deps = parse_pom(pom);
    for i=1:numel(pkg.deps)
        pkg.deps(i) = package_dependencies(pkg.deps(i), opts);
    end
end

function filenames = package_download(pkg, opts)
    %PACKAGE_DOWNLOAD  Download JAR package and its dependencies

    % fetch JAR file
    [fpath, filename] = package_filepath(pkg, '.jar');
    if ~isempty(opts.OutDir)
        filename = fullfile(opts.OutDir, filename);
        if ~isdir(opts.OutDir)
            mkdir(opts.OutDir);
        end
    end
    if exist(filename, 'file') ~= 2
        if opts.Verbose, disp(['Downloading... ' fpath]); end
        url = 'http://search.maven.org/remotecontent';
        query = {'filepath',fpath};
        filename = websave(filename, url, query{:});
    else
        if opts.Verbose, disp(['Skipped ' fpath]); end
    end
    filenames = filename;

    % download dependencies
    if ~opts.SkipDependencies
        fnames = cell(size(pkg.deps));
        for i=1:numel(pkg.deps)
            fnames{i} = package_download(pkg.deps(i), opts);
        end

        % combine and flatten names
        filenames = [filenames fnames];
        while any(cellfun(@iscell, filenames))
            filenames = [filenames{:}];
        end
        filenames = unique(filenames, 'stable');
    end
end

function [fpath, filename] = package_filepath(pkg, packaging)
    %PACKAGE_FILEPATH  Construct path to fetch package from Maven Central

    % fpath = org/github/com/my-project/1.0.0/my-project-1.0.0.jar
    assert(~isempty(pkg.groupId));
    assert(~isempty(pkg.artifactId));
    assert(~isempty(pkg.version));
    packaging = validatestring(packaging, ...
        {'.pom', '.jar', '-sources.jar', '-javadoc.jar'});
    filename = sprintf('%s-%s%s', pkg.artifactId, pkg.version, packaging);
    fpath = sprintf('%s/%s/%s/%s', ...
        strrep(pkg.groupId,'.','/'), pkg.artifactId, pkg.version, filename);
end

function deps = parse_pom(pom)
    %PARSE_POM  Extract dependencies from POM document DOM
    %
    % See also: xmlread
    %

    % output structure-array of dependencies
    deps = struct('groupId',{}, 'artifactId',{}, 'version',{}, 'deps',{});
    k = 1;  % insertion index

    % debug
    %{
    disp(pom.saveXML([]));
    keyboard
    %}

    % get <dependencies> tag
    nodes = pom.getElementsByTagName('dependencies').item(0);
    if isempty(nodes)
        return;  % no dependencies
    end

    % check if contains a <parent> tag
    node = pom.getElementsByTagName('parent').item(0);
    if ~isempty(node)
        p_groupId = getElementTextByTagName(node, 'groupId');
        p_artifactId = getElementTextByTagName(node, 'artifactId');
        p_version = getElementTextByTagName(node, 'version');
    else
        p_groupId = '';
        p_artifactId = '';
        p_version = '';
    end

    % loop over child <dependency> tags
    for i=1:nodes.getLength()
        node = nodes.item(i-1);

        % skip anything other than <dependency> (text/comments/etc. nodes)
        if node.getNodeType() ~= 1 || ~strcmp(node.getNodeName(), 'dependency')
            continue;
        end

        % check dependency <scope> and ignore test dependencies
        scope = getElementTextByTagName(node, 'scope');
        if ~isempty(scope) && strcmp(scope, 'test')
            continue;
        end

        % get dependency <groupId>, <artifactId>, <version>
        deps(k).groupId = getElementTextByTagName(node, 'groupId');
        deps(k).artifactId = getElementTextByTagName(node, 'artifactId');
        deps(k).version = getElementTextByTagName(node, 'version');

        %HACK: fill empty fields with parent fields
        if isempty(deps(k).groupId)
            deps(k).groupId = p_groupId;
        end
        if isempty(deps(k).artifactId)
            deps(k).artifactId = p_artifactId;
        end
        if isempty(deps(k).version)
            deps(k).version = p_version;
        end

        % prepare for next entry
        k = k + 1;
    end
end

function txt = getElementTextByTagName(node, tag)
    %GETELEMENTTEXTBYTAGNAME  Helper function to get text content of tag node

    % equivalent to: txt = node.select('tag').first().text()
    nodeTAG = node.getElementsByTagName(tag).item(0);
    if ~isempty(nodeTAG)
        txt = char(nodeTAG.getFirstChild().getTextContent());
    else
        txt = '';
    end
end
