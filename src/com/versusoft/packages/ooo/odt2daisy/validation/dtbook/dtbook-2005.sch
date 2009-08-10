<?xml version="1.0" encoding="utf-8"?>
<sch:schema xmlns:sch="http://www.ascc.net/xml/schematron">
	<!--
	A set of Schematron 1.5 tests for the DTBook 2005 grammar.
	The tests apply to minor versions 2005-1, 2005-2 and 2005-3.
	The tests are taken from the formal Z3986 conformance validator, see zedval.sf.net.
	Unless specified in comments, the id values given for each sch:pattern match the id of a test description in
	the formal Z3986 conformance validator 'testMap', see:
	http://zedval.cvs.sourceforge.net/zedval/z3986/src/org/daisy/zedval/zedsuite/v2005/maps/testmap_dtbook.xml?view=markup
	A future upgrade to using ISO Schematron is to be expected.
	This schema compiled by mgylling 20080328. 
	-->
	
	<sch:ns prefix="dtbk" uri="http://www.daisy.org/z3986/2005/dtbook/"/>
	<sch:key name="notes" match="dtbk:note[@id]" path="@id"/>
	<sch:key name="annotations" match="dtbk:annotation[@id]" path="@id"/>
	
	<sch:pattern name="dtbook_MetaUid" id="dtbook_MetaUid">
		<sch:rule context="dtbk:head">
			<sch:assert test="count(dtbk:meta[@name='dtb:uid'])=1"
				>dtb:uid metadata does not exist</sch:assert>        
		</sch:rule>
	</sch:pattern> 
	
	<sch:pattern name="dtbook_MetaTitle" id="dtbook_MetaTitle">
		<sch:rule context="dtbk:head">
			<sch:assert test="count(dtbk:meta[@name='dc:Title'])=1"
				>dc:Title metadata does not exist</sch:assert>  
		</sch:rule>
	</sch:pattern>
	
	<sch:pattern name="dtbook_idrefNote" id="dtbook_idrefNote">
		<sch:rule context="dtbk:noteref">	
			<!-- zedid::dtbook_noteFragment -->
			<sch:assert test="contains(@idref, '#')"
				>noteref URI value does not contain a fragment identifier</sch:assert>
				
			<!-- zedid::dtbook_idrefNote -->
			<sch:report test="contains(@idref, '#') and string-length(substring-before(@idref, '#'))=0 and count(key('notes',substring(current()/@idref,2)))!=1"
				>noteref URI value does not resolve to a note element</sch:report>
		</sch:rule>
	</sch:pattern>
	
	<sch:pattern name="dtbook_idrefAnnotation" id="dtbook_idrefAnnotation">
		<sch:rule context="dtbk:annoref">
			<!-- zedid::dtbook_annotationFragment -->
			<sch:assert test="contains(@idref, '#')"
				>annoref URI value does not contain a fragment identifier</sch:assert>
				
			<!-- zedid::dtbook_idrefAnnotation -->
			<sch:report test="contains(@idref, '#') and string-length(substring-before(@idref, '#'))=0 and count(key('annotations',substring(current()/@idref,2)))!=1"
				>annoref URI value does not resolve to a annotation element</sch:report>
		</sch:rule>
	</sch:pattern>	

	<sch:pattern name="dtbook_internalLinks" id="dtbook_internalLinks">
		<sch:rule context="dtbk:a[starts-with(@href, '#')]">
			<sch:assert test="count(//dtbk:*[@id=substring(current()/@href, 2)])=1"
				>internal link does not resolve</sch:assert>
		</sch:rule>  	
	</sch:pattern> 

	<sch:pattern name="dtbook_enumAttrInList" id="dtbook_enumAttrInList">
		<sch:rule context="dtbk:list">
			<sch:report test="@enum and @type!='ol'"
				>The enum attribute is only allowed in numbered lists</sch:report>
		</sch:rule>
	</sch:pattern>
	
	<sch:pattern name="dtbook_depthList" id="dtbook_depthList">
		<sch:rule context="dtbk:list">
			<sch:report test="@depth and @depth!=count(ancestor-or-self::dtbk:list)"
				>The depth attribute on list element does not contain the list wrapping level</sch:report>
		</sch:rule>
	</sch:pattern>
	
	<sch:pattern name="dtbook_dcMetadata" id="dtbook_dcMetadata">
		<sch:rule context="dtbk:meta">
			<!-- zedid::dtbook_dcAttrNamePart -->
			<sch:report test="starts-with(@name, 'dc:') and not(@name='dc:Title' or @name='dc:Subject' or @name='dc:Description' or
    	                                                    @name='dc:Type' or @name='dc:Source' or @name='dc:Relation' or 
    	                                                    @name='dc:Coverage' or @name='dc:Creator' or @name='dc:Publisher' or 
    	                                                    @name='dc:Contributor' or @name='dc:Rights' or @name='dc:Date' or 
    	                                                    @name='dc:Format' or @name='dc:Identifier' or @name='dc:Language')"
            >Incorrect Dublin Core metadata name</sch:report>
			
			<!-- zedid::dtbook_dcAttrPrefixPart -->
			<sch:report test="starts-with(@name, 'DC:') or starts-with(@name, 'Dc:') or starts-with(@name, 'dC:')"
				>Incorrect Dublin Core metadata prefix</sch:report>
		</sch:rule>
	</sch:pattern>
	
	<sch:pattern name="dtbook_levelDepth" id="dtbook_levelDepth">
		<sch:rule context="dtbk:level[@depth]">
			<sch:assert test="@depth=count(ancestor-or-self::dtbk:level)"
				>The value of the depth attribute on the level element does not correspond to actual nesting level</sch:assert>
		</sch:rule>
	</sch:pattern>
	
	<sch:pattern name="dtbook_startAttrInList" id="dtbook_startAttrInList">
		<sch:rule context="dtbk:list">
			<!-- zedid::dtbook_startAttrInList -->
			<sch:report test="@start and @type!='ol'"
				>A start attribute occurs in a non-numbered list</sch:report>
				
			<!-- zedid::dtbook_startAttrNonNegative -->	
			<sch:report test="@start='' or string-length(translate(@start,'0123456789',''))!=0"
				>The list start attribute is not a non negative number</sch:report>
				
		</sch:rule>
	</sch:pattern>
	
	<sch:pattern name="dtbook_headersThTd" id="dtbook_headersThTd">
		<sch:rule context="dtbk:*[@headers and (self::dtbk:th or self::dtbk:td)]">
			<sch:assert test="
				count(
					ancestor::dtbk:table//dtbk:th/@id[contains( concat(' ',current()/@headers,' '), concat(' ',normalize-space(),' ') )]
				) = 
				string-length(normalize-space(@headers)) - string-length(translate(normalize-space(@headers), ' ','')) + 1
			">Not all the tokens in the headers attribute match the id attributes of 'th' elements in this or a parent table</sch:assert>
		</sch:rule>
	</sch:pattern>

	<sch:pattern name="dtbook_imgrefProdnote" id="dtbook_imgrefProdnote">
		<sch:rule context="dtbk:prodnote[@imgref]">
			<sch:assert test="
				count(
					//dtbk:img/@id[contains( concat(' ',current()/@imgref,' '), concat(' ',normalize-space(),' ') )]
				) = 
				string-length(normalize-space(@imgref)) - string-length(translate(normalize-space(@imgref), ' ','')) + 1
			">Not all the tokens in the imgref attribute match the id attributes of 'img' elements</sch:assert>
		</sch:rule>
	</sch:pattern>
	
	<sch:pattern name="dtbook_imgrefCaption" id="dtbook_imgrefCaption">
		<sch:rule context="dtbk:caption[@imgref]">
			<sch:assert test="
				count(
					//dtbk:img/@id[contains( concat(' ',current()/@imgref,' '), concat(' ',normalize-space(),' ') )]
				) = 
				string-length(normalize-space(@imgref)) - string-length(translate(normalize-space(@imgref), ' ','')) + 1
			">Not all the tokens in the imgref attribute match the id attributes of 'img' elements</sch:assert>
		</sch:rule>
	</sch:pattern>	
	
	<sch:pattern name="dtbook_imgWidth" id="dtbook_imgWidth">
		<sch:rule context="dtbk:img">
			<!-- zedid::dtbook_imgWidth -->
			<sch:assert test="not(@width) or 
    	                  string-length(translate(@width,'0123456789',''))=0 or
    	                  (contains(@width,'%') and substring-after(@width,'%')='' and translate(@width,'%0123456789','')='' and string-length(@width)>=2)"
    	   >The image width is not expressed in integer pixels or percentage</sch:assert>
    	   
		   <!-- zedid::dtbook_imgHeight -->
		   <sch:assert test="not(@height) or 
    	                  string-length(translate(@height,'0123456789',''))=0 or
    	                  (contains(@height,'%') and substring-after(@height,'%')='' and translate(@height,'%0123456789','')='' and string-length(@height)>=2)"
    	   >The image height is not expressed in integer pixels or percentage</sch:assert>
		</sch:rule>
	</sch:pattern>
	
	<sch:pattern name="dtbook_spanColColgroup" id="dtbook_spanColColgroup">
		<sch:rule context="dtbk:*[self::dtbk:col or self::dtbk:colgroup]">
			<sch:report test="@span and (translate(@span,'0123456789','')!='' or starts-with(@span,'0'))"
				>column span attribute is not a positive integer</sch:report>
		</sch:rule>
	</sch:pattern>

	<sch:pattern name="dtbook_rowspanColspan" id="dtbook_rowspanColspan">
		<sch:rule context="dtbk:*[self::dtbk:td or self::dtbk:th]">
			<!-- zedid::dtbook_rowSpanValue -->
			<sch:report test="@rowspan and (translate(@rowspan,'0123456789','')!='' or starts-with(@rowspan,'0'))"
				>The rowspan attribute value is not a positive integer</sch:report>
			<!-- zedid::dtbook_colSpanValue -->	
			<sch:report test="@colspan and (translate(@colspan,'0123456789','')!='' or starts-with(@colspan,'0'))"
				>The colspan attribute value is not a positive integer</sch:report>    	
			<!-- zedid::dtbook_rowSpanRelativeValue -->	
			<sch:report test="@rowspan and number(@rowspan) > count(parent::dtbk:tr/following-sibling::dtbk:tr)+1"
				>The rowspan attribute value is larger than the number of rows left in the table</sch:report>
		</sch:rule>
	</sch:pattern>  
	
</sch:schema>