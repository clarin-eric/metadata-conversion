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
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:cmdp="http://www.clarin.eu/cmd/1/profiles/clarin.eu:cr1:p_1610707853541"
    xmlns:datacite_oai_1_0="http://schema.datacite.org/oai/oai-1.0/"
    xmlns:datacite_oai_1_1="http://schema.datacite.org/oai/oai-1.1/"
    xmlns:datacite_cmd="http://www.clarin.eu/cmd/conversion/ddi/cmd"
    xmlns:datacite_3="http://datacite.org/schema/kernel-3"
    xmlns:datacite_4="http://datacite.org/schema/kernel-4"
    xsi:schemaLocation="http://datacite.org/schema/kernel-4 http://schema.datacite.org/meta/kernel-4/metadata.xsd
        http://datacite.org/schema/kernel-3 http://schema.datacite.org/meta/kernel-3/metadata.xsd"
        exclude-result-prefixes="xs datacite_oai_1_0 datacite_oai_1_1 datacite_cmd"
    version="2.0">

    <xsl:output indent="yes"/>
    
    <xsl:include href="datacite_to_cmdi-common.xsl"/>
    <xsl:include href="datacite_to_cmdi-kernel3.xsl"/>
    <xsl:include href="datacite_to_cmdi-kernel4.xsl"/>
    
    <xsl:template match="/datacite_oai_1_0:oai_datacite">
        <xsl:apply-templates select="datacite_oai_1_0:payload/*" mode="root" />
    </xsl:template>
    
    <xsl:template match="/datacite_oai_1_1:oai_datacite">
        <xsl:apply-templates select="datacite_oai_1_1:payload/*" mode="root" />
    </xsl:template>
    
    <xsl:template match="/datacite_3:resource|/datacite_4:resource">
        <xsl:apply-templates select="." mode="root" />
    </xsl:template>
    
    <xsl:template match="/*" priority="-1">
        <xsl:comment>ERROR in main template: cannot convert metadata, no DataCite or DataCite OAI detected at root</xsl:comment>
    </xsl:template>
    
    <xsl:template match="*" priority="-1" mode="root">
        <xsl:comment>ERROR in main template: cannot convert metadata, no DataCite or DataCite OAI detected at (payload) root</xsl:comment>
    </xsl:template>
    
</xsl:stylesheet>
