<?xml version="1.0" encoding="utf-8"?>

<!--
This is an XSL stylesheet which converts mscript XML files into HTML.
Use the XSLT command to perform the conversion.

Copyright 1984-2015 The MathWorks, Inc.
-->

<!-- Adapted from "mxdom2simplehtml.xsl" from MATLAB R2017a. -->

<!DOCTYPE xsl:stylesheet [
  <!ENTITY nbsp "&#160;">
  <!ENTITY reg "&#174;">
  <!ENTITY nl  "&#xa;">
]>

<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mwsh="http://www.mathworks.com/namespace/mcode/v1/syntaxhighlight.dtd"
  exclude-result-prefixes="mwsh">

<xsl:output method="html" encoding="utf-8" indent="yes"/>
<xsl:strip-space elements="*"/>
<xsl:preserve-space elements="mwsh:code pre mcode mcodeoutput originalCode"/>

<xsl:template match="mscript">
  <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;&nl;</xsl:text>
  <html>
    <head>
      <xsl:comment>This HTML was auto-generated from published MATLAB code.</xsl:comment>

      <!-- Page Title -->
      <title>
        <xsl:choose>
          <xsl:when test="count(cell/steptitle[@style='document'])">
            <xsl:value-of select="cell/steptitle[@style='document']"/>
          </xsl:when>
          <xsl:otherwise><xsl:value-of select="m-file"/></xsl:otherwise>
        </xsl:choose>
      </title>

      <meta name="generator">
        <xsl:attribute name="content">MATLAB <xsl:value-of select="version"/></xsl:attribute>
      </meta>
      <link rel="schema.DC" href="http://purl.org/dc/elements/1.1/" />
      <meta name="DC.date">
        <xsl:attribute name="content"><xsl:value-of select="date"/></xsl:attribute>
      </meta>
      <meta name="DC.source">
        <xsl:attribute name="content"><xsl:value-of select="m-file"/>.m</xsl:attribute>
      </meta>

      <link rel="stylesheet" type="text/css" href="publish_custom.css" />
    </head>

    <body>
      <div class="content">
        <!-- Display the introduction section if there is one -->
        <xsl:if test="count(cell[@style = 'overview'])">
          <xsl:call-template name="intro">
            <xsl:with-param name="intro-cell" select="cell[@style = 'overview'][1]"/>
          </xsl:call-template>
        </xsl:if>

        <!-- Extract other sections -->
        <xsl:variable name="body-cells" select="cell[not(@style = 'overview')]"/>

        <!-- Display the TOC if there are section titles -->
        <xsl:if test="count(cell/steptitle[not(@style = 'document')])">
          <xsl:call-template name="contents">
            <xsl:with-param name="body-cells" select="$body-cells"/>
          </xsl:call-template>
        </xsl:if>

        <!-- Loop over sections -->
        <xsl:for-each select="$body-cells">
          <!-- Title of section -->
          <xsl:call-template name="heading">
            <xsl:with-param name="body-cell" select="."/>
          </xsl:call-template>

          <!-- Contents of section (in specified order) -->
          <xsl:apply-templates select="text"/>
          <!--<xsl:apply-templates select="mcode"/>-->
          <xsl:apply-templates select="mcode-xmlized"/>
          <xsl:apply-templates select="mcodeoutput"/>
          <xsl:apply-templates select="img"/>
        </xsl:for-each>

        <!-- Footer -->
        <xsl:call-template name="footer"/>
      </div>

      <!-- Include MathJax scripts -->
      <!-- (only when needed: img equations, embedded latex, or latex output) -->
      <xsl:if test="count(//img[@class='equation']) or count(//latex) or count(//mcodeoutput[starts-with(normalize-space(.),'&lt;latex&gt;')])">
        <xsl:call-template name="mathjax"/>
      </xsl:if>

      <!-- Stash original MATLAB code in HTML (for grabcode function) -->
      <xsl:apply-templates select="originalCode"/>
    </body>
  </html>
