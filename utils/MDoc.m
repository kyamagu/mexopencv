function varargout = MDoc(varargin)
    %MDOC  mexopencv documentation utility
    %
    %     MDoc()
    %     MDoc(action)
    %     MDoc(topic)
    %     MDoc(..., 'OptionName',optionValue, ...)
    %     filename = MDoc(...)
    %
    % ## Input
    % * __action__ Special targets (default `-all`). One of:
    %   * `-clean`: delete all generated docs.
    %   * `-wiki`: generate HTML wiki files.
    %   * `-all`: generate full documentation for all mexopencv functions.
    %   * `-index`: only generate table of contents.
    %   * `-indexcat`: only generate table of contents (grouped by modules).
    %   * `-contents`: generate Contents.m file.
    %   * `-helptoc`: generate helpfuncbycat.xml file (TOC function reference).
    % * __topic__ generate docs for specified mexopencv function.
    %
    % ## Output
    % * __filename__ optional, generated HTML file path.
    %
    % ## Options
    % * __Force__ Unconditionally re-create HTML output files. default true
    % * __MarkdownRender__ Process markdown. default true
    % * __MarkdownBackend__ Markdown parser implementation to use. The
    %   following backends are available to choose from:
    %   * 'CommonMark-Java' (https://github.com/atlassian/commonmark-java/)
    %   * 'MarkdownPapers' (https://github.com/lruiz/MarkdownPapers/)
    %   * 'pegdown' (https://github.com/sirthias/pegdown/)
    %   * 'MarkdownJ' (https://github.com/myabc/markdownj/)
    %   * 'Markdown4j' (https://github.com/jdcasey/markdown4j/)
    %   * 'Txtmark' (https://github.com/rjeschke/txtmark/)
    % * __AutoLinking__ search for "http://" in text and convert them into
    %   hyperlinks. default false
    % * __AutoLinkingDeep__ search for "www." in text and convert them into
    %   hyperlinks. default false
    % * __AutoLinkingCV__ search for "cv.*" functions in text, and convert
    %   them into hyperlinks. default true
    % * __SyntaxHighlighting__ syntax highlighted code. default true
    % * __PrettifyLang__ language of syntax highlighting. default 'lang-matlab'
    % * __TableSorting__ sortable HTML tables (used in index.html).
    %   default true
    % * __NoExternals__ download all CSS/JS external resources locally.
    %   default true
    %
    % ## Options (batch mode)
    % * __IndexGroups__ group by OpenCV module in index. default true
    % * __IgnoreHandleClass__ skip generating redundant docs for methods
    %   inherited from "handle" base class. default true
    % * __Verbose__ Display info messages. default true
    % * __Progress__ Show progress bar. default true
    %
    % This function generates simple MATLAB HTML documentation using
    % MATLAB's internal utility help2html.
    %
    % See also: doc, help, help2html, publish
    %

    % validate input arguments
    nargoutchk(0, 1);
    opts = parse_options(varargin{:});

    % initialize Java dependencies
    init_jsoup(opts);
    init_markdown(opts);

    if strcmp(opts.topic, '-clean')
        % clean all docs
        if isdir(opts.DIR)
            if opts.Verbose, fprintf('Cleaning %s\n', opts.DIR); end
            rmdir(opts.DIR, 's');
        end
        return;
    elseif ~any(strcmp(opts.topic, {'-wiki', '-contents', '-helptoc'}))
        if ~isdir(opts.DIR)
            % prepare output directory and CSS stylesheets
            if opts.Verbose, fprintf('Creating %s\n', opts.DIR); end
            mkdir(opts.DIR);
            copy_stylesheets(opts);
        end
    end

    % generate docs
    [filename, isbatch, needed] = get_output_filename(opts, opts.topic);
    if needed
        switch opts.topic
            case '-wiki'
                download_wiki(opts);
                generate_wiki(opts);
            case '-all'
                generate_all_docs(opts);
            case {'-index', '-indexcat'}
                txt = generate_index(opts, opts.topic);
            case '-contents'
                txt = generate_contents_m(opts);
            case '-helptoc'
                txt = generate_helptoc_xml(opts);
            otherwise
                txt = generate_doc(opts, opts.topic);
        end
        if ~isbatch
            % write to file
            assert(~isempty(txt), 'No doc generated');
            filewrite(filename, txt);
        end
    end

    % return/show result
    if nargout > 0
        % return output filename
        varargout{1} = filename;
    else
        if ~isbatch
            % open documentation in embedded browser or editor
            [~,~,ext] = fileparts(filename);
            if strcmp(ext, '.html')
                web(filename, '-new');
            else
                edit(filename);
            end
        else
            % show output directory
            if ispc()
                winopen(filename);
            else
                disp(filename);
            end
        end
    end
end

function opts = parse_options(varargin)
    %PARSE_OPTIONS  Parse function input argument

    % helper function to validate true/false arguments
    isbool = @(x) isscalar(x) && (islogical(x) || isnumeric(x));

    % parse input arguments
    p = inputParser();
    p.addOptional('topic', '-all', @ischar);
    p.addParameter('Force', true, isbool);
    p.addParameter('MarkdownRender', true, isbool);
    p.addParameter('MarkdownBackend', 'commonmark-java', @ischar);
    p.addParameter('AutoLinking', false, isbool);
    p.addParameter('AutoLinkingDeep', false, isbool);
    p.addParameter('AutoLinkingCV', true, isbool);
    p.addParameter('SyntaxHighlighting', true, isbool);
    p.addParameter('PrettifyLang', 'lang-matlab', @ischar);
    p.addParameter('TableSorting', true, isbool);
    p.addParameter('NoExternals', true, isbool);
    p.addParameter('IndexGroups', true, isbool);
    p.addParameter('IgnoreHandleClass', true, isbool);
    p.addParameter('Verbose', true, isbool);
    p.addParameter('Progress', true, isbool);

    % options struct
    p.parse(varargin{:});
    opts = p.Results;

    % documentation output directory
    opts.DIR = fullfile(mexopencv.root(), 'doc', 'matlab');

    % validate topic/action
    if strncmp(opts.topic, '-', 1)
        opts.topic = validatestring(opts.topic, ...
            {'-clean', '-wiki', '-all', '-index', '-indexcat', '-contents', '-helptoc'});
    elseif ~strncmp(opts.topic, 'cv.', 3)
        % prepend "cv." prefix to topic name if necessary
        opts.topic = ['cv.' opts.topic];
    end

    % list of recognized backends
    backends = {
        'commonmark-java'
        'MarkdownPapers'
        'pegdown'
        'markdownj'
        'markdown4j'
        'txtmark'
    };
    opts.MarkdownBackend = validatestring(opts.MarkdownBackend, backends);

    opts.Ignore = {};
    if opts.IgnoreHandleClass
        % methods/properties/events inherited from "handle"
        opts.Ignore = union(opts.Ignore, methods('handle'));
        opts.Ignore = union(opts.Ignore, properties('handle'));
        opts.Ignore = union(opts.Ignore, events('handle'));
        opts.Ignore = setdiff(opts.Ignore, 'delete');  % exclude dtor
    end
end

function init_jsoup(opts)
    %INIT_JSOUP  Download and setup the jsoup Java library

    persistent initialized
    if isempty(initialized), initialized = false; end
    if ~initialized
        % download if it doesn't exist
        dname = fullfile(mexopencv.root(), 'utils', 'jars', 'jsoup');
        if ~isdir(dname)
            MavenDownload('org.jsoup', 'jsoup', 'OutDir',dname, ...
                'Verbose',opts.Verbose);
        end

        % add all JAR files to classpath
        if opts.Verbose, disp('Initializing jsoup'); end
        JavaAddJarDir(dname);

        % mark as initialized
        initialized = true;
    end
end

function init_markdown(opts)
    %INIT_MARKDOWN  Download and setup backend Markdown Java libraries

    persistent initialized
    if isempty(initialized), initialized = {}; end
    if ~ismember(opts.MarkdownBackend, initialized)
        % download if it doesn't exist
        dname = fullfile(mexopencv.root(), 'utils', 'jars', opts.MarkdownBackend);
        if ~isdir(dname)
            % group and artifact ids
            switch opts.MarkdownBackend
                case 'commonmark-java'
                    groupId = 'com.atlassian.commonmark';
                    artifactId = 'commonmark';
                case 'MarkdownPapers'
                    groupId = 'org.tautua.markdownpapers';
                    artifactId = 'markdownpapers-core';
                case 'pegdown'
                    groupId = 'org.pegdown';
                    artifactId = 'pegdown';
                case 'markdownj'
                    groupId = 'org.markdownj';
                    artifactId = 'markdownj-core';
                case 'markdown4j'
                    groupId = 'org.commonjava.googlecode.markdown4j';
                    artifactId = 'markdown4j';
                case 'txtmark'
                    groupId = 'com.github.rjeschke';
                    artifactId = 'txtmark';
                otherwise
                    error('Unrecognized Markdown backend')
            end
            MavenDownload(groupId, artifactId, 'OutDir',dname, ...
                'Verbose',opts.Verbose);
        end

        % add all JAR files to classpath
        if opts.Verbose, fprintf('Initializing %s\n', opts.MarkdownBackend); end
        JavaAddJarDir(dname);

        % mark as initialized
        initialized = union(initialized, opts.MarkdownBackend);
    end
end

function JavaAddJarDir(dname)
    %JAVAADDJARDIR  Add all jar files inside a directory to Java class path

    % list of JAR files inside directory
    jars = dir(fullfile(dname, '*.jar'));
    jars = {jars.name};

    % only keep those not already on the Java class path
    jcp = javaclasspath();
    idx = cellfun(@(j) all(cellfun(@isempty, strfind(jcp, j))), jars);
    jars = jars(idx);

    % put remaining jars on classpath
    if ~isempty(jars)
        jars = cellfun(@(j) fullfile(dname, j), jars, 'UniformOutput',false);
        javaaddpath(jars);
    end
end

function copy_stylesheets(opts)
    %COPY_STYLESHEETS  Copy CSS stylesheets to output directory

    % copy default stylesheet locally
    CSS = fullfile(toolboxdir('matlab'), 'helptools', 'private', 'helpwin.css');
    copyfile(CSS, opts.DIR);

    % copy second stylesheet with customization
    CSS = fullfile(fileparts(mfilename('fullpath')), 'helpwin_custom.css');
    copyfile(CSS, opts.DIR);
end

function [filename, isbatch, needed] = get_output_filename(opts, topic, fname)
    %GET_OUTPUT_FILENAME  Output filename according to action

    isbatch = false;
    switch topic
        case '-wiki'
            if nargin > 2
                [~,fname,~] = fileparts(fname);
                filename = [strrep(lower(fname), '-', '_') '.html'];
                filename = fullfile(mexopencv.root(), 'doc', 'wiki', filename);
            else
                filename = fullfile(mexopencv.root(), 'doc', 'wiki');
                isbatch = true;
            end
        case '-all'
            filename = opts.DIR;
            isbatch = true;
        case '-index'
            filename = fullfile(opts.DIR, 'index.html');
        case '-indexcat'
            filename = fullfile(opts.DIR, 'index_cat.html');
        case '-contents'
            filename = fullfile(mexopencv.root(), 'Contents.m');
        case '-helptoc'
            filename = fullfile(mexopencv.root(), 'doc', 'helpfuncbycat.xml');
        otherwise
            filename = fullfile(opts.DIR, [topic '.html']);
    end

    % checks if file already exists
    needed = isbatch || opts.Force || exist(filename, 'file') ~= 2;
end

function files = download_wiki(opts)
    %DOWNLOAD_WIKI  Download wiki files from GitHub

    % list of Wiki files
    dname = get_output_filename(opts, '-wiki');
    files = {
        'README.md'
        'Home.md'
        'Getting-Started.md'
        'Developing-a-new-MEX-function.md'
        'Gotchas.md'
        'Installation-(Windows,-MATLAB,-OpenCV-3).md'
        'Installation-(Windows,-Octave,-OpenCV-3).md'
        'Installation-(Linux,-MATLAB,-OpenCV-3).md'
        'Installation-(Linux,-Octave,-OpenCV-3).md'
        'Installation-(Windows,-MATLAB,-OpenCV-2).md'
        'Troubleshooting-(Windows).md'
        'Troubleshooting-(UNIX).md'
    };

    % download from GitHub
    % (git clone https://github.com/kyamagu/mexopencv.wiki.git)
    url = 'https://rawgit.com/wiki/kyamagu/mexopencv/';
    if ~isdir(dname), mkdir(dname); end
    copyfile(fullfile(mexopencv.root(), 'README.markdown'), fullfile(dname, files{1}));
    for i=2:numel(files)
        fname = fullfile(dname, files{i});
        if exist(fname, 'file') ~= 2 % || opts.Force
            if opts.Verbose, fprintf('Downloading %s...\n', files{i}); end
            urlwrite([url files{i}], fname);
        end
    end
end

function generate_wiki(opts)
    %GENERATE_WIKI  Generate HTML docs from Wiki files

    % process markdown files
    dname = get_output_filename(opts, '-wiki');
    files = dir(fullfile(dname, '*.md'));
    for i=1:numel(files)
        % convert and save as HTML
        fname = fullfile(dname, files(i).name);
        [filename, ~, needed] = get_output_filename(opts, '-wiki', fname);
        if needed
            txt = wiki_md2html(opts, fname);
            assert(~isempty(txt), 'Failed to convert Markdown');
            filewrite(filename, txt);
        end
    end
end

function generate_all_docs(opts)
    %GENERATE_ALL_DOCS  Generate full docs for all functions

    % create index.html
    [filename, ~, needed] = get_output_filename(opts, '-index');
    if needed
        if opts.Verbose, disp('Creating index...'); end
        txt = generate_index(opts, '-index');
        assert(~isempty(txt), 'Failed to generate index');
        filewrite(filename, txt);
    end

    % create index_cat.html
    [filename, ~, needed] = get_output_filename(opts, '-indexcat');
    if needed
        if opts.Verbose, disp('Creating index...'); end
        txt = generate_index(opts, '-indexcat');
        assert(~isempty(txt), 'Failed to generate index');
        filewrite(filename, txt);
    end

    % get a list of functions/classes
    list = enumerate_mexopencv_members(opts);

    % show progress
    if opts.Progress
        hWait = waitbar(0, 'Generating docs...', 'Name',mfilename(), ...
            'CreateCancelBtn','setappdata(gcbf,''cancel'',true)');
        setappdata(hWait, 'cancel',false);
        wbCleanObj = onCleanup(@() delete(hWait));
    end

    % process all functions
    if opts.Verbose, disp('Creating docs...'); end
    for i=1:numel(list)
        % next topic to process
        topic = list{i};
        if opts.Progress
            waitbar(i/numel(list), hWait, strrep(topic, '_', '\_'));
            if getappdata(hWait, 'cancel'), break; end
        end

        % generate HTML doc file
        [filename, ~, needed] = get_output_filename(opts, topic);
        if needed
            txt = generate_doc(opts, topic);
            if ~isempty(txt)
                filewrite(filename, txt);
                status = 'DONE';
            else
                % non-existant cv function
                % (doc/help/help2html cannot process hidden and private methods)
                %TODO: it seems thats no longer the case in recent versions,
                % we need to filter them in enumerate_mexopencv_members
                status = 'MISSING';
            end
            if opts.Verbose, fprintf('[%s] %s\n', status, topic); end
        end
    end
end

function txt = generate_doc(opts, topic)
    %GENERATE_DOC  Generate HTML docs for a function, class method/member, etc.

    % convert M-help into parsed HTML document
    jdoc = parse_help2html(opts, topic);
    if isempty(jdoc)
        txt = '';
        return;
    end

    % convert document back to HTML string
    txt = char(jdoc.toString());
end

function txt = generate_index(opts, topic)
    %GENERATE_INDEX  Create index.html/index_cat.html containing list of all functions

    % HTML doc of cv package function/class names and their H1-lines
    opts.MarkdownRender = false;  % turn off markdown processing for index
    jdoc = parse_help2html(opts, 'cv');
    if isempty(jdoc)
        txt = '';
        return;
    end

    % replace title near the top
    div = jdoc.select('div.title').empty().first();
    assert(~isempty(div), '<div> not found');
    a = div.appendElement('a');
    a.text('mexopencv').attr('href', 'https://github.com/kyamagu/mexopencv');
    % append description after it
    p = jdoc.createElement('p').addClass('h1line');
    p.appendText('Collection and development kit of MATLAB MEX functions for ');
    p.appendElement('a').text('OpenCV').attr('href', 'https://opencv.org/');
    p.appendText(' library.');
    div.after(p);

    % extract listing of cv package function/class names and their H1-lines
    pre = jdoc.select('div.helptext > pre').first();
    assert(~isempty(pre), '<pre> not found');
    txt = char(pre.text());
    t = create_files_table(opts, txt);

    % format it as HTML table(s)
    switch topic
        case '-index'
            % one big table
            txt = table_to_index_html(opts, t);
        case '-indexcat'
            % one table per module
            txt = table_to_index_cat_html(opts, t);
        otherwise
            txt = '';
    end

    % insert table(s)
    div = pre.parent();
    assert(~isempty(div), '<div> not found');
    div.removeClass('helptext').addClass('helpcontent');
    div.html(txt);

    % style table(s)
    tabl = div.select('table');
    assert(~isempty(tabl), '<table> not found');
    tabl.addClass('table');
    if opts.TableSorting
        tabl.addClass('sortable');  % enable_sortable_tables
    end

    % convert document back to HTML string
    txt = char(jdoc.toString());
end

function txt = generate_contents_m(opts)
    %GENERATE_CONTENTS_M  Create Contents.m containing list of all functions

    % cv package function/class names and their H1-lines
    txt = help('cv');
    if isempty(txt)
        return;
    end

    % parse text into table
    t = create_files_table(opts, txt);

    % format table as contents.m file
    txt = table_to_contents_m(opts, t);
end

function txt = generate_helptoc_xml(opts)
    %GENERATE_HELPTOC_XML  Create helpfuncbycat.xml containing list of all functions

    % cv package function/class names and their H1-lines
    txt = help('cv');
    if isempty(txt)
        return;
    end

    % parse text into table
    t = create_files_table(opts, txt);

    % format table as helpfuncbycat.xml file
    txt = table_to_helptoc_xml(opts, t);
end

function t = create_files_table(opts, txt)
    %CREATE_FILES_TABLE  Build table containing list of all mexopencv files

    % split by lines
    C = textscan(txt, '%s', 'Delimiter','\n');
    C = C{1};
    C(cellfun(@isempty, C)) = [];

    % remove section headers
    str = 'Contents of ';
    C(strncmp(C, str, numel(str))) = [];

    % remove simcoverage entry cv.schema
    str = 'schema ';
    C(strncmp(C, str, numel(str))) = [];

    % split each line: "name - description"
    C = regexp(C, ' - ', 'split', 'once');
    C = strtrim(cat(1, C{:}));

    % add cv. prefix to name
    C(:,1) = strcat('cv.', C(:,1));

    % create table
    t = cell2table(C, 'VariableNames',{'names','descriptions'});

    if opts.IndexGroups
        % extract OpenCV module names for each mexopencv function
        tt = enumerate_mexopencv_files(opts);

        % join the two tables by name
        t = innerjoin(t, tt, 'Keys','names');

        % sort table
        t = sortrows(t, {'repos', 'modules', 'names'});
    end
end

function txt = table_to_index_html(opts, t)
    %TABLE_TO_INDEX_HTML  Format table of mexopencv files as HTML table

    if opts.IndexGroups
        linkify = @(p) strrep(strrep(p, mexopencv.root(), ...
            'https://github.com/kyamagu/mexopencv/blob/master'), '\', '/');
        txt = strcat('<tr>', ...
            '<td><a href="', t.names, '.html">', t.names, '</a></td>', ...
            '<td>', t.modules, '</td>', ...
            '<td>', t.repos, '</td>', ...
            '<td>', t.descriptions, '</td>', ...
            '<td><a href="', linkify(t.cppfiles), '">C</a>&nbsp;', ...
            '<a href="', linkify(t.mfiles), '">M</a>&nbsp;', ...
            '<a href="', linkify(t.tfiles), '">T</a></td>', ...
            '</tr>');
        txt = strjoin({
            '<table>'
            '<thead><tr><th>Name</th><th>Module</th><th>Repo</th>'
            '<th>Description</th><th>Source Files</th></tr></thead>'
            '<tbody>'
            strjoin(txt, '\n')
            '</tbody>'
            '</table>'
        }, '\n');
    else
        txt = strcat(...
            '<tr><td><a href="', t.names, '.html">', t.names, '</a></td>', ...
            '<td>', t.descriptions, '</td></tr>');
        txt = strjoin({
            '<table>'
            '<thead><tr><th>Name</th><th>Description</th></tr></thead>'
            '<tbody>'
            strjoin(txt, '\n')
            '</tbody>'
            '</table>'
        }, '\n');
    end
end

function txt = table_to_index_cat_html(opts, t)
    %TABLE_TO_INDEX_CAT_HTML  Format table of mexopencv files as HTML tables

    opts.IndexGroups = false; % for the table_to_index_html calls below

    % format list of files as HTML tables, one per module
    txt = {};
    [repos,~,rid] = unique(t.repos);
    for r=1:max(rid)
        tt = t(rid == r,:);
        [modules,~,mid] = unique(tt.modules);
        txt{end+1} = sprintf('<h1 id="%s">%s</h1>', repos{r}, repos{r});
        for m=1:max(mid)
            ttt = tt(mid == m,:);
            txt{end+1} = sprintf('<h4 id="%s">%s</h4>', modules{m}, modules{m});
            txt{end+1} = table_to_index_html(opts, ttt);
        end
    end
    txt = strjoin(txt, '\n');
end

function txt = table_to_contents_m(opts, t)
    %TABLE_TO_CONTENTS_M  Format table of mexopencv files as contents.m file

    % formatting string for each entry
    maxlen = max(cellfun(@length, t.names));
    frmt = ['%%   %-' int2str(maxlen) 's - %s\n'];

    % format list of files as Contents.m text
    if opts.IndexGroups
        txt = {};
        [repos,~,rid] = unique(t.repos);
        for r=1:max(rid)
            tt = t(rid == r,:);
            [modules,~,mid] = unique(tt.modules);
            txt{end+1} = ['%% ' repos{r} ':'];
            txt{end+1} = '%';
            for m=1:max(mid)
                ttt = tt(mid == m,:);
                C = [ttt.names, ttt.descriptions]';
                txt{end+1} = ['% ' modules{m} ':'];
                txt{end+1} = [sprintf(frmt, C{:}) '%'];
            end
        end
        txt = strjoin(txt, '\n');
    else
        C = [t.names, t.descriptions]';
        txt = [sprintf(frmt, C{:}) '%'];
    end

    % add header
    txt = strjoin({
        '% mexopencv'
        sprintf('%% Version %s (R%s) %s', cv.Utils.version(), ...
            version('-release'), datestr(now(), 'dd-mmmm-yyyy'))
        '%'
        txt
        ''
    }, '\n');
end

function txt = table_to_helptoc_xml(opts, t)
    %TABLE_TO_HELPTOC_XML  Format table of mexopencv files as helpfuncbycat.xml file

    %HACK: description should not be included in R2014b and up
    % (only supported in older help browser "doc -classic")
    withPurpose = verLessThan('matlab','8.4');

    % format list of files as functions reference for helptoc.xml/helpfuncbycat.xml
    txt = {};
    txt{end+1} = '<?xml version="1.0" encoding="utf-8"?>';
    txt{end+1} = '<toc version="2.0">';
    txt{end+1} = '  <tocitem image="HelpIcon.FUNCTION" target="matlab/index.html">Functions';
    if opts.IndexGroups
        [repos,~,rid] = unique(t.repos);
        for r=1:max(rid)
            tt = t(rid == r,:);
            [modules,~,mid] = unique(tt.modules);
            txt{end+1} = sprintf(...
                '    <tocitem target="matlab/index_cat.html#%s">%s', ...
                repos{r}, repos{r});
            for m=1:max(mid)
                ttt = tt(mid == m,:);
                if withPurpose
                    C = strcat(...
                        '        <tocitem image="HelpIcon.FUNCTION" target="matlab/', ...
                        ttt.names, '.html"><name>', ttt.names, '</name><purpose>', ...
                        xml_escape(ttt.descriptions), '</purpose></tocitem>');
                else
                    C = strcat(...
                        '        <tocitem image="HelpIcon.FUNCTION" target="matlab/', ...
                        ttt.names, '.html">', ttt.names, '</tocitem>');
                end
                txt{end+1} = sprintf(...
                    '      <tocitem target="matlab/index_cat.html#%s">%s', ...
                    modules{m}, modules{m});
                txt{end+1} = strjoin(C, '\n');
                txt{end+1} = '      </tocitem>';
            end
            txt{end+1} = '    </tocitem>';
        end
    else
        if withPurpose
            C = strcat(...
                '    <tocitem image="HelpIcon.FUNCTION" target="matlab/', ...
                t.names, '.html"><name>', t.names, '</name><purpose>', ...
                xml_escape(t.descriptions), '</purpose></tocitem>');
        else
            C = strcat(...
                '    <tocitem image="HelpIcon.FUNCTION" target="matlab/', ...
                t.names, '.html">', t.names, '</tocitem>');
        end
        txt{end+1} = strjoin(C, '\n');
    end
    txt{end+1} = '  </tocitem>';
    txt{end+1} = '</toc>';
    txt{end+1} = '';
    txt = strjoin(txt, '\n');
end

function txt = wiki_md2html(opts, mdFile)
    %WIKI_MD2HTML  Convert Wiki Markdown file to HTML

    % read and convert Markdown to HTML
    txt = fileread(mdFile);
    txt = MarkdownProcess(txt, opts.MarkdownBackend);

    % full HMTL page from fragment
    [~,name] = fileparts(mdFile);
    C = {
        '<!DOCTYPE html>'
        '<html>'
        '<head>'
        '<meta charset="utf-8">'
        ['<title>' strrep(name, '-', ' ') '</title>']
        '<link rel="stylesheet" type="text/css" href="../matlab/helpwin.css">'
        '<link rel="stylesheet" type="text/css" href="../matlab/helpwin_custom.css">'
    };
    if opts.SyntaxHighlighting
        C = [
            C
            '<link rel="stylesheet" type="text/css" href="../matlab/matlab.min.css">'
            '</head>'
            '<body onload="onReady();">'
            txt
            '<script type="text/javascript" src="../matlab/prettify.js"></script>'
            '<script type="text/javascript" src="../matlab/lang-matlab.min.js"></script>'
            '<script type="text/javascript">'
            'function onReady() {'
            '    var list = document.getElementsByTagName("pre");'
            '    for (var i = 0; i < list.length; ++i) {'
            '        if (list[i].classList)'
            '            list[i].classList.add("prettyprint");'
            '        else'
            '            list[i].className += " prettyprint";'
            '    }'
            '    PR.prettyPrint();'
            '}'
            '</script>'
            '</body>'
            '</html>'
        ];
    else
        C = [
            C
            '</head>'
            '<body>'
            txt
            '</body>'
            '</html>'
        ];
    end
    C{end+1} = '';
    txt = strjoin(C, '\n');
end

function jdoc = parse_help2html(opts, topic)
    %PARSE_HELP2HTML  Parse HELP2HTML output and perform common filtering

    % convert M-help into HTML document
    [txt, found] = help2html(topic);
    if ~found
        jdoc = [];
        return;
    end

    % parse HTML string
    jdoc = javaMethod('parse', 'org.jsoup.Jsoup', txt);
    jdoc.outputSettings.prettyPrint(false);  % for proper markdown parsing

    % replace CSS stylesheet with our local version (relative URI)
    jdoc.select('link[href$=helpwin.css]').attr('href', 'helpwin.css');

    % add another sytlesheet for customization (relative URI)
    inject_css_file(jdoc, 'helpwin_custom.css');

    % change title
    txt = char(jdoc.title());
    txt = strrep(txt, 'MATLAB File Help: ', '');
    txt = strrep(txt, ' - MATLAB File Help', '');
    jdoc.title([txt ' - mexopencv']);

    % add generator meta tag
    mt = append_element(jdoc.head(), 'meta');
    mt.attr('name', 'generator').attr('content', ['MATLAB ' version()]);

    % remove highlighting of function names
    % (turn <span class="helptopic">func</span> into func)
    jdoc.select('span.helptopic').unwrap();

    % rewrite <a href="matlab:..">..</a> hyperlinks (mainly in header/footer)
    rewrite_hyperlinks(opts, jdoc);

    if opts.MarkdownRender
        % render Markdown
        render_markdown(opts, jdoc);

        % mark the first paragraph which corresponds to H1-line
        p = jdoc.select('div.helpcontent > p:first-child').first();
        if ~isempty(p)
            p.addClass('h1line');

            % add description meta tag (using H1-line description)
            desc = [topic ' - ' char(p.text())];
            mt = append_element(jdoc.head(), 'meta');
            mt.attr('name', 'description').attr('content', desc);
        end
    end

    % set external links to open in new tabs
    jdoc.select('a[href^=http]').attr('target', '_blank');

    % enable syntax highlighting of code blocks using google-code-prettify
    if opts.SyntaxHighlighting && ~strcmp(topic, 'cv')
        enable_syntax_highlighting(opts, jdoc);
    end

    % enable sorting tables (only used in index.html)
    if opts.TableSorting && strcmp(topic, 'cv')
        enable_sortable_tables(opts, jdoc);
    end
end

function rewrite_hyperlinks(opts, jdoc)
    %REWRITE_HYPERLINKS  Rewrite hyperlinks for offline use

    % replace "matlab:helpwin" (i.e "Default Topics") with index link
    jdoc.select('a[href=matlab:helpwin]').html('Index').attr('href', 'index.html');

    % process rest of "matlab:(helpwin|doc) cv.fcn" links
    links = jdoc.select('a[href^=matlab:helpwin], a[href^=matlab:doc]');
    it = links.iterator();  % iterate over links as ArrayList<Element>
    while it.hasNext()
        % get href
        a = it.next();
        topic = char(a.attr('href'));

        % remove "matlab:(helpwin|doc)" prefix
        topic = regexprep(topic, 'matlab:(helpwin|doc)\s*', '', 'once');

        % remove enclosing parens/quotes in case of function syntax
        % "matlab:helpwin('x')" vs. command syntax "matlab:helpwin x"
        topic = regexprep(topic, '^\(''', '', 'once');
        topic = regexprep(topic, '''\);?$', '', 'once');

        % fix class methods (i.e: cv.Class/method -> cv.Class.method)
        topic = strrep(topic, '/', '.');

        % check if link to another cv function
        if strncmp(topic, 'cv.', 3)
            if is_handle_member(opts, topic)
                % replace link to handle.* methods
                url = 'https://www.mathworks.com/help/matlab/ref/handle-class.html';
                a.attr('href', url);
            else
                % replace link with a relative "fcn.html" link
                a.attr('href', [topic '.html']);
            end
        else
            % check if link to an official TMW function
            url = is_mathworks_function(opts, topic);
            if ~isempty(url)
                a.attr('href', url);
            end
        end
    end

    % remove some raw-code links ("matlab:open .." and "matlab:edit ..")
    jdoc.select('a[href~=matlab:(open|edit)]').remove();

    % turn any remaning "matlab:" links to plain text
    jdoc.select('a[href^=matlab:]').unwrap();
end

function render_markdown(opts, jdoc)
    %RENDER_MARKDOWN  Convert help text from Markdown to HTML + autolinking

    % extract markdown text
    pre = jdoc.select('div.helptext > pre').first();
    assert(~isempty(pre), '<pre> not found');
    %NOTE: this also undoes http:// autolinking done by help2html
    txt = char(pre.text());

    %HACK: for correct Markdown indentation, we remove two leading spaces:
    % - first one inserted by help2html for some reason
    % - second one is part of when we write a comment (e.g "% some text")
    %   being the space between the % symbol and the first character
    txt = regexprep(txt, '^  ', '', 'lineanchors');

    % remove redundant function name at the beginning (exclude property docs)
    if jdoc.select('div.sectiontitle:containsOwn(Property Details)').isEmpty()
        txt = regexprep(txt, '^\w+\s+', '', 'once');
    end

    % autolink "http://" and "www." text
    % (before rendering MD so that we dont later double-link <a href=""> links)
    if opts.AutoLinking
        txt = auto_link_http(opts, txt);
    end
    if opts.AutoLinkingDeep
        txt = auto_link_www(opts, txt);
    end

    % convert Markdown to HTML
    txt = MarkdownProcess(txt, opts.MarkdownBackend);

    % autolink "cv." functions text
    % (after rendering MD so that we dont break indented code with cv. calls)
    if opts.AutoLinkingCV
        txt = auto_link_cv(opts, txt);
    end

    % replace the "helptext" part with the rendered Markdown
    div = jdoc.select('div.helptext').first();
    assert(~isempty(div), '<div> not found');
    div.removeClass('helptext').addClass('helpcontent');
    div.html(txt);
end

function klass = enable_syntax_highlighting(opts, jdoc)
    %ENABLE_SYNTAX_HIGHLIGHTING  Add syntax highlighting using google-code-prettify

    % add prettyprint CSS class to pre+code blocks
    klass = 'prettyprint';
    jdoc.select('pre:has(code)').addClass(klass);

    % set language hint (only if one is not already present, which could be
    % specified in case MD backend supports fenced code blocks "```lang")
    if ~isempty(opts.PrettifyLang)
        jdoc.select('pre:has(code:not([class]))').addClass(opts.PrettifyLang);
    end

    % append code-prettify matlab theme CSS stylesheet
    url = 'https://cdn.rawgit.com/amroamroamro/prettify-matlab/master/dist/css/matlab.min.css';
    inject_css_file(jdoc, get_resource(opts, url));

    % append code-prettify JavaScript
    url = 'https://cdn.rawgit.com/google/code-prettify/master/loader/prettify.js';
    inject_js_file(jdoc, get_resource(opts, url));

    % append lang-matlab extension for code-prettify JavaScript
    url = 'https://cdn.rawgit.com/amroamroamro/prettify-matlab/master/dist/js/full/lang-matlab.min.js';
    inject_js_file(jdoc, get_resource(opts, url));

    % execute JavaScript when page is ready
    jdoc.body().attr('onload', 'PR.prettyPrint();');
end

function klass = enable_sortable_tables(opts, jdoc)
    %ENABLE_SORTABLE_TABLES  Adds ability to sort tables by clicking on headers

    % set CSS class to tables with header
    klass = 'sortable';
    jdoc.select('table:has(thead)').addClass(klass);

    % append sorttable JavaScript library
    url = 'https://cdn.jsdelivr.net/sorttable/2/sorttable.min.js';
    inject_js_file(jdoc, get_resource(opts, url));
end

function fname = get_resource(opts, url)
    %GET_RESOURCE  Return resource URI, optionally downloaded locally

    if opts.NoExternals
        % download resource
        [~, f, ext] = fileparts(url);
        fname = [f ext];
        filename = fullfile(opts.DIR, fname);
        if exist(filename, 'file') ~= 2
            urlwrite(url, filename);
        end
    else
        fname = url;
    end
end

function skip = is_handle_member(opts, topic)
    %IS_HANDLE_MEMBER  Whether to ignore processing a function

    % decide to skip if it matches the pattern "cv.Class.method",
    % and the "method" is inherited from the HANDLE class
    C = strsplit(topic, {'.', '/'});
    skip = (numel(C) >= 2 && ismember(C{end}, opts.Ignore));
end

function url = is_mathworks_function(~, topic)
    %IS_MATHWORKS_FUNCTION  Get online address for official MathWorks function

    % template for URL of online function help
    tmpl = 'https://www.mathworks.com/help/%s/ref/%s.html';

    % check if it is a builtin function
    if exist(topic, 'builtin') == 5
        url = sprintf(tmpl, 'matlab', lower(topic));
        return;
    end

    % locate function and test if it is a toolbox function
    str = which(topic);
    base = toolboxdir('');
    if ~isempty(str) && strncmp(str, base, numel(base))
        tbx = strsplit(strrep(str, base, ''), filesep());
        url = sprintf(tmpl, tbx{2}, lower(topic));
        return;
    end

    % function not found
    url = '';
end

function txt = auto_link_http(~, txt)
    %AUTO_LINK_HTTP  Autolinks "http://" text

    % http:// or https://
    % (neg lookbehind to avoid breaking existing [..](http://..) MD links/imgs)
    re = '(?<!\]\()https?://[\w&@#\/%=~|!,;:.?+-]*[\w&@#\/%=~|+-]';
    rep = '[$0]($0)';
    txt = regexprep(txt, re, rep, 'all', 'preservecase', 'lineanchors');
end

function txt = auto_link_www(~, txt)
    %AUTO_LINK_WWW  Autolinks "www." text

    % www. without http:// or https://
    re = '(^|[^/-])(www\.\S+(?:\>|$))';
    rep = '$1[$2](http://$2)';
    txt = regexprep(txt, re, rep, 'all', 'preservecase', 'lineanchors');
end

function txt = auto_link_cv(~, txt)
    %AUTO_LINK_HTTP  Autolinks cv.* functions text

    % linkify cv.func (relative URLs)
    re = '\<cv\.[\w\.]*\w+\>';
    rep = '<a href="$0.html">$0</a>';
    txt = regexprep(txt, re, rep, 'all', 'preservecase', 'lineanchors');
end

function names = enumerate_mexopencv_members(opts)
    %ENUMERATE_MEXOPENCV_MEMBERS  Enumerate all members in mexopencv

    % names of ignored methods/properties/events
    if opts.IgnoreHandleClass
        % those inherited from handle class (exclude dtor and static empty)
        mt0 = meta.class.fromName('handle');
        m0 = setdiff({mt0.MethodList.Name}, {'delete', 'empty'});
        p0 = {mt0.PropertyList.Name};
        e0 = {mt0.EventList.Name};
    else
        m0 = {};
        p0 = {};
        e0 = {};
    end

    %NOTE: we're taking all methods/props/events, including hidden and private
    %TODO: filter out hidden and private members

    mt = meta.package.fromName('cv');

    % list of functions
    f = strcat('cv.', {mt.FunctionList.Name});

    % list of classes
    c = {mt.ClassList.Name};

    % list of class methods
    m = arrayfun(@(k) strcat(k.Name, '.', setdiff({k.MethodList.Name}, m0)), ...
        mt.ClassList, 'UniformOutput',false);
    m = m(~cellfun(@isempty, m));
    m = cat(2, m{:});

    % conditionaly exclude .empty() method if inherited from handle class
    ind = arrayfun(@(k) find(strcmp({k.MethodList.Name}, 'empty'), ...
        1, 'first'), mt.ClassList);
    mask = arrayfun(@(k,i) k.MethodList(i).Static, mt.ClassList, ind);
    m1 = strcat({mt.ClassList(mask).Name}, '.empty');
    m = setdiff(m, m1);

    % list of class properties
    p = arrayfun(@(k) strcat(k.Name, '.', setdiff({k.PropertyList.Name}, p0)), ...
        mt.ClassList, 'UniformOutput',false);
    p = p(~cellfun(@isempty, p));
    p = cat(2, p{:});

    % list of class events
    e = arrayfun(@(k) strcat(k.Name, '.', setdiff({k.EventList.Name}, e0)), ...
        mt.ClassList, 'UniformOutput',false);
    e = e(~cellfun(@isempty, e));
    e = cat(2, e{:});

    % combined list
    names = unique([f(:); c(:); m(:); p(:); e(:)]);
end

function t = enumerate_mexopencv_files(~)
    %ENUMERATE_MEXOPENCV_FILES  Return a table of all mexopencv files

    % get list of all C++ sources
    paths = {
        fullfile(mexopencv.root(), 'src', '+cv', '*.cpp')
        fullfile(mexopencv.root(), 'src', '+cv', 'private', '*.cpp')
        fullfile(mexopencv.root(), 'opencv_contrib', 'src', '+cv', '*.cpp')
        fullfile(mexopencv.root(), 'opencv_contrib', 'src', '+cv', 'private', '*.cpp')
    };
    cppfiles = cellfun(@cv.glob, paths, 'UniformOutput',false);
    cppfiles = [cppfiles{:}];
    cppfiles = cppfiles(:);

    % determine which ones are from "opencv_contrib"
    iscontrib = regexp(cppfiles, '\<opencv_contrib\>', 'once');
    iscontrib = ~cellfun(@isempty, iscontrib);

    repos = {'opencv'; 'opencv_contrib'};
    repos = repos(iscontrib + 1);

    % get module name of each file
    modules = cellfun(@get_opencv_module, cppfiles, 'UniformOutput',false);

    % get base file name
    [~,names] = cellfun(@fileparts, cppfiles, 'UniformOutput',false);
    names = regexprep(names, '_$', '', 'once');

    % corresponding M-files
    paths = {
        fullfile(mexopencv.root(), '+cv')
        fullfile(mexopencv.root(), 'opencv_contrib', '+cv')
    };
    mfiles = strcat(paths(iscontrib + 1), filesep(), names, '.m');

    % corresponding test files
    paths = {
        fullfile(mexopencv.root(), 'test', 'unit_tests')
        fullfile(mexopencv.root(), 'opencv_contrib', 'test', 'unit_tests')
    };
    tfiles = regexprep(names, '^[a-z]', '${upper($0)}', 'once');
    tfiles = regexprep(tfiles, '_(\w)', '${upper($1)}', 'once');
    tfiles = strcat(paths(iscontrib + 1), filesep(), 'Test', tfiles, '.m');

    % add cv. prefix to name
    names = strcat('cv.', names);

    % create table
    t = table(names, cppfiles, mfiles, tfiles, modules, repos);
end

function module = get_opencv_module(cppfile)
    %GET_OPENCV_MODULE  Extract OpenCV module name for a mexopencv C++ source file

    module = '';
    fid = fopen(cppfile, 'rt');
    tline = fgetl(fid);
    while ischar(tline)
        if ~isempty(strfind(tline, '@ingroup'))
            module = regexp(tline, '@ingroup (\w+)$', 'tokens', 'once');
            module = module{1};
            break;
        end
        tline = fgetl(fid);
    end
    fclose(fid);
end

function inject_css_file(jdoc, url)
    %INJECT_CSS_FILE  Inject CSS stylesheet

    link = append_element(jdoc.head(), 'link');
    link.attr('rel', 'stylesheet');
    link.attr('type', 'text/css');
    link.attr('href', url);
end

function inject_css(jdoc, txt)
    %INJECT_CSS  Inject CSS code

    style = append_element(jdoc.head(), 'style');
    style.attr('type', 'text/css');
    append_data_node(style, txt);
end

function inject_js_file(jdoc, url)
    %INJECT_JS_FILE  Inject JavaScript file

    script = append_element(jdoc.body(), 'script');
    script.attr('type', 'text/javascript');
    script.attr('src', url);
end

function inject_js(jdoc, txt)
    %INJECT_JS  Inject JavaScript code

    script = append_element(jdoc.body(), 'script');
    script.attr('type', 'text/javascript');
    append_data_node(script, txt);
end

function append_data_node(node, txt)
    %APPEND_DATA_NODE  Used to set a style/script tag CSS/JavaScript text without escaping

    % append a child DataNode to specified node
    if ~isempty(node)
        node.appendChild(...
            javaObject('org.jsoup.nodes.DataNode', txt, node.baseUri()));
    end
end

function el = append_element(node, tagName)
    %APPEND_ELEMENT  Create new element by tag name and append it to node

    % create by tag name, append to node, and return newly created element
    assert(~isempty(node), 'empty node');
    el = node.appendElement(tagName);

    %HACK: insert a newline to avoid long lines (assuming prettyPrint=false)
    if true
        el.after(sprintf('\n'));
    else
        node.append(sprintf('\n'));
    end
end

function txt = xml_escape(txt)
    %XML_ESCAPE  Escape XML special characters

    txt = strrep(txt, '&', '&amp;');
    txt = strrep(txt, '<', '&lt;');
    txt = strrep(txt, '>', '&gt;');
    txt = strrep(txt, '"', '&quot;');
    txt = strrep(txt, '''', '&apos;');
end

function filewrite(filename, str)
    %FILEWRITE  Write text to file

    fid = fopen(filename, 'wt', 'n', 'UTF-8');
    fprintf(fid, '%s', str);
    fclose(fid);
end

function outHTML = MarkdownProcess(inMD, backend)
    %MARKDOWNPROCESS  Converts Markdown text to HTML
    %
    %     outHTML = MarkdownProcess(inMD)
    %     outHTML = MarkdownProcess(inMD, backend)
    %
    % ## Input
    % * __inMD__ Input string containing Markdown source.
    %
    % ## Output
    % * __outHTML__ Output HTML formatted string.
    %
    % This function takes a a string of Markdown source and converts it
    % into a formatted HTML output string.
    %
    % [Markdown language](https://daringfireball.net/projects/markdown/) was
    % created by John Gruber and provides an easy-to-read, easy-to-write plain
    % text format that takes many cues from existing conventions for marking
    % up plain text in email.
    %
    % ## Example
    %
    %     % benchmark the different backends
    %     str = repmat(sprintf('*Hello* __world__!\n\n'), 1, 100);
    %     %web(['text://' MarkdownProcess(str)])
    %     backends = {..};
    %     t = zeros(size(backends));
    %     for i=1:numel(backends)
    %         t(i) = timeit(@() MarkdownProcess(str, backends{i}));
    %     end
    %     disp([backends num2cell(t*1000)])
    %

    % process Markdown
    switch backend
        case 'commonmark-java'
            builder = javaMethod('builder', 'org.commonmark.parser.Parser');
            parser = builder.build();
            document = parser.parse(inMD);
            builder = javaMethod('builder', ...
                'org.commonmark.renderer.html.HtmlRenderer');
            renderer = builder.build();
            outHTML = char(renderer.render(document));

        case 'MarkdownPapers'
            parser = javaObject('org.tautua.markdownpapers.Markdown');
            reader = javaObject('java.io.StringReader', inMD);
            writer = javaObject('java.io.StringWriter');
            parser.transform(reader, writer);
            outHTML = char(writer.toString());

        case 'pegdown'
            parser = javaObject('org.pegdown.PegDownProcessor');
            outHTML = char(parser.markdownToHtml(inMD));

        case 'markdownj'
            parser = javaObject('org.markdownj.MarkdownProcessor');
            outHTML = char(parser.markdown(inMD));

        case 'markdown4j'
            %NOTE: it treats newlines as real line breaks!
            parser = javaObject('org.markdown4j.Markdown4jProcessor');
            outHTML = char(parser.process(inMD));

        case 'txtmark'
            outHTML = char(javaMethod('process', ...
                'com.github.rjeschke.txtmark.Processor', inMD));

        case 'none'
            outHTML = inMD;

        otherwise
            error('Unrecognized Markdown backend: %s', backend);
    end
end
