<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [
<!ENTITY nbsp "&#160;">
]>

<!--

/**
 *  odt2daisy - OpenDocument to DAISY XML/Audio
 *
 *  (c) Copyright 2008 - 2009 by Vincent Spiewak, All Rights Reserved.
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Lesser Public License as published by
 *  the Free Software Foundation; either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License along
 *  with this program; if not, write to the Free Software Foundation, Inc.,
 *  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */
  -->

<!--
    Supported Elements:

    
    Major Structural Elements
    =========================
    
    Levels                    => Para Style Heading_1 ... Heading_N
      - Alternative Markup    => Export Dialog Param
    Front Matter              => Auto or Before BodyMatterStart Section
    Doctitle 	              => Export Dialog Param
    Docauthor 	              => Export Dialog Param
    Title Page                => -
    Acknowledgments           => -
    Dedication                => -
    Preface                   => -
    Table of Contents         => OOo TOC
    Body Matter               => Auto or After BodyMatterStart Section
    Part 	              => Template "Part" or "DAISY TOP ELEMENT" meta:user-defined
    Chapter 	              => Template "Chapter" 
    Section, Subsection, ...  => Template "Section"
    Rear Matter               => Auto or After RearMatterStart Section
    Appendix                  => -
    Glossary 	              => -
    Bibliography              => -
    Index                     => -
    Divisions                 => Sections
		
    
    Block Elements 		
    ==============

    Address 	              => Custom Style
    Author                    => Custom Style
    Bridgehead                => Custom Style
    Byline                    => Custom Style
    Computer Code             => -
    Dateline                  => Custom Style
    Epigraph 	              => -
    Keyboard Input            => Custom Style
    Linegroup                 => -
    Lists                     => text:list
    Annotation	              => OOo Note 
    Footnote 	              => OOo FootNote
    Endnote 	              => OOo EndNote
    Rear-Note 	              => -
    Paragraph 	              => default for text:p
    Producer's Note 	      => Custom Style
    Quotation 	              => Custom Style
    Sample 	              => Custom Style
    Notice 	              => removed since 2005-3
    Sidebar 	              => OOo Frames

    
    Inlines Elements 		
    ================
    
    Anchor 	              => OOo Bookmark 
    Abbreviation 	      => Custom Style
    Acronym 	              => Custom Style
    Computer Code 	      => Custom Style
    Defining Instance 	      => -
    Emphasis 	              => Char Style Emphasis
    Horizontal Rule 	      => removed since 2005-3 
    Keyboard Input 	      => Custom Style
    Line Break  	      => Shift-Enter
    Page Number  	      => OOo PageNumber Field in Footer OR/AND Header
    Producer's Note 	      => Custom Style
    Quotation 	              => Char. Style Quotation
    Sample 	              => Custom Style
    Sentence 	              => Custom Style
    Span 	              => Custom Style
    Strong Emphasis 	      => Char Style Strong Emphasis, Bold, Bold+Italic
    Subscript and Superscript => text:position
    Word                      => -
   
    Table
    =====
    - basic table
    - headers
    - nested
    
    MathML
    ======
    
    Images
    ======
    - alt => Picture > Options > Alt Text (Only Text)
    - caption
    - handle image link
    
    File > Properties
    =================
    - Title: as default value in Export Dialog
    - Subject: as dc:Subject if present
    - Keywords: as dc:Subject if presents
    - Comment: not mapped (?)
