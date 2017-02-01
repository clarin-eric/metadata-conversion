<?xml version="1.0" encoding="UTF-8"?>
<!--
    =====================================================================
    EDM to CMDI conversion
    <https://github.com/clarin-eric/metadata-conversion>
    
    Author: Twan Goosen <twan@clarin.eu>
    
    <https://www.clarin.eu>
    <https://www.europeana.eu>
    =====================================================================
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    =====================================================================
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:wgs84_pos="http://www.w3.org/2003/01/geo/wgs84_pos#"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:ore="http://www.openarchives.org/ore/terms/"
    xmlns:cc="http://creativecommons.org/ns#"
    xmlns:odrl="http://www.w3.org/ns/odrl/2/"
    xmlns:ebucore="http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#"
    xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns:rdaGr2="http://rdvocab.info/ElementsGr2/"
    xmlns:svcs="http://rdfs.org/sioc/services#"
    xmlns:doap="http://usefulinc.com/ns/doap#"
    xmlns:edm="http://www.europeana.eu/schemas/edm/"
    xmlns:cmd="http://www.clarin.eu/cmd/1"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:func="http://www.clarin.eu/cmd/conversion/edm-cmd"
    xmlns="http://www.clarin.eu/cmd/1/profiles/clarin.eu:cr1:p_1475136016208"
    exclude-result-prefixes="xs owl rdf skos wgs84_pos dc dcterms ore cc odrl ebucore foaf rdaGr2 svcs doap edm func"
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
    
    <!--
        *****************************************************************
        * HEADER                                                        *
        *****************************************************************
    -->
    
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
        
        <xsl:variable name="collectionName">
            <xsl:choose>
                <xsl:when test="edm:ProvidedCHO/dcterms:isPartOf[normalize-space(.) != '']">
                    <xsl:value-of select="edm:ProvidedCHO/dcterms:isPartOf[normalize-space(.) != ''][1]"/>
                </xsl:when>
                <xsl:when test="ore:Proxy/dcterms:isPartOf[normalize-space(.) != '']">
                    <xsl:value-of select="ore:Proxy/dcterms:isPartOf[normalize-space(.) != ''][1]"/>
                </xsl:when>
                <xsl:when test="//edm:EuropeanaAggregation/edm:datasetName">
                    <xsl:value-of select="//edm:EuropeanaAggregation/edm:datasetName"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of  select="//edm:EuropeanaAggregation/edm:collectionName" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
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
                <cmd:MdCollectionDisplayName>
                    <xsl:value-of select="func:sanitiseCollectionName($collectionName/text())"/>
                </cmd:MdCollectionDisplayName>
            </xsl:if>
        </cmd:Header>
    </xsl:template>
    
    <!--
        *****************************************************************
        * RESOURCES SECTION (RESOURCE PROXIES)                          *
        *****************************************************************
    -->
    
    <xsl:template match="rdf:RDF" mode="resources">
        <cmd:Resources>
            <!-- Mapping of WebResources and other types of resource references to resource proxies -->
            <cmd:ResourceProxyList>
                <!-- create optional resource proxy for the landing page -->
                <xsl:apply-templates select="edm:EuropeanaAggregation/edm:landingPage" mode="resources" />
                
                <!-- create resource proxies for WebResources -->
                <!--    edm:object first -->
                <xsl:apply-templates select="edm:WebResource[@rdf:about = //edm:object/@rdf:resource]" mode="resources" />
                <!--        cases without local edm:WebResource -->
                <xsl:apply-templates select="//(edm:object)[not(@rdf:resource = //edm:WebResource/@rdf:about)]" mode="resources"/>
                
                <!--    then edm:isShownBy (exclude those already mapped through edm:object) -->
                <xsl:apply-templates select="edm:WebResource[@rdf:about = //edm:isShownBy/@rdf:resource and not(@rdf:about = //edm:object/@rdf:resource)]" mode="resources" />
                <!--        cases without local edm:WebResource -->
                <xsl:apply-templates select="//(edm:isShownBy)[not(@rdf:resource = //edm:WebResource/@rdf:about)]" mode="resources"/>
                
                <!--    others... -->
                <xsl:apply-templates select="edm:WebResource[not(@rdf:about = (//edm:object|//edm:isShownBy)/@rdf:resource)]" mode="resources" />
                
                <!-- all the rest: remaining types of resource references that do not reference locally available WebResources (in preferred order) -->
                <xsl:apply-templates select="//edm:isShownAt[not(@rdf:resource = //edm:WebResource/@rdf:about)]" mode="resources"/>
                <xsl:apply-templates select="//edm:hasView[not(@rdf:resource = //edm:WebResource/@rdf:about)]" mode="resources"/>
                <xsl:apply-templates select="//edm:preview[not(@rdf:resource = //edm:WebResource/@rdf:about)]" mode="resources"/>
            </cmd:ResourceProxyList>
            <cmd:JournalFileProxyList>
            </cmd:JournalFileProxyList>
            <cmd:ResourceRelationList>
            </cmd:ResourceRelationList>
        </cmd:Resources>
        <!--  TODO
          <cmd:IsPartOfList>
              <cmd:IsPartOf></cmd:IsPartOf>
          </cmd:IsPartOfList>
        -->
    </xsl:template>
    
    <xsl:template match="edm:landingPage" mode="resources">
        <xsl:if test="normalize-space(@rdf:resource) != ''">
            <cmd:ResourceProxy id="{func:landingPageProxyId(.)}">
                <cmd:ResourceType>LandingPage</cmd:ResourceType>
                <cmd:ResourceRef><xsl:value-of select="@rdf:resource"/></cmd:ResourceRef>
            </cmd:ResourceProxy>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="edm:WebResource" mode="resources">
        <xsl:if test="normalize-space(@rdf:about) != ''">
            <cmd:ResourceProxy id="{func:webResourceProxyId(.)}">
                <cmd:ResourceType>
                    <xsl:if test="ebucore:hasMimeType">
                        <xsl:attribute name="mimetype" select="ebucore:hasMimeType" />
                    </xsl:if>
                    <xsl:text>Resource</xsl:text>
                </cmd:ResourceType> 
                <cmd:ResourceRef><xsl:value-of select="@rdf:about"/></cmd:ResourceRef>
            </cmd:ResourceProxy>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="edm:object|edm:isShownAt|edm:isShownBy|edm:hasView|edm:preview" mode="resources">
        <xsl:if test="normalize-space(@rdf:resource) != ''">
            <cmd:ResourceProxy id="{func:nodeResourceProxyId(.)}">
                <cmd:ResourceType>Resource</cmd:ResourceType>
                <cmd:ResourceRef><xsl:value-of select="@rdf:resource"/></cmd:ResourceRef>
            </cmd:ResourceProxy>
        </xsl:if>
    </xsl:template>
    
    <!--
        *****************************************************************
        * COMPONENTS SECTION                                            *
        *****************************************************************
    -->
    
    <xsl:template match="rdf:RDF" mode="components">
        <cmd:Components>
            <EDM>
                <xsl:apply-templates select="edm:ProvidedCHO" />
                <xsl:apply-templates select="ore:Proxy" />
                <xsl:apply-templates select="ore:Aggregation" />
                <xsl:apply-templates select="edm:EuropeanaAggregation" />
            </EDM>
        </cmd:Components>
    </xsl:template>
    
    <xsl:template match="edm:ProvidedCHO">
        <edm-ProvidedCHO rdf-about="{@rdf:about}">
            <xsl:apply-templates select="." mode="cho-props" />
        </edm-ProvidedCHO>
    </xsl:template>
    
    <xsl:template match="ore:Proxy">
        <xsl:variable name="proxyFor" select="ore:proxyFor/@rdf:resource" />
        <!-- check if it is a proxy for an existing ProvidedCHO -->
        <xsl:if test="//rdf:RDF/edm:ProvidedCHO[@rdf:about = $proxyFor]">
            <ProvidedCHOProxy
                rdf-about="{@rdf:about}"
                proxyFor="{ore:proxyFor/@rdf:resource}" 
                proxyIn="{ore:proxyIn/@rdf:resource}">
                <xsl:if test="normalize-space(edm:europeanaProxy) = 'true'">
                    <xsl:attribute name="edm-europeanaProxy">true</xsl:attribute>
                </xsl:if>
                <edm-ProvidedCHO>
                    <xsl:apply-templates select="." mode="cho-props" />
                </edm-ProvidedCHO>
            </ProvidedCHOProxy>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="edm:ProvidedCHO|ore:Proxy" mode="cho-props">
        <!--
            **********************************
            * ProvidedCHO (proxy) properties *
            **********************************
         -->        
        <xsl:apply-templates select="dc:description" mode="element-prop" />
        <xsl:apply-templates select="dc:format" mode="element-prop" />
        <xsl:apply-templates select="dc:identifier" mode="element-prop" />
        <xsl:apply-templates select="dc:language" mode="element-prop" />
        <xsl:apply-templates select="dc:relation" mode="element-prop" />
        <xsl:apply-templates select="dc:rights" mode="element-prop" />
        <xsl:apply-templates select="dc:source" mode="element-prop" />
        <xsl:apply-templates select="dc:title" mode="element-prop" />
        <xsl:apply-templates select="dcterms:alternative" mode="element-prop" />
        <xsl:apply-templates select="dcterms:conformsTo" mode="element-prop" />
        <xsl:apply-templates select="dcterms:extent" mode="element-prop" />
        <xsl:apply-templates select="dcterms:hasFormat" mode="element-prop" />
        <xsl:apply-templates select="dcterms:hasPart" mode="element-prop" />
        <xsl:apply-templates select="dcterms:hasVersion" mode="element-prop" />
        <xsl:apply-templates select="dcterms:isFormatOf" mode="element-prop" />
        <xsl:apply-templates select="dcterms:isPartOf" mode="element-prop" />
        <xsl:apply-templates select="dcterms:isReferencedBy" mode="element-prop" />
        <xsl:apply-templates select="dcterms:isReplacedBy" mode="element-prop" />
        <xsl:apply-templates select="dcterms:isRequiredBy" mode="element-prop" />
        <xsl:apply-templates select="dcterms:isVersionOf" mode="element-prop" />
        <xsl:apply-templates select="dcterms:medium" mode="element-prop" />
        <xsl:apply-templates select="dcterms:provenance" mode="element-prop" />
        <xsl:apply-templates select="dcterms:references" mode="element-prop" />
        <xsl:apply-templates select="dcterms:replaces" mode="element-prop" />
        <xsl:apply-templates select="dcterms:requires" mode="element-prop" />
        <xsl:apply-templates select="dcterms:tableOfContents" mode="element-prop" />
        <xsl:apply-templates select="edm:incorporates" mode="element-prop" />
        <xsl:apply-templates select="edm:isDerivativeOf" mode="element-prop" />
        <xsl:apply-templates select="edm:isNextInSequence" mode="element-prop" />
        <xsl:apply-templates select="edm:isRelatedTo" mode="element-prop" />
        <xsl:apply-templates select="edm:isRepresentationOf" mode="element-prop" />
        <xsl:apply-templates select="edm:isSimilarTo" mode="element-prop" />
        <xsl:apply-templates select="edm:isSuccessorOf" mode="element-prop" />
        <xsl:apply-templates select="edm:type" mode="element-prop" />
        <xsl:apply-templates select="edm:year" mode="element-prop">
            <xsl:with-param name="allow-xml-lang" select="false()" />
        </xsl:apply-templates>
        <xsl:apply-templates select="owl:sameAs" mode="element-prop" /> 
        
        <xsl:apply-templates select="dc:contributor" mode="component-prop" />
        <xsl:apply-templates select="dc:coverage" mode="component-prop" />
        <xsl:apply-templates select="dc:creator" mode="component-prop" />
        <xsl:apply-templates select="dc:date" mode="component-prop" />
        <xsl:apply-templates select="dc:publisher" mode="component-prop" />
        <xsl:apply-templates select="dc:subject" mode="component-prop" />
        <xsl:apply-templates select="dc:type" mode="component-prop" />
        <xsl:apply-templates select="dcterms:created" mode="component-prop" />
        <xsl:apply-templates select="dcterms:issued" mode="component-prop" />
        <xsl:apply-templates select="dcterms:spatial" mode="component-prop" />
        <xsl:apply-templates select="dcterms:temporal" mode="component-prop" />
        <xsl:apply-templates select="dcterms:currentLocation" mode="component-prop" />
        <xsl:apply-templates select="edm:hasMet" mode="component-prop" />
        <xsl:apply-templates select="edm:hasType" mode="component-prop" />
        <xsl:apply-templates select="edm:realizes" mode="component-prop" />
    </xsl:template>
    
    <xsl:template match="ore:Aggregation">
        <edm-Aggregation rdf-about="{@rdf:about}" aggregatedCHO="{edm:aggregatedCHO/@rdf:resource}">
            <!--
                **************************
                * Aggregation properties *
                **************************
             -->     
            <xsl:apply-templates select="edm:dataProvider" mode="element-prop" />
            <xsl:apply-templates select="edm:provider" mode="element-prop" />
            <xsl:apply-templates select="dc:rights" mode="element-prop" />
            <xsl:apply-templates select="edm:ugc" mode="element-prop" />
            <xsl:apply-templates select="edm-intermediateProvider" mode="element-prop" />
            
            <xsl:apply-templates select="edm:hasView" />
            <xsl:apply-templates select="edm:isShownAt" />
            <xsl:apply-templates select="edm:isShownBy" />
            <xsl:apply-templates select="edm:object" />
            
            <xsl:apply-templates select="edm:rights" />
        </edm-Aggregation>
    </xsl:template>
    
    <xsl:template match="edm:hasView|edm:isShownAt|edm:isShownBy|edm:object|edm:preview">
        <xsl:param name="forceRef" select="'no'" />
        <xsl:variable name="targetWebResource" select="@rdf:resource"/>
        <xsl:element name="{func:get-cmd-name(.)}">
            <xsl:choose>
                <xsl:when test="$forceRef != 'yes' and //edm:WebResource[@rdf:about = $targetWebResource]">
                    <!-- a webresource exists -->
                    <xsl:apply-templates select="//edm:WebResource[@rdf:about = $targetWebResource]" />                    
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="cmd:ref" select="func:nodeResourceProxyId(.)" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="edm:landingPage">
        <xsl:element name="edm-landingPage">
            <xsl:attribute name="cmd:ref" select="func:landingPageProxyId(.)" />
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="edm:EuropeanaAggregation">
        <edm-EuropeanaAggregation  rdf-about="{@rdf:about}" aggregatedCHO="{edm:aggregatedCHO/@rdf:resource}">
            <xsl:apply-templates select="edm:collectionName" mode="element-prop" />
            <xsl:apply-templates select="edm:datasetName" mode="element-prop" />
            <xsl:apply-templates select="edm:country" mode="element-prop" />
            <xsl:apply-templates select="edm:language" mode="element-prop" />
            <xsl:apply-templates select="dc:creator"  mode="component-prop" />
            
            <xsl:apply-templates select="edm:hasView" />
            <xsl:apply-templates select="edm:isShownBy" />
            <xsl:apply-templates select="edm:landingPage" />
            <xsl:apply-templates select="edm:preview" />
            
            <xsl:apply-templates select="edm:rights" />
        </edm-EuropeanaAggregation>
    </xsl:template>
    
    <xsl:template match="edm:WebResource">
        <edm-WebResource cmd:ref="{func:webResourceProxyId(.)}">
            <!--
                **************************
                * WebResource properties *
                **************************
             -->
            <xsl:apply-templates select="dc:description" mode="element-prop" />
            <xsl:apply-templates select="dc:format" mode="element-prop" />
            <xsl:apply-templates select="dc:rights" mode="element-prop" />
            <xsl:apply-templates select="dcterms:conformsTo" mode="element-prop" />
            <xsl:apply-templates select="dcterms:extent" mode="element-prop" />
            <xsl:apply-templates select="dcterms:hasPart" mode="element-prop" />
            <xsl:apply-templates select="dcterms:isFormatOf" mode="element-prop" />
            <xsl:apply-templates select="dcterms:isPartOf" mode="element-prop" />
            <xsl:apply-templates select="dcterms:isReferencedBy" mode="element-prop" />
            <xsl:apply-templates select="edm:isNextInSequence" mode="element-prop" />
            <xsl:apply-templates select="owl:sameAs" mode="element-prop" />
            
            <xsl:apply-templates select="edm:codecName" mode="element-prop" />
            <xsl:apply-templates select="ebucore:hasMimeType" mode="element-prop" />
            <xsl:apply-templates select="ebucore:fileByteSize" mode="element-prop" />
            <xsl:apply-templates select="ebucore:duration" mode="element-prop" />
            <xsl:apply-templates select="ebucore:width" mode="element-prop" />
            <xsl:apply-templates select="ebucore:height" mode="element-prop" />
            <xsl:apply-templates select="edm:spatialResolution" mode="element-prop" />
            <xsl:apply-templates select="ebucore:sampleSize" mode="element-prop" />
            <xsl:apply-templates select="ebucore:sampleRate" mode="element-prop" />
            <xsl:apply-templates select="ebucore:bitRate" mode="element-prop" />
            <xsl:apply-templates select="ebucore:frameRate" mode="element-prop" />
            <xsl:apply-templates select="edm:hasColorSpace" mode="element-prop" />
            <xsl:apply-templates select="edm:componentColor" mode="element-prop" />
            <xsl:apply-templates select="ebucore:orientation" mode="element-prop" />
            <xsl:apply-templates select="ebucore:audiochannelNumber" mode="element-prop" />

            <xsl:apply-templates select="dc:creator" mode="component-prop" />
            <xsl:apply-templates select="dc:created" mode="component-prop" />
            <xsl:apply-templates select="dcterms:issued" mode="component-prop" />            
            
            <xsl:apply-templates select="edm:preview">
                <!-- WebResource cannot be contained in itself, so force a resource proxy ref -->
                <xsl:with-param name="forceRef" select="'yes'" /> 
            </xsl:apply-templates>

            <xsl:apply-templates select="edm:rights" />
            <xsl:apply-templates select="svcs:Service" />
        </edm-WebResource>
    </xsl:template>
    
    <xsl:template match="edm:WebResource/svcs:Service">
        <xsl:variable name="serviceResource" select="//svcs:Service[@rdf:about = current()/@rdf:resource]" />
        <svcs-Service>
            <xsl:apply-templates select="$serviceResource/dcterms:conformsTo" mode="element-prop" />
            <xsl:apply-templates select="$serviceResource/doap:implements" mode="element-prop" />
        </svcs-Service>
    </xsl:template>
    
    <xsl:template match="edm:rights">
        <xsl:variable name="rightsUri" select="@rdf:resource"/>
        <edm-rights>
            <rightsURI><xsl:value-of select="$rightsUri"/></rightsURI>
            <xsl:apply-templates select="//cc:License[@rdf:about = $rightsUri]" mode="contextual" />
        </edm-rights>
    </xsl:template>
    
    <!--
        *****************************************************************
        * ELEMENT PROPERTIES                                            *
        *****************************************************************
    -->
    
    <xsl:template match="*" mode="element-prop">
        <xsl:param name="cmd-name" select="func:get-cmd-name(.)" />
        <xsl:param name="allow-xml-lang" select="true()" />
        <xsl:element name="{$cmd-name}">
            <xsl:if test="$allow-xml-lang">
                <xsl:copy-of select="@xml:lang" />
            </xsl:if>
            <xsl:if test="normalize-space(@rdf:about)">
                <xsl:attribute name="rdf-about" select="@rdf:about" />
            </xsl:if>
            <xsl:if test="normalize-space(@rdf:resource)">
                <xsl:attribute name="rdf-resource" select="@rdf:resource" />
            </xsl:if>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="ebucore:fileByteSize" mode="element-prop">
        <ebucore-fileByteSize>
            <xsl:attribute name="unit">bytes</xsl:attribute>
            <xsl:value-of select="."/>
        </ebucore-fileByteSize>
    </xsl:template>
    
    <!--
        *****************************************************************
        * COMPONENT PROPERTIES                                          *
        *****************************************************************
    -->
    
    <xsl:template match="*" mode="component-prop">
        <xsl:param name="cmd-outer-name" select="func:get-cmd-name(.)" />
        <xsl:param name="cmd-inner-name" select="$cmd-outer-name" />
        <xsl:element name="{$cmd-outer-name}">
            <xsl:choose>
                <xsl:when test="@rdf:resource">
                    <!-- reference -->
                    <xsl:variable name="refId" select="@rdf:resource"/>
                    <xsl:variable name="refTarget" select="//*[@rdf:about = $refId]"/>
                    <xsl:choose>
                        <xsl:when test="$refTarget">
                            <!-- Matching target in document -->
                            <xsl:apply-templates select="$refTarget" mode="contextual" />
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- No matching target in document -->
                            <xsl:attribute name="rdf-resource" select="$refId" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <!-- literal -->
                    <xsl:element name="{$cmd-inner-name}">
                        <xsl:copy-of select="@xml:lang" />
                        <xsl:value-of select="."/>
                    </xsl:element>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>

    <!--
        *****************************************************************
        * CONTEXTUAL CLASSES                                            *
        *****************************************************************
    -->

    <xsl:template match="skos:Concept" mode="contextual">
        <skos-Concept>
            <xsl:attribute name="rdf-about" select="@rdf:about" />
            <xsl:apply-templates select="skos:prefLabel" mode="element-prop" />
            <xsl:apply-templates select="skos:altLabel" mode="element-prop" />
            <xsl:apply-templates select="skos:broader" mode="element-prop" />
            <xsl:apply-templates select="skos:narrower" mode="element-prop" />
            <xsl:apply-templates select="skos:related" mode="element-prop" />
            <xsl:apply-templates select="skos:note" mode="element-prop" />
            <xsl:apply-templates select="skos:notation" mode="element-prop" />
            <xsl:apply-templates select="skos:inScheme" mode="element-prop" />
        </skos-Concept>
    </xsl:template>
    
    <xsl:template match="edm:TimeSpan" mode="contextual">
        <edm-TimeSpan>
            <xsl:attribute name="rdf-about" select="@rdf:about" />
            <xsl:apply-templates select="skos:prefLabel" mode="element-prop" />
            <xsl:apply-templates select="skos:altLabel" mode="element-prop" />
            <xsl:apply-templates select="dcterms:hasPart" mode="element-prop" />
            <xsl:apply-templates select="dcterms:isPartOf" mode="element-prop" />
            <xsl:apply-templates select="edm:begin" mode="element-prop" />
            <xsl:apply-templates select="edm:end" mode="element-prop" />
            <xsl:apply-templates select="owl:sameAs" mode="element-prop" />
        </edm-TimeSpan>
    </xsl:template>
    
    <xsl:template match="edm:Place" mode="contextual">
        <edm-Place>
            <xsl:attribute name="rdf-about" select="@rdf:about" />
            <xsl:apply-templates select="wgs84_pos:lat" mode="element-prop" />
            <xsl:apply-templates select="wgs84_pos:long" mode="element-prop" />
            <xsl:apply-templates select="wgs84_pos:alt" mode="element-prop" />
            <xsl:apply-templates select="skos:prefLabel" mode="element-prop" />
            <xsl:apply-templates select="skos:altLabel" mode="element-prop" />
            <xsl:apply-templates select="skos:note" mode="element-prop" />
            <xsl:apply-templates select="dcterms:hasPart" mode="element-prop" />
            <xsl:apply-templates select="dcterms:isPartOf" mode="element-prop" />
            <xsl:apply-templates select="owl:sameAs" mode="element-prop" />
        </edm-Place>
    </xsl:template>
    
    <xsl:template match="edm:Agent" mode="contextual">
        <edm-Agent>
            <xsl:attribute name="rdf-about" select="@rdf:about" />
            <xsl:apply-templates select="skos:prefLabel" mode="element-prop" />
            <xsl:apply-templates select="skos:altLabel" mode="element-prop" />
            <xsl:apply-templates select="skos:note" mode="element-prop" />
            <xsl:apply-templates select="dcterms:hasPart" mode="element-prop" />
            <xsl:apply-templates select="dcterms:isPartOf" mode="element-prop" />
            <xsl:apply-templates select="edm:begin" mode="element-prop" />
            <xsl:apply-templates select="edm:end" mode="element-prop" />
            <xsl:apply-templates select="edm:isRelatedTo" mode="element-prop" />
            
            <xsl:apply-templates select="foaf:name" mode="element-prop" />
            <xsl:apply-templates select="rdaGr2:biographicalInformation" mode="element-prop" />
            <xsl:apply-templates select="rdaGr2:dateOfBirth" mode="element-prop" />
            <xsl:apply-templates select="rdaGr2:dateOfDeath" mode="element-prop" />
            <xsl:apply-templates select="rdaGr2:dateOfEstablishment" mode="element-prop" />
            <xsl:apply-templates select="rdaGr2:dateOfTermination" mode="element-prop" />
            <xsl:apply-templates select="rdaGr2:gender" mode="element-prop" />
            <xsl:apply-templates select="rdaGr2:professionOrOccupation" mode="element-prop" />
            
            <xsl:apply-templates select="owl:sameAs" mode="element-prop" />
            
            <xsl:apply-templates select="dc:date" mode="component-prop" />
            <xsl:apply-templates select="edm:hasMet" mode="component-prop" />            
            <xsl:apply-templates select="rdaGr2:placeOfBirth" mode="component-prop" />            
            <xsl:apply-templates select="rdaGr2:placeOfDeath" mode="component-prop" />            
        </edm-Agent>
    </xsl:template>
    
    <xsl:template match="cc:License" mode="contextual">
        <cc-License>
            <xsl:attribute name="rdf-about" select="@rdf:about" />
            <xsl:apply-templates select="odrl:inheritFrom" mode="element-prop" />
            <xsl:apply-templates select="cc:deprecatedOn" mode="element-prop" />
        </cc-License>
    </xsl:template>
    
    <xsl:template match="*" mode="contextual">
        <!-- fallback -->
        <xsl:attribute name="rdf-resource" select="@rdf:resource" />
        <xsl:comment select="concat(name(), ' ', @rdf:about)" />
    </xsl:template>

    <!--
        *****************************************************************
        * UTILS AND FUNCTIONS                                           *
        *****************************************************************
    -->
    
    <xsl:function name="func:get-cmd-name">
        <!--
            Maps an element name to a CMD element/component name (only for recognised namespaces)
        -->
        <xsl:param name="node" />
        <xsl:value-of select="concat(func:get-cmd-name-prefix($node/namespace-uri()), '-', $node/local-name())" />
    </xsl:function>
    
    <xsl:function name="func:get-cmd-name-prefix">
        <!--
            Maps a recognised namespace to a 'prefix' for a CMD element or component so that the name can be derived from the original name automatically and reliably
        -->
        <xsl:param name="ns" />
        
        <xsl:variable name="ns-prefix-map">
            <func:entry key="http://purl.org/dc/elements/1.1/">dc</func:entry>
            <func:entry key="http://purl.org/dc/terms/">dcterms</func:entry>
            <func:entry key="http://www.europeana.eu/schemas/edm/">edm</func:entry>
            <func:entry key="http://www.w3.org/1999/02/22-rdf-syntax-ns#">rdf</func:entry>
            <func:entry key="http://www.w3.org/2004/02/skos/core#">skos</func:entry>
            <func:entry key="http://www.w3.org/2002/07/owl#">owl</func:entry>
            <func:entry key="http://www.w3.org/2003/01/geo/wgs84_pos#">wgs84_pos</func:entry>
            <func:entry key="http://www.openarchives.org/ore/terms/">ore</func:entry>
            <func:entry key="http://creativecommons.org/ns#">cc</func:entry>
            <func:entry key="http://www.w3.org/ns/odrl/2/">odrl</func:entry>
            <func:entry key="http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#">ebucore</func:entry>
            <func:entry key="http://xmlns.com/foaf/0.1/">foaf</func:entry>
            <func:entry key="http://rdvocab.info/ElementsGr2/">rdaGr2</func:entry>
            <func:entry key="http://rdfs.org/sioc/services#">svcs</func:entry>            
            <func:entry key="http://usefulinc.com/ns/doap#">doap</func:entry>
        </xsl:variable>
        
        <xsl:variable name="prefix" select="$ns-prefix-map/func:entry[@key = string($ns)]"/>
        <xsl:choose>
            <xsl:when test="normalize-space($prefix) != ''">
                <xsl:value-of select="$prefix"/>
            </xsl:when>
            <xsl:otherwise>unkown</xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>
    
    <xsl:function name="func:webResourceProxyId">
        <xsl:param name="webResouce" />
        <xsl:value-of select="concat('webResource_', generate-id($webResouce))"/>
    </xsl:function>
    
    <xsl:function name="func:landingPageProxyId">
        <xsl:param name="webResouce" />
        <xsl:value-of select="concat('landingPage_', generate-id($webResouce))"/>
    </xsl:function>

    <xsl:function name="func:nodeResourceProxyId">
        <xsl:param name="node" />
        <xsl:value-of select="concat($node/local-name(), '_', generate-id($node))"/>
    </xsl:function>
    
    <xsl:function name="func:sanitiseCollectionName">
        <xsl:param name="collectionName" />
        
        <!-- TEL collections have collection names like 92004_Ag_EU_TEL_a0588_TEL_NKP_manuscriptorium" -->
        <xsl:analyze-string select="$collectionName" regex="^([^-]+_)Ag_EU_TEL_(a[^_]+_)?(.*)$">
            <xsl:matching-substring>
                <xsl:value-of select="concat('The European Library: ', replace(regex-group(3), '_', ' '))"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="$collectionName" />
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:function>
    

</xsl:stylesheet>