<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.clarin.eu/cmd/1/profiles/clarin.eu:cr1:p_1610707853541"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:cmd="http://www.clarin.eu/cmd/1"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:datacite_cmd="http://www.clarin.eu/cmd/conversion/ddi/cmd"
    xsi:schemaLocation="http://datacite.org/schema/kernel-4 http://schema.datacite.org/meta/kernel-4/metadata.xsd"
    xpath-default-namespace="http://datacite.org/schema/kernel-4" exclude-result-prefixes="xs"
    version="2.0">

    <xsl:output indent="yes"/>

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
    
    <xsl:template match="/resource/resourceType" mode="ResourceType">
        <ResourceType>
            <!-- 
                TODO: identifier for DataCite resource type vocab items??
                
                See https://sparontologies.github.io/datacite/current/datacite.html
                    and https://databus.dbpedia.org/ontologies/purl.org/spar%2D%2Ddatacite
                    
                The 'dcmitype' ontology is supported/recommended. See https://dublincore.org/specifications/dublin-core/dcmi-terms/#section-7
            
            -->
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
        
        <VersionInfo>
            <versionIdentifier>versionIdentifier0</versionIdentifier>
            <responsible>responsible0</responsible>
            <responsible>responsible1</responsible>
            <note xml:lang="en-US">note0</note>
            <note xml:lang="en-US">note1</note>
            <Description>
                <description xml:lang="en-US">description2</description>
                <description xml:lang="en-US">description3</description>
            </Description>
            <Description>
                <description xml:lang="en-US">description4</description>
                <description xml:lang="en-US">description5</description>
            </Description>
            <Responsible>
                <identifier>identifier0</identifier>
                <identifier>identifier1</identifier>
                <label xml:lang="en-US">label2</label>
                <label xml:lang="en-US">label3</label>
                <AgentInfo> </AgentInfo>
            </Responsible>
            <Responsible>
                <identifier>identifier2</identifier>
                <identifier>identifier3</identifier>
                <label xml:lang="en-US">label4</label>
                <label xml:lang="en-US">label5</label>
                <AgentInfo> </AgentInfo>
            </Responsible>
        </VersionInfo>
        <Language>
            <name xml:lang="en-US">name0</name>
            <name xml:lang="en-US">name1</name>
            <code cmd:ValueConceptLink="http://www.oxygenxml.com/">code0</code>
        </Language>
        <Creator>
            <identifier>http://www.oxygenxml.com/</identifier>
            <identifier>http://www.oxygenxml.com/</identifier>
            <label xml:lang="en-US">label6</label>
            <label xml:lang="en-US">label7</label>
            <role>role0</role>
            <role>role1</role>
            <AgentInfo>
                <PersonInfo>
                    <name>name2</name>
                </PersonInfo>
                <OrganisationInfo>
                    <name xml:lang="en-US">name3</name>
                    <name xml:lang="en-US">name4</name>
                </OrganisationInfo>
            </AgentInfo>
        </Creator>
        <Contributor>
            <identifier>http://www.oxygenxml.com/</identifier>
            <identifier>http://www.oxygenxml.com/</identifier>
            <label xml:lang="en-US">label8</label>
            <label xml:lang="en-US">label9</label>
            <role>role2</role>
            <role>role3</role>
            <AgentInfo>
                <PersonInfo>
                    <name>name5</name>
                </PersonInfo>
                <OrganisationInfo>
                    <name xml:lang="en-US">name6</name>
                    <name xml:lang="en-US">name7</name>
                </OrganisationInfo>
            </AgentInfo>
        </Contributor>
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

</xsl:stylesheet>
