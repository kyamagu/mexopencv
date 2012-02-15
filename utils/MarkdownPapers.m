function [ output ] = MarkdownPapers( input )
%MarkdownPapers A java implementation of Markdown language created by John Gruber
%
% MarkdownPapers is a java implementation of Markdown language created by
% John Gruber which provides an easy-to-read, easy-to-write plain text
% format that takes many cues from existing conventions for marking up
% plain text in email.
%
% http://markdown.tautua.org/
%
% Markdown syntax: http://daringfireball.net/projects/markdown/
%

% check jar path
p = fullfile(fileparts(mfilename('fullpath')),'MarkdownPapers',...
    'markdownpapers-core-1.2.3.jar');
if all(cellfun(@isempty,strfind(javaclasspath, p)))
    javaaddpath(p);
end

% call java function
md = org.tautua.markdownpapers.Markdown;
in = java.io.StringReader(java.lang.String(input));
out = java.io.StringWriter();
md.transform(in,out);
output = char(out.toString());

end
