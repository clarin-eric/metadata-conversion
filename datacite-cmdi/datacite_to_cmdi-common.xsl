<?xml version="1.0" encoding="UTF-8"?>

<!--

    Datacite to CMD conversion stylesheet
    Author: Twan Goosen (CLARIN ERIC) <twan@clarin.eu>
    Version: 1.0.0-alpha1
    
    This stylesheet converts a Datacite XML metadata record to a CLARIN
    Component Metadata instance (CMDI record). The output record is an instance
    of the Datacite Profile, which has been developed using CLARIN's "core
    components" set of metadata components.
    
    DataCite Metadata Schema 4.4: <https://schema.datacite.org/meta/kernel-4.4/>
    CMD: <https://www.clarin.eu/cmdi>
    
    For up-to-date versions and other metadata conversions, see
    <https://github.com/clarin-eric/metadata-conversion>
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.clarin.eu/cmd/1/profiles/clarin.eu:cr1:p_1610707853541"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:cmd="http://www.clarin.eu/cmd/1"
    xmlns:datacite_cmd="http://www.clarin.eu/cmd/conversion/ddi/cmd"
    xpath-default-namespace="http://datacite.org/schema/kernel-3" exclude-result-prefixes="xs datacite_cmd"
    version="2.0">
    
    <xsl:variable name="resourceTypeUris">
        <datacite_cmd:entry key="Collection"
            >http://purl.org/dc/dcmitype/Collection</datacite_cmd:entry>
        <datacite_cmd:entry key="Dataset">http://purl.org/dc/dcmitype/Dataset</datacite_cmd:entry>
        <datacite_cmd:entry key="Event">http://purl.org/dc/dcmitype/Event</datacite_cmd:entry>
        <datacite_cmd:entry key="Image">http://purl.org/dc/dcmitype/Image</datacite_cmd:entry>
        <datacite_cmd:entry key="InteractiveResource"
            >http://purl.org/dc/dcmitype/InteractiveResource</datacite_cmd:entry>
        <datacite_cmd:entry key="MovingImage"
            >http://purl.org/dc/dcmitype/MovingImage</datacite_cmd:entry>
        <datacite_cmd:entry key="PhysicalObject"
            >http://purl.org/dc/dcmitype/PhysicalObject</datacite_cmd:entry>
        <datacite_cmd:entry key="Service">http://purl.org/dc/dcmitype/Service</datacite_cmd:entry>
        <datacite_cmd:entry key="Software">http://purl.org/dc/dcmitype/Software</datacite_cmd:entry>
        <datacite_cmd:entry key="Sound">http://purl.org/dc/dcmitype/Sound</datacite_cmd:entry>
        <datacite_cmd:entry key="StillImage"
            >http://purl.org/dc/dcmitype/StillImage</datacite_cmd:entry>
        <datacite_cmd:entry key="Text">http://purl.org/dc/dcmitype/Text</datacite_cmd:entry>
    </xsl:variable>

    <xsl:variable name="dateTimePattern">-?\d{4}-\d{2}-\d{2}(T\d{2}:\d{2}:(\d{2})?)?</xsl:variable>
    <xsl:variable name="dateRangePattern"
        select="concat('^', $dateTimePattern, '/', $dateTimePattern, '$')"/>
    
    <xsl:variable name="rangePattern">^([^/]*)/([^/]*)$</xsl:variable>
    
    <xsl:function name="datacite_cmd:isValidDateRange">
        <xsl:param name="dateValue"/>
        <xsl:choose>
            <xsl:when test="matches($dateValue, $rangePattern)">
                <xsl:variable name="start" select="replace($dateValue, $rangePattern, '$1')"/>
                <xsl:variable name="end" select="replace($dateValue, $rangePattern, '$2')"/>
                <xsl:choose>
                    <xsl:when test="($start castable as xs:date) and ($end castable as xs:date)">
                        <xsl:sequence select="true()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="false()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="datacite_cmd:getStartDateFromRange">
        <xsl:param name="dateValue"/>
        <xsl:sequence select="replace($dateValue, $rangePattern, '$1')"/>
    </xsl:function>
    
    <xsl:function name="datacite_cmd:getEndDateFromRange">
        <xsl:param name="dateValue"/>
        <xsl:sequence select="replace($dateValue, $rangePattern, '$2')"/>
    </xsl:function>
    
    <xsl:function name="datacite_cmd:getDateFromDateTime">
        <xsl:param name="dateValue"/>
        <xsl:sequence select="replace($dateValue, '^(\d{4}-\d{2}-\d{2}).*', '$1')"/>
    </xsl:function>
    
    <xsl:function name="datacite_cmd:getYearFromDateTime">
        <xsl:param name="dateValue"/>
        <xsl:sequence select="replace($dateValue, '^(\d{4})-\d{2}-\d{2}.*', '$1')"/>
    </xsl:function>

    <!-- Helper templates and functions -->

    <xsl:template name="wrapper-component">
        <xsl:param name="name"/>
        <xsl:param name="content"/>
        <xsl:if test="count($content/*) > 0">
            <xsl:element name="{$name}">
                <xsl:sequence select="$content"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>


    <xsl:function name="datacite_cmd:isAbsoluteUri">
        <xsl:param name="value"/>
        <xsl:sequence select="matches($value, '^(http|https|hdl|doi):.*$')"/>
    </xsl:function>

    <xsl:function name="datacite_cmd:isDOI" as="xs:boolean">
        <xsl:param name="uri" required="yes" as="text()"/>
        <xsl:sequence select="contains(string($uri), 'doi.org/')"/>
    </xsl:function>

    <xsl:function name="datacite_cmd:normalize_doi">
        <xsl:param name="uri" required="yes"/>
        <xsl:variable name="doi"
            select="replace($uri, '^((doi:|https?://)?([a-z]+\.)?doi.org/)(.*)$', '$4')"/>
        <xsl:choose>
            <xsl:when test="normalize-space($doi) != ''">
                <xsl:sequence select="concat('https://doi.org/', $doi)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$uri"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="datacite_cmd:toISO693-3">
        <xsl:param name="code" required="yes"/>
        <xsl:choose>
            <xsl:when test="string-length($code) = 3">
                <xsl:sequence select="$code"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="no">WARNING: language code is NOT a valid ISO-639-3 code:
                        '<xsl:value-of select="$code"/>'</xsl:message>
                <xsl:sequence select="$code"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="datacite_cmd:isMediaType">
        <xsl:param name="value" as="xs:string"/>
        <xsl:sequence
            select="matches(normalize-space($value), '^(application|audio|image|message|multipart|text|video|font|example|model|image|text)/.+$', 'i')"
        />
    </xsl:function>

    <xsl:function name="datacite_cmd:firstToUpper">
        <xsl:param name="value" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="string-length($value) = 0">
                <xsl:sequence select="''"/>
            </xsl:when>
            <xsl:when test="string-length($value) = 1">
                <xsl:sequence select="upper-case($value)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of
                    select="concat(upper-case(substring($value, 1, 1)), substring($value, 2))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>
