<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:outline="http://wkhtmltopdf.org/outline"
                xmlns="http://www.w3.org/1999/xhtml">
  <xsl:output doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
              doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
              indent="yes" />
  <xsl:template match="outline:outline">
    <html>
      <head>
        <title>Table of Contents</title>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <style>
          *{
            font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
          }
          .clr{
            clear: both;
          }
          hr{
            margin: 10px 30px 18px 30px;
          }
          div.title {
            font-size: 18px;
            line-height: 20px;
            font-weight: 200;
            color: #1c7dab;
            padding: 30px 30px 10px 30px;
          }
          div.content{
            border-bottom: 1px dotted #414042
          }
          li {
            list-style: none;
            font-size: 16px;
            padding: 10px 30px;
          }
          ul {
            font-size: 16px;
          }
          ul ul {font-size: 80%; }
          ul {padding-left: 0em;}
          ul ul {padding-left: 1em;}
          a {text-decoration:none; color: black;}
          .section_name, .page_no{
            background: #fff;
            margin-bottom: -6px;
          }
          .section_name{
            max-width: 95%;
            float: left;
            padding-right: 10px;
          }
          .page_no{
            max-width: 4%;
            float: right;
            text-align: right;
            padding-left: 10px;
          }
        </style>
      </head>
      <body>
        <div class='title'>Table of Contents</div>
        <hr/>
        <ul><xsl:apply-templates select="outline:item/outline:item"/></ul>
      </body>
    </html>
  </xsl:template>
  <xsl:template match="outline:item">
    <li>
      <xsl:if test="@title!=''">
        <div class="content">
          
          <a class="section_name">
            <xsl:if test="@link">
              <xsl:attribute name="href"><xsl:value-of select="@link"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="@backLink">
              <xsl:attribute name="name"><xsl:value-of select="@backLink"/></xsl:attribute>
            </xsl:if>
            <xsl:value-of select="@title" /> 
          </a>
          <div class="page_no"> <xsl:value-of select="@page" /> </div>
          <div class="clr"></div>
        </div>
      </xsl:if>
      <ul>
        <xsl:comment>added to prevent self-closing tags in QtXmlPatterns</xsl:comment>
        <xsl:apply-templates select="outline:item"/>
      </ul>
    </li>
  </xsl:template>
</xsl:stylesheet>

