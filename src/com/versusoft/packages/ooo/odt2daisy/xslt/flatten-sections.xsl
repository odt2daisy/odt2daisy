<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xalan="http://xml.apache.org/xslt"
                xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0">

    <xsl:output method="xml" 
                encoding="UTF-8"
                media-type="text/xml" 
                indent="yes"
                omit-xml-declaration="no"
                xalan:indent-amount="3"/>
	
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
	
	<xsl:template match="text:section">
        <xsl:choose>
            <xsl:when test="@text:name='BodyMatterStart' or
                            @text:name='RearMatterStart'">
                <xsl:copy>
                    <xsl:apply-templates select="@*"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="node()"/>
            </xsl:otherwise>
		</xsl:choose>
    </xsl:template>

</xsl:stylesheet>