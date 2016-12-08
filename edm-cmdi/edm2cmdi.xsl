<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:edm="http://www.europeana.eu/schemas/edm/"
    xmlns:cmd="http://www.clarin.eu/cmd/1"
    xmlns:cmdp="http://www.clarin.eu/cmd/1/profiles/clarin.eu:cr1:p_1475136016208"
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
        <cmd:Header>
            <cmd:MdCreator></cmd:MdCreator>
            <cmd:MdCreationDate>...</cmd:MdCreationDate>
            <cmd:MdSelfLink>...</cmd:MdSelfLink>
            <cmd:MdProfile>clarin.eu:cr1:p_1475136016208</cmd:MdProfile>
            <cmd:MdCollectionDisplayName>...</cmd:MdCollectionDisplayName>
        </cmd:Header>
    </xsl:template>
    
    <xsl:template match="rdf:RDF" mode="resources">
        <cmd:Resources>
            <cmd:ResourceProxyList>
                <!-- landing page -->
                <!-- webresources -->
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
    
    <xsl:template match="rdf:RDF" mode="components">
        <cmd:Components  xmlns="http://www.clarin.eu/cmd/1/profiles/clarin.eu:cr1:p_1475136016208">
            <EDM>
                
            </EDM>
        </cmd:Components>
    </xsl:template>
    
</xsl:stylesheet>