</xsl:template>

<!-- Introduction section -->

<xsl:template name="intro">
  <xsl:param name="intro-cell"/>
  <!-- title -->
  <xsl:if test="$intro-cell/steptitle">
    <h1>
      <xsl:attribute name="id">
        <xsl:value-of select="$intro-cell/count"/>
      </xsl:attribute>
      <xsl:apply-templates select="$intro-cell/steptitle"/>
    </h1>
  </xsl:if>
  <!-- contents -->
  <xsl:comment>introduction</xsl:comment>
  <xsl:apply-templates select="$intro-cell/text"/>
  <!-- There can be text output if there was a parse error -->
  <xsl:apply-templates select="$intro-cell/mcodeoutput"/>
  <xsl:comment>/introduction</xsl:comment>
</xsl:template>

<!-- Table of Contents -->

<xsl:template name="contents">
  <xsl:param name="body-cells"/>
  <h2 id="toc">Contents</h2>
  <div><ul>
    <xsl:for-each select="$body-cells">
      <!-- place in TOC if section has a title -->
      <xsl:if test="steptitle">
        <li><a>
          <xsl:attribute name="href">#<xsl:value-of select="count"/></xsl:attribute>
          <xsl:apply-templates select="steptitle"/>
        </a></li>
      </xsl:if>
    </xsl:for-each>
  </ul></div>
</xsl:template>

<!-- Section title -->

<xsl:template name="heading">
  <xsl:param name="body-cell"/>
  <xsl:if test="$body-cell/steptitle">
    <xsl:variable name="headinglevel">
      <!-- when there is only one cell, it wont be marked 'overview', but its title is marked 'document' -->
      <xsl:choose>
        <xsl:when test="$body-cell/steptitle[@style = 'document']">h1</xsl:when>
        <xsl:otherwise>h2</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{$headinglevel}">
      <xsl:attribute name="id">
        <xsl:value-of select="$body-cell/count"/>
      </xsl:attribute>
      <xsl:apply-templates select="$body-cell/steptitle"/>
    </xsl:element>
  </xsl:if>
</xsl:template>

<!-- Footer -->

<xsl:template name="footer">
  <div class="footer">
    <xsl:if test="copyright">
      <p><xsl:value-of select="copyright"/></p>
    </xsl:if>
    <p><a href="https://www.mathworks.com/products/matlab.html">
      <xsl:text>Published with MATLAB&reg; R</xsl:text>
      <xsl:value-of select="release"/>
    </a></p>
  </div>
</xsl:template>

<!-- MathJax -->

<xsl:template name="mathjax">
  <script type="text/x-mathjax-config">
  // https://stackoverflow.com/a/14631703/97160
  MathJax.Extension.myImg2jax = {
    version: "1.0",
    PreProcess: function (element) {
      var images = element.getElementsByTagName("img");
      for (var i = images.length - 1; i >= 0; i--) {
        var img = images[i];
        if (img.className === "equation") {
          var match = img.alt.match(/^(\$\$?)([\s\S]*)\1$/m);
          if (!match) continue;
          var script = document.createElement("script");
          script.type = "math/tex";
          if (match[1] === "$$") {script.type += ";mode=display"}
          MathJax.HTML.setScript(script, match[2]);
          img.parentNode.replaceChild(script, img);
        }
      }
    }
  };
  MathJax.Hub.Register.PreProcessor(["PreProcess", MathJax.Extension.myImg2jax]);
  </script>
  <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.2/MathJax.js?config=TeX-AMS_CHTML"></script>
</xsl:template>

<!-- HTML Tags in text sections -->
<!--
% * bullet list item
% # numbered list item
%
%  pre text
%
% *bold*
% _italic_
% |monospace|
%
% <http://www.google.com hyperlink>
%
% <html><h3>embedded HTML</h3></html>
%
% <latex>Embedded \LaTeX</latex>
-->

<xsl:template match="p">
  <p><xsl:apply-templates/></p>