-->
<xsl:stylesheet version="1.0" 
                
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" 
                xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0" 
                xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" 
                xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0" 
                xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0" 
                xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0" 
                xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0" 
                xmlns:number="urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0" 
                xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0" 
                xmlns:chart="urn:oasis:names:tc:opendocument:xmlns:chart:1.0" 
                xmlns:dr3d="urn:oasis:names:tc:opendocument:xmlns:dr3d:1.0" 
                xmlns:form="urn:oasis:names:tc:opendocument:xmlns:form:1.0" 
                xmlns:script="urn:oasis:names:tc:opendocument:xmlns:script:1.0" 
                xmlns:xlink="http://www.w3.org/1999/xlink" 
                xmlns:dc="http://purl.org/dc/elements/1.1/" 
                xmlns:math="http://www.w3.org/1998/Math/MathML" 
                xmlns:dom="http://www.w3.org/2001/xml-events" 
                xmlns:xforms="http://www.w3.org/2002/xforms" 
                xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:exsl="http://exslt.org/common"
                xmlns:xalan="http://xml.apache.org/xslt" 
                xmlns="http://www.daisy.org/z3986/2005/dtbook/"
                exclude-result-prefixes="exsl office style dom xforms xsi xsd text table draw fo xlink number svg chart dr3d math form script dc meta xalan">
                    
    <xsl:import  href="measure_conversion.xsl" />                    
    <xsl:variable name="stylesheet" select="document('')/xsl:stylesheet" />
    
    <!--
       <xsl:output method="xml" indent="yes" omit-xml-declaration="no"
	doctype-public="-//NISO//DTD dtbook 2005-3//EN"
	doctype-system="http://www.daisy.org/z3986/2005/dtbook-2005-3.dtd"
	/>
    -->
    <xsl:output method="xml" 
                encoding="UTF-8"
                media-type="text/xml" 
                indent="yes"
                omit-xml-declaration="no"
                xalan:indent-amount="3"
    />
    
    <!-- XSLT Parameters  -->
    <xsl:param name="L10N_Title_Page" select="'Title Page'" />
    <xsl:param name="L10N_Blank_Page_X" select="'Page @, Blank page'" />
    <xsl:param name="paramUID" select="'Not defined UID'" />
    <xsl:param name="paramTitle" select="'Not defined Title'" />
    <xsl:param name="paramCreator" select="'Not defined Creator'" />
    <xsl:param name="paramPublisher" select="'Not defined Publisher'" />
    <xsl:param name="paramProducer" select="'Not defined Producer'" />
    <xsl:param name="paramLang" select="'en-US'" />
    <xsl:param name="paramAlternateMarkup" select="false()" />
    <xsl:param name="paramWriteCSS" select="false()" />
    <xsl:param name="paramPathToCSS" select="'dtbook.2005.basic.css'" />
    
    <!-- Constant defining the newline token. -->
    <xsl:param name="NL" select="'&#10;'"/>
    <xsl:param name="TAB" select="'   '"/>
    
    <!-- Strip Space for Listed Elements -->
    <xsl:strip-space elements="text:section text:p text:h text:span text:a text:list text:list-item text:note text:note-body
                     table:table table:table-row table:table-cell draw:frame draw:image 
                     math:math math:annotation math:semantics math:mo math:mi math:mrow math:msup  
    office:annotation" />
    
    <!--
  =============
  DOCUMENT ROOT
  =============
    -->
    <xsl:template match="/"> 
        <!-- Link to CSS file -->
        <xsl:if test="$paramWriteCSS">
            <xsl:processing-instruction name="xml-stylesheet">
                <xsl:text>type="text/css" </xsl:text>
                <xsl:text>href="</xsl:text>
                <xsl:value-of select="$paramPathToCSS"/>
                <xsl:text>"</xsl:text>
            </xsl:processing-instruction>
        </xsl:if>
        <xsl:variable name="advFrontMatter" select="/office:document/office:body/office:text/text:section[@text:name='BodyMatterStart'][1]" />
        <xsl:variable name="advRearMatter" select="/office:document/office:body/office:text/text:section[@text:name='RearMatterStart'][1]" />
        <xsl:variable name="hadHeading" select="//text:h[1]" />
        <xsl:variable name="noFrontMatter" select="name(/office:document/office:body/office:text/pagenum[1]/following-sibling::*[1]) = 'text:h'
                        or
                       name(/office:document/office:body/office:text/text:sequence-decls[1]/following-sibling::*[1]) = 'text:h'" />
        <xsl:text disable-output-escaping="yes"><![CDATA[
        <!--     This DAISY Book was generated with odt2daisy      -->
        <!--     More info at http://odt2daisy.sourceforge.net     -->
        <!--     © Copyright 2008 - Vincent Spiewak                -->
        ]]>
        </xsl:text>
        
        
        <!-- Output Different Doctype if MathML present -->
        <xsl:choose>
            <xsl:when test="//math:math">
                
                <!-- Output MathML Modular Doctype -->
                <xsl:text disable-output-escaping="yes"><![CDATA[
<!DOCTYPE dtbook
          PUBLIC "-//NISO//DTD dtbook 2005-3//EN" 
          "http://www.daisy.org/z3986/2005/dtbook-2005-3.dtd"
          [
          <!ENTITY % MATHML.prefixed "INCLUDE" >
          <!ENTITY % MATHML.prefix "math">
          <!ENTITY % MATHML.Common.attrib "xlink:href     CDATA       #IMPLIED
                                           xlink:type     CDATA       #IMPLIED   
                                           class          CDATA       #IMPLIED
                                           style          CDATA       #IMPLIED
                                           id             ID          #IMPLIED
                                           xref           IDREF       #IMPLIED
                                           other          CDATA       #IMPLIED
                                           xmlns:dtbook   CDATA       #FIXED 
                                             'http://www.daisy.org/z3986/2005/dtbook/'
                                           dtbook:smilref CDATA       #IMPLIED">    
          <!ENTITY % mathML2 PUBLIC "-//W3C//DTD MathML 2.0//EN"
                                    "http://www.w3.org/Math/DTD/mathml2/mathml2.dtd">
          %mathML2;
          
          <!ENTITY % externalFlow "| math:math">
          <!ENTITY % externalNamespaces "xmlns:math CDATA #FIXED 
					   'http://www.w3.org/1998/Math/MathML'">      
          ]>

                ]]>
                </xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text disable-output-escaping="yes"><![CDATA[
<!DOCTYPE dtbook
          PUBLIC "-//NISO//DTD dtbook 2005-3//EN" 
          "http://www.daisy.org/z3986/2005/dtbook-2005-3.dtd">

                ]]>
                </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        
        
        <!-- DTBOOK Element -->
        <xsl:element name="dtbook" namespace="http://www.daisy.org/z3986/2005/dtbook/">
            
            <!-- Output MathML Namespace if MathML Elements are present -->
            <xsl:if test="//math:math">
                <xsl:copy-of select="$stylesheet/namespace::math" />
            </xsl:if>
            <xsl:attribute name="version">
                <xsl:value-of select="'2005-3'" />
            </xsl:attribute>
            <xsl:attribute name="xml:lang">
                <xsl:value-of select="$paramLang" />
            </xsl:attribute>
            
            <!-- HEAD Element -->
            <head>
                <meta name="dc:Identifier" 
                      content="{$paramUID}" />
                <meta name="dc:Language"
                      content="{$paramLang}" />
                <meta name="dc:Title" content="{$paramTitle}" />
                <xsl:if test="/office:document/office:meta/dc:subject">
                    <meta name="dc:Subject"  content="{/office:document/office:meta/dc:subject/text()}" />
                </xsl:if>
                <xsl:for-each select="/office:document/office:meta/meta:keyword">
                    <meta name="dc:Subject"  content="{text()}" />
                </xsl:for-each>
                <meta name="dc:Creator" 
                      content="{$paramCreator}" />
                <meta name="dc:Publisher" 
                      content="{$paramPublisher}" />
                <meta name="dtb:Producer"
                      content="{$paramProducer}" />
                <!-- Meta Always in ODT -->
                <meta name="dc:Date" 
                      content="{substring-before(/office:document/office:meta/meta:creation-date/text(),'T')}" />
                <meta name="dc:Type" content="Text" />
                <meta name="dc:Format" content="ANSI/NISO Z39.86-2005" />
                <meta name="dtb:uid" 
                      content="{$paramUID}" />
                <meta name="dtb:revision"
                      content="{/office:document/office:meta/meta:editing-cycles/text()}" />
                <meta name="dtb:revisionDate"
                      content="{substring-before(/office:document/office:meta/dc:date/text(),'T')}" />
                <meta name="Generator" content="odt2daisy by Vincent Spiewak"/>
            </head>
            
            <!-- BOOK Element -->
            <xsl:element name="book">
                
                <!-- FRONTMATTER Element -->
                <xsl:element name="frontmatter">
                    
                    <!-- DOCTITLE ELEMENT -->
                    <xsl:element name="doctitle">
                        <xsl:value-of select="$paramTitle" />
                    </xsl:element>
                    
                    <!-- DOCAUTHOR Element -->
                    <xsl:element name="docauthor">
                        <xsl:value-of select="$paramCreator" />
                    </xsl:element>
                    
                    <!--<xsl:for-each 
                        select="/office:document/office:body/office:text/
                    text:p[@text:style-name='Signature']">
                        
                        <xsl:element name="docauthor">
                            <xsl:value-of select="text()" />
                        </xsl:element>
                        
                    </xsl:for-each>
                    -->
                    <xsl:choose>
                        <xsl:when test="$advFrontMatter">
                            <xsl:comment>[FrontMatter Mode: Advanced]</xsl:comment>
                            <xsl:apply-templates select="/office:document/office:body/office:text/text:sequence-decls[1]/following-sibling::text:h[1]" mode="hierarchy" />
                        </xsl:when>
                        <xsl:when test="$hadHeading and not($noFrontMatter)">
                            <xsl:comment>[FrontMatter Mode: Basic]</xsl:comment>
                            <xsl:call-template name="basicFrontMatter" />
                            
                            <!--<xsl:apply-templates select="/office:document/office:body/office:text/pagenum[1]" mode="frontMatterHierarchy" />-->
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:comment>[FrontMatter Mode: None]</xsl:comment>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element><!-- END FRONTMATTER Element --> 
                
                <!-- BODYMATTER Element -->
                <xsl:element name="bodymatter">
                    
                    <!-- We start with the first title of level 1 -->
                    <xsl:choose>
                        
                        <!-- Adv Matter Mode-->
                        <xsl:when test="$advFrontMatter">
                            <xsl:apply-templates select="/office:document/office:body/office:text/text:section[@text:name='BodyMatterStart'][1]/following-sibling::*[1]" mode="hierarchy">
                                <xsl:with-param name="source" select="'book'"/>
                            </xsl:apply-templates>
                        </xsl:when>
                        <xsl:when test="/office:document/office:body
                        /office:text/text:h[@text:outline-level='1']">
                            <xsl:apply-templates
                                select="/office:document/office:body
                                /office:text/text:h[@text:outline-level='1'][1]"
                                mode="hierarchy">
                                <xsl:with-param name="source" select="'book'"/>
                            </xsl:apply-templates>
                        </xsl:when>
                        <xsl:when test="/office:document/office:body
                        /office:text/text:section/text:h[@text:outline-level='1']">
                            <xsl:apply-templates
                                select="/office:document/office:body
                                /office:text/text:section/text:h[@text:outline-level='1'][1]"
                                mode="hierarchy">
                                <xsl:with-param name="source" select="'book'"/>
                            </xsl:apply-templates>
                        </xsl:when>
                        <!-- If no title of level 1 found -->
                        <xsl:otherwise>
                            
                            <!-- output <level depth=""><hd> style -->
                            <xsl:if test="$paramAlternateMarkup">
                                <level depth="1">
                                    <xsl:apply-templates select="/office:document/office:body
                                    /office:text/pagenum[1]" />
                                    <hd>
                                        <xsl:call-template name="addLangAttrPara" />
                                        <xsl:value-of select="$paramTitle" />
                                    </hd>
                                    <xsl:apply-templates select="/office:document/office:body
                                                         /office:text/text:sequence-decls[1]/following-sibling::*[name()!='pagenum'][1]"
                                                         mode="hierarchy"/>
                                </level>
                            </xsl:if>
                            <!-- output <level1><h1> style -->
                            <xsl:if test="not($paramAlternateMarkup)">
                                <level1>
                                    <xsl:apply-templates select="/office:document/office:body
                                    /office:text/pagenum[1]" />
                                    <h1>
                                        <xsl:call-template name="addLangAttrPara" />
                                        <xsl:value-of select="$paramTitle" />
                                    </h1>
                                    <xsl:apply-templates select="/office:document/office:body
                                                         /office:text/text:sequence-decls[1]/following-sibling::*[name()!='pagenum'][1]"
                                                         mode="hierarchy"/>
                                </level1>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element><!-- END BODYMATTER ELEMENT -->
                <xsl:if test="$advRearMatter">
                    <xsl:element name="rearmatter">
                        <xsl:apply-templates select="/office:document/office:body/office:text/text:section[@text:name='RearMatterStart']/following-sibling::*[1]" mode="hierarchy" />
                    </xsl:element>
                </xsl:if>
            </xsl:element><!-- END BOOK ELEMENT -->
        </xsl:element><!-- END DTBOOK ELEMENT -->
        <xsl:value-of select="$NL" />
    </xsl:template>
    
    
    
    <!-- 
    ===========
    FRONTMATTER
    ===========
    -->
    <xsl:template name="basicFrontMatter">
        
        <!-- output <level depth=""><hd> style -->
        <xsl:if test="$paramAlternateMarkup">
            <level depth="1" class="title_page">
                <xsl:apply-templates select="/office:document/office:body/office:text/pagenum[1]" />
                <hd>
                    <xsl:call-template name="addLangAttrPara" />
                    <xsl:value-of select="$L10N_Title_Page" />
                </hd>
                <xsl:apply-templates select="/office:document/office:body
                                     /office:text/text:sequence-decls[1]/following-sibling::*[name()!='pagenum'][1]"
                                     mode="basicFrontMatterHierarchy">
                    <xsl:with-param name="level" select="'1'" />
                </xsl:apply-templates>
            </level>
        </xsl:if>
        <!-- output <level1><h1> style -->
        <xsl:if test="not($paramAlternateMarkup)">
            <level1 class="title_page">
                <xsl:apply-templates select="/office:document/office:body/office:text/pagenum[1]" />
                <h1>
                    <xsl:call-template name="addLangAttrPara" />
                    <xsl:value-of select="$L10N_Title_Page" />
                </h1>
                <xsl:apply-templates select="/office:document/office:body
                                     /office:text/text:sequence-decls[1]/following-sibling::*[name()!='pagenum'][1]"
                                     mode="basicFrontMatterHierarchy">
                    <xsl:with-param name="level" select="'1'" />
                </xsl:apply-templates>
            </level1>
        </xsl:if>
    </xsl:template>
    <xsl:template match="*|@*" name="basicFrontMatterHierarchy" mode="basicFrontMatterHierarchy">
        <xsl:param name="level" select="'0'"/>
        <xsl:choose>
            <xsl:when test="name()='text:h'" />
            <xsl:otherwise>
                <xsl:call-template name="allTags">
                    <xsl:with-param name="level" select="$level" />
                </xsl:call-template>
                <xsl:apply-templates select="following-sibling::*[1]" mode="basicFrontMatterHierarchy">
                    <xsl:with-param name="level" select="$level" />
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!--
	=============================
	LEVEL HIERARCHY
	=============================
    -->
    <xsl:template match="*|@*" name="hierarchy" mode="hierarchy">
        <!-- Specify which element calls this template (optional) -->
        <xsl:param name="source"/>
        <!-- Store the current depth level (1, 2, etc.) (optional) -->
        <xsl:param name="level" select="'0'"/>
        <!--
    Specify the id of the node you don't want to have in the result set
    (optional)
        -->
        <xsl:param name="excludeNodeId"/>
        <xsl:choose>
            <xsl:when test="name(current())='text:section' and current()/@text:name='BodyMatterStart'" />
            <xsl:when test="name(current())='text:section' and current()/@text:name='RearMatterStart'" />
            
            <!-- If the matched element is an address  -->
            <xsl:when test="name(current())='text:p' and @text:style-name='_5b_DAISY_5d__20_Address'">
                <address>
                    <xsl:call-template name="addLangAttrPara" />
                    <xsl:apply-templates select="." mode="scanAddress">
                        <xsl:with-param name="level" select="$level"/>
                    </xsl:apply-templates>
                </address>
                <xsl:variable name="numberLines">
                    <xsl:call-template name="numberFollowingSameStyle">
                        <xsl:with-param name="tagName" select="'text:p'"/>
                        <xsl:with-param name="styleName" select="'_5b_DAISY_5d__20_Address'"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:apply-templates select="following-sibling::*[$numberLines+0]" mode="hierarchy">
                    <xsl:with-param name="level" select="$level"/>
                </xsl:apply-templates>
            </xsl:when>
            
            
            <!-- If the matched element is an Computer Code  -->
            <!--
            <xsl:when test="name(current())='text:p' and current()/@text:style-name='Computer_20_Code'">
                <code>
                    <xsl:apply-templates select="." mode="scanComputerCode">
                        <xsl:with-param name="level" select="$level"/>
                    </xsl:apply-templates>
                </code>
                <xsl:variable name="numberLines">
                    <xsl:call-template name="numberFollowingSameStyle">
                        <xsl:with-param name="tagName" select="'text:p'"/>
                        <xsl:with-param name="styleName" select="'Computer_20_Code'"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:apply-templates select="following-sibling::*[$numberLines+0]" mode="hierarchy">
                    <xsl:with-param name="level" select="$level"/>
                </xsl:apply-templates>
            </xsl:when>
            -->
            
            <!-- If the matched element is a Blockquote  -->
            <xsl:when test="name(current())='text:p' and current()/@text:style-name='_5b_DAISY_5d__20_Blockquote'">
                <blockquote>
                    <xsl:call-template name="addLangAttrPara" />
                    <xsl:apply-templates select="." mode="scanBlockquote">
                        <xsl:with-param name="level" select="$level"/>
                    </xsl:apply-templates>
                </blockquote>
                <xsl:variable name="numberLines">
                    <xsl:call-template name="numberFollowingSameStyle">
                        <xsl:with-param name="tagName" select="'text:p'"/>
                        <xsl:with-param name="styleName" select="'_5b_DAISY_5d__20_Blockquote'"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:apply-templates select="following-sibling::*[$numberLines+0]" mode="hierarchy">
                    <xsl:with-param name="level" select="$level"/>
                </xsl:apply-templates>
            </xsl:when>
            
            
            <!-- If the matched element is a Prodnote -->
            <xsl:when test="name(current())='text:p' and current()/@text:style-name='_5b_DAISY_5d__20_Prodnote'">
                <prodnote render="required">
                    <xsl:call-template name="addLangAttrPara" />
                    <xsl:apply-templates select="." mode="scanProdnote">
                        <xsl:with-param name="level" select="$level"/>
                    </xsl:apply-templates>
                </prodnote>
                <xsl:variable name="numberLines">
                    <xsl:call-template name="numberFollowingSameStyle">
                        <xsl:with-param name="tagName" select="'text:p'"/>
                        <xsl:with-param name="styleName" select="'_5b_DAISY_5d__20_Prodnote'"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:apply-templates select="following-sibling::*[$numberLines+0]" mode="hierarchy">
                    <xsl:with-param name="level" select="$level"/>
                </xsl:apply-templates>
            </xsl:when>
            
            
            <!-- If the matched element is a Prodnote Optional -->
            <xsl:when test="name(current())='text:p' and current()/@text:style-name='_5b_DAISY_5d__20_Prodnote_20__28_Optional_29_'">
                <prodnote render="optional">
                    <xsl:call-template name="addLangAttrPara" />
                    <xsl:apply-templates select="." mode="scanProdnoteOptional">
                        <xsl:with-param name="level" select="$level"/>
                    </xsl:apply-templates>
                </prodnote>
                <xsl:variable name="numberLines">
                    <xsl:call-template name="numberFollowingSameStyle">
                        <xsl:with-param name="tagName" select="'text:p'"/>
                        <xsl:with-param name="styleName" select="'_5b_DAISY_5d__20_Prodnote_20__28_Optional_29_'"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:apply-templates select="following-sibling::*[$numberLines+0]" mode="hierarchy">
                    <xsl:with-param name="level" select="$level"/>
                </xsl:apply-templates>
            </xsl:when>
            
            
            <!-- If the matched element is a Sample -->
            <xsl:when test="name(current())='text:p' and current()/@text:style-name='_5b_DAISY_5d__20_Sample'">
                <samp>
                    <xsl:call-template name="addLangAttrPara" />
                    <xsl:apply-templates select="." mode="scanSample">
                        <xsl:with-param name="level" select="$level"/>
                    </xsl:apply-templates>
                </samp>
                <xsl:variable name="numberLines">
                    <xsl:call-template name="numberFollowingSameStyle">
                        <xsl:with-param name="tagName" select="'text:p'"/>
                        <xsl:with-param name="styleName" select="'_5b_DAISY_5d__20_Sample'"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:apply-templates select="following-sibling::*[$numberLines+0]" mode="hierarchy">
                    <xsl:with-param name="level" select="$level"/>
                </xsl:apply-templates>
            </xsl:when>
            
            
            <!-- If the matched element is not a title (text:h) -->
            <xsl:when test="name(.) != 'text:h'">
                <xsl:call-template name="allTags">
                    <xsl:with-param name="level" select="$level"/>
                    <xsl:with-param name="source" select="'hierarchy'"/>
                </xsl:call-template>
                <xsl:apply-templates select="following-sibling::*[1]" mode="hierarchy">
                    <xsl:with-param name="level" select="$level"/>
                    <xsl:with-param name="source" select="$source"/>
                </xsl:apply-templates>
            </xsl:when>
            
            <!-- If the matched element is a title (text:h)
            and is deeper (level) than the preceding title -->
            <xsl:when test="@text:outline-level > $level">
                <xsl:if test="$level >= 0">
                    
                    <!-- Part, Chapter, Section, Subsection -->
                    <xsl:variable name="topStructuringElementName" 
                                  select="/office:document/office:meta/meta:user-defined[@meta:name='DAISY TOP LEVEL']/text()" />
                    
                    <!-- Part, Chapter, Section, Subsection -->
                    <xsl:variable name="structuringElementName">
                        <xsl:choose>
                            <xsl:when test="@text:outline-level=1 and $source='book' and $topStructuringElementName='Part'">
                                <xsl:value-of select="'part'"/>
                            </xsl:when>
                            <xsl:when test="@text:outline-level=2 and $source='book' and $topStructuringElementName='Part'">
                                <xsl:value-of select="'chapter'"/>
                            </xsl:when>
                            <xsl:when test="@text:outline-level=3 and $source='book' and $topStructuringElementName='Part'">
                                <xsl:value-of select="'section'"/>
                            </xsl:when>
                            <xsl:when test="@text:outline-level=4 and $source='book' and $topStructuringElementName='Part'">
                                <xsl:value-of select="'subsection'"/>
                            </xsl:when>
                            <xsl:when test="@text:outline-level=1 and $source='book' and $topStructuringElementName='Chapter'">
                                <xsl:value-of select="'chapter'"/>
                            </xsl:when>
                            <xsl:when test="@text:outline-level=2 and $source='book' and $topStructuringElementName='Chapter'">
                                <xsl:value-of select="'section'"/>
                            </xsl:when>
                            <xsl:when test="@text:outline-level=3 and $source='book' and $topStructuringElementName='Chapter'">
                                <xsl:value-of select="'subsection'"/>
                            </xsl:when>
                            <xsl:when test="@text:outline-level=1 and $source='book' and $topStructuringElementName='Section'">
                                <xsl:value-of select="'section'"/>
                            </xsl:when>
                            <xsl:when test="@text:outline-level=2 and $source='book' and $topStructuringElementName='Section'">
                                <xsl:value-of select="'subsection'"/>
                            </xsl:when>
                            
                            <!-- Add class attribute for level1 (title_page, acknowledgments, dedication, preface, appendix, ...)-->
                            <!--<xsl:when test="$level=0 and $source!='book'">
                                <xsl:value-of select="$source" />
                            </xsl:when>
                            -->
                            <xsl:otherwise>
                                <xsl:value-of select="''"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    
                    <!-- LEVEL Element -->
                    <!-- output <level depth=""><hd> style -->
                    <xsl:if test="$paramAlternateMarkup">
                        <xsl:element name="level">
                            <xsl:attribute name="depth">
                                <xsl:value-of select="current()/@text:outline-level" />
                            </xsl:attribute>
                            <xsl:if test="string-length($structuringElementName)>0">
                                <xsl:attribute name="class">
                                    <xsl:value-of select="$structuringElementName" />
                                </xsl:attribute>
                            </xsl:if>
                            
                            <!-- pagenum before -->
                            <xsl:if test="name(preceding-sibling::*[1]) = 'pagenum'">
                                <!--<xsl:comment>pagenumber before !</xsl:comment>-->
                                <xsl:apply-templates select="preceding-sibling::*[1]" />
                            </xsl:if>
                            
                            <!-- HD ELEMENT -->
                            <hd>
                                <xsl:call-template name="addLangAttrPara" />
                                <xsl:apply-templates />
                            </hd>
                            <xsl:apply-templates select="following-sibling::*[1]" mode="hierarchy">
                                <xsl:with-param name="level" select="@text:outline-level"/>
                                <xsl:with-param name="source" select="$source"/>
                            </xsl:apply-templates>
                        </xsl:element>
                    </xsl:if>
                    
                    <!-- LEVEL1-LEVEL6 Element -->
                    <!-- output <level1><h1> style -->
                    <xsl:if test="not($paramAlternateMarkup)">
                        <xsl:element name="level{current()/@text:outline-level}">
                            <xsl:if test="string-length($structuringElementName)>0">
                                <xsl:attribute name="class">
                                    <xsl:value-of select="$structuringElementName" />
                                </xsl:attribute>
                            </xsl:if>
                            
                            <!-- pagenum before -->
                            <xsl:if test="name(preceding-sibling::*[1]) = 'pagenum'">
                                <!--<xsl:comment>pagenumber before !</xsl:comment>-->
                                <xsl:apply-templates select="preceding-sibling::*[1]" />
                            </xsl:if>
                            
                            <!-- H1-H6 ELEMENT -->
                            <xsl:element name="h{current()/@text:outline-level}">
                                <xsl:call-template name="addLangAttrPara" />
                                <xsl:apply-templates />
                            </xsl:element>
                            <xsl:apply-templates select="following-sibling::*[1]" mode="hierarchy">
                                <xsl:with-param name="level" select="@text:outline-level"/>
                                <xsl:with-param name="source" select="$source"/>
                            </xsl:apply-templates>
                        </xsl:element>
                    </xsl:if>
                </xsl:if>
                <xsl:apply-templates select="following-sibling::*[1]" mode="scanLevel">
                    <xsl:with-param name="level" select="@text:outline-level"/>
                    <xsl:with-param name="source" select="$source"/>
                </xsl:apply-templates>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="*" mode="scanLevel">
        <xsl:param name="level" select="'0'"/>
        <xsl:param name="source"/>
        <xsl:choose>
            <xsl:when test="name() = 'text:section' and @text:name='BodyMatterStart'" />
            <xsl:when test="name() = 'text:section' and @text:name='RearMatterStart'" />
            <xsl:when test="@text:outline-level &lt; $level"/>
            <xsl:when test="@text:outline-level = $level">
                <xsl:call-template name="hierarchy">
                    <!--     <xsl:with-param name="level" select="$level"/>-->
                    <xsl:with-param name="source" select="$source"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="following-sibling::*[1]" mode="scanLevel">
                    <xsl:with-param name="level" select="$level"/>
                    <xsl:with-param name="source" select="$source"/>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="*" mode="scanAddress">
        <xsl:param name="level" select="'0'"/>
        <xsl:param name="source"/>
        <line>
            <xsl:apply-templates />
        </line>
        <xsl:choose>
            <xsl:when test="name(following-sibling::*[1])='text:p' and following-sibling::*[1]/@text:style-name='_5b_DAISY_5d__20_Address'">
                <xsl:apply-templates select="following-sibling::*[1]" mode="scanAddress">
                    <xsl:with-param name="level" select="$level"/>
                    <xsl:with-param name="source" select="$source"/>
                </xsl:apply-templates>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    
    
    <!--
    <xsl:template match="*" mode="scanComputerCode">
        <xsl:param name="level" select="'0'"/>
        <xsl:param name="source"/>
        
        <xsl:value-of select="$NL" />
        <xsl:value-of select="current()/text()" />
        
        <xsl:choose>
            <xsl:when test="name(following-sibling::*[1])='text:p' and following-sibling::*[1]/@text:style-name='Computer_20_Code'">
                <xsl:apply-templates select="following-sibling::*[1]" mode="scanComputerCode">
                    <xsl:with-param name="level" select="$level"/>
                    <xsl:with-param name="source" select="$source"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$NL" />
            </xsl:otherwise>
            
        </xsl:choose>
    </xsl:template>
    -->
    <xsl:template match="*" mode="scanBlockquote">
        <xsl:param name="level" select="'0'"/>
        <xsl:param name="source"/>
        <p>
            <xsl:apply-templates />
        </p>
        <xsl:choose>
            <xsl:when test="name(following-sibling::*[1])='text:p' and following-sibling::*[1]/@text:style-name='_5b_DAISY_5d__20_Blockquote'">
                <xsl:apply-templates select="following-sibling::*[1]" mode="scanBlockquote">
                    <xsl:with-param name="level" select="$level"/>
                    <xsl:with-param name="source" select="$source"/>
                </xsl:apply-templates>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="*" mode="scanProdnote">
        <xsl:param name="level" select="'0'"/>
        <xsl:param name="source"/>
        <p>
            <xsl:apply-templates />
        </p>
        <xsl:choose>
            <xsl:when test="name(following-sibling::*[1])='text:p' and following-sibling::*[1]/@text:style-name='_5b_DAISY_5d__20_Prodnote'">
                <xsl:apply-templates select="following-sibling::*[1]" mode="scanProdnote">
                    <xsl:with-param name="level" select="$level"/>
                    <xsl:with-param name="source" select="$source"/>
                </xsl:apply-templates>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="*" mode="scanProdnoteOptional">
        <xsl:param name="level" select="'0'"/>
        <xsl:param name="source"/>
        <p>
            <xsl:apply-templates />
        </p>
        <xsl:choose>
            <xsl:when test="name(following-sibling::*[1])='text:p' and following-sibling::*[1]/@text:style-name='_5b_DAISY_5d__20_Prodnote_20__28_Optional_29_'">
                <xsl:apply-templates select="following-sibling::*[1]" mode="scanProdnoteOptional">
                    <xsl:with-param name="level" select="$level"/>
                    <xsl:with-param name="source" select="$source"/>
                </xsl:apply-templates>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="*" mode="scanSample">
        <xsl:param name="level" select="'0'"/>
        <xsl:param name="source"/>
        
        <!--<xsl:value-of select="$NL" />-->
        <span><xsl:apply-templates /><br /></span>
        <xsl:choose>
            <xsl:when test="name(following-sibling::*[1])='text:p' and following-sibling::*[1]/@text:style-name='_5b_DAISY_5d__20_Sample'">
                <xsl:apply-templates select="following-sibling::*[1]" mode="scanSample">
                    <xsl:with-param name="level" select="$level"/>
                    <xsl:with-param name="source" select="$source"/>
                </xsl:apply-templates>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="postParaProcess">
        <!-- ELEMENT SIDEBAR -->
        <!-- if it's a frame -->
        <xsl:if test="current()//draw:frame">
            <xsl:for-each select="current()//draw:frame">
            <xsl:choose>
                <!-- A frame starting with a para -->
                <xsl:when test="draw:text-box/text:p/@text:style-name='Frame_20_contents'">
                   <sidebar render="required">
                      <xsl:apply-templates select="draw:text-box/*" />
                   </sidebar>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="name(draw:text-box/*[1]) != '' and name(draw:text-box/*[1]) != 'text:p'">
                        <sidebar render="required">
                            <xsl:apply-templates select="draw:text-box/*" />
                        </sidebar>
                    </xsl:if>
                </xsl:otherwise>                    
            </xsl:choose>
            </xsl:for-each>
        </xsl:if>
        
        <!-- ANNOTATION ELEMENT -->
        <!-- Added Note After <p> using it (NOT at end of page) -->
        <xsl:if test="current()//office:annotation">
            <xsl:for-each select="current()//office:annotation">
                <xsl:element name="annotation">
                    <xsl:attribute name= "id">
                        <xsl:value-of select="'anno_'" />
                        <xsl:value-of select="generate-id()" />
                    </xsl:attribute>
                    <xsl:for-each select="text:p">
                        <xsl:call-template name="para" />
                    </xsl:for-each>
                    <xsl:if test="dc:creator">
                        <author>
                            <xsl:value-of select="dc:creator"/>
                        </author>
                    </xsl:if>
                    <xsl:if test="dc:date">
                        <dateline>
                            <xsl:call-template name="formatDate">
                                <xsl:with-param name="date" select="dc:date"/>
                            </xsl:call-template>
                        </dateline>
                    </xsl:if>
                </xsl:element>
            </xsl:for-each>
        </xsl:if>
        
        
        <!-- FOOTNOTE/ENDNOTE ELEMENT -->
        <!-- Added Note After <p> using it (NOT at end of page) -->
        <xsl:if test="current()//text:note">
            <xsl:for-each select="current()//text:note">
                <xsl:element name="note">
                    <xsl:attribute name="id">
                        <xsl:value-of select="@text:id" />
                    </xsl:attribute>
                    <xsl:attribute name="class">
                        <xsl:value-of select="@text:note-class" />
                    </xsl:attribute>
                    <xsl:apply-templates select="text:note-body" />
                </xsl:element>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    <xsl:template name="allTags">
        <xsl:param name="source"/>
        <xsl:param name="level" />
        <xsl:choose>
            <xsl:when test="name(current())='text:h'">
                <xsl:choose>
                    <xsl:when test="$source='hierarchy'"/>
                    <xsl:otherwise>
                        <p>ERROR: Title hierarchy is wrong, section title is in bad position.</p>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="name(current())='text:p'">
                <xsl:call-template name="para">
                    <xsl:with-param name="source" select="$source"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="name(current())='text:section'">
                <xsl:call-template name="section">
                    <xsl:with-param name="level" select="$level" />
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="name(current())='text:list'">
                <xsl:call-template name="list"/>
            </xsl:when>
            <xsl:when test="name(current())='table:table'">
                <xsl:call-template name="table"/>
            </xsl:when>
            <xsl:when test="name(current())='pagenum'">
                <xsl:if test="name(following-sibling::*[1]) != 'text:h'">
                    <xsl:call-template name="pagenumbering" />
                </xsl:if>
            </xsl:when>
            <xsl:when test="name(current())='text:table-of-content'">
                <xsl:call-template name="printtoc">
                    <xsl:with-param name="level" select="$level" />
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    
    
    <!--
	=============
	DOCUMENT BODY
	=============
      -->
    
    <!--
	===========
	BLOCKS TAGS
	===========
      -->
    
    <!-- Blocks - Standards blocks -->
    <xsl:template name="para">
        <xsl:param name="source"/>
        <xsl:choose>
            
            <!-- Non-Empty Para -->
            <xsl:when test="string(.) or count(./*) > 0">
                <xsl:variable name="parentStyleName"
                              select="/office:document/office:automatic-styles/
                              style:style[@style:name=(current()/@text:style-name)]/
                @style:parent-style-name"/>
                <xsl:variable name="parentStyleNameOfPreceding"
                              select="/office:document/office:automatic-styles/
                              style:style[@style:name=current()/
                              preceding-sibling::*[1]/@text:style-name]/
                @style:parent-style-name"/>
                <xsl:variable name="parentStyleNameOfFollowing"
                              select="/office:document/office:automatic-styles/
                              style:style[@style:name=current()/
                              following-sibling::*[1]/@text:style-name]/
                @style:parent-style-name"/>
                <xsl:choose>
                    
                    <!-- AUTHOR ELEMENT -->
                    <xsl:when test="@text:style-name='_5b_DAISY_5d__20_Author' or $parentStyleName='_5b_DAISY_5d__20_Author'">
                        <author>
                            <xsl:call-template name="addLangAttrPara" />
                            <xsl:apply-templates/>
                        </author>
                    </xsl:when>
                    
                    <!-- BRIDGEHEAD ELEMENT -->
                    <xsl:when test="@text:style-name='_5b_DAISY_5d__20_BridgeHead' or $parentStyleName='_5b_DAISY_5d__20_BridgeHead'">
                        <bridgehead>
                            <xsl:call-template name="addLangAttrPara" />
                            <xsl:apply-templates/>
                        </bridgehead>
                    </xsl:when>
                    
                    <!-- BYLINE ELEMENT -->
                    <xsl:when test="@text:style-name='_5b_DAISY_5d__20_ByLine' or $parentStyleName='_5b_DAISY_5d__20_ByLine'">
                        <byline>
                            <xsl:call-template name="addLangAttrPara" />
                            <xsl:apply-templates/>
                        </byline>
                    </xsl:when>
                    
                    <!-- DATELINE ELEMENT -->
                    <xsl:when test="@text:style-name='_5b_DAISY_5d__20_DateLine' or $parentStyleName='_5b_DAISY_5d__20_DateLine'">
                        <dateline>
                            <xsl:call-template name="addLangAttrPara" />
                            <xsl:apply-templates/>
                        </dateline>
                    </xsl:when>
                    
                    <!-- KEYBOARD INPUT ELEMENT -->
                    <xsl:when test="@text:style-name='_5b_DAISY_5d__20_Keyboard_20_Input' or $parentStyleName='_5b_DAISY_5d__20_Keyboard_20_Input'">
                        <kbd>
                            <xsl:call-template name="addLangAttrPara" />
                            <xsl:apply-templates/>
                        </kbd>
                    </xsl:when>
                    
                    <!-- QUOTATION ELEMENT -->
                    <!--<xsl:when test="@text:style-name='Quotations' or $parentStyleName='Quotations'">
                        <q><xsl:apply-templates/></q>
                    </xsl:when>
                    -->
                    <xsl:otherwise>
                        
                        <!-- P ELEMENT -->
                        <!-- No breaklines in paras -->
                        <p>
                            <xsl:call-template name="addLangAttrPara" />
                            <xsl:apply-templates />
                        </p>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:call-template name="postParaProcess" />
            </xsl:when>
            
            <!-- Empty Para -->
            <xsl:otherwise>
                <!--<br />-->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="text:note">
        <xsl:element name="noteref">
            <xsl:attribute name="idref">
                <xsl:value-of select="'#'" />
                <xsl:value-of select="@text:id" />
            </xsl:attribute>
            <xsl:attribute name="class">
                <xsl:value-of select="@text:note-class" />
            </xsl:attribute>
            <xsl:value-of select="text:note-citation/text()" />
        </xsl:element>
    </xsl:template>
    <xsl:template match="office:annotation">
        <xsl:element name="annoref">
            <xsl:attribute name="idref">
                <xsl:value-of select="'#anno_'" />
                <xsl:value-of select="generate-id()" />
            </xsl:attribute>
            <xsl:value-of select="' '" />
        </xsl:element>
    </xsl:template>
    
    
    <!--
        ========
        SECTIONS
        ======== 
    -->
    <xsl:template name="section">
        <xsl:param name="level" />
        <!--<div>-->
        <xsl:apply-templates select="child::*[1]" mode="hierarchy">
            <xsl:with-param name="level" select="$level" />
        </xsl:apply-templates>
        <!--</div>-->
    </xsl:template>
    
    <!--
	=====
	LISTS
	=====
      -->
    
    <!-- LIST ELEMENT -->
    <xsl:template name="list" match="text:list">

        <xsl:variable name="offset-list">
            <xsl:call-template name="find-offset-list">
                <xsl:with-param name="node" select="." />
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="list-style-name">
            <xsl:call-template name="find-list-style-name">
                <xsl:with-param name="node" select="." />
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="numbering-format">
                    <xsl:value-of select="/office:document/office:automatic-styles
                  /text:list-style[
                        @style:name = $list-style-name]
                        /text:list-level-style-number[@text:level = ($offset-list + 1)]
          /@style:num-format" />
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="string-length($numbering-format) > 0">
                <list type="ol" enum="{$numbering-format}">
                    <xsl:apply-templates />
                </list>
            </xsl:when>
            <xsl:otherwise>
                <list type="ul">
                    <xsl:apply-templates />
                </list>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    
    <!-- LI ELEMENT -->
    <xsl:template match="text:list-item">
        <li>
            <xsl:choose>
                <xsl:when test="name(child::*[1]) != 'text:list'">
                    <xsl:apply-templates  select="child::*" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="child::*" />
                </xsl:otherwise>
            </xsl:choose>
        </li>
    </xsl:template>


    <xsl:template name="find-offset-list">
       <xsl:param name="node" />
       <xsl:param name="acc" select="0" />
       <xsl:choose>
           <xsl:when test="name($node) = 'text:list' and $node[not(@text:style-name)]">
               <xsl:call-template name="find-offset-list">
                   <xsl:with-param name="node" select="$node/parent::*" />
                   <xsl:with-param name="acc" select="$acc+1" />
               </xsl:call-template>
           </xsl:when>
           <xsl:when test="name($node) = 'text:list'">
              <xsl:value-of select="$acc" />
           </xsl:when>
           <xsl:otherwise>
               <xsl:call-template name="find-offset-list">
                   <xsl:with-param name="node" select="$node/parent::*" />
                   <xsl:with-param name="acc" select="$acc" />
               </xsl:call-template>
           </xsl:otherwise>
       </xsl:choose>
    </xsl:template>

    <xsl:template name="find-list-style-name">
       <xsl:param name="node" />
       <xsl:choose>
           <xsl:when test="name($node) = 'text:list' and $node[not(@text:style-name)]">
               <xsl:call-template name="find-list-style-name">
                   <xsl:with-param name="node" select="$node/parent::*" />
               </xsl:call-template>
           </xsl:when>
           <xsl:when test="name($node) = 'text:list'">
              <xsl:value-of select="$node/@text:style-name" />
           </xsl:when>
           <xsl:otherwise>
               <xsl:call-template name="find-list-style-name">
                   <xsl:with-param name="node" select="$node/parent::*" />
               </xsl:call-template>
           </xsl:otherwise>
       </xsl:choose>
    </xsl:template>
    
    <!--
  ======
  TABLES
  ======
    -->
    <xsl:template match="table:table" name="table">
        
        <!-- get Parant Style Name of first para cell -->
        <xsl:variable name="parentStyleNameFirstCell"
                      select="/office:document/office:automatic-styles/
                      style:style[
                      @style:name=(current()/table:table-row[1]/table:table-cell/text:p/@text:style-name)
        ]/@style:parent-style-name"/>
        <xsl:variable name="styleNameFirstCell"
                      select="current()/table:table-row[1]/table:table-cell/text:p/@text:style-name"/>
        
        <!-- TABLE ELEMENT -->
        <table>
            <xsl:choose>
                
                <!-- if table have headings -->
                <xsl:when test="$parentStyleNameFirstCell = 'Table_20_Heading' or $styleNameFirstCell = 'Table_20_Heading'">
                    
                    <!-- THEAD ELEMENT -->
                    <thead>
                        <xsl:apply-templates select="current()/table:table-row[ position() = 1 ]">
                            <xsl:with-param name="heading" select="true()" />
                        </xsl:apply-templates>
                    </thead>
                    
                    <!-- TBODY ELEMENT -->
                    <tbody>
                        <xsl:apply-templates select="current()/table:table-row[ position() > 1 ]" />
                    </tbody>
                </xsl:when>

                <!-- if table have headings (with table:table-header-rows) -->
                <xsl:when test="current()/table:table-header-rows">

                    <!-- THEAD ELEMENT -->
                    <thead>
                        <xsl:apply-templates select="current()/table:table-header-rows/table:table-row">
                            <xsl:with-param name="heading" select="true()" />
                        </xsl:apply-templates>
                    </thead>

                    <!-- TBODY ELEMENT -->
                    <tbody>
                        <xsl:apply-templates select="current()/table:table-row" />
                    </tbody>
                </xsl:when>

                <!-- simple table -->
                <xsl:otherwise>
                    <xsl:apply-templates />
                </xsl:otherwise>
            </xsl:choose>
        </table>
    </xsl:template>
    
    
    
    <!-- TR ELEMENT -->
    <xsl:template match="table:table-row" name="table-row">
        <xsl:param name="heading" select="false()" />
        <tr>
            <xsl:apply-templates>
                <xsl:with-param name="heading" select="$heading" />
            </xsl:apply-templates>
        </tr>
    </xsl:template>
    <xsl:template match="table:table-cell" name="table-cell">
        <xsl:param name="heading" select="false()" />
        <xsl:choose>
            
            <!-- TH ELEMENT -->
            <!-- if it is an heading table -->
            <xsl:when test="$heading">
                <th>
                    <xsl:apply-templates />
                </th>
            </xsl:when>
            
            <!-- if it a normal cell -->
            <xsl:otherwise>
                
                <!-- TD ELEMENT -->
                <xsl:element name="td">
                    <xsl:if test="@table:number-columns-spanned">
                        <xsl:attribute name="colspan">
                            <xsl:value-of select="@table:number-columns-spanned" />
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="@table:number-rows-spanned">
                        <xsl:attribute name="rowspan">
                            <xsl:value-of select="@table:number-rows-spanned" />
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:apply-templates />
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <!--
       =============
       PAGENUMBERING
       =============
    -->
    <xsl:template match="pagenum" name="pagenumbering">
        <xsl:call-template name="printPageTag" />
    </xsl:template>
    <xsl:template name="printPageTag">
        <xsl:variable name="attrPage">
            <xsl:choose>
                <xsl:when test="@enum = '1'">
                    <xsl:value-of select="'normal'" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'special'" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="@render='true'">
            <pagenum id="{concat('p',generate-id())}" page="{$attrPage}">
                <xsl:value-of select="@value" />
            </pagenum>
        </xsl:if>
        <xsl:if test="name(following-sibling::*[1]) = 'pagenum'">
            <p><xsl:value-of select="translate($L10N_Blank_Page_X,'@',@value)" /></p>
        </xsl:if>
    </xsl:template>
    
    <!-- 
    ================
    TOC
    ================
    -->
    <xsl:template name="printtoc">
        <xsl:param name="level" />
        <xsl:variable name="tocname" select="text:table-of-content-source/text:index-title-template/text()" />
        
        <!-- print toc level -->
        <xsl:if test="$paramAlternateMarkup">
            <level depth="{$level+1}" class="print_toc">
                <hd>
                    <xsl:value-of select="$tocname" />
                </hd>
                <xsl:apply-templates select="text:index-body" />
            </level>
        </xsl:if>
        <xsl:if test="not($paramAlternateMarkup)">
            <xsl:element name="level{$level+1}">
                <xsl:attribute name="class">print_toc</xsl:attribute>
                <xsl:element name="h{$level+1}">
                    <xsl:value-of select="$tocname" />
                </xsl:element>
                <xsl:apply-templates select="text:index-body" />
            </xsl:element>
        </xsl:if>
    </xsl:template>
    <xsl:template match="text:index-body">
        <list class="toc" type="pl">
            <xsl:for-each select="*">
                <xsl:if test="name(.)='text:p'">
                    <li>
                        <lic class="entry">
                            <xsl:call-template name="scanTocEntry" />
                        </lic>
                        <lic class="pagenum">
                            <xsl:call-template name="scanTocPagenum" />
                        </lic>
                    </li>
                </xsl:if>
                <xsl:if test="name(.)='pagenum'">
                    <xsl:call-template name="pagenumbering" />
                </xsl:if>
            </xsl:for-each>
        </list>
    </xsl:template>
    <xsl:template name="scanTocEntry">
        <xsl:variable name="entry">
            <xsl:apply-templates select="." />
        </xsl:variable>
        <xsl:value-of select="substring-before($entry,$TAB)" />
    </xsl:template>
    <xsl:template name="scanTocPagenum">
        <xsl:variable name="entry">
            <xsl:apply-templates select="." />
        </xsl:variable>
        <xsl:value-of select="substring-after($entry,$TAB)" />
    </xsl:template>
    <xsl:template match="text:tab">
        <xsl:value-of select="$TAB" />
    </xsl:template>
    
    
    
    <!--
     ============
     INLINES TAGS
     ============
  -->
    <xsl:template match="text:p">
        <xsl:param name="source" />
        <xsl:call-template name="para">
            <xsl:with-param name="source" select="$source"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="text:span">
        <xsl:if test="string(.) or count(./*) > 0">
            <xsl:variable name="fontStyle"
                      select="/office:document/office:automatic-styles/
                      style:style[@style:name=(current()/@text:style-name)]
        /style:text-properties/@fo:font-style"/>
            <xsl:variable name="fontWeight"
                      select="/office:document/office:automatic-styles/
                      style:style[@style:name=(current()/
                      @text:style-name)]/style:text-properties/
        @fo:font-weight"/>
            <xsl:variable name="fontName"
                      select="/office:document/office:automatic-styles/
                      style:style[@style:name=(current()/
                      @text:style-name)]/style:properties/
        @style:font-name"/>
            <xsl:variable name="textPosition"
                      select="/office:document/office:automatic-styles/
                      style:style[@style:name=(current()/
                      @text:style-name)]/style:text-properties/
        @style:text-position"/>
            <xsl:variable name="parentStyleName"
                      select="/office:document/office:styles/
                      style:style[@style:name=(current()/
        @text:style-name)]/@style:parent-style-name"/>
        
        <!-- With this template, we matches derived of derived (of derived ...) of Citation Styles -->
        <!--<xsl:variable name="isCitation">
            <xsl:call-template name="hasParentStyle">
                <xsl:with-param name="style-name" select="@text:style-name" />
                <xsl:with-param name="match-style-name" select="'Citation'" />
            </xsl:call-template>
        </xsl:variable>-->
            <xsl:choose>
            
            <!-- QUOTATION INLINE ELEMENT (can match derived of derived of Quotation)-->
            <!-- <xsl:when test="$isCitation=1">
                <q>
                    <xsl:call-template name="addLangAttrSpan" />
                    <xsl:apply-templates/>
                </q>
            </xsl:when>-->
            
            <!-- QUOTATION INLINE ELEMENT -->
                <xsl:when test="@text:style-name='Citation' 
            or $parentStyleName='Citation'
            or @text:style-name='_5b_DAISY_5d__20_Quotation'
            or $parentStyleName='_5b_DAISY_5d__20_Quotation'">
                    <q>
                        <xsl:call-template name="addLangAttrSpan" />
                        <xsl:apply-templates/>
                    </q>
                </xsl:when>
            
            <!-- ABBREVIATION INLINE ELEMENT -->
                <xsl:when test="@text:style-name='_5b_DAISY_5d__20_Abbreviation'
            or $parentStyleName='_5b_DAISY_5d__20_Abbreviation'">
                    <abbr>
                        <xsl:call-template name="addLangAttrSpan" />
                        <xsl:apply-templates/>
                    </abbr>
                </xsl:when>
            
            <!-- ACRONYM INLINE ELEMENT -->
                <xsl:when test="@text:style-name='_5b_DAISY_5d__20_Acronym'
            or $parentStyleName='_5b_DAISY_5d__20_Acronym'">
                    <acronym pronounce="no">
                        <xsl:call-template name="addLangAttrSpan" />
                        <xsl:apply-templates/>
                    </acronym>
                </xsl:when>
            
            <!-- ACRONYM PRONOUNCE INLINE ELEMENT -->
                <xsl:when test="@text:style-name='_5b_DAISY_5d__20_Acronym_20__28_Pronounce_29_'
            or $parentStyleName='_5b_DAISY_5d__20_Acronym_20__28_Pronounce_29_'">
                    <acronym pronounce="yes">
                        <xsl:call-template name="addLangAttrSpan" />
                        <xsl:apply-templates/>
                    </acronym>
                </xsl:when>
            
            <!-- COMPUTER CODE INLINE ELEMENT -->
                <xsl:when test="@text:style-name='_5b_DAISY_5d__20_Computer_20_Code'
            or $parentStyleName='_5b_DAISY_5d__20_Computer_20_Code'">
                    <code>
                        <xsl:apply-templates/>
                    </code>
                </xsl:when>
            
            <!-- KEYBOARD INPUT INLINE ELEMENT -->
                <xsl:when test="@text:style-name='_5b_DAISY_5d__20_Keyboard_20_Input'
            or $parentStyleName='_5b_DAISY_5d__20_Keyboard_20_Input'">
                    <kbd>
                        <xsl:apply-templates/>
                    </kbd>
                </xsl:when>
            
            <!-- PRODNOTE INLINE ELEMENT -->
                <xsl:when test="@text:style-name='_5b_DAISY_5d__20_Prodnote'
            or $parentStyleName='_5b_DAISY_5d__20_Prodnote'">
                    <prodnote render="required">
                        <xsl:call-template name="addLangAttrSpan" />
                        <xsl:apply-templates/>
                    </prodnote>
                </xsl:when>
            
            <!-- PRODNOTE OPTIONAL INLINE ELEMENT -->
                <xsl:when test="@text:style-name='_5b_DAISY_5d__20_Prodnote_20__28_Optional_29_'
            or $parentStyleName='_5b_DAISY_5d__20_Prodnote_20__28_Optional_29_'">
                    <prodnote render="optional">
                        <xsl:call-template name="addLangAttrSpan" />
                        <xsl:apply-templates/>
                    </prodnote>
                </xsl:when>
            
            <!-- SAMPLE INLINE ELEMENT -->
                <xsl:when test="@text:style-name='_5b_DAISY_5d__20_Sample'
            or $parentStyleName='_5b_DAISY_5d__20_Sample'">
                    <samp>
                        <xsl:call-template name="addLangAttrSpan" />
                        <xsl:apply-templates/>
                    </samp>
                </xsl:when>
            
            <!-- SENTENCE INLINE ELEMENT -->
                <xsl:when test="@text:style-name='_5b_DAISY_5d__20_Sentence'
            or $parentStyleName='_5b_DAISY_5d__20_Sentence'">
                    <sent>
                        <xsl:call-template name="addLangAttrSpan" />
                        <xsl:apply-templates/>
                    </sent>
                </xsl:when>
            
            <!-- SPAN INLINE ELEMENT -->
                <xsl:when test="@text:style-name='_5b_DAISY_5d__20_Span'
            or $parentStyleName='_5b_DAISY_5d__20_Span'">
                    <span>
                        <xsl:call-template name="addLangAttrSpan" />
                        <xsl:apply-templates/>
                    </span>
                </xsl:when>
            
            <!-- STRONG EMPHASIS INLINE ELEMENT -->
                <xsl:when test="@text:style-name='Strong_20_Emphasis'
            or $parentStyleName='Strong_20_Emphasis'">
                    <strong>
                        <xsl:call-template name="addLangAttrSpan" />
                        <xsl:apply-templates/>
                    </strong>
                </xsl:when>
            
            <!-- EMPHASIS INLINE ELEMENT -->
                <xsl:when test="@text:style-name='Emphasis'
            or $parentStyleName='Emphasis'">
                    <em>
                        <xsl:call-template name="addLangAttrSpan" />
                        <xsl:apply-templates/>
                    </em>
                </xsl:when>
            
            <!-- SUBSCRIPT INLINE ELEMENT -->
                <xsl:when test="contains($textPosition,'sub')">
                    <sub>
                        <xsl:call-template name="addLangAttrSpan" />
                        <xsl:apply-templates/>
                    </sub>
                </xsl:when>
            
            <!-- SUPERSCRIPT INLINE ELEMENT -->
                <xsl:when test="contains($textPosition,'sup')">
                    <sup>
                        <xsl:call-template name="addLangAttrSpan" />
                        <xsl:apply-templates/>
                    </sup>
                </xsl:when>
                <xsl:when test="$fontWeight='bold'">
                    <strong>
                        <xsl:call-template name="addLangAttrSpan" />
                        <xsl:apply-templates/>
                    </strong>
                </xsl:when>
                <xsl:when test="$fontStyle='italic'">
                    <em>
                        <xsl:call-template name="addLangAttrSpan" />
                        <xsl:apply-templates/>
                    </em>
                </xsl:when>
                <xsl:otherwise>
                    <span>
                        <xsl:call-template name="addLangAttrSpan" />
                        <xsl:apply-templates />
                    </span>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
    <!--
       BREAK LINE
       ==========
    -->
    <xsl:template match="text:line-break">
        <br />
    </xsl:template>
    
    
    <!-- 
     HYPERLINK, EMAIL
     ================
