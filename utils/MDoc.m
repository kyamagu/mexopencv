classdef MDoc < handle
    %MDOC  mexopencv documentation utility
    %
    % This class generates a simple Matlab HTML documentation using
    % matlab's internal utility help2html. To generate documentation,
    % create an instance of this class:
    %
    %    addpath('utils');
    %    MDoc;
    %
    % Once you run this command, you can find html documentation under
    % MDoc.DIR directory.
    %

    properties (Constant)
        % Directory to place documentation
        DIR = fullfile(mexopencv.root(),'doc','matlab')
        % Default CSS file
        CSS = fullfile(matlabroot,'toolbox','matlab','helptools',...
            'private','helpwin.css')
    end

    properties (SetAccess = private)
        % Internal use
        yet = {};
        % Internal use
        processed = {};
    end

    methods
        function this = MDoc
            %MDOC  execute MDoc
            if ~exist(MDoc.DIR,'dir'), mkdir(MDoc.DIR); end

            % Copy CSS file
            txt = fileread(MDoc.CSS);
            txt = this.process_css(txt);
            fid = fopen(fullfile(MDoc.DIR,'helpwin.css'),'w');
            fprintf(fid,'%s',txt);
            fclose(fid);

            % Make contents index
            this.process_index();

            % Get a list of functions
            list = dir(fullfile(mexopencv.root(),'+cv','*.m'));
            this.yet = strrep({list.name},'.m','');
            while ~isempty(this.yet)
                fname = this.yet{1};
                this.process(fname);
                this.yet = setdiff(this.yet, fname);
                this.processed = union(this.processed,fname);
            end
        end

        function txt = process(this, func)
            %PROCESS  process an entity
            txt = help2html(['cv.',func]);
            txt = strrep(txt,'&amp;','&');
            txt = strrep(txt,'&lt;','<');
            txt = strrep(txt,'&gt;','>');
            filename = fullfile(MDoc.DIR,[func,'.html']);
            fprintf('%s\n',filename);

            % Filter
            txt = this.filter_text(txt);
            txt = this.markdown(txt);

            % Write
            fid = fopen(filename,'w');
            fprintf(fid,'%s',txt);
            fclose(fid);
        end

        function txt = filter_text(this, txt)
            %FILTER_TEXT  Filter anchor tags
            txt = strrep(txt,sprintf('file:///%s',MDoc.CSS),'helpwin.css');
            txt = regexprep(txt,'<span class="helptopic">([^<]*)</span>','$1');
            [splt,tokens] = regexp(txt,'<a href=\"matlab:(\S+\s*[^\"]*)">([^<]*)</a>',...
                'split','tokens');
            tokens = cellfun(@(tok) this.make_link(tok{1},tok{2}),...
                tokens,'UniformOutput',false);
            txt = [splt;[tokens,{''}]];
            txt = [txt{:}];
        end

        function txt = make_link(this, href, txt)
            %MAKE_LINK  Rewrite hyperlinks
            A = '<a href="%s">%s</a>';

            % Link to raw codes: do nothing
            tok = regexp(href,'open (.*)', 'tokens', 'once');
            if ~isempty(tok)
                txt = '';
            end

            % Link to index
            if strcmp(href,'helpwin')
                txt = sprintf(A, 'index.html', 'Index');
            end

            % Link to another function
            tok = regexp(href,'helpwin cv\.(.*)', 'tokens', 'once');
            if isempty(tok)
                tok = regexp(href,'helpwin\(''cv\.(.*)''\)', 'tokens', 'once');
            end
            if ~isempty(tok)
                fname = strrep(tok{1},'/','.');
                href = [fname,'.html'];
                txt = sprintf(A, href, txt);
                if ~any(strcmp(this.processed,fname))
                    this.yet = union(this.yet,fname);
                end
            end
        end

        function txt = markdown(this, txt)
            %MARKDOWN add html tags
            [splt,tok] = regexp(txt,...
                '(<div class="helptext">\s*<pre>.*</pre>\s*</div>)','split','tokens');
            if ~isempty(tok)
                tok = regexp(tok{1}{1},'<pre><!--helptext -->\s*(.*)</pre>','tokens');
                if ~isempty(tok)
                    % remove space inserted by matlab
                    tok = regexprep(tok{1}{1},'\n ','\n');
                    % remove function name in the header
                    tok = regexprep(tok,'^[A-Z0-9_]+\s+(.*)$','$1');
                    % markup
                    tok = MarkdownPapers(tok);
                    % autolink cv functions
                    tok = regexprep(tok,'cv\.([a-zA-Z0-9_]+)([:;,\.\(\s])',...
                        '<a href="$1.html">cv.$1</a>$2');
                    txt = [splt;{sprintf('<div class="helpcontent">%s</div>',tok),''}];
                    txt = [txt{:}];
                end
            end
        end

        function txt = process_css(this, txt)
            %PROCESS_CSS
            txt = strrep(txt,'font-size: 12px;','font-size: 14px;');
            txt = sprintf(['%s\npre {\n'...
                '    margin: 0em 2em;\n'...
                '    padding: .5em 1em;\n'...
                '    background-color: #E7EBF7;\n'...
                '}\n'...
                '\nh1, h2, h3, h4, h5, h6 {\n'...
                '    color:#990000;'...
                '}'],txt);
        end

        function txt = process_index(this)
            %PROCESS_INDEX
            txt = help2html('cv');
            filename = fullfile(MDoc.DIR,'index.html');

            % Filter
            description = ['<p>Collection and a development kit of matlab '...
                'mex functions for OpenCV library</p>'...
                '<p><a href="http://github.com/kyamagu/mexopencv">'...
                'http://github.com/kyamagu/mexopencv</a></p>'];
            txt = strrep(txt,'<div class="title">cv</div>',...
                sprintf('<div class="title">mexopencv</div>%s',description));
            txt = regexprep(txt,'Contents of \w+:\s*','');
            txt = this.filter_text(txt);
            txt = this.build_table(txt);

            % Write
            fid = fopen(filename,'w');
            fprintf(fid,'%s',txt);
            fclose(fid);
        end

        function txt = build_table(this, txt)
            %BUILD_TABLE
            [splt,tok] = regexp(txt,...
                '(<div class="helptext">\s*<pre>.*</pre>\s*</div>)','split','tokens');
            if ~isempty(tok)
                tok = regexp(tok{1}{1},'<pre><!--helptext -->\s*(.*)</pre>','tokens');
                if ~isempty(tok)
                    tok = sprintf('%s\n',tok{1}{1});
                    t = regexp(tok,'(<a[^<]+</a>)\s*-\s*([^\n]*)\n','tokens');
                    tok = cellfun(@(x) sprintf('<tr><td>%s</td><td>%s</td></tr>\n',x{1},x{2}),...
                        t, 'UniformOutput', false);
                    tok = sprintf('<table>\n%s</table>\n',[tok{:}]);
                    txt = [splt;{sprintf('<div class="helpcontent">%s</div>',tok),''}];
                    txt = [txt{:}];
                end
            end
        end
    end

    methods (Static)
        function open
            %OPEN  Opens documentation
            if ~exist(fullfile(MDoc.DIR,'index.html'),'file')
                MDoc;
            end
            web(fullfile(MDoc.DIR,'index.html'));
        end
    end

end
