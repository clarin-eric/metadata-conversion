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
    xmlns:datacite_oai="http://schema.datacite.org/oai/oai-1.1/"
    xmlns:datacite_cmd="http://www.clarin.eu/cmd/conversion/ddi/cmd"
    xsi:schemaLocation="http://datacite.org/schema/kernel-4 http://schema.datacite.org/meta/kernel-4/metadata.xsd"
    xpath-default-namespace="http://datacite.org/schema/kernel-4" exclude-result-prefixes="xs datacite_oai datacite_cmd"
    version="2.0">

    <xsl:output indent="yes"/>

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
    
    <xsl:template match="/datacite_oai:oai_datacite">
        <xsl:apply-templates select="datacite_oai:payload/resource" mode="root" />
    </xsl:template>
    
    <xsl:template match="/resource">
        <xsl:apply-templates select="." mode="root" />
    </xsl:template>
    
    <xsl:template match="/*" priority="-1">
        <xsl:comment>Cannot convert metadata, no DataCite or DataCite OAI detected at root</xsl:comment>
    </xsl:template>
    
    <xsl:template match="resource" mode="root">
        <cmd:CMD CMDVersion="1.2"
            xsi:schemaLocation="http://www.clarin.eu/cmd/1 https://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/1.x/profiles/clarin.eu:cr1:p_1610707853541/xsd">
            <xsl:apply-templates select="." mode="header-section"/>
            <xsl:apply-templates select="." mode="resource-section"/>
            <cmd:Components>
                <DataCiteRecord>
                    <xsl:apply-templates select="." mode="component-section"/>
                </DataCiteRecord>
            </cmd:Components>
        </cmd:CMD>
    </xsl:template>

    <xsl:template match="identifier[@identifierType = 'DOI']" mode="ResourceProxy">
        <cmd:ResourceProxy>
            <xsl:attribute name="id" select="generate-id(.)"/>
            <cmd:ResourceType>Resource</cmd:ResourceType>
            <cmd:ResourceRef>
                <xsl:choose>
                    <xsl:when test="datacite_cmd:isDOI(text())">
                        <xsl:sequence select="datacite_cmd:normalize_doi(text())"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence
                            select="datacite_cmd:normalize_doi(concat('https://doi.org/', text()))"
                        />
                    </xsl:otherwise>
                </xsl:choose>
            </cmd:ResourceRef>
        </cmd:ResourceProxy>
    </xsl:template>

    <xsl:template
        match="identifier[@identifierType != 'DOI' and datacite_cmd:isAbsoluteUri(text())]"
        mode="ResourceProxy">
        <cmd:ResourceProxy>
            <xsl:attribute name="id" select="generate-id(.)"/>
            <cmd:ResourceType>Resource</cmd:ResourceType>
            <cmd:ResourceRef>
                <xsl:value-of select="text()"/>
            </cmd:ResourceRef>
        </cmd:ResourceProxy>
    </xsl:template>

    <xsl:template match="identifier" mode="ResourceProxy">
        <xsl:comment>Resource identifier cannot be converted to a ResourceRef: <xsl:value-of select="text()"/></xsl:comment>
    </xsl:template>

    <!-- Header section -->

    <xsl:template match="resource" mode="header-section">
        <cmd:Header>
            <!-- Metadata creator not in DataCite model - make this a parameter? -->
            <!--                <cmd:MdCreator>MdCreator1</cmd:MdCreator>-->
            <!-- Ok to use generation date of conversion?? -->
            <!--                <cmd:MdCreationDate>2006-05-04</cmd:MdCreationDate>-->
            <!-- Can we generate a selflink? -->
            <!--                <cmd:MdSelfLink>http://www.oxygenxml.com/</cmd:MdSelfLink>-->
            <cmd:MdProfile>clarin.eu:cr1:p_1610707853541</cmd:MdProfile>
            <!--<cmd:MdCollectionDisplayName>MdCollectionDisplayName0</cmd:MdCollectionDisplayName>-->
        </cmd:Header>
    </xsl:template>

    <!-- Resources section -->

    <xsl:template match="resource" mode="resource-section">
        <cmd:Resources>
            <cmd:ResourceProxyList>
                <!-- there should be only one identifier -->
                <xsl:apply-templates select="identifier[1]" mode="ResourceProxy"/>
            </cmd:ResourceProxyList>
            <cmd:JournalFileProxyList/>
            <cmd:ResourceRelationList/>
        </cmd:Resources>
        <cmd:IsPartOfList/>
    </xsl:template>

    <!-- Component section -->

    <xsl:template match="resource" mode="component-section">
        <!-- IdentificationInfo -->

        <xsl:call-template name="wrapper-component">
            <xsl:with-param name="name" select="'IdentificationInfo'"/>
            <xsl:with-param name="content">
                <xsl:apply-templates select="./identifier" mode="IdentificationInfo.identifier"/>
                <xsl:apply-templates select="./alternateIdentifiers/alternateIdentifier"
                    mode="IdentificationInfo.alternativeIdentifier"/>
            </xsl:with-param>
        </xsl:call-template>

        <!-- TitleInfo -->
        <xsl:apply-templates select="titles" mode="TitleInfo"/>

        <!-- Description -->

        <xsl:call-template name="wrapper-component">
            <xsl:with-param name="name" select="'Description'"/>
            <xsl:with-param name="content">
                <xsl:apply-templates select="descriptions/description"
                    mode="Description.description"/>
            </xsl:with-param>
        </xsl:call-template>

        <!-- Resource type -->
        <xsl:apply-templates select="resourceType" mode="ResourceType"/>

        <!-- Version info -->
        <xsl:apply-templates select="version[1]" mode="VersionInfo"/>

        <!-- Language -->
        <xsl:apply-templates select="language[1]" mode="Language"/>

        <!-- Subject -->
        <xsl:apply-templates select="subjects/subject" mode="Subject"/>

        <!-- Creator -->
        <xsl:apply-templates select="creators/creator" mode="Creator"/>

        <!-- Contributor -->
        <xsl:apply-templates select="contributors/contributor" mode="Contributor"/>

        <!-- ProvenanceInfo -->

        <xsl:call-template name="wrapper-component">
            <xsl:with-param name="name" select="'ProvenanceInfo'"/>
            <xsl:with-param name="content">
                <!-- Creation -->
                <xsl:apply-templates select="dates" mode="ProvenanceInfo.Creation"/>
                <!-- Collection -->
                <xsl:apply-templates select="dates" mode="ProvenanceInfo.Collection"/>
                <!-- Publication -->
                <xsl:apply-templates select="publicationYear"
                    mode="ProvenanceInfo.Publication"/>
                <!-- other activities -->
                <xsl:apply-templates
                    select="dates/date[@dateType != 'Created' and @dateType != 'Collected']"
                    mode="ProvenanceInfo.Activity"/>
            </xsl:with-param>
        </xsl:call-template>

        <!-- Subresource -->
        <xsl:apply-templates select="." mode="Subresource"/>

        <!-- AccessInfo -->

        <xsl:call-template name="wrapper-component">
            <xsl:with-param name="name" select="'AccessInfo'"/>
            <xsl:with-param name="content">
                <xsl:apply-templates select="rightsList/rights"
                    mode="AccessInfo.otherAccessInfo"/>
                <xsl:apply-templates select="rightsList/rights" mode="AccessInfo.Licence"
                />
            </xsl:with-param>
        </xsl:call-template>

        <!-- GeoLocation -->
        <xsl:apply-templates select="geoLocations/geoLocation" mode="GeoLocation"/>

        <!-- FundingInfo -->

        <xsl:call-template name="wrapper-component">
            <xsl:with-param name="name" select="'FundingInfo'"/>
            <xsl:with-param name="content">
                <xsl:apply-templates select="fundingReferences/fundingReference"
                    mode="Funding"/>
            </xsl:with-param>
        </xsl:call-template>

        <!-- RelatedResource -->
        <xsl:apply-templates select="relatedItems/relatedItem" mode="RelatedResource"/>
    </xsl:template>

    <xsl:template match="resource/identifier" mode="IdentificationInfo.identifier">
        <xsl:element name="identifier">
            <xsl:choose>
                <xsl:when test="normalize-space(@identifierType | @alternateIdentifierType) = 'DOI'">
                    <xsl:attribute name="type">DOI</xsl:attribute>
                    <xsl:sequence select="datacite_cmd:normalize_doi(text())"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="@identifierType | @alternateIdentifierType"
                        mode="identifier.type"/>
                    <xsl:sequence select="text()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>

    <xsl:template match="resource/alternateIdentifiers/alternateIdentifier"
        mode="IdentificationInfo.alternativeIdentifier">
        <xsl:element name="alternativeIdentifier">
            <xsl:choose>
                <xsl:when test="normalize-space(@identifierType | @alternateIdentifierType) = 'DOI'">
                    <xsl:attribute name="type">DOI</xsl:attribute>
                    <xsl:sequence select="datacite_cmd:normalize_doi(text())"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="@identifierType | @alternateIdentifierType"
                        mode="identifier.type"/>
                    <xsl:sequence select="text()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>

    <xsl:template match="@identifierType" mode="identifier.type">
        <xsl:choose>
            <xsl:when test="normalize-space(.) = 'DOI'">
                <xsl:attribute name="type">DOI</xsl:attribute>
            </xsl:when>
            <!-- TOOD: other supported identifier types -->
        </xsl:choose>
    </xsl:template>

    <xsl:template match="titles" mode="TitleInfo">
        <xsl:call-template name="wrapper-component">
            <xsl:with-param name="name" select="'TitleInfo'"/>
            <xsl:with-param name="content">
                <!-- main title -->
                <xsl:apply-templates select="./title[not(@titleType)]" mode="TitleInfo.title"/>
                <!-- alternative title -->
                <xsl:apply-templates
                    select="./title[@titleType = 'AlternativeTitle' or @titleType = 'TranslatedTitle' or @titleType = 'Other']"
                    mode="TitleInfo.title"/>
                <!-- subtitle -->
                <xsl:apply-templates select="./title[@titleType = 'Subtitle']"
                    mode="TitleInfo.title"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="titles/title" mode="TitleInfo.title">
        <xsl:variable name="elementName">
            <xsl:choose>
                <xsl:when test="normalize-space(@titleType) = ''">
                    <xsl:sequence select="'title'"/>
                </xsl:when>
                <xsl:when test="@titleType = 'Subtitle'">
                    <xsl:sequence select="'subtitle'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="'alternativeTitle'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:element name="{$elementName}">
            <xsl:copy-of select="@xml:lang"/>
            <xsl:sequence select="text()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="resource/descriptions/description" mode="Description.description">
        <description>
            <xsl:copy-of select="@xml:lang"/>
            <xsl:sequence select="text()"/>
        </description>
    </xsl:template>

    <xsl:template match="resourceType/@resourceTypeGeneral | relatedItem/@relatedItemType"
        mode="ResourceType.identifier">
        <!-- 
                The 'dcmitype' ontology is supported/recommended. See https://dublincore.org/specifications/dublin-core/dcmi-terms/#section-7. 
                See https://sparontologies.github.io/datacite/current/datacite.html and https://databus.dbpedia.org/ontologies/purl.org/spar%2D%2Ddatacite        
        -->

        <xsl:variable name="resourceTypeGeneral" select="string(.)"/>

        <xsl:variable name="resourceTypeUri"
            select="$resourceTypeUris/datacite_cmd:entry[@key = $resourceTypeGeneral]"/>

        <xsl:if test="normalize-space($resourceTypeUri) != ''">
            <identifier>
                <xsl:value-of select="$resourceTypeUri"/>
            </identifier>
        </xsl:if>
    </xsl:template>

    <xsl:template match="resource/resourceType" mode="ResourceType">
        <ResourceType>

            <!-- Identifier from @resourceTypeGeneral attribute -->
            <xsl:apply-templates select="@resourceTypeGeneral" mode="ResourceType.identifier"/>

            <!-- Label from @resourceTypeGeneral attribute -->
            <xsl:if test="@resourceTypeGeneral">
                <label>
                    <xsl:value-of select="@resourceTypeGeneral"/>
                </label>
            </xsl:if>

            <!-- Label from free-text node content -->
            <xsl:if test="normalize-space(text()) != ''">
                <!-- Do not duplicate value from @resourceTypeGeneral -->
                <xsl:if test="normalize-space(text()) != normalize-space(@resourceTypeGeneral)">
                    <label>
                        <xsl:sequence select="text()"/>
                    </label>
                </xsl:if>
            </xsl:if>
        </ResourceType>
    </xsl:template>

    <xsl:template match="resource/version" mode="VersionInfo">
        <VersionInfo>
            <versionIdentifier>
                <xsl:sequence select="text()"/>
            </versionIdentifier>
        </VersionInfo>
    </xsl:template>

    <xsl:template match="resource/language[1]" mode="Language">
        <!-- TODO: convert to ISO-639-3 -->
        <xsl:variable name="iso639-3-code" select="datacite_cmd:toISO693-3(text())"/>

        <Language>
            <name>
                <!-- TODO: language name from vocab -->
                <xsl:sequence select="$iso639-3-code"/>
            </name>
            <code>
                <!-- TODO: @cmd:ValueConceptLink="..." -->
                <xsl:sequence select="$iso639-3-code"/>
            </code>
        </Language>
    </xsl:template>


    <!-- Subject -->
    <xsl:template match="subjects/subject" mode="Subject">
        <Subject>
            <xsl:if test="@valueURI">
                <identifier>
                    <xsl:value-of select="@valueURI"/>
                </identifier>
            </xsl:if>
            <label>
                <xsl:sequence select="text()"/>
            </label>
            <xsl:if test="@subjectScheme">
                <scheme>
                    <xsl:value-of select="@subjectScheme"/>
                </scheme>
            </xsl:if>
            <xsl:if test="@schemeURI">
                <schemeURI>
                    <xsl:value-of select="@schemeURI"/>
                </schemeURI>
            </xsl:if>
        </Subject>
    </xsl:template>

    <xsl:template match="creator | contributor" mode="AgentInfo">
        <xsl:variable name="nameElement" select="(contributorName | creatorName)[1]"/>

        <AgentInfo>
            <xsl:choose>
                <xsl:when test="$nameElement/@nameType = 'Organizational'">
                    <OrganisationInfo>
                        <name>
                            <xsl:copy-of select="@xml:lang"/>
                            <xsl:sequence select="$nameElement/text()"/>
                        </name>
                        <xsl:for-each select="affiliation">
                            <affiliation>
                                <xsl:sequence select="text()"/>
                            </affiliation>
                        </xsl:for-each>
                    </OrganisationInfo>
                </xsl:when>
                <xsl:otherwise>
                    <PersonInfo>
                        <name>
                            <xsl:copy-of select="@xml:lang"/>
                            <xsl:sequence select="$nameElement/text()"/>
                        </name>
                        <xsl:for-each select="givenName | familyName">
                            <alternativeName>
                                <xsl:copy-of select="@xml:lang"/>
                                <xsl:attribute name="type">
                                    <xsl:value-of select="name()"/>
                                </xsl:attribute>
                                <xsl:sequence select="text()"/>
                            </alternativeName>
                        </xsl:for-each>
                        <xsl:for-each select="affiliation">
                            <affiliation>
                                <xsl:sequence select="text()"/>
                            </affiliation>
                        </xsl:for-each>
                    </PersonInfo>
                </xsl:otherwise>
            </xsl:choose>
        </AgentInfo>
    </xsl:template>

    <xsl:template match="nameIdentifier" mode="CreatorContributor.identifier">
        <identifier>
            <!-- TODO: specify scheme in attribute (to be added to component) -->
            <xsl:sequence select="text()"/>
        </identifier>
    </xsl:template>

    <xsl:template match="creator" mode="Creator">
        <Creator>
            <xsl:apply-templates select="nameIdentifier" mode="CreatorContributor.identifier"/>
            <label>
                <xsl:copy-of select="@xml:lang"/>
                <xsl:sequence select="creatorName/text()"/>
            </label>
            <xsl:apply-templates select="." mode="AgentInfo"/>
        </Creator>
    </xsl:template>

    <xsl:template match="contributor" mode="Contributor">
        <Contributor>
            <xsl:apply-templates select="nameIdentifier" mode="CreatorContributor.identifier"/>
            <label>
                <xsl:copy-of select="@xml:lang"/>
                <xsl:sequence select="contributorName/text()"/>
            </label>
            <xsl:for-each select="@contributorType">
                <role>
                    <xsl:sequence select="string()"/>
                </role>
            </xsl:for-each>
            <xsl:apply-templates select="." mode="AgentInfo"/>
        </Contributor>
    </xsl:template>

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

    <xsl:template match="date" mode="ActivityInfo">
        <ActivityInfo>
            <xsl:if test="@dateInformation">
                <note>
                    <xsl:value-of select="@dateInformation"/>
                </note>
            </xsl:if>
            <When>
                <xsl:choose>
                    <xsl:when test="datacite_cmd:isValidDateRange(text())">
                        <!-- TODO: also support open ended ranges (only start or end) -->
                        <start>
                            <xsl:value-of
                                select="datacite_cmd:getDateFromDateTime(datacite_cmd:getStartDateFromRange(text()))"
                            />
                        </start>
                        <end>
                            <xsl:value-of
                                select="datacite_cmd:getDateFromDateTime(datacite_cmd:getEndDateFromRange(text()))"
                            />
                        </end>
                    </xsl:when>
                    <xsl:when test="(datacite_cmd:getDateFromDateTime(text()) castable as xs:date)">
                        <date>
                            <xsl:value-of select="datacite_cmd:getDateFromDateTime(text())"/>
                        </date>
                    </xsl:when>
                    <xsl:when test="(datacite_cmd:getYearFromDateTime(text()) castable as xs:gYear)">
                        <year>
                            <xsl:value-of select="datacite_cmd:getYearFromDateTime(text())"/>
                        </year>
                    </xsl:when>
                    <xsl:otherwise>
                        <label>
                            <xsl:value-of select="text()"/>
                        </label>
                    </xsl:otherwise>
                </xsl:choose>
            </When>
        </ActivityInfo>
    </xsl:template>

    <!-- Provenance: Creation -->
    <xsl:template match="dates" mode="ProvenanceInfo.Creation">
        <xsl:call-template name="wrapper-component">
            <xsl:with-param name="name" select="'Creation'"/>
            <xsl:with-param name="content">
                <xsl:for-each select="date[@dateType = 'Created']">
                    <xsl:apply-templates select="." mode="ActivityInfo"/>
                </xsl:for-each>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!-- Provenance: Collection -->
    <xsl:template match="dates" mode="ProvenanceInfo.Collection">
        <xsl:call-template name="wrapper-component">
            <xsl:with-param name="name" select="'Collection'"/>
            <xsl:with-param name="content">
                <xsl:for-each select="date[@dateType = 'Collected']">
                    <xsl:apply-templates select="." mode="ActivityInfo"/>
                </xsl:for-each>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!-- Provenance: other activities -->
    <xsl:template match="date" mode="ProvenanceInfo.Activity">
        <Activity>
            <label>
                <xsl:value-of select="@dateType"/>
            </label>
            <xsl:apply-templates select="." mode="ActivityInfo"/>
        </Activity>
    </xsl:template>

    <!-- Provenance: Publication -->
    <xsl:template match="resource/publicationYear" mode="ProvenanceInfo.Publication">
        <Publication>
            <ActivityInfo>
                <When>
                    <year>
                        <xsl:value-of select="."/>
                    </year>
                </When>
            </ActivityInfo>
        </Publication>
    </xsl:template>

    <xsl:template match="size[matches(lower-case(text()), '^\d+ *kb?$')]"
        mode="SubresourceTechnicalInfo.size">
        <size SizeUnit="kilobyte">
            <xsl:value-of select="replace(text(), '^(\d+).*$', '$1')"/>
        </size>
    </xsl:template>

    <xsl:template match="size[matches(lower-case(text()), '^\d+ *mb?$')]"
        mode="SubresourceTechnicalInfo.size">
        <size SizeUnit="megabyte">
            <xsl:value-of select="replace(text(), '^(\d+).*$', '$1')"/>
        </size>
    </xsl:template>

    <xsl:template match="size[matches(lower-case(text()), '^\d+ *b(ytes?)?$')]"
        mode="SubresourceTechnicalInfo.size">
        <size SizeUnit="byte">
            <xsl:value-of select="replace(text(), '^(\d+).*$', '$1')"/>
        </size>
    </xsl:template>

    <xsl:template match="size" mode="SubresourceTechnicalInfo.size">
        <!-- Not detected as a file (bitstream) size -->
        <xsl:comment>Size: <xsl:value-of select="."/></xsl:comment>
    </xsl:template>

    <xsl:template match="format" mode="SubresourceTechnicalInfo.type">
        <!-- <type> is for type indications/specifications other than media types -->
        <xsl:choose>
            <xsl:when test="datacite_cmd:isMediaType(text())">
                <!-- nothing, handled by <mediaType> template -->
            </xsl:when>
            <xsl:otherwise>
                <type>
                    <xsl:sequence select="text()"/>
                </type>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="format" mode="SubresourceTechnicalInfo.mediaType">
        <!-- <mediaType> is for IANA media type specifications only -->
        <xsl:choose>
            <xsl:when test="datacite_cmd:isMediaType(text())">
                <mediaType>
                    <xsl:sequence select="text()"/>
                </mediaType>
            </xsl:when>
            <xsl:otherwise>
                <!-- nothing, handled by <type> template -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="resource" mode="Subresource">
        <xsl:variable name="sizes">
            <xsl:apply-templates select="sizes/size" mode="SubresourceTechnicalInfo.size"/>
        </xsl:variable>
        <!-- 
            <Subresource> 
        -->
        <xsl:call-template name="wrapper-component">
            <xsl:with-param name="name" select="'Subresource'"/>
            <xsl:with-param name="content">
                <!-- 
                    <SubresourceTechnicalInfo>
                -->
                <xsl:call-template name="wrapper-component">
                    <xsl:with-param name="name" select="'SubresourceTechnicalInfo'"/>
                    <xsl:with-param name="content">
                        <!-- Type: other type specifications, then media type ('mime type') -->
                        <xsl:apply-templates select="formats/format"
                            mode="SubresourceTechnicalInfo.type"/>
                        <xsl:apply-templates select="formats/format"
                            mode="SubresourceTechnicalInfo.mediaType"/>
                        <!-- Size: Profile only accepts one size -->
                        <xsl:sequence select="$sizes/cmdp:size[1]"/>
                        <xsl:copy-of select="$sizes/comment()"/>
                    </xsl:with-param>
                </xsl:call-template>
                <!-- 
                    </SubresourceTechnicalInfo> 
                -->
            </xsl:with-param>
        </xsl:call-template>
        <!-- 
            </Subresource> 
        -->
    </xsl:template>

    <xsl:template match="rights[@rightsURI castable as xs:anyURI]" mode="AccessInfo.Licence">
        <xsl:call-template name="wrapper-component">
            <xsl:with-param name="name" select="'Licence'"/>
            <xsl:with-param name="content">
                <!--
                    <Licence>
                -->
                <xsl:if test="@rightsURI">
                    <identifier>
                        <xsl:value-of select="@rightsURI"/>
                    </identifier>
                </xsl:if>
                <xsl:if test="@rightsIdentifier">
                    <identifier>
                        <xsl:value-of select="@rightsIdentifier"/>
                    </identifier>
                </xsl:if>
                <xsl:choose>
                    <xsl:when test="normalize-space(text()) != ''">
                        <label>
                            <xsl:copy-of select="@xml:lang"/>
                            <xsl:sequence select="text()"/>
                        </label>
                    </xsl:when>
                    <xsl:when test="@rightsURI">
                        <label><xsl:value-of select="@rightsURI"/></label>
                    </xsl:when>
                </xsl:choose>
                <!--
                    </Licence>
                -->
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="rights" mode="AccessInfo.Licence">
        <!-- nothing -->
    </xsl:template>

    <xsl:template match="rights" mode="AccessInfo.otherAccessInfo">
        <otherAccessInfo>
            <xsl:value-of select="text()"/>
        </otherAccessInfo>
        <xsl:if test="@rightsURI">
            <otherAccessInfo>
                <xsl:value-of select="@rightsURI"/>
            </otherAccessInfo>
        </xsl:if>
        <xsl:if test="@rightsIdentifier">
            <otherAccessInfo>
                <xsl:value-of select="@rightsIdentifier"/>
            </otherAccessInfo>
        </xsl:if>
    </xsl:template>

    <xsl:template match="rights[@rightsURI castable as xs:anyURI]" mode="AccessInfo.otherAccessInfo">
        <!-- nothing -->
    </xsl:template>

    <xsl:template match="geoLocation" mode="GeoLocation">
        <!-- TODO: support geoLocationBox, geoLocationPolygon?? -->
        <xsl:call-template name="wrapper-component">
            <xsl:with-param name="name" select="'GeoLocation'"/>
            <xsl:with-param name="content">
                <!-- 
                    <GeoLocation> 
                -->
                <xsl:for-each select="geoLocationPlace">
                    <label>
                        <xsl:copy-of select="@xml:lang"/>
                        <xsl:value-of select="."/>
                    </label>
                </xsl:for-each>
                <xsl:apply-templates select="geoLocationPoint[1]" mode="GeographicCoordinates"/>
                <!-- 
                    </GeoLocation> 
                -->
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="geoLocationPoint" mode="GeographicCoordinates">
        <xsl:choose>
            <xsl:when
                test="(./pointLatitude castable as xs:decimal) and (./pointLongitude castable as xs:decimal)">
                <GeographicCoordinates>
                    <latitude>
                        <xsl:value-of select="pointLatitude"/>
                    </latitude>
                    <longitude>
                        <xsl:value-of select="pointLongitude"/>
                    </longitude>
                </GeographicCoordinates>
            </xsl:when>
            <xsl:otherwise>
                <label><xsl:value-of select="pointLongitude"/>; <xsl:value-of select="pointLatitude"
                    /></label>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="fundingReference" mode="Funding">
        <xsl:call-template name="wrapper-component">
            <xsl:with-param name="name" select="'Funding'"/>
            <xsl:with-param name="content">
                <!-- 
                    <Funding> 
                -->
                <xsl:if test="awardNumber">
                    <grantNumber>
                        <xsl:value-of select="awardNumber"/>
                    </grantNumber>
                </xsl:if>
                <xsl:if test="awardTitle">
                    <label>
                        <xsl:value-of select="awardTitle"/>
                    </label>
                </xsl:if>
                <xsl:if test="funderName | funderIdentifier">
                    <FundingAgency>
                        <xsl:if test="funderIdentifier">
                            <identifier>
                                <xsl:value-of select="funderIdentifier/@funderIdentifierType"/>:
                                    <xsl:value-of select="funderIdentifier"/>
                            </identifier>
                        </xsl:if>
                        <xsl:if test="funderName">
                            <label>
                                <xsl:value-of select="funderName"/>
                            </label>
                        </xsl:if>
                    </FundingAgency>
                </xsl:if>
                <!-- 
                    </Funding> 
                -->
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="*" mode="bibliographicCitation">
        <xsl:param name="label" as="xs:string"
            select="datacite_cmd:firstToUpper(normalize-space(name()))"/>
        <bibliographicCitation><xsl:value-of select="$label"/>: <xsl:value-of select="text()"
            /></bibliographicCitation>
    </xsl:template>

    <xsl:template match="relatedItem" mode="RelatedResource.CitationInfo">
        <CitationInfo>
            <xsl:apply-templates select="publicationYear" mode="bibliographicCitation">
                <xsl:with-param name="label">Publication year</xsl:with-param>
            </xsl:apply-templates>
            <xsl:apply-templates select="volume" mode="bibliographicCitation"/>
            <xsl:apply-templates select="issue" mode="bibliographicCitation"/>
            <xsl:apply-templates select="number" mode="bibliographicCitation"/>
            <xsl:apply-templates select="firstPage" mode="bibliographicCitation">
                <xsl:with-param name="label">First page</xsl:with-param>
            </xsl:apply-templates>
            <xsl:apply-templates select="lastPage" mode="bibliographicCitation">
                <xsl:with-param name="label">Last page</xsl:with-param>
            </xsl:apply-templates>
            <xsl:apply-templates select="publisher" mode="bibliographicCitation"/>
            <xsl:apply-templates select="edition" mode="bibliographicCitation"/>
        </CitationInfo>
    </xsl:template>

    <xsl:template match="relatedItem" mode="RelatedResource">
        <RelatedResource>
            <!-- identifier -->
            <xsl:if test="relatedItemIdentifier">
                <identifier>
                    <xsl:choose>
                        <xsl:when test="datacite_cmd:isDOI(relatedItemIdentifier/text())">
                            <xsl:value-of
                                select="datacite_cmd:normalize_doi(relatedItemIdentifier/text())"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="relatedItemIdentifier/text()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </identifier>
            </xsl:if>

            <!-- label -->
            <xsl:choose>
                <xsl:when test="titles/title[not(@titleType)]">
                    <xsl:for-each select="titles/title[not(@titleType)]">
                        <label>
                            <xsl:copy-of select="@xml:lang"/>
                            <xsl:value-of select="."/>
                        </label>
                    </xsl:for-each>
                </xsl:when>
            </xsl:choose>
            <xsl:if test="(relatedItemIdentifier/text() castable as xs:anyURI)">
                <location>
                    <xsl:value-of select="relatedItemIdentifier/text()"/>
                </location>
            </xsl:if>

            <!-- TitleInfo -->
            <xsl:apply-templates select="titles" mode="TitleInfo"/>

            <!-- ResourceType -->
            <xsl:if test="@relatedItemType">
                <ResourceType>
                    <xsl:apply-templates select="@relatedItemType" mode="ResourceType.identifier"/>
                    <label>
                        <xsl:value-of select="@relatedItemType"/>
                    </label>
                </ResourceType>
            </xsl:if>

            <!-- CitationInfo -->
            <xsl:apply-templates select="." mode="RelatedResource.CitationInfo"/>

            <!-- Creator -->
            <xsl:apply-templates select="creators/creator" mode="Creator"/>

            <!-- Contributor -->
            <xsl:apply-templates select="contributors/contributor" mode="Contributor"/>
        </RelatedResource>
    </xsl:template>

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
