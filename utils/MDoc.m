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
        DIR = fullfile('doc','matlab')
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
            
            % Get a list of functions
            list = dir('+cv/*.m');
            this.yet = strrep({list.name},'.m','');
            while ~isempty(this.yet)
                fname = this.yet{1};
                this.process(fname);
                this.yet = setdiff(this.yet, fname);
                this.processed = union(this.processed,fname);
            end
            
            % Make contents index
            this.process('cv');
            
            % Copy CSS file
            copyfile(MDoc.CSS,MDoc.DIR,'f');
        end
        
        function txt = process(this, func)
            %PROCESS  process an entity
            if strcmp(func,'cv')
                txt = help2html('cv');
                filename = fullfile(MDoc.DIR,'index.html');
                txt = strrep(txt,'<div class="title">cv</div>',...
                    '<div class="title">mexopencv</div>');
            else
                txt = help2html(['cv.',func]);
                filename = fullfile(MDoc.DIR,[func,'.html']);
            end
            fprintf('%s\n',filename);
            
            % Write
            txt = this.filter_text(txt);
            fid = fopen(filename,'w');
            fprintf(fid,'%s',txt);
            fclose(fid);
        end
        
        function txt = filter_text(this, txt)
            %FILTER_TEXT  Filter anchor tags
            txt = strrep(txt,sprintf('file:///%s',MDoc.CSS),'helpwin.css');
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