-->
    <xsl:template match="text:a">
        <!-- is it http or mailto -->
        <xsl:variable name="protocol"
                      select="substring-before(@xlink:href,':')"/>
        <xsl:choose>
            <xsl:when test="$protocol = 'http'">
                <a href="{@xlink:href}" external="true">
                    <xsl:choose>
                        <xsl:when test="string(.) or count(./*) > 0">
                            <xsl:value-of select="." />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="@xlink:href" />
                        </xsl:otherwise>
                    </xsl:choose>
                </a>
            </xsl:when>
            <xsl:when test="$protocol = 'mailto'">
                <a href="{@xlink:href}" external="true">
                    <xsl:choose>
                        <xsl:when test="string(.) or count(./*) > 0">
                            <xsl:value-of select="." />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="@xlink:href" />
                        </xsl:otherwise>
                    </xsl:choose>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="substring-after(@xlink:href,':')" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <!--
        BOOKMARKS
        ========
        -->
    <xsl:template match="text:bookmark-ref">
        <xsl:element name="a">
            <xsl:attribute name="href">
                <xsl:value-of select="'#'" />
                <xsl:value-of select="@text:ref-name" />
            </xsl:attribute>
            <xsl:attribute name="external">
                <xsl:value-of select="'false'" />
            </xsl:attribute>
            <xsl:apply-templates />
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="text:bookmark-start | text:bookmark">
       <xsl:element name="a">
           <xsl:attribute name="id">
               <xsl:value-of select="@text:name" />
           </xsl:attribute>
           <xsl:attribute name="external">
               <xsl:value-of select="'false'" />
           </xsl:attribute>
           <xsl:value-of select="following::text()[1]"/>
       </xsl:element>
   </xsl:template>

   <xsl:template match="text()[following-sibling::text:bookmark-end]"/>
   <xsl:template match="text()[preceding-sibling::text:bookmark]"/>
    
    <!--
        Image Link Element
        ==================
    -->
    <xsl:template match="draw:a">
        <xsl:element name="a">
            <xsl:attribute name="href">
                <xsl:value-of select="current()/@xlink:href" />
            </xsl:attribute>
            <xsl:attribute name="external">
                <xsl:value-of select="'true'" />
            </xsl:attribute>
            <xsl:apply-templates select="draw:frame" />
        </xsl:element>
    </xsl:template>
    
    
    <xsl:template match="draw:frame">
        <!--
    MathML Element
    ==============
    -->    
        <!-- IF this draw:frame is a MathML -->
        <xsl:if test="/office:document/office:automatic-styles
                /style:style[@style:name=(current()/@draw:style-name)]
        /@style:parent-style-name='Formula'">
            <xsl:apply-templates select="draw:object/math:math" />
        </xsl:if>
        <!-- IF this draw:frame is a MathML with Caption -->
        <xsl:if test="/office:document/office:automatic-styles
                /style:style[@style:name=(current()/@draw:style-name)]
                /@style:parent-style-name='Frame'
                and 
                /office:document/office:automatic-styles
                /style:style[@style:name=(current()/draw:text-box/text:p/draw:frame/@draw:style-name)]
        /@style:parent-style-name='Formula'">
            <xsl:apply-templates select="draw:text-box/text:p/draw:frame/draw:object/math:math" />
        </xsl:if>
        <!--
        Image Element
        ==============
        -->
        <!-- IF this draw:frame is an Image -->
        <xsl:if test="/office:document/office:automatic-styles
                /style:style[@style:name=(current()/@draw:style-name)]
        /@style:parent-style-name='Graphics'">
            <xsl:element name="img">
                <xsl:attribute name="src">
                    <xsl:value-of select="draw:image/@xlink:href" />
                </xsl:attribute>
                <xsl:attribute name="alt">
                    <xsl:value-of select="svg:title/text()" />
                </xsl:attribute>
                <xsl:attribute name="width">
                    <xsl:call-template name="convert2px">
                        <xsl:with-param name="dpi" select="'96'" />
                        <xsl:with-param name="value" select="@svg:width" />
                    </xsl:call-template>
                </xsl:attribute>
                <xsl:attribute name="height">
                    <xsl:call-template name="convert2px">
                        <xsl:with-param name="dpi" select="'96'" />
                        <xsl:with-param name="value" select="@svg:height" />
                    </xsl:call-template>
                </xsl:attribute>
            </xsl:element>
        </xsl:if>
        <xsl:if test="/office:document/office:automatic-styles
                /style:style[@style:name=(current()/@draw:style-name)]
                /@style:parent-style-name='Frame'
                and 
                /office:document/office:automatic-styles
                /style:style[@style:name=(current()/draw:text-box/text:p/draw:frame/@draw:style-name)]
        /@style:parent-style-name='Graphics'">
            <imggroup>
                <xsl:element name="img">
                    <xsl:attribute name="src">
                        <xsl:value-of select="draw:text-box/text:p/draw:frame/draw:image/@xlink:href" />
                    </xsl:attribute>
                    <xsl:attribute name="alt">
                        <xsl:value-of select="draw:text-box/text:p/draw:frame/svg:title/text()" />
                    </xsl:attribute>
                    <xsl:attribute name="width">
                        <xsl:call-template name="convert2px">
                            <xsl:with-param name="dpi" select="'96'" />
                            <xsl:with-param name="value" select="draw:text-box/text:p/draw:frame/@svg:width" />
                        </xsl:call-template>
                    </xsl:attribute>
                    <xsl:attribute name="height">
                        <xsl:call-template name="convert2px">
                            <xsl:with-param name="dpi" select="'96'" />
                            <xsl:with-param name="value" select="draw:text-box/text:p/draw:frame/@svg:height" />
                        </xsl:call-template>
                    </xsl:attribute>
                </xsl:element>
                <caption>
                    <xsl:value-of select="substring-after(draw:text-box/text:p,draw:text-box/text:p/draw:frame/svg:title/text())" />
                </caption>
            </imggroup>
        </xsl:if>
    </xsl:template>
    <xsl:template match="math:math">
        <!--<xsl:copy-of select="current()"/>-->
        <xsl:element name="{name()}">
            <xsl:attribute name="alttext">
                <xsl:value-of select="../../svg:title/text()" />
            </xsl:attribute>
           
           <!-- <xsl:attribute name="dtbook:altext" xmlns:dtbook="http://www.daisy.org/z3986/2005/dtbook/"/> -->
            <xsl:variable name="dummy">
                <dtbook:elem xmlns:dtbook="http://www.daisy.org/z3986/2005/dtbook/"/>
            </xsl:variable>
            <xsl:copy-of select="exsl:node-set($dummy)/*/namespace::*"/>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
        <!--        <xsl:copy-of select="node()" />-->
    </xsl:template>
    <xsl:template match="math:*">
        <xsl:element name="{name()}">
            <xsl:for-each select="@*">
                <xsl:attribute name="{local-name()}">
                    <xsl:value-of select="normalize-space(.)" />
                </xsl:attribute>
            </xsl:for-each>
            <xsl:apply-templates />
        </xsl:element>
    </xsl:template>
    <xsl:template match="svg:title" />
    
    <!-- Deleted styles -->
    <!--
      <xsl:template match="text:sequence-decls"/>
      <xsl:template match="text:table-of-content"/>
      -->

    
    <!--
  HELPERS TEMPLATES
  =================
  -->
    
    <!--
    hasParentStyle

    return 1 only if the first param is or has a parentStyle of the
    second param 
    -->
    <xsl:template name="hasParentStyle">
        <xsl:param name="style-name" />
        <xsl:param name="match-style-name" />
        
        <!--
  <xsl:value-of select="'call hasParentStyle'" />
  <xsl:value-of select="' '" />
  <xsl:value-of select="$style-name" />
  <xsl:value-of select="' '" />
  <xsl:value-of select="$match-style-name" />
  <xsl:value-of select="$NL" />
  -->
        <xsl:variable 
            name="current-parent-name" 
            select="/office:document/office:styles/
            style:style[@style:name=$style-name]/
        @style:parent-style-name" />
        
        <!--
   <xsl:value-of select="'value of parent-style '" />
   <xsl:value-of select="/office:document/office:styles/
	     style:style[@style:name = $style-name]/@style:parent-style-name" />
   <xsl:value-of select="$NL" />
   -->
        <xsl:choose>
            <xsl:when test="$style-name = 'Standard'">
                <xsl:value-of select="0" />
            </xsl:when>
            <xsl:when test="count(/office:document/office:styles/
                      style:style[@style:name=$style-name]/
            @style:parent-style-name) = 0">
                <xsl:value-of select="0" />
            </xsl:when>
            <xsl:when test="$style-name = $match-style-name">
                <xsl:value-of select="1" />
            </xsl:when>
            <xsl:when test="$current-parent-name = $match-style-name">
                <xsl:value-of select="1" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="hasParentStyle">
                    <xsl:with-param name="style-name" select="$current-parent-name" />
                    <xsl:with-param name="match-style-name" select="$match-style-name" />
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="numberFollowingSameStyle">
        <xsl:param name="tagName" />
        <xsl:param name="styleName" />
        <xsl:param name="i" select="1" />
        <xsl:choose>
            <xsl:when test="name(following-sibling::*[$i])=$tagName and following-sibling::*[$i]/@text:style-name=$styleName">
                <xsl:call-template name="numberFollowingSameStyle">
                    <xsl:with-param name="i" select="$i + 1"/>
                    <xsl:with-param name="tagName" select="$tagName" />
                    <xsl:with-param name="styleName" select="$styleName" />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$i" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="addLangAttrPara">
        <xsl:variable name="language"
                      select="//style:style[@style:name=(current()/@text:style-name)]/
        style:text-properties/@fo:language"/>
        <xsl:variable name="country"
                      select="//style:style[@style:name=(current()/@text:style-name)]/
        style:text-properties/@fo:country"/>
        <xsl:if test="$language and $country">
            <xsl:attribute name="xml:lang">
                <xsl:value-of select="$language" />
                <xsl:text>-</xsl:text>
                <xsl:value-of select="$country" />
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <xsl:template name="addLangAttrSpan">
        <xsl:variable name="language"
                      select="//style:style[@style:name=(current()/@text:style-name)]
        /style:text-properties/@fo:language"/>
        <xsl:variable name="country"
                      select="//style:style[@style:name=(current()/@text:style-name)]
        /style:text-properties/@fo:country"/>
        <xsl:if test="$language and $country">
            <xsl:attribute name="xml:lang">
                <xsl:value-of select="$language" />
                <xsl:text>-</xsl:text>
                <xsl:value-of select="$country" />
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    <xsl:template name="formatDate">
        <xsl:param name="date" />
        <!-- expected format like: 2008-06-27T04:31:05 -->
        <!-- convert to 06/27/2008, 04:31:05 -->
        <xsl:variable name="year">
            <xsl:value-of select="substring($date,1,4)" />
        </xsl:variable>
        <xsl:variable name="month">
            <xsl:value-of select="substring($date,6,2)" />
        </xsl:variable>
        <xsl:variable name="day">
            <xsl:value-of select="substring($date,9,2)" />
        </xsl:variable>
        <xsl:variable name="hh">
            <xsl:value-of select="substring($date,12,2)" />
        </xsl:variable>
        <xsl:variable name="mm">
            <xsl:value-of select="substring($date,15,2)" />
        </xsl:variable>
        <xsl:variable name="ss">
            <xsl:value-of select="substring($date,18,2)" />
        </xsl:variable>
        <xsl:variable name="month-en">
            <xsl:choose>
                <xsl:when test="$month = '01'">January
                </xsl:when>
                <xsl:when test="$month = '02'">Febuary
                </xsl:when>
                <xsl:when test="$month = '03'">March
                </xsl:when>
                <xsl:when test="$month = '04'">April
                </xsl:when>
                <xsl:when test="$month = '05'">May
                </xsl:when>
                <xsl:when test="$month = '06'">June
                </xsl:when>
                <xsl:when test="$month = '07'">July
                </xsl:when>
                <xsl:when test="$month = '08'">August
                </xsl:when>
                <xsl:when test="$month = '09'">September
                </xsl:when>
                <xsl:when test="$month = '10'">October
                </xsl:when>
                <xsl:when test="$month = '11'">November
                </xsl:when>
                <xsl:when test="$month = '12'">December
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        
        <!-- debug
        <xsl:value-of select="$year" />
        <xsl:value-of select="$month" />
        <xsl:value-of select="$day" />
        <xsl:value-of select="$hh" />
        <xsl:value-of select="$mm" />
        <xsl:value-of select="$ss" />
        <xsl:value-of select="$month-en" />
        -->
        <xsl:value-of select="$month" />
        <xsl:value-of select="'/'" />
        <xsl:value-of select="$day" />
        <xsl:value-of select="'/'" />
        <xsl:value-of select="$year" />
        <xsl:value-of select="', '" />
        <xsl:value-of select="$hh" />
        <xsl:value-of select="':'" />
        <xsl:value-of select="$mm" />
        <xsl:value-of select="':'" />
        <xsl:value-of select="$ss" />
    </xsl:template>
</xsl:stylesheet>


