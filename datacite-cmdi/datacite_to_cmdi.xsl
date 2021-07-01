<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:cmd="http://www.clarin.eu/cmd/1"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:datacite_cmd="http://www.clarin.eu/cmd/conversion/ddi/cmd"
    xsi:schemaLocation="http://datacite.org/schema/kernel-4 http://schema.datacite.org/meta/kernel-4/metadata.xsd"
    xpath-default-namespace="http://datacite.org/schema/kernel-4"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output indent="yes" />
    
    <xsl:template match="identifier[@identifierType='DOI']" mode="ResourceProxy">
        <cmd:ResourceProxy id="ID001">
            <cmd:ResourceType>Resource</cmd:ResourceType>
            <cmd:ResourceRef>
             <xsl:choose>
                 <xsl:when test="datacite_cmd:isDOI(text())">
                     <xsl:sequence select="datacite_cmd:normalize_doi(text())" />
                 </xsl:when>
                 <xsl:otherwise>
                     <xsl:sequence select="datacite_cmd:normalize_doi(concat('https://doi.org/', text()))"/>
                 </xsl:otherwise>
             </xsl:choose>
            </cmd:ResourceRef>
        </cmd:ResourceProxy>
    </xsl:template>
    
    <xsl:template match="/resource">
            <cmd:CMD 
                CMDVersion="1.2"
                xmlns="http://www.clarin.eu/cmd/1/profiles/clarin.eu:cr1:p_1610707853541"
                xsi:schemaLocation="http://www.clarin.eu/cmd/1 https://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/1.x/profiles/clarin.eu:cr1:p_1610707853541/xsd">
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
            <cmd:Resources>
                <cmd:ResourceProxyList>
                    <xsl:apply-templates select="identifier" mode="ResourceProxy" />
                </cmd:ResourceProxyList>
                <cmd:JournalFileProxyList/>
                <cmd:ResourceRelationList/>
            </cmd:Resources>
            <cmd:IsPartOfList/>
            <cmd:Components>
                <DataCiteRecord xml:base="http://www.oxygenxml.com/" >
                    <IdentificationInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762421">
                        <identifier type="DOI">http://www.oxygenxml.com/</identifier>
                        <identifier type="DOI">http://www.oxygenxml.com/</identifier>
                        <internalIdentifier type="type5">internalIdentifier0</internalIdentifier>
                        <internalIdentifier type="type7">internalIdentifier1</internalIdentifier>
                        <alternativeIdentifier type="type9">alternativeIdentifier0</alternativeIdentifier>
                        <alternativeIdentifier type="type11">alternativeIdentifier1</alternativeIdentifier>
                    </IdentificationInfo>
                    <TitleInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762412">
                        <title xml:lang="en-US">title0</title>
                        <title xml:lang="en-US">title1</title>
                        <alternativeTitle xml:lang="en-US">alternativeTitle0</alternativeTitle>
                        <alternativeTitle xml:lang="en-US">alternativeTitle1</alternativeTitle>
                        <subtitle xml:lang="en-US">subtitle0</subtitle>
                        <subtitle xml:lang="en-US">subtitle1</subtitle>
                    </TitleInfo>
                    <Description xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762411">
                        <description xml:lang="en-US">description0</description>
                        <description xml:lang="en-US">description1</description>
                    </Description>
                    <ResourceType xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762403">
                        <identifier>http://www.oxygenxml.com/</identifier>
                        <identifier>http://www.oxygenxml.com/</identifier>
                        <label xml:lang="en-US">label0</label>
                        <label xml:lang="en-US">label1</label>
                    </ResourceType>
                    <VersionInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762424">
                        <versionIdentifier>versionIdentifier0</versionIdentifier>
                        <responsible>responsible0</responsible>
                        <responsible>responsible1</responsible>
                        <note xml:lang="en-US">note0</note>
                        <note xml:lang="en-US">note1</note>
                        <Description xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762411">
                            <description xml:lang="en-US">description2</description>
                            <description xml:lang="en-US">description3</description>
                        </Description>
                        <Description xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762411">
                            <description xml:lang="en-US">description4</description>
                            <description xml:lang="en-US">description5</description>
                        </Description>
                        <Responsible xml:base="http://www.oxygenxml.com/" >
                            <identifier>identifier0</identifier>
                            <identifier>identifier1</identifier>
                            <label xml:lang="en-US">label2</label>
                            <label xml:lang="en-US">label3</label>
                            <AgentInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762451">
                            </AgentInfo>
                        </Responsible>
                        <Responsible xml:base="http://www.oxygenxml.com/" >
                            <identifier>identifier2</identifier>
                            <identifier>identifier3</identifier>
                            <label xml:lang="en-US">label4</label>
                            <label xml:lang="en-US">label5</label>
                            <AgentInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762451">
                            </AgentInfo>
                        </Responsible>
                    </VersionInfo>
                    <Language xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762414">
                        <name xml:lang="en-US">name0</name>
                        <name xml:lang="en-US">name1</name>
                        <code cmd:ValueConceptLink="http://www.oxygenxml.com/">code0</code>
                    </Language>
                    <Creator xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762404">
                        <identifier>http://www.oxygenxml.com/</identifier>
                        <identifier>http://www.oxygenxml.com/</identifier>
                        <label xml:lang="en-US">label6</label>
                        <label xml:lang="en-US">label7</label>
                        <role>role0</role>
                        <role>role1</role>
                        <AgentInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762451">
                            <PersonInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762426">
                                <name>name2</name>
                            </PersonInfo>
                            <OrganisationInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762452">
                                <name xml:lang="en-US">name3</name>
                                <name xml:lang="en-US">name4</name>
                            </OrganisationInfo>
                        </AgentInfo>
                    </Creator>
                    <Contributor xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762453">
                        <identifier>http://www.oxygenxml.com/</identifier>
                        <identifier>http://www.oxygenxml.com/</identifier>
                        <label xml:lang="en-US">label8</label>
                        <label xml:lang="en-US">label9</label>
                        <role>role2</role>
                        <role>role3</role>
                        <AgentInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762451">
                            <PersonInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762426">
                                <name>name5</name>
                            </PersonInfo>
                            <OrganisationInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762452">
                                <name xml:lang="en-US">name6</name>
                                <name xml:lang="en-US">name7</name>
                            </OrganisationInfo>
                        </AgentInfo>
                    </Contributor>
                    <ProvenanceInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762423">
                        <Creation xml:base="http://www.oxygenxml.com/" >
                            <ActivityInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762422">
                                <When xml:base="http://www.oxygenxml.com/" >
                                </When>
                            </ActivityInfo>
                            <ActivityInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762422">
                                <When xml:base="http://www.oxygenxml.com/" >
                                </When>
                            </ActivityInfo>
                        </Creation>
                        <Collection xml:base="http://www.oxygenxml.com/" >
                            <ActivityInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762422">
                                <When xml:base="http://www.oxygenxml.com/" >
                                </When>
                            </ActivityInfo>
                            <ActivityInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762422">
                                <When xml:base="http://www.oxygenxml.com/" >
                                </When>
                            </ActivityInfo>
                        </Collection>
                        <Publication xml:base="http://www.oxygenxml.com/" >
                            <ActivityInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762422">
                                <When xml:base="http://www.oxygenxml.com/" >
                                </When>
                            </ActivityInfo>
                            <ActivityInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762422">
                                <When xml:base="http://www.oxygenxml.com/" >
                                </When>
                            </ActivityInfo>
                        </Publication>
                        <Activity xml:base="http://www.oxygenxml.com/" >
                            <identifier>http://www.oxygenxml.com/</identifier>
                            <identifier>http://www.oxygenxml.com/</identifier>
                            <label xml:lang="en-US">label10</label>
                            <label xml:lang="en-US">label11</label>
                            <note xml:lang="en-US">note2</note>
                            <note xml:lang="en-US">note3</note>
                            <ActivityInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762422">
                                <When xml:base="http://www.oxygenxml.com/" >
                                </When>
                            </ActivityInfo>
                            <ActivityInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762422">
                                <When xml:base="http://www.oxygenxml.com/" >
                                </When>
                            </ActivityInfo>
                        </Activity>
                        <Activity xml:base="http://www.oxygenxml.com/" >
                            <identifier>http://www.oxygenxml.com/</identifier>
                            <identifier>http://www.oxygenxml.com/</identifier>
                            <label xml:lang="en-US">label12</label>
                            <label xml:lang="en-US">label13</label>
                            <note xml:lang="en-US">note4</note>
                            <note xml:lang="en-US">note5</note>
                            <ActivityInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762422">
                                <When xml:base="http://www.oxygenxml.com/" >
                                </When>
                            </ActivityInfo>
                            <ActivityInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762422">
                                <When xml:base="http://www.oxygenxml.com/" >
                                </When>
                            </ActivityInfo>
                        </Activity>
                    </ProvenanceInfo>
                    <Subresource xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762415">
                        <SubresourceDescription xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762413">
                            <label xml:lang="en-US">label14</label>
                            <label xml:lang="en-US">label15</label>
                            <description xml:lang="en-US">description6</description>
                            <description xml:lang="en-US">description7</description>
                            <bibliographicCitation>bibliographicCitation0</bibliographicCitation>
                            <IdentificationInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762421">
                                <identifier type="DOI">http://www.oxygenxml.com/</identifier>
                                <identifier type="DOI">http://www.oxygenxml.com/</identifier>
                            </IdentificationInfo>
                            <Language xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762414">
                                <name xml:lang="en-US">name8</name>
                                <name xml:lang="en-US">name9</name>
                                <code cmd:ValueConceptLink="http://www.oxygenxml.com/">code1</code>
                            </Language>
                            <Language xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762414">
                                <name xml:lang="en-US">name10</name>
                                <name xml:lang="en-US">name11</name>
                                <code cmd:ValueConceptLink="http://www.oxygenxml.com/">code2</code>
                            </Language>
                            <VersionInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762424">
                            </VersionInfo>
                        </SubresourceDescription>
                        <SubresourceTechnicalInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762405">
                            <type>type0</type>
                            <type>type1</type>
                            <mediaType>mediaType0</mediaType>
                            <size SizeUnit="byte">0</size>
                            <checksum scheme="scheme1">checksum0</checksum>
                            <checksum scheme="scheme3">checksum1</checksum>
                        </SubresourceTechnicalInfo>
                        <AccessInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762454">
                            <accessRights>openAccess</accessRights>
                            <accessRequirement>authenticationRequired</accessRequirement>
                            <accessRequirement>authenticationRequired</accessRequirement>
                            <condition xml:lang="en-US">condition0</condition>
                            <condition xml:lang="en-US">condition1</condition>
                            <disclaimer xml:lang="en-US">disclaimer0</disclaimer>
                            <disclaimer xml:lang="en-US">disclaimer1</disclaimer>
                            <otherAccessInfo type="type17" xml:lang="en-US">otherAccessInfo0</otherAccessInfo>
                            <otherAccessInfo type="type19" xml:lang="en-US">otherAccessInfo1</otherAccessInfo>
                            <Licence xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762457">
                                <label xml:lang="en-US">label16</label>
                                <label xml:lang="en-US">label17</label>
                            </Licence>
                            <Licence xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762457">
                                <label xml:lang="en-US">label18</label>
                                <label xml:lang="en-US">label19</label>
                            </Licence>
                            <IntellectualPropertyRightsHolder xml:base="http://www.oxygenxml.com/" >
                            </IntellectualPropertyRightsHolder>
                            <IntellectualPropertyRightsHolder xml:base="http://www.oxygenxml.com/" >
                            </IntellectualPropertyRightsHolder>
                            <Contact xml:base="http://www.oxygenxml.com/" >
                                <AgentInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762451">
                                </AgentInfo>
                            </Contact>
                            <Contact xml:base="http://www.oxygenxml.com/" >
                                <AgentInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762451">
                                </AgentInfo>
                            </Contact>
                        </AccessInfo>
                    </Subresource>
                    <AccessInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762454">
                        <accessRights>openAccess</accessRights>
                        <accessRequirement>authenticationRequired</accessRequirement>
                        <accessRequirement>authenticationRequired</accessRequirement>
                        <condition xml:lang="en-US">condition2</condition>
                        <condition xml:lang="en-US">condition3</condition>
                        <disclaimer xml:lang="en-US">disclaimer2</disclaimer>
                        <disclaimer xml:lang="en-US">disclaimer3</disclaimer>
                        <otherAccessInfo type="type21" xml:lang="en-US">otherAccessInfo2</otherAccessInfo>
                        <otherAccessInfo type="type23" xml:lang="en-US">otherAccessInfo3</otherAccessInfo>
                        <Licence xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762457">
                            <identifier>identifier4</identifier>
                            <identifier>identifier5</identifier>
                            <label xml:lang="en-US">label20</label>
                            <label xml:lang="en-US">label21</label>
                            <url>http://www.oxygenxml.com/</url>
                            <Description xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762411">
                                <description xml:lang="en-US">description8</description>
                                <description xml:lang="en-US">description9</description>
                            </Description>
                            <Description xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762411">
                                <description xml:lang="en-US">description10</description>
                                <description xml:lang="en-US">description11</description>
                            </Description>
                        </Licence>
                        <Licence xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762457">
                            <identifier>identifier6</identifier>
                            <identifier>identifier7</identifier>
                            <label xml:lang="en-US">label22</label>
                            <label xml:lang="en-US">label23</label>
                            <url>http://www.oxygenxml.com/</url>
                            <Description xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762411">
                                <description xml:lang="en-US">description12</description>
                                <description xml:lang="en-US">description13</description>
                            </Description>
                            <Description xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762411">
                                <description xml:lang="en-US">description14</description>
                                <description xml:lang="en-US">description15</description>
                            </Description>
                        </Licence>
                        <IntellectualPropertyRightsHolder xml:base="http://www.oxygenxml.com/" >
                            <identifier>http://www.oxygenxml.com/</identifier>
                            <identifier>http://www.oxygenxml.com/</identifier>
                            <label xml:lang="en-US">label24</label>
                            <label xml:lang="en-US">label25</label>
                            <AgentInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762451">
                            </AgentInfo>
                        </IntellectualPropertyRightsHolder>
                        <IntellectualPropertyRightsHolder xml:base="http://www.oxygenxml.com/" >
                            <identifier>http://www.oxygenxml.com/</identifier>
                            <identifier>http://www.oxygenxml.com/</identifier>
                            <label xml:lang="en-US">label26</label>
                            <label xml:lang="en-US">label27</label>
                            <AgentInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762451">
                            </AgentInfo>
                        </IntellectualPropertyRightsHolder>
                        <Contact xml:base="http://www.oxygenxml.com/" >
                            <identifier>http://www.oxygenxml.com/</identifier>
                            <identifier>http://www.oxygenxml.com/</identifier>
                            <label xml:lang="en-US">label28</label>
                            <label xml:lang="en-US">label29</label>
                            <Description xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762411">
                                <description xml:lang="en-US">description16</description>
                                <description xml:lang="en-US">description17</description>
                            </Description>
                            <AgentInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762451">
                            </AgentInfo>
                        </Contact>
                        <Contact xml:base="http://www.oxygenxml.com/" >
                            <identifier>http://www.oxygenxml.com/</identifier>
                            <identifier>http://www.oxygenxml.com/</identifier>
                            <label xml:lang="en-US">label30</label>
                            <label xml:lang="en-US">label31</label>
                            <Description xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762411">
                                <description xml:lang="en-US">description18</description>
                                <description xml:lang="en-US">description19</description>
                            </Description>
                            <AgentInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762451">
                            </AgentInfo>
                        </Contact>
                    </AccessInfo>
                    <GeoLocation xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762418">
                        <identifier>http://www.oxygenxml.com/</identifier>
                        <identifier>http://www.oxygenxml.com/</identifier>
                        <label xml:lang="en-US">label32</label>
                        <label xml:lang="en-US">label33</label>
                        <description xml:lang="en-US">description20</description>
                        <description xml:lang="en-US">description21</description>
                        <Country xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762419">
                            <code>AD</code>
                            <label xml:lang="en-US">label34</label>
                            <label xml:lang="en-US">label35</label>
                        </Country>
                        <GeographicCoordinates xml:base="http://www.oxygenxml.com/" >
                            <latitude>0</latitude>
                            <longitude>0</longitude>
                            <elevation>0</elevation>
                        </GeographicCoordinates>
                    </GeoLocation>
                    <FundingInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762429">
                        <Funding xml:base="http://www.oxygenxml.com/" >
                            <grantNumber>grantNumber0</grantNumber>
                            <label xml:lang="en-US">label36</label>
                            <label xml:lang="en-US">label37</label>
                            <FundingAgency xml:base="http://www.oxygenxml.com/" >
                                <label xml:lang="en-US">label38</label>
                                <label xml:lang="en-US">label39</label>
                            </FundingAgency>
                            <ActivityInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762422">
                                <When xml:base="http://www.oxygenxml.com/" >
                                </When>
                            </ActivityInfo>
                            <ActivityInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762422">
                                <When xml:base="http://www.oxygenxml.com/" >
                                </When>
                            </ActivityInfo>
                        </Funding>
                        <Funding xml:base="http://www.oxygenxml.com/" >
                            <grantNumber>grantNumber1</grantNumber>
                            <label xml:lang="en-US">label40</label>
                            <label xml:lang="en-US">label41</label>
                            <FundingAgency xml:base="http://www.oxygenxml.com/" >
                                <label xml:lang="en-US">label42</label>
                                <label xml:lang="en-US">label43</label>
                            </FundingAgency>
                            <ActivityInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762422">
                                <When xml:base="http://www.oxygenxml.com/" >
                                </When>
                            </ActivityInfo>
                            <ActivityInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762422">
                                <When xml:base="http://www.oxygenxml.com/" >
                                </When>
                            </ActivityInfo>
                        </Funding>
                    </FundingInfo>
                    <RelatedResource xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762430">
                        <identifier>http://www.oxygenxml.com/</identifier>
                        <identifier>http://www.oxygenxml.com/</identifier>
                        <label xml:lang="en-US">label44</label>
                        <label xml:lang="en-US">label45</label>
                        <location>http://www.oxygenxml.com/</location>
                        <location>http://www.oxygenxml.com/</location>
                        <TitleInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762412">
                            <title xml:lang="en-US">title2</title>
                            <title xml:lang="en-US">title3</title>
                            <alternativeTitle xml:lang="en-US">alternativeTitle2</alternativeTitle>
                            <alternativeTitle xml:lang="en-US">alternativeTitle3</alternativeTitle>
                            <subtitle xml:lang="en-US">subtitle2</subtitle>
                            <subtitle xml:lang="en-US">subtitle3</subtitle>
                        </TitleInfo>
                        <TitleInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762412">
                            <title xml:lang="en-US">title4</title>
                            <title xml:lang="en-US">title5</title>
                            <alternativeTitle xml:lang="en-US">alternativeTitle4</alternativeTitle>
                            <alternativeTitle xml:lang="en-US">alternativeTitle5</alternativeTitle>
                            <subtitle xml:lang="en-US">subtitle4</subtitle>
                            <subtitle xml:lang="en-US">subtitle5</subtitle>
                        </TitleInfo>
                        <Description xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762411">
                            <description xml:lang="en-US">description22</description>
                            <description xml:lang="en-US">description23</description>
                        </Description>
                        <Description xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762411">
                            <description xml:lang="en-US">description24</description>
                            <description xml:lang="en-US">description25</description>
                        </Description>
                        <ResourceType xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762403">
                            <identifier>http://www.oxygenxml.com/</identifier>
                            <identifier>http://www.oxygenxml.com/</identifier>
                            <label xml:lang="en-US">label46</label>
                            <label xml:lang="en-US">label47</label>
                        </ResourceType>
                        <ResourceType xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762403">
                            <identifier>http://www.oxygenxml.com/</identifier>
                            <identifier>http://www.oxygenxml.com/</identifier>
                            <label xml:lang="en-US">label48</label>
                            <label xml:lang="en-US">label49</label>
                        </ResourceType>
                        <CitationInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762416">
                            <bibliographicCitation format="format1">bibliographicCitation1</bibliographicCitation>
                            <bibliographicCitation format="format3">bibliographicCitation2</bibliographicCitation>
                        </CitationInfo>
                        <Creator xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762404">
                            <identifier>http://www.oxygenxml.com/</identifier>
                            <identifier>http://www.oxygenxml.com/</identifier>
                            <label xml:lang="en-US">label50</label>
                            <label xml:lang="en-US">label51</label>
                            <role>role4</role>
                            <role>role5</role>
                            <AgentInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762451">
                            </AgentInfo>
                        </Creator>
                        <Creator xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762404">
                            <identifier>http://www.oxygenxml.com/</identifier>
                            <identifier>http://www.oxygenxml.com/</identifier>
                            <label xml:lang="en-US">label52</label>
                            <label xml:lang="en-US">label53</label>
                            <role>role6</role>
                            <role>role7</role>
                            <AgentInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762451">
                            </AgentInfo>
                        </Creator>
                        <Contributor xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762453">
                            <identifier>http://www.oxygenxml.com/</identifier>
                            <identifier>http://www.oxygenxml.com/</identifier>
                            <label xml:lang="en-US">label54</label>
                            <label xml:lang="en-US">label55</label>
                            <role>role8</role>
                            <role>role9</role>
                            <AgentInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762451">
                            </AgentInfo>
                        </Contributor>
                        <Contributor xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762453">
                            <identifier>http://www.oxygenxml.com/</identifier>
                            <identifier>http://www.oxygenxml.com/</identifier>
                            <label xml:lang="en-US">label56</label>
                            <label xml:lang="en-US">label57</label>
                            <role>role10</role>
                            <role>role11</role>
                            <AgentInfo xml:base="http://www.oxygenxml.com/"  cmd:ComponentId="clarin.eu:cr1:c_1595321762451">
                            </AgentInfo>
                        </Contributor>
                    </RelatedResource>
                </DataCiteRecord>
            </cmd:Components>
        </cmd:CMD>
    </xsl:template>
    
    <xsl:function name="datacite_cmd:isDOI" as="xs:boolean">
        <xsl:param name="uri" required="yes" />
        <xsl:sequence select="contains($uri, 'doi.org/')"/>
    </xsl:function>
    
    <xsl:function name="datacite_cmd:normalize_doi">
        <xsl:param name="uri" required="yes" />
        <xsl:variable name="doi" select="replace($uri,'^((doi:|https?://)?([a-z]+\.)?doi.org/)(.*)$' , '$4')"/>
        <xsl:choose>
            <xsl:when test="normalize-space($doi) != ''">
                <xsl:sequence select="concat('https://doi.org/', $doi)" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$uri" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
</xsl:stylesheet>