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
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:ore="http://www.openarchives.org/ore/terms/"
    xmlns:cc="http://creativecommons.org/ns#"
    xmlns:edm="http://www.europeana.eu/schemas/edm/"
    xmlns:cmd="http://www.clarin.eu/cmd/1"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:func="http://www.clarin.eu/cmd/conversion/edm-cmd"
    xmlns="http://www.clarin.eu/cmd/1/profiles/clarin.eu:cr1:p_1475136016208"
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
    
    <!--
        *****************************************************************
        * RESOURCES SECTION                                             *
        *****************************************************************
    -->
    
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
            <cmd:ResourceProxy id="{func:webResourceProxyId(.)}">
                <cmd:ResourceType>Resource</cmd:ResourceType>
                <cmd:ResourceRef><xsl:value-of select="@rdf:about"/></cmd:ResourceRef>
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
        <!--
            TODO: includes a webresource!
            <xsl:apply-templates select="dcterms:hasFormat" mode="component-prop" />
            and decide on this one... make element instead?
            <xsl:apply-templates select="dcterms:hasPart" mode="component-prop" />
        -->
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
    
    <xsl:template match="edm:hasView|edm:isShownAt|edm:isShownBy|edm:object">
        <xsl:variable name="targetWebResource" select="@rdf:resource"/>
        <xsl:element name="{replace(name(), ':', '-')}">
            <xsl:apply-templates select="//edm:WebResource[@rdf:about = $targetWebResource]" />
        </xsl:element>
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

            <xsl:apply-templates select="dc:creator" mode="component-prop" />
            <xsl:apply-templates select="dc:created" mode="component-prop" />
            <xsl:apply-templates select="dcterms:issued" mode="component-prop" />            

            <xsl:apply-templates select="edm:rights" />
        </edm-WebResource>
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
        <xsl:param name="cmd-name" select="replace(name(), ':', '-')" />
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
    
    <!--
        *****************************************************************
        * COMPONENT PROPERTIES                                          *
        *****************************************************************
    -->
    
    <xsl:template match="*" mode="component-prop">
        <xsl:param name="cmd-outer-name" select="replace(name(), ':', '-')" />
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
            <!-- TODO -->
        </skos-Concept>
    </xsl:template>
    
    <xsl:template match="edm:TimeSpan" mode="contextual">
        <edm-TimeSpan>
            <xsl:attribute name="rdf-about" select="@rdf:about" />
            <xsl:apply-templates select="skos:prefLabel" mode="element-prop" />
            <xsl:apply-templates select="skos:altLabel" mode="element-prop" />
            <!-- TODO -->
        </edm-TimeSpan>
    </xsl:template>
    
    <xsl:template match="edm:Place" mode="contextual">
        <edm-Place>
            <xsl:attribute name="rdf-about" select="@rdf:about" />
            <xsl:apply-templates select="skos:prefLabel" mode="element-prop" />
            <xsl:apply-templates select="skos:altLabel" mode="element-prop" />
            <!-- TODO -->
        </edm-Place>
    </xsl:template>
    
    <xsl:template match="edm:Agent" mode="contextual">
        <edm-Agent>
            <xsl:attribute name="rdf-about" select="@rdf:about" />
            <xsl:apply-templates select="skos:prefLabel" mode="element-prop" />
            <xsl:apply-templates select="skos:altLabel" mode="element-prop" />
            <!-- TODO -->
        </edm-Agent>
    </xsl:template>
    
    <xsl:template match="cc:License" mode="contextual">
        <cc-License>
            <!-- TODO -->
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

    <xsl:function name="func:webResourceProxyId">
        <xsl:param name="webResouce" required="yes"/>
        <xsl:value-of select="concat('webResource_', generate-id($webResouce))"/>
    </xsl:function>
    
</xsl:stylesheet>