</xsl:template>
<xsl:template match="ul">
  <div><ul><xsl:apply-templates/></ul></div>
</xsl:template>
<xsl:template match="ol">
  <div><ol><xsl:apply-templates/></ol></div>
</xsl:template>
<xsl:template match="li">
  <li><xsl:apply-templates/></li>
</xsl:template>
<xsl:template match="pre">
  <pre>
    <xsl:if test="@class">
      <xsl:attribute name="class">
        <xsl:value-of select="@class"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:apply-templates/>
  </pre>
</xsl:template>
<xsl:template match="b">
  <b><xsl:apply-templates/></b>
</xsl:template>
<xsl:template match="i">
  <i><xsl:apply-templates/></i>
</xsl:template>
<xsl:template match="tt">
  <tt><xsl:apply-templates/></tt>
</xsl:template>
<xsl:template match="a">
  <a>
    <xsl:attribute name="href"><xsl:value-of select="@href"/></xsl:attribute>
    <xsl:apply-templates/>
  </a>
</xsl:template>
<xsl:template match="html">
  <xsl:value-of select="@text" disable-output-escaping="yes"/>
</xsl:template>
<xsl:template match="latex">
  <script type="math/tex; mode=display">
    <xsl:value-of select="@text" disable-output-escaping="yes"/>
  </script>
</xsl:template>

<!-- M-Code in comments -->
<!--
% (Note: for non-mfiles, the inlude is processed as normal PRE text)
%
% <include>syntax_highlighted_matlab_code.m</include>
%
%   if true, disp('syntax highlighted matlab code'); end
-->

<xsl:template match="text/mcode-xmlized">
  <pre class="code-matlab"><xsl:apply-templates/></pre>
</xsl:template>

<!-- M-Code input -->
<!--
if true, disp('syntax highlighted matlab code'); end
-->

<xsl:template match="mcode-xmlized">
  <pre class="codeinput"><xsl:apply-templates/></pre>
</xsl:template>

<!-- Raw M-Code input -->
<!-- same as above, but raw without syntax highlighting -->
<!-- (we could use google-code-prettify apply our own highlighting) -->

<xsl:template match="mcode">
  <pre class="codeinput prettify language-matlab"><xsl:apply-templates/></pre>
</xsl:template>

<!-- M-Code output -->

<xsl:template match="mcodeoutput">
  <xsl:choose>
    <!-- HTML output from stuff like: disp('<html>..</html>') -->
    <xsl:when test="concat(substring(.,1,6),substring(.,string-length(.)-7,7))='&lt;html&gt;&lt;/html&gt;'">
      <xsl:value-of select="substring(.,7,string-length(.)-14)" disable-output-escaping="yes"/>
    </xsl:when>
    <!-- LaTeX output from stuff like: disp('<latex>..</latex>') -->
    <xsl:when test="concat(substring(.,1,7),substring(.,string-length(.)-8,8))='&lt;latex&gt;&lt;/latex&gt;'">
      <script type="math/tex; mode=display">
        <xsl:value-of select="substring(.,8,string-length(.)-16)" disable-output-escaping="yes"/>
      </script>
    </xsl:when>
    <!-- any other output -->
    <xsl:otherwise>
      <pre>
        <xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
        <xsl:apply-templates/>
      </pre>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Colors for syntax-highlighted code (mcode-xmlized) -->
<!-- C:\Program Files\MATLAB\R2017a\sys\namespace\mcode\v1\syntaxhighlight.dtd -->

<xsl:template match="mwsh:code">
  <xsl:apply-templates/>
</xsl:template>
<xsl:template match="mwsh:keywords">
  <span class="keyword"><xsl:value-of select="."/></span>
</xsl:template>
<xsl:template match="mwsh:strings">
  <span class="string"><xsl:value-of select="."/></span>
</xsl:template>
<xsl:template match="mwsh:comments">
  <span class="comment"><xsl:value-of select="."/></span>
