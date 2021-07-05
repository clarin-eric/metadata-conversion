<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.clarin.eu/cmd/1/profiles/clarin.eu:cr1:p_1610707853541"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:cmd="http://www.clarin.eu/cmd/1"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:datacite_cmd="http://www.clarin.eu/cmd/conversion/ddi/cmd"
    xsi:schemaLocation="http://datacite.org/schema/kernel-4 http://schema.datacite.org/meta/kernel-4/metadata.xsd"
    xpath-default-namespace="http://datacite.org/schema/kernel-4" exclude-result-prefixes="xs"
    version="2.0">

    <xsl:output indent="yes"/>

    <xsl:variable name="resourceTypeUris">
        <datacite_cmd:entry key="Collection">http://purl.org/dc/dcmitype/Collection</datacite_cmd:entry>
        <datacite_cmd:entry key="Dataset">http://purl.org/dc/dcmitype/Dataset</datacite_cmd:entry>
        <datacite_cmd:entry key="Event">http://purl.org/dc/dcmitype/Event</datacite_cmd:entry>
        <datacite_cmd:entry key="Image">http://purl.org/dc/dcmitype/Image</datacite_cmd:entry>
        <datacite_cmd:entry key="InteractiveResource">http://purl.org/dc/dcmitype/InteractiveResource</datacite_cmd:entry>
        <datacite_cmd:entry key="MovingImage">http://purl.org/dc/dcmitype/MovingImage</datacite_cmd:entry>
        <datacite_cmd:entry key="PhysicalObject">http://purl.org/dc/dcmitype/PhysicalObject</datacite_cmd:entry>
        <datacite_cmd:entry key="Service">http://purl.org/dc/dcmitype/Service</datacite_cmd:entry>
        <datacite_cmd:entry key="Software">http://purl.org/dc/dcmitype/Software</datacite_cmd:entry>
        <datacite_cmd:entry key="Sound">http://purl.org/dc/dcmitype/Sound</datacite_cmd:entry>
        <datacite_cmd:entry key="StillImage">http://purl.org/dc/dcmitype/StillImage</datacite_cmd:entry>
        <datacite_cmd:entry key="Text">http://purl.org/dc/dcmitype/Text</datacite_cmd:entry>
    </xsl:variable>

    <xsl:template match="identifier[@identifierType = 'DOI']" mode="ResourceProxy">
        <cmd:ResourceProxy id="ID001">
            <cmd:ResourceType>Resource</cmd:ResourceType>
            <cmd:ResourceRef>
                <xsl:choose>
                    <xsl:when test="datacite_cmd:isDOI(text())">
                        <xsl:sequence select="datacite_cmd:normalize_doi(text())"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="datacite_cmd:normalize_doi(concat('https://doi.org/', text()))"/>
                    </xsl:otherwise>
                </xsl:choose>
            </cmd:ResourceRef>
        </cmd:ResourceProxy>
    </xsl:template>

    <xsl:template match="/resource">
        <cmd:CMD CMDVersion="1.2"
            
            xsi:schemaLocation="http://www.clarin.eu/cmd/1 https://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/1.x/profiles/clarin.eu:cr1:p_1610707853541/xsd">
            <xsl:call-template name="header-section"/>
            <xsl:call-template name="resource-section"/>
            <cmd:Components>
                <DataCiteRecord>
                    <xsl:call-template name="component-section" />
                </DataCiteRecord>
            </cmd:Components>
        </cmd:CMD>
    </xsl:template>
    
    <!-- Header section -->
    
    <xsl:template name="header-section">
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
    
    <xsl:template name="resource-section">
        <cmd:Resources>
            <cmd:ResourceProxyList>
                <xsl:apply-templates select="identifier" mode="ResourceProxy"/>
            </cmd:ResourceProxyList>
            <cmd:JournalFileProxyList/>
            <cmd:ResourceRelationList/>
        </cmd:Resources>
        <cmd:IsPartOfList/>
    </xsl:template>
    
    <!-- Component section -->
    
    <xsl:template match="/resource/identifier" mode="IdentificationInfo.identifier">
        <xsl:element name="identifier">
            <xsl:choose>
                <xsl:when test="normalize-space(@identifierType|@alternateIdentifierType)='DOI'">
                    <xsl:attribute name="type">DOI</xsl:attribute>
                    <xsl:sequence select="datacite_cmd:normalize_doi(text())"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="@identifierType|@alternateIdentifierType" mode="identifier.type" />
                    <xsl:sequence select="text()" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="/resource/alternateIdentifiers/alternateIdentifier" mode="IdentificationInfo.alternativeIdentifier">
        <xsl:element name="alternativeIdentifier">
            <xsl:choose>
                <xsl:when test="normalize-space(@identifierType|@alternateIdentifierType)='DOI'">
                    <xsl:attribute name="type">DOI</xsl:attribute>
                    <xsl:sequence select="datacite_cmd:normalize_doi(text())"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="@identifierType|@alternateIdentifierType" mode="identifier.type" />
                    <xsl:sequence select="text()" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="@identifierType" mode="identifier.type">
        <xsl:choose>
            <xsl:when test="normalize-space(.)='DOI'">
                <xsl:attribute name="type">DOI</xsl:attribute>
            </xsl:when>
            <!-- TOOD: other supported identifier types -->
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="/resource/titles/title" mode="TitleInfo.title">
        <xsl:variable name="elementName">
           <xsl:choose>
               <xsl:when test="normalize-space(@titleType)=''">
                   <xsl:sequence select="'title'" />
               </xsl:when>
               <xsl:when test="@titleType='Subtitle'">
                   <xsl:sequence select="'subtitle'" />
               </xsl:when>
               <xsl:otherwise>
                   <xsl:sequence select="'alternativeTitle'" />
               </xsl:otherwise>
           </xsl:choose>
        </xsl:variable>
        <xsl:element name="{$elementName}">
            <xsl:copy-of select="@xml:lang" />
            <xsl:sequence select="text()"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="/resource/descriptions/description" mode="Description.description">
        <description>
            <xsl:copy-of select="@xml:lang" />
            <xsl:sequence select="text()" />
        </description>
    </xsl:template>

    <xsl:template match="resourceType/@resourceTypeGeneral" mode="ResourceType.identifier">
        <!-- 
                The 'dcmitype' ontology is supported/recommended. See https://dublincore.org/specifications/dublin-core/dcmi-terms/#section-7. 
                See https://sparontologies.github.io/datacite/current/datacite.html and https://databus.dbpedia.org/ontologies/purl.org/spar%2D%2Ddatacite        
        -->
        
        <xsl:variable name="resourceTypeGeneral" select="string(.)" />
        
        <xsl:variable name="resourceTypeUri" select="$resourceTypeUris/datacite_cmd:entry[@key=$resourceTypeGeneral]" />
        
        <xsl:if test="normalize-space($resourceTypeUri) != ''">
            <identifier><xsl:value-of select="$resourceTypeUri"/></identifier>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="/resource/resourceType" mode="ResourceType">
        <ResourceType>
            
            <!-- Identifier from @resourceTypeGeneral attribute -->
            <xsl:apply-templates select="@resourceTypeGeneral" mode="ResourceType.identifier" />
            
            <!-- Label from @resourceTypeGeneral attribute -->
            <xsl:if test="@resourceTypeGeneral">
                <label><xsl:value-of select="@resourceTypeGeneral" /></label>
            </xsl:if>
            
            <!-- Label from free-text node content -->
            <xsl:if test="normalize-space(text()) != ''">
                <!-- Do not duplicate value from @resourceTypeGeneral -->
                <xsl:if test="normalize-space(text()) != normalize-space(@resourceTypeGeneral)">
                    <label><xsl:sequence select="text()" /></label>
                </xsl:if>
            </xsl:if>
        </ResourceType>
    </xsl:template>
    
    <xsl:template match="/resource/version" mode="VersionInfo">
        <VersionInfo>
            <versionIdentifier><xsl:sequence select="text()" /></versionIdentifier>
        </VersionInfo>
    </xsl:template>

    <xsl:template match="/resource/language[1]"  mode="Language">
        <!-- TODO: convert to ISO-639-3 -->
        <xsl:variable name="iso639-3-code" select="datacite_cmd:toISO693-3(text())"/>
        
        <Language>
            <name>
                <!-- TODO: language name from vocab -->
                <xsl:sequence select="$iso639-3-code" />
            </name>
            <code>
                <!-- TODO: @cmd:ValueConceptLink="..." --> 
                <xsl:sequence select="$iso639-3-code" />
            </code>
        </Language>
    </xsl:template>
    
    <xsl:template match="creator|contributor" mode="AgentInfo">
        <xsl:variable name="nameElement" select="(contributorName|creatorName)[1]"/>
        
        <AgentInfo>
            <xsl:choose>
                <xsl:when test="$nameElement/@nameType = 'Organizational'">
                    <OrganisationInfo>
                        <name>
                            <xsl:copy-of select="@xml:lang" />
                            <xsl:sequence select="$nameElement/text()" />
                        </name>
                        <xsl:for-each select="affiliation">
                            <affiliation><xsl:sequence select="text()" /></affiliation>
                        </xsl:for-each>
                    </OrganisationInfo>
                </xsl:when>
                <xsl:otherwise>
                    <PersonInfo>
                        <name>
                            <xsl:copy-of select="@xml:lang" />
                            <xsl:sequence select="$nameElement/text()" />
                        </name>
                        <xsl:for-each select="givenName | familyName">
                            <alternativeName>
                                <xsl:copy-of select="@xml:lang" />
                                <xsl:attribute name="type"><xsl:value-of select="name()"/></xsl:attribute>
                                <xsl:sequence select="text()" />
                            </alternativeName>
                        </xsl:for-each>
                        <xsl:for-each select="affiliation">
                            <affiliation><xsl:sequence select="text()" /></affiliation>
                        </xsl:for-each>
                    </PersonInfo>                        
                </xsl:otherwise>
            </xsl:choose>
        </AgentInfo>
    </xsl:template>
    
    <xsl:template match="nameIdentifier" mode="CreatorContributor.identifier">
        <identifier>
            <!-- TODO: specify scheme in attribute (to be added to component) -->
            <xsl:sequence select="text()" />
        </identifier>
    </xsl:template>
    
    <xsl:template match="creator" mode="Creator">
        <Creator>
            <xsl:apply-templates select="nameIdentifier" mode="CreatorContributor.identifier" />
            <label>
                <xsl:copy-of select="@xml:lang" />
                <xsl:sequence select="creatorName/text()" />
            </label>
            <xsl:apply-templates select="." mode="AgentInfo" />
        </Creator>
    </xsl:template>
    
    <xsl:template match="contributor" mode="Contributor">
        <Contributor>
            <xsl:apply-templates select="nameIdentifier" mode="CreatorContributor.identifier" />
            <label>
                <xsl:copy-of select="@xml:lang" />
                <xsl:sequence select="contributorName/text()" />
            </label>
            <xsl:for-each select="@contributorType">
                <role><xsl:sequence select="string()" /></role>
            </xsl:for-each>
            <xsl:apply-templates select="." mode="AgentInfo" />
        </Contributor>
    </xsl:template>

    <xsl:template name="component-section">
        <!-- IdentificationInfo -->

        <xsl:call-template name="wrapper-component">
            <xsl:with-param name="name" select="'IdentificationInfo'" />
            <xsl:with-param name="content">
                <xsl:apply-templates select="./identifier" mode="IdentificationInfo.identifier" />
                <xsl:apply-templates select="./alternateIdentifiers/alternateIdentifier" mode="IdentificationInfo.alternativeIdentifier" />
            </xsl:with-param>
        </xsl:call-template>
        
        <!-- TitleInfo -->
        
        <xsl:call-template name="wrapper-component">
            <xsl:with-param name="name" select="'TitleInfo'" />
            <xsl:with-param name="content">
                <!-- main title -->
                <xsl:apply-templates select="./titles/title[not(@titleType)]" mode="TitleInfo.title" />
                <!-- alternative title -->
                <xsl:apply-templates select="./titles/title[@titleType='AlternativeTitle' or @titleType='TranslatedTitle'  or @titleType='Other']" mode="TitleInfo.title" />
                <!-- subtitle -->
                <xsl:apply-templates select="./titles/title[@titleType='Subtitle']" mode="TitleInfo.title" />
            </xsl:with-param>
        </xsl:call-template>
        
        <!-- Description -->
        
        <xsl:call-template name="wrapper-component">
            <xsl:with-param name="name" select="'Description'" />
            <xsl:with-param name="content">
                <xsl:apply-templates select="/resource/descriptions/description" mode="Description.description"/>
            </xsl:with-param>
        </xsl:call-template>
        
        <!-- Resource type -->
        <xsl:apply-templates select="/resource/resourceType" mode="ResourceType" />
        
        <!-- Version info -->
        <xsl:apply-templates select="/resource/version[1]"  mode="VersionInfo" />        

        <!-- Language -->
        <xsl:apply-templates select="/resource/language[1]"  mode="Language" />        
        
        <!-- Creator -->
        <xsl:apply-templates select="/resource/creators/creator" mode="Creator" />

        <!-- Contributor -->
        <xsl:apply-templates select="/resource/contributors/contributor" mode="Contributor" />
        
        <ProvenanceInfo>
            <Creation>
                <ActivityInfo>
                    <When> </When>
                </ActivityInfo>
                <ActivityInfo>
                    <When> </When>
                </ActivityInfo>
            </Creation>
            <Collection>
                <ActivityInfo>
                    <When> </When>
                </ActivityInfo>
                <ActivityInfo>
                    <When> </When>
                </ActivityInfo>
            </Collection>
            <Publication>
                <ActivityInfo>
                    <When> </When>
                </ActivityInfo>
                <ActivityInfo>
                    <When> </When>
                </ActivityInfo>
            </Publication>
            <Activity>
                <identifier>http://www.oxygenxml.com/</identifier>
                <identifier>http://www.oxygenxml.com/</identifier>
                <label xml:lang="en-US">label10</label>
                <label xml:lang="en-US">label11</label>
                <note xml:lang="en-US">note2</note>
                <note xml:lang="en-US">note3</note>
                <ActivityInfo>
                    <When> </When>
                </ActivityInfo>
                <ActivityInfo>
                    <When> </When>
                </ActivityInfo>
            </Activity>
            <Activity>
                <identifier>http://www.oxygenxml.com/</identifier>
                <identifier>http://www.oxygenxml.com/</identifier>
                <label xml:lang="en-US">label12</label>
                <label xml:lang="en-US">label13</label>
                <note xml:lang="en-US">note4</note>
                <note xml:lang="en-US">note5</note>
                <ActivityInfo>
                    <When> </When>
                </ActivityInfo>
                <ActivityInfo>
                    <When> </When>
                </ActivityInfo>
            </Activity>
        </ProvenanceInfo>
        <Subresource>
            <SubresourceDescription>
                <label xml:lang="en-US">label14</label>
                <label xml:lang="en-US">label15</label>
                <description xml:lang="en-US">description6</description>
                <description xml:lang="en-US">description7</description>
                <bibliographicCitation>bibliographicCitation0</bibliographicCitation>
                <IdentificationInfo>
                    <identifier type="DOI">http://www.oxygenxml.com/</identifier>
                    <identifier type="DOI">http://www.oxygenxml.com/</identifier>
                </IdentificationInfo>
                <Language>
                    <name xml:lang="en-US">name8</name>
                    <name xml:lang="en-US">name9</name>
                    <code cmd:ValueConceptLink="http://www.oxygenxml.com/">code1</code>
                </Language>
                <Language>
                    <name xml:lang="en-US">name10</name>
                    <name xml:lang="en-US">name11</name>
                    <code cmd:ValueConceptLink="http://www.oxygenxml.com/">code2</code>
                </Language>
                <VersionInfo> </VersionInfo>
            </SubresourceDescription>
            <SubresourceTechnicalInfo>
                <type>type0</type>
                <type>type1</type>
                <mediaType>mediaType0</mediaType>
                <size SizeUnit="byte">0</size>
                <checksum scheme="scheme1">checksum0</checksum>
                <checksum scheme="scheme3">checksum1</checksum>
            </SubresourceTechnicalInfo>
            <AccessInfo>
                <accessRights>openAccess</accessRights>
                <accessRequirement>authenticationRequired</accessRequirement>
                <accessRequirement>authenticationRequired</accessRequirement>
                <condition xml:lang="en-US">condition0</condition>
                <condition xml:lang="en-US">condition1</condition>
                <disclaimer xml:lang="en-US">disclaimer0</disclaimer>
                <disclaimer xml:lang="en-US">disclaimer1</disclaimer>
                <otherAccessInfo type="type17" xml:lang="en-US">otherAccessInfo0</otherAccessInfo>
                <otherAccessInfo type="type19" xml:lang="en-US">otherAccessInfo1</otherAccessInfo>
                <Licence>
                    <label xml:lang="en-US">label16</label>
                    <label xml:lang="en-US">label17</label>
                </Licence>
                <Licence>
                    <label xml:lang="en-US">label18</label>
                    <label xml:lang="en-US">label19</label>
                </Licence>
                <IntellectualPropertyRightsHolder> </IntellectualPropertyRightsHolder>
                <IntellectualPropertyRightsHolder> </IntellectualPropertyRightsHolder>
                <Contact>
                    <AgentInfo> </AgentInfo>
                </Contact>
                <Contact>
                    <AgentInfo> </AgentInfo>
                </Contact>
            </AccessInfo>
        </Subresource>
        <AccessInfo>
            <accessRights>openAccess</accessRights>
            <accessRequirement>authenticationRequired</accessRequirement>
            <accessRequirement>authenticationRequired</accessRequirement>
            <condition xml:lang="en-US">condition2</condition>
            <condition xml:lang="en-US">condition3</condition>
            <disclaimer xml:lang="en-US">disclaimer2</disclaimer>
            <disclaimer xml:lang="en-US">disclaimer3</disclaimer>
            <otherAccessInfo type="type21" xml:lang="en-US">otherAccessInfo2</otherAccessInfo>
            <otherAccessInfo type="type23" xml:lang="en-US">otherAccessInfo3</otherAccessInfo>
            <Licence>
                <identifier>identifier4</identifier>
                <identifier>identifier5</identifier>
                <label xml:lang="en-US">label20</label>
                <label xml:lang="en-US">label21</label>
                <url>http://www.oxygenxml.com/</url>
                <Description>
                    <description xml:lang="en-US">description8</description>
                    <description xml:lang="en-US">description9</description>
                </Description>
                <Description>
                    <description xml:lang="en-US">description10</description>
                    <description xml:lang="en-US">description11</description>
                </Description>
            </Licence>
            <Licence>
                <identifier>identifier6</identifier>
                <identifier>identifier7</identifier>
                <label xml:lang="en-US">label22</label>
                <label xml:lang="en-US">label23</label>
                <url>http://www.oxygenxml.com/</url>
                <Description>
                    <description xml:lang="en-US">description12</description>
                    <description xml:lang="en-US">description13</description>
                </Description>
                <Description>
                    <description xml:lang="en-US">description14</description>
                    <description xml:lang="en-US">description15</description>
                </Description>
            </Licence>
            <IntellectualPropertyRightsHolder>
                <identifier>http://www.oxygenxml.com/</identifier>
                <identifier>http://www.oxygenxml.com/</identifier>
                <label xml:lang="en-US">label24</label>
                <label xml:lang="en-US">label25</label>
                <AgentInfo> </AgentInfo>
            </IntellectualPropertyRightsHolder>
            <IntellectualPropertyRightsHolder>
                <identifier>http://www.oxygenxml.com/</identifier>
                <identifier>http://www.oxygenxml.com/</identifier>
                <label xml:lang="en-US">label26</label>
                <label xml:lang="en-US">label27</label>
                <AgentInfo> </AgentInfo>
            </IntellectualPropertyRightsHolder>
            <Contact>
                <identifier>http://www.oxygenxml.com/</identifier>
                <identifier>http://www.oxygenxml.com/</identifier>
                <label xml:lang="en-US">label28</label>
                <label xml:lang="en-US">label29</label>
                <Description>
                    <description xml:lang="en-US">description16</description>
                    <description xml:lang="en-US">description17</description>
                </Description>
                <AgentInfo> </AgentInfo>
            </Contact>
            <Contact>
                <identifier>http://www.oxygenxml.com/</identifier>
                <identifier>http://www.oxygenxml.com/</identifier>
                <label xml:lang="en-US">label30</label>
                <label xml:lang="en-US">label31</label>
                <Description>
                    <description xml:lang="en-US">description18</description>
                    <description xml:lang="en-US">description19</description>
                </Description>
                <AgentInfo> </AgentInfo>
            </Contact>
        </AccessInfo>
        <GeoLocation>
            <identifier>http://www.oxygenxml.com/</identifier>
            <identifier>http://www.oxygenxml.com/</identifier>
            <label xml:lang="en-US">label32</label>
            <label xml:lang="en-US">label33</label>
            <description xml:lang="en-US">description20</description>
            <description xml:lang="en-US">description21</description>
            <Country>
                <code>AD</code>
                <label xml:lang="en-US">label34</label>
                <label xml:lang="en-US">label35</label>
            </Country>
            <GeographicCoordinates>
                <latitude>0</latitude>
                <longitude>0</longitude>
                <elevation>0</elevation>
            </GeographicCoordinates>
        </GeoLocation>
        <FundingInfo>
            <Funding>
                <grantNumber>grantNumber0</grantNumber>
                <label xml:lang="en-US">label36</label>
                <label xml:lang="en-US">label37</label>
                <FundingAgency>
                    <label xml:lang="en-US">label38</label>
                    <label xml:lang="en-US">label39</label>
                </FundingAgency>
                <ActivityInfo>
                    <When> </When>
                </ActivityInfo>
                <ActivityInfo>
                    <When> </When>
                </ActivityInfo>
            </Funding>
            <Funding>
                <grantNumber>grantNumber1</grantNumber>
                <label xml:lang="en-US">label40</label>
                <label xml:lang="en-US">label41</label>
                <FundingAgency>
                    <label xml:lang="en-US">label42</label>
                    <label xml:lang="en-US">label43</label>
                </FundingAgency>
                <ActivityInfo>
                    <When> </When>
                </ActivityInfo>
                <ActivityInfo>
                    <When> </When>
                </ActivityInfo>
            </Funding>
        </FundingInfo>
        <RelatedResource>
            <identifier>http://www.oxygenxml.com/</identifier>
            <identifier>http://www.oxygenxml.com/</identifier>
            <label xml:lang="en-US">label44</label>
            <label xml:lang="en-US">label45</label>
            <location>http://www.oxygenxml.com/</location>
            <location>http://www.oxygenxml.com/</location>
            <TitleInfo>
                <title xml:lang="en-US">title2</title>
                <title xml:lang="en-US">title3</title>
                <alternativeTitle xml:lang="en-US">alternativeTitle2</alternativeTitle>
                <alternativeTitle xml:lang="en-US">alternativeTitle3</alternativeTitle>
                <subtitle xml:lang="en-US">subtitle2</subtitle>
                <subtitle xml:lang="en-US">subtitle3</subtitle>
            </TitleInfo>
            <TitleInfo>
                <title xml:lang="en-US">title4</title>
                <title xml:lang="en-US">title5</title>
                <alternativeTitle xml:lang="en-US">alternativeTitle4</alternativeTitle>
                <alternativeTitle xml:lang="en-US">alternativeTitle5</alternativeTitle>
                <subtitle xml:lang="en-US">subtitle4</subtitle>
                <subtitle xml:lang="en-US">subtitle5</subtitle>
            </TitleInfo>
            <Description>
                <description xml:lang="en-US">description22</description>
                <description xml:lang="en-US">description23</description>
            </Description>
            <Description>
                <description xml:lang="en-US">description24</description>
                <description xml:lang="en-US">description25</description>
            </Description>
            <ResourceType>
                <identifier>http://www.oxygenxml.com/</identifier>
                <identifier>http://www.oxygenxml.com/</identifier>
                <label xml:lang="en-US">label46</label>
                <label xml:lang="en-US">label47</label>
            </ResourceType>
            <ResourceType>
                <identifier>http://www.oxygenxml.com/</identifier>
                <identifier>http://www.oxygenxml.com/</identifier>
                <label xml:lang="en-US">label48</label>
                <label xml:lang="en-US">label49</label>
            </ResourceType>
            <CitationInfo>
                <bibliographicCitation format="format1"
                    >bibliographicCitation1</bibliographicCitation>
                <bibliographicCitation format="format3"
                    >bibliographicCitation2</bibliographicCitation>
            </CitationInfo>
            <Creator>
                <identifier>http://www.oxygenxml.com/</identifier>
                <identifier>http://www.oxygenxml.com/</identifier>
                <label xml:lang="en-US">label50</label>
                <label xml:lang="en-US">label51</label>
                <role>role4</role>
                <role>role5</role>
                <AgentInfo> </AgentInfo>
            </Creator>
            <Creator>
                <identifier>http://www.oxygenxml.com/</identifier>
                <identifier>http://www.oxygenxml.com/</identifier>
                <label xml:lang="en-US">label52</label>
                <label xml:lang="en-US">label53</label>
                <role>role6</role>
                <role>role7</role>
                <AgentInfo> </AgentInfo>
            </Creator>
            <Contributor>
                <identifier>http://www.oxygenxml.com/</identifier>
                <identifier>http://www.oxygenxml.com/</identifier>
                <label xml:lang="en-US">label54</label>
                <label xml:lang="en-US">label55</label>
                <role>role8</role>
                <role>role9</role>
                <AgentInfo> </AgentInfo>
            </Contributor>
            <Contributor>
                <identifier>http://www.oxygenxml.com/</identifier>
                <identifier>http://www.oxygenxml.com/</identifier>
                <label xml:lang="en-US">label56</label>
                <label xml:lang="en-US">label57</label>
                <role>role10</role>
                <role>role11</role>
                <AgentInfo> </AgentInfo>
            </Contributor>
        </RelatedResource>
    </xsl:template>
    
    <xsl:template name="wrapper-component">
        <xsl:param name="name" />
        <xsl:param name="content" />
        <xsl:if test="count($content/*) > 0">
            <xsl:element name="{$name}">
                <xsl:sequence select="$content" />
            </xsl:element>
        </xsl:if>
    </xsl:template>
    
    <xsl:function name="datacite_cmd:isDOI" as="xs:boolean">
        <xsl:param name="uri" required="yes"/>
        <xsl:sequence select="contains($uri, 'doi.org/')"/>
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
                <xsl:sequence select="$code" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="no">WARNING: language code is NOT a valid ISO-639-3 code: '<xsl:value-of select="$code"/>'</xsl:message>
                <xsl:sequence select="$code" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>
