<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:edm="http://www.europeana.eu/schemas/edm/"
    xmlns:cmd="http://www.clarin.eu/cmd/1"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="xml" indent="yes" />
    
    <xsl:template match="/rdf:RDF">
        <cmd:CMD
            xsi:schemaLocation="http://www.clarin.eu/cmd/1 https://infra.clarin.eu/CMDI/1.x/xsd/cmd-envelop.xsd http://www.clarin.eu/cmd/1/profiles/clarin.eu:cr1:p_1475136016208 https://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/1.x/profiles/clarin.eu:cr1:p_1475136016208/xsd"
            CMDVersion="1.2">
            <xsl:apply-templates select="." mode="header" />
            <xsl:apply-templates select="." mode="resources" />
            <xsl:apply-templates select="." mode="components" />
        </cmd:CMD>
    </xsl:template>
    
    <xsl:template match="rdf:RDF" mode="header">
        <xsl:variable name="selfLink">
            <xsl:choose>
                <xsl:when test="edm:EuropeanaAggregation">
                    <xsl:value-of select="replace(edm:EuropeanaAggregation/@rdf:about, '^.*://(data.europeana.eu/)?', 'europeana:')"/>
                </xsl:when>
                <xsl:when test="edm:ProvidedCHO">
                    <xsl:value-of select="replace(edm:ProvidedCHO/@rdf:about, '^.*://(data.europeana.eu/)?', 'europeana:')"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="collectionName" select="edm:EuropeanaAggregation/edm:collectionName" />
        <cmd:Header>
            <!--
                cmd:MdCreator?
            -->
            <cmd:MdCreationDate><xsl:value-of select="current-date()"/></cmd:MdCreationDate>
            <xsl:if test="normalize-space($selfLink) != ''">
                <cmd:MdSelfLink><xsl:value-of select="$selfLink"/></cmd:MdSelfLink>
            </xsl:if>
            <cmd:MdProfile>clarin.eu:cr1:p_1475136016208</cmd:MdProfile>
            <xsl:if test="normalize-space($collectionName) != ''">
                <cmd:MdCollectionDisplayName><xsl:value-of select="$collectionName"/></cmd:MdCollectionDisplayName>
            </xsl:if>
        </cmd:Header>
    </xsl:template>
    
    <xsl:template match="rdf:RDF" mode="resources">
        <cmd:Resources>
            <cmd:ResourceProxyList>
                <xsl:apply-templates select="edm:EuropeanaAggregation/edm:landingPage" mode="resources" />
                <xsl:apply-templates select="edm:WebResource" mode="resources" />
            </cmd:ResourceProxyList>
            <cmd:JournalFileProxyList>
            </cmd:JournalFileProxyList>
            <cmd:ResourceRelationList>
            </cmd:ResourceRelationList>
        </cmd:Resources>
        <!-- 
          <cmd:IsPartOfList>
              <cmd:IsPartOf></cmd:IsPartOf>
          </cmd:IsPartOfList>
        -->
    </xsl:template>
    
    <xsl:template match="edm:landingPage" mode="resources">
        <xsl:if test="normalize-space(@rdf:resource) != ''">
            <cmd:ResourceProxy id="{concat('landingPage_', generate-id(.))}">
                <cmd:ResourceType>LandingPage</cmd:ResourceType>
                <cmd:ResourceRef><xsl:value-of select="@rdf:resource"/></cmd:ResourceRef>
            </cmd:ResourceProxy>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="edm:WebResource" mode="resources">
        <xsl:if test="normalize-space(@rdf:about) != ''">
            <cmd:ResourceProxy id="{concat('webResource_', generate-id(.))}">
                <cmd:ResourceType>Resource</cmd:ResourceType>
                <cmd:ResourceRef><xsl:value-of select="@rdf:about"/></cmd:ResourceRef>
            </cmd:ResourceProxy>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="rdf:RDF" mode="components">
        <cmd:Components xmlns="http://www.clarin.eu/cmd/1/profiles/clarin.eu:cr1:p_1475136016208">
            <EDM>
                <edm-ProvidedCHO></edm-ProvidedCHO>
                <edm-Aggregation aggregatedCHO="">
                    <edm-dataProvider></edm-dataProvider>
                    <edm-provider></edm-provider>
                    <edm-rights>
                        <rightsURI></rightsURI>
                    </edm-rights>
                </edm-Aggregation>
            </EDM>
        </cmd:Components>
    </xsl:template>
    
</xsl:stylesheet>