</xsl:template>
<xsl:template match="mwsh:unterminated_strings">
  <span class="untermstring"><xsl:value-of select="."/></span>
</xsl:template>
<xsl:template match="mwsh:system_commands">
  <span class="syscmd"><xsl:value-of select="."/></span>
</xsl:template>

<!-- Equations (rendered LaTeX equations) -->
<!--
% Inline Expression: $x^2$
%
% Block Equation:
%
% $$e^x = 0$$
-->

<xsl:template match="img[@class='equation']">
  <img>
    <!-- alt and class are used by MathJax when replacing image with rendered equation -->
    <xsl:attribute name="src"><xsl:value-of select="@src"/></xsl:attribute>
    <xsl:attribute name="alt"><xsl:value-of select="@alt"/></xsl:attribute>
    <xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
    <xsl:choose>
      <xsl:when test="@scale">
        <xsl:attribute name="style">
          <xsl:if test="@width">
            <xsl:text>width:</xsl:text>
            <xsl:value-of select="@width"/>
            <xsl:text>;</xsl:text>
          </xsl:if>
          <xsl:if test="@height">
            <xsl:text>height:</xsl:text>
            <xsl:value-of select="@height"/>
            <xsl:text>;</xsl:text>
          </xsl:if>
        </xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="@width">
          <xsl:attribute name="width">
            <xsl:value-of select="substring-before(@width,'px')"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:if test="@height">
          <xsl:attribute name="height">
            <xsl:value-of select="substring-before(@height,'px')"/>
          </xsl:attribute>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </img>
</xsl:template>

<!-- Figure/model snapshots and external images -->
<!--
% <<image.png>>
%
plot(1:10)
-->

<xsl:template match="img">
  <img>
    <xsl:attribute name="src"><xsl:value-of select="@src"/></xsl:attribute>
    <xsl:if test="@alt">
      <xsl:attribute name="alt"><xsl:value-of select="@alt"/></xsl:attribute>
    </xsl:if>
    <xsl:if test="@width or @height">
      <xsl:attribute name="style">
        <xsl:if test="@width">
          <xsl:text>width:</xsl:text>
          <xsl:value-of select="@width"/>
          <xsl:text>;</xsl:text>
        </xsl:if>
        <xsl:if test="@height">
          <xsl:text>height:</xsl:text>
          <xsl:value-of select="@height"/>
          <xsl:text>;</xsl:text>
        </xsl:if>
      </xsl:attribute>
    </xsl:if>
  </img>
</xsl:template>

<!-- Original MATLAB Code saved in HTML comment -->

<xsl:template match="originalCode">
  <!-- HTML comments cannot contain any occurence of "DASH DASH" -->
  <xsl:variable name="xcomment">
    <xsl:call-template name="globalReplace">
      <xsl:with-param name="outputString" select="."/>
      <xsl:with-param name="target" select="'--'"/>
      <xsl:with-param name="replacement" select="'REPLACE_WITH_DASH_DASH'"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:comment>
    <xsl:text>&nl;##### SOURCE BEGIN #####&nl;</xsl:text>
    <xsl:value-of select="$xcomment"/>
    <xsl:text>&nl;##### SOURCE END #####&nl;</xsl:text>
  </xsl:comment>
</xsl:template>

<!-- Search and replace  -->
<!-- From http://www.xml.com/lpt/a/2002/06/05/transforming.html -->

<xsl:template name="globalReplace">
  <xsl:param name="outputString"/>
  <xsl:param name="target"/>
  <xsl:param name="replacement"/>
  <xsl:choose>
    <xsl:when test="contains($outputString,$target)">
      <xsl:value-of select="concat(substring-before($outputString,$target),$replacement)"/>
      <xsl:call-template name="globalReplace">
        <xsl:with-param name="outputString" select="substring-after($outputString,$target)"/>
        <xsl:with-param name="target" select="$target"/>
        <xsl:with-param name="replacement" select="$replacement"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$outputString"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
