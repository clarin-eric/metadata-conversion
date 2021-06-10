<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:cmd="http://www.clarin.eu/cmd/1"
    xmlns:ddi_cmd="http://www.clarin.eu/cmd/conversion/ddi/cmd"
    xmlns="http://www.clarin.eu/cmd/1/profiles/clarin.eu:cr1:p_1595321762428"
    xsi:schemaLocation="http://www.clarin.eu/cmd/1 https://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/1.x/profiles/clarin.eu:cr1:p_1595321762428/xsd"
    exclude-result-prefixes="xs ddi_cmd"
    xpath-default-namespace="ddi:codebook:2_5"
    version="2.0">

    <!--
        DDI 2.5 to CMDI core components DDI profile conversion stylesheet
        Made for ADP use cases (Arhiv družboslovnih podatkov / Social Science Data Archives, Ljubljana, SI)
        Author: Twan Goosen (CLARIN ERIC) <twan@clarin.eu>
        
        Sheet that documents (part of) the mapping: https://docs.google.com/spreadsheets/d/1r-vAxoqoM1iezpc1xp2Y-9mkgh8aZy-2RR_FpJ1ZtQg/edit#gid=562368645
    -->

    <xsl:output indent="yes" encoding="UTF-8" />
    
    <xsl:param name="MdSelfLink" required="no" />
    <xsl:param name="MdCollectionDisplayName" required="no" />
    <xsl:param name="resourceBaseUrl"  required="no" />
    
    <xsl:template match="/*" priority="-1">
        <cmd:CMD CMDVersion="1.2">
            <error>Input document is not a DDI 2.5 document</error>
        </cmd:CMD>
    </xsl:template>
    
    <xsl:template match="/codeBook">
        <cmd:CMD xsi:schemaLocation="http://www.clarin.eu/cmd/1 https://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/1.x/profiles/clarin.eu:cr1:p_1595321762428/xsd" CMDVersion="1.2">
            <xsl:apply-templates mode="header" select="." />
            <xsl:apply-templates mode="resourceProxies" select="." />
            <xsl:apply-templates mode="components" select="." />            
        </cmd:CMD>
    </xsl:template>
    
    <!-- HEADER -->
    
    <xsl:template mode="header" match="codeBook">
        <cmd:Header>
            <xsl:apply-templates select="docDscr/citation/verStmt/verResp | docDscr/citation/rspStmt/AuthEnty" mode="header.MdCreator" />
            <xsl:apply-templates select="docDscr/citation/prodStmt/prodDate/@date" mode="header.MdCreationDate" />
            <xsl:if test="normalize-space($MdSelfLink) != ''">
                <cmd:MdSelfLink><xsl:value-of select="$MdSelfLink"/></cmd:MdSelfLink>
            </xsl:if>
            <cmd:MdProfile>clarin.eu:cr1:p_1595321762428</cmd:MdProfile>
            <xsl:if test="normalize-space($MdCollectionDisplayName) != ''">
                <cmd:MdCollectionDisplayName><xsl:value-of select="$MdCollectionDisplayName"/></cmd:MdCollectionDisplayName>
            </xsl:if>
        </cmd:Header>
    </xsl:template>
    
    <xsl:template mode="header.MdCreator" match="verResp|AuthEnty">
        <cmd:MdCreator><xsl:value-of select="." /></cmd:MdCreator>
    </xsl:template>
    
    <xsl:template mode="header.MdCreationDate" match="@date">
        <xsl:variable name="fullDate" select="ddi_cmd:toFullDate(.)"/>
        <xsl:if test="normalize-space($fullDate) != ''">
            <xsl:if test="normalize-space(.) != $fullDate">
                <xsl:comment>Derived creation date. Value in original metadata: '<xsl:value-of select="."/>'</xsl:comment>
            </xsl:if>
            <cmd:MdCreationDate><xsl:value-of select="$fullDate" /></cmd:MdCreationDate>
        </xsl:if>
    </xsl:template>
    
    <!-- RESOURCE PROXIES -->
    
    <xsl:template mode="resourceProxies" match="codeBook">
        <cmd:Resources>
            <cmd:ResourceProxyList>
                <xsl:choose>
                    <xsl:when test="stdyDscr/citation/titlStmt/IDNo[contains(text(),'doi.org')]">
                        <xsl:apply-templates mode="landingPage" select="stdyDscr/citation/titlStmt/IDNo[contains(text(),'doi.org')]" />
                    </xsl:when>
                    <xsl:when test="stdyDscr/citation/holdings[@URI]">
                        <xsl:apply-templates mode="landingPage" select="stdyDscr/citation/holdings[@URI]" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates mode="landingPage" select="stdyDscr/dataAccs/setAvail/accsPlac[@URI]" />
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:for-each select="fileDscr[@URI]">
                    <cmd:ResourceProxy>
                        <xsl:attribute name="id">
                            <xsl:apply-templates mode="resourceId" select="." />
                        </xsl:attribute>
                        <cmd:ResourceType>Resource</cmd:ResourceType>
                        <cmd:ResourceRef><xsl:value-of select="ddi_cmd:resolve-to-base(@URI)"/></cmd:ResourceRef>
                    </cmd:ResourceProxy>
                </xsl:for-each>
            </cmd:ResourceProxyList>
            <cmd:JournalFileProxyList />
            <cmd:ResourceRelationList />
        </cmd:Resources>
    </xsl:template>
    
    <xsl:template mode="landingPage" match="IDNo">
        <cmd:ResourceProxy>
            <xsl:attribute name="id" select="generate-id(.)" />
            <cmd:ResourceType>LandingPage</cmd:ResourceType>
            <cmd:ResourceRef><xsl:value-of select="ddi_cmd:resolve-to-base(text())"/></cmd:ResourceRef>
        </cmd:ResourceProxy>
    </xsl:template>
    
    <xsl:template mode="landingPage" match="*[@URI]">
        <cmd:ResourceProxy>
            <xsl:attribute name="id" select="generate-id(.)" />
            <cmd:ResourceType>LandingPage</cmd:ResourceType>
            <cmd:ResourceRef><xsl:value-of select="ddi_cmd:resolve-to-base(@URI)"/></cmd:ResourceRef>
        </cmd:ResourceProxy>
    </xsl:template>
    
    <xsl:template mode="resourceId" match="node()">
        <xsl:variable name="nodeId" select="@ID"/>
        <xsl:choose>
            <!-- node ID is available AND unique -->
            <xsl:when test="$nodeId and count(//node()[@ID=$nodeId]) = 1">
                <xsl:value-of select="@ID"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="generate-id(.)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- COMPONENT SECTION -->

    <xsl:template mode="components" match="/codeBook">
        <cmd:Components>
            <DDICodebook>
                
                <!-- <IdentificationInfo> -->
                <xsl:apply-templates mode="record.IdentificationInfo" select="stdyDscr/citation/titlStmt" />
                
                <xsl:if test="stdyDscr/citation/titlStmt/titl|codeBook/stdyDscr/citation/titlStmt/parTitl">
                    <TitleInfo>
                        <xsl:apply-templates mode="TitleInfo.title" select="stdyDscr/citation/titlStmt/titl" />
                        <xsl:apply-templates mode="TitleInfo.title" select="stdyDscr/citation/titlStmt/parTitl" />
                    </TitleInfo>
                </xsl:if>
                
                <!-- <Description> -->
                <xsl:apply-templates mode="record.Description" select="stdyDscr/stdyInfo" />
                
                <!-- <ResourceType> -->
                <xsl:apply-templates mode="record.ResourceType" select="stdyDscr/stdyInfo/sumDscr/dataKind" />
                
                <!-- <Creator> -->
                <xsl:apply-templates mode="Creator" select="stdyDscr/citation/rspStmt/AuthEnty" />
                
                <!-- <Contributor> -->
                <xsl:apply-templates mode="Contributor" select="stdyDscr/citation/rspStmt/othId" />
                
                <!-- TODO: publisher ?? -->
                <!--               <Publisher> 
                   <identifier>http://www.oxygenxml.com/</identifier>
                   <identifier>http://www.oxygenxml.com/</identifier>
                   <name>name8</name>
                   <ContactInfo>
                       <email>email0</email>
                       <email>email1</email>
                   </ContactInfo>
               </Publisher>-->
                
                <!-- <ProvenanceInfo> -->
                <xsl:apply-templates mode="ProvenanceInfo" select="stdyDscr" />
                
                <!-- <DistributionInfo -->
                <xsl:apply-templates mode="DistributionInfo" select="stdyDscr/citation/distStmt" />
                
                <!-- <Subject> -->
                
                <xsl:apply-templates mode="record.Subject" select="stdyDscr/stdyInfo/subject/topcClas" />
                <xsl:apply-templates mode="record.Keyword" select="stdyDscr/stdyInfo/subject/keyword" />
                
                <!-- TODO: <VersionInfo> ?? -->
                
                <!--
               <VersionInfo>
                   <versionIdentifier>versionIdentifier0</versionIdentifier>
                   <responsible>responsible0</responsible>
                   <note>note0</note>
                   <Description>
                       <description>description3</description>
                   </Description>
                   <Responsible>
                       <identifier>identifier1</identifier>
                       <label>label21</label>
                   </Responsible>
               </VersionInfo>
               -->
                
                <!-- <FundingInfo> -->
                <xsl:apply-templates mode="FundingInfo" select="stdyDscr/citation/prodStmt" />
                
                <!-- <TemporalCoverage> -->
                <xsl:apply-templates mode="record.TemporalCoverage" select="stdyDscr/stdyInfo/sumDscr" />
                
                <!-- <GeographicCoverage> -->
                <xsl:apply-templates mode="record.GeographicCoverage" select="stdyDscr/stdyInfo/sumDscr" />
                
                <!-- <AccessInfo> -->
                <xsl:apply-templates mode="record.AccessInfo" select="stdyDscr" />
                
                <!-- <CitationInfo> -->
                <xsl:apply-templates mode="CitationInfo" select="stdyDscr/citation" />
                
                <!-- <Subresource> -->
                <xsl:apply-templates mode="record.Subresource" select="fileDscr" />
                
                <!-- <RelatedResource> -->
                <xsl:apply-templates mode="record.RelatedResource" select="stdyDscr/othrStdyMat/relMat" />
                <xsl:apply-templates mode="record.RelatedResource" select="otherMat" />
                
                <!-- <MetadataInfo> -->
                <xsl:apply-templates mode="record.MetadataInfo" select="docDscr" />
            </DDICodebook>
        </cmd:Components>
    </xsl:template>

    <xsl:template mode="record.Subresource" match="fileDscr">
        <Subresource>
            <xsl:attribute name="cmd:ref">
                <xsl:apply-templates mode="resourceId" select="." />
            </xsl:attribute>
            <SubresourceDescription>
                <label>
                    <xsl:apply-templates mode="xmlLangAttr" select="fileTxt/fileName" />
                    <xsl:value-of select="fileTxt/fileName"/>
                </label>
                <xsl:for-each select="fileTxt/dimensns/caseQnty">
                    <description>caseQnty: <xsl:value-of select="."/></description>
                </xsl:for-each>
                <!-- TODO: other description aspects? -->
            </SubresourceDescription>
        </Subresource>
    </xsl:template>
    
    <xsl:template mode="record.IdentificationInfo" match="titlStmt">
        <xsl:if test="IDNo">
            <IdentificationInfo>
                <xsl:choose>
                    <xsl:when test="IDNo[contains(text(), '/doi.org/')]">
                        <!-- treat DOI(s) as 'primary' identifier and other IDs as internal identifiers --> 
                        <xsl:for-each select="IDNo[contains(text(), '/doi.org/')]">
                            <identifier><xsl:value-of select="."/></identifier>
                        </xsl:for-each>
                        <xsl:for-each select="IDNo[not(contains(text(), '/doi.org/'))]">
                            <internalIdentifier><xsl:value-of select="."/></internalIdentifier>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- no DOI(s): treat all identifier as 'primary' identifiers --> 
                        <xsl:for-each select="IDNo">
                            <identifier><xsl:value-of select="."/></identifier>
                        </xsl:for-each>
                    </xsl:otherwise>
                </xsl:choose>
            </IdentificationInfo>
        </xsl:if>
    </xsl:template>
    
    <xsl:template mode="TitleInfo.title" match="*">
        <title>
            <xsl:apply-templates mode="xmlLangAttr" select="." />
            <xsl:value-of select="."/>
        </title>
    </xsl:template>
    
    <xsl:template mode="record.Description" match="*">
        <xsl:if test="abstract">
            <Description>
                <xsl:apply-templates mode="record.Description.description" select="abstract[@contentType='abstract']" />
                <xsl:apply-templates mode="record.Description.description" select="abstract[not(@contentType='abstract')]" />
            </Description>
        </xsl:if>
    </xsl:template>
    
    <xsl:template mode="record.Description.description" match="*">
        <description>
            <xsl:apply-templates mode="xmlLangAttr" select="." />
            <xsl:value-of select="."/>
        </description>
    </xsl:template>    
    
    <xsl:template mode="record.ResourceType" match="dataKind">
        <ResourceType>
            <xsl:if test="concept">
                <xsl:apply-templates mode="identifier" select="concept/text()">
                    <xsl:with-param name="vocabUri" select="concept/@vocabURI" />
                </xsl:apply-templates>      
            </xsl:if>
            <label>
                <xsl:apply-templates mode="xmlLangAttr" select="." />
                <xsl:choose>
                    <xsl:when test="./concept">
                        <xsl:value-of select="./child::text()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </label>
        </ResourceType>
    </xsl:template>
    
    <xsl:template mode="Creator" match="AuthEnty">
        <Creator>
            <label><xsl:value-of select="."/></label>
            <AgentInfo>
                <PersonInfo>
                    <name><xsl:value-of select="."/></name>
                    <xsl:if test="@affiliation">
                        <affiliation><xsl:value-of select="@affiliation"/></affiliation>
                    </xsl:if>
                </PersonInfo>
            </AgentInfo>
        </Creator>
    </xsl:template>
    
    <xsl:template mode="Contributor" match="othId|distrbtr">
        <xsl:param name="role" required="no" />
        <Contributor>
            <label>
                <xsl:apply-templates mode="xmlLangAttr" select="." />
                <xsl:value-of select="descendant-or-self::text()[normalize-space() != '']"/>
            </label>
            <xsl:if test="@abbr">
                <label><xsl:value-of select="@abbr"/></label>
            </xsl:if>
            <xsl:if test="@role">
                <role><xsl:value-of select="@role"/></role>
            </xsl:if>
            <xsl:if test="normalize-space($role) != ''">
                <role><xsl:value-of select="$role"/></role>                
            </xsl:if>
            <!-- TODO: @affiliation IFF known if person or organisation -->
        </Contributor>
    </xsl:template>
    
    <xsl:template mode="ActivityInfo.When" match="*[@event='single' or normalize-space(@event) = '']">
        <When>
            <xsl:choose>
                <xsl:when test="ddi_cmd:isDate(@date)">
                    <xsl:if test="normalize-space(.) != ''">
                        <label><xsl:value-of select="."/></label>
                    </xsl:if>
                    <date><xsl:value-of select="@date"/></date>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates mode="ActivityInfo.When.label" select="." />
                </xsl:otherwise>
            </xsl:choose>
        </When>
    </xsl:template>
    
    <xsl:template mode="ActivityInfo.When" match="*[@event='start' or @event='end']">
        <!-- TODO: support range via <start> and/or <end> of core component -->
        <When>
            <xsl:apply-templates mode="ActivityInfo.When.label" select="." />
        </When>
    </xsl:template>
    
    <xsl:template mode="ActivityInfo.When.label" match="*[@event='start' or @event='end']">
        <xsl:if test="@date">
            <label><xsl:value-of select="@event"/>: <xsl:value-of select="@date"/></label>
        </xsl:if>
        <xsl:if test="normalize-space(.) != ''">
            <label><xsl:value-of select="@event"/>: <xsl:value-of select="."/></label>
        </xsl:if>    
    </xsl:template>
    
    <xsl:template mode="ActivityInfo.When.label" match="*">
        <label><xsl:value-of select="."/></label>
        <xsl:if test="@date">
            <label><xsl:value-of select="@date"/></label>
        </xsl:if>
    </xsl:template>
    
    
    <xsl:template mode="ActivityInfo" match="prodStmt">
        <ActivityInfo>
            <method>Production</method>
            <xsl:for-each select="prodPlac">
                <note>prodPlac = <xsl:value-of select="."/></note>
            </xsl:for-each>
            <xsl:choose>
               <xsl:when test="count(prodDate) = 1">
                 <xsl:apply-templates mode="ActivityInfo.When" select="prodDate" />
               </xsl:when>
                <xsl:when test="count(prodDate) > 1">
                    <When>
                        <xsl:apply-templates mode="ActivityInfo.When.label" select="prodDate" />
                    </When>
                </xsl:when>
                <xsl:otherwise>
                    <When>
                        <label>Unspecified</label>
                    </When>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:for-each select="producer">
             <Responsible>
                 <label><xsl:value-of select="."/></label>
                 <xsl:if test="@abbr">
                     <label><xsl:value-of select="@abbr"/></label>
                 </xsl:if>
             </Responsible>
            </xsl:for-each>
        </ActivityInfo>
    </xsl:template>
    
    <xsl:template mode="ActivityInfo" match="sumDscr/collDate">
        <ActivityInfo>
            <xsl:apply-templates mode="ActivityInfo.When" select="." />
        </ActivityInfo>
    </xsl:template>


    <xsl:template mode="ProvenanceInfo.Creation" match="stdyDscr|docDscr">
        <xsl:if test="citation/prodStmt">
            <Creation>
                <xsl:apply-templates mode="ActivityInfo" select="citation/prodStmt" />
            </Creation>
        </xsl:if>
    </xsl:template>
    
    <xsl:template mode="ProvenanceInfo" match="stdyDscr">
        <ProvenanceInfo>
            <xsl:apply-templates mode="ProvenanceInfo.Creation" select="." />
            <xsl:if test="stdyInfo/sumDscr/collDate">
                <Collection>
                    <xsl:apply-templates mode="ActivityInfo" select="stdyInfo/sumDscr/collDate" />
                </Collection>
            </xsl:if>
        </ProvenanceInfo>
    </xsl:template>
    
    <xsl:template mode="ProvenanceInfo" match="docDscr">
        <ProvenanceInfo>
            <xsl:apply-templates mode="ProvenanceInfo.Creation" select="." />
            <Activity>
                <label>Conversion to CMDI</label>
                <note>Automatic metadata conversion with stylesheet adp-ddi_2_5_to_cmdi.xsl</note>
                <ActivityInfo>
                    <When>
                        <date><xsl:value-of select="adjust-date-to-timezone(current-date(), xs:dayTimeDuration('PT0H'))"/></date>
                    </When>
                </ActivityInfo>
            </Activity>
        </ProvenanceInfo>
    </xsl:template>
    
    <xsl:template mode="DistributionInfo" match="distStmt">
        <DistributionInfo>
            <!-- <distributionDate> -->
            <xsl:apply-templates select="distDate" mode="makeFullDate">
                <xsl:with-param name="elementName" select="'distributionDate'" />
            </xsl:apply-templates>
            
            <!-- <depositionDate> -->
            <xsl:apply-templates select="depDate" mode="makeFullDate">
                <xsl:with-param name="elementName" select="'depositionDate'" />
            </xsl:apply-templates>

            <xsl:for-each select="distrbtr">
                <Distributor>
                    <label><xsl:value-of select="."/></label>
                    <xsl:if test="@abbr">
                        <label><xsl:value-of select="@abbr"/></label>
                    </xsl:if>
                    <!-- TODO: @affiliation? -->
                </Distributor>
            </xsl:for-each>
            
            <xsl:for-each select="depositr">
                <Depositor>
                    <label><xsl:value-of select="."/></label>
                    <xsl:if test="@abbr">
                        <label><xsl:value-of select="@abbr"/></label>
                    </xsl:if>
                    <!-- TODO: @affiliation? -->
                </Depositor>
            </xsl:for-each>
        </DistributionInfo>
    </xsl:template>
    
    <xsl:template mode="record.Subject" match="subject/topcClas">
        <Subject>
            <xsl:apply-templates mode="identifier" select="@ID">
                <xsl:with-param name="vocabUri" select="@vocabURI" />
            </xsl:apply-templates>
            <label>
                <xsl:apply-templates mode="xmlLangAttr" select="."/>
                <xsl:value-of select="."/>
            </label>
        </Subject>
    </xsl:template>
    
    <xsl:template mode="record.Keyword" match="subject/keyword">
        <Keyword>
            <xsl:apply-templates mode="identifier" select="@ID">
                <xsl:with-param name="vocabUri" select="@vocabURI" />
            </xsl:apply-templates>
            <label>
                <xsl:apply-templates mode="xmlLangAttr" select="." />
                <xsl:value-of select="."/>
            </label>
        </Keyword>
    </xsl:template>
    
    
    <xsl:template mode="FundingInfo" match="prodStmt">
        <xsl:if test="grantNo or fundAg">
            <FundingInfo>
                <xsl:for-each select="grantNo">
                 <Funding>
                     <grantNumber><xsl:value-of select="."/></grantNumber>
                 </Funding>
                </xsl:for-each>
                <xsl:for-each select="fundAg">
                     <Funding>
                         <FundingAgency>
                             <label>
                                 <xsl:apply-templates mode="xmlLangAttr" select="." />
                                 <xsl:value-of select="."/>
                             </label>
                             <xsl:if test="@abbr">
                               <label><xsl:value-of select="@abbr"/></label>
                             </xsl:if>
                         </FundingAgency>
                     </Funding>
                </xsl:for-each>
            </FundingInfo>
        </xsl:if>
    </xsl:template>    

    <xsl:template mode="record.TemporalCoverage" match="sumDscr[not(timePrd/@event='start' or timePrd/@event='end')]">
        <TemporalCoverage>
            <xsl:for-each select="timePrd">
                <xsl:choose>
                    <xsl:when test="@event">
                        <label><xsl:value-of select="@event"/>: <xsl:value-of select="."/></label>
                    </xsl:when>
                    <xsl:otherwise>
                        <label><xsl:value-of select="."/></label>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </TemporalCoverage>
    </xsl:template>

    <!-- Temporal coverage -->
    <xsl:template mode="record.TemporalCoverage" match="sumDscr[timePrd/@event='start' or timePrd/@event='end']">
        <TemporalCoverage>
            <!-- TODO: make this nicer for cases where one of the two is missing -->
            <xsl:if test="normalize-space(timePrd[@event='start']) !='' or normalize-space(timePrd[@event='end']) != ''">
                <label><xsl:value-of select="timePrd[@event='start']"/> - <xsl:value-of select="timePrd[@event='end']"/></label>
            </xsl:if>
            <xsl:for-each select="timePrd[@event = 'start']">
                <xsl:variable name="startDate" select="ddi_cmd:toFullDate(normalize-space(@date))"/>
                <xsl:choose>
                    <xsl:when test="ddi_cmd:isDate(normalize-space(string($startDate)))">
                        <Start>
                            <date><xsl:value-of select="$startDate"/></date>
                            <xsl:choose>
                                <xsl:when test="normalize-space(.) != ''">
                                    <xsl:apply-templates mode="label" select=".[normalize-space() != '']" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <label><xsl:value-of select="$startDate"/></label>
                                </xsl:otherwise>
                            </xsl:choose>
                        </Start>
                    </xsl:when>
                    <xsl:when test="normalize-space(.) != ''">
                        <Start>
                            <xsl:apply-templates mode="label" select="." />
                        </Start>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
            <xsl:for-each select="timePrd[@event = 'end']">
                <xsl:variable name="endDate" select="ddi_cmd:toFullDate(normalize-space(@date))"/>
                <xsl:choose>
                    <xsl:when test="ddi_cmd:isDate(normalize-space(string($endDate)))">
                        <End>
                            <date><xsl:value-of select="$endDate"/></date>
                            <xsl:choose>
                                <xsl:when test="normalize-space(.) != ''">
                                    <xsl:apply-templates mode="label" select=".[normalize-space() != '']" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <label><xsl:value-of select="$endDate"/></label>
                                </xsl:otherwise>
                            </xsl:choose>
                        </End>
                    </xsl:when>
                    <xsl:when test="normalize-space(.) != ''">
                        <End>
                            <xsl:apply-templates mode="label" select="." />
                        </End>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </TemporalCoverage>
    </xsl:template>
    
    <xsl:template mode="record.GeographicCoverage" match="sumDscr">
        <xsl:if test="geogCover">
            <GeographicCoverage>
                <xsl:for-each select="geogCover">
                    <GeoLocation>
                        <label>
                            <xsl:apply-templates mode="xmlLangAttr" select="." />
                            <xsl:value-of select="."/>
                        </label>
                    </GeoLocation>
                </xsl:for-each>
            </GeographicCoverage>
        </xsl:if>
    </xsl:template>
    
    <xsl:template mode="record.AccessInfo.condition" match="*">
        <condition>
            <xsl:apply-templates mode="xmlLangAttr" select="." />
            <xsl:value-of select="."/>
        </condition>
    </xsl:template>    
    
    <xsl:template mode="record.AccessInfo.condition" match="@*">
        <condition>
            <xsl:value-of select="."/>
        </condition>
    </xsl:template>
    
    <xsl:template mode="record.AccessInfo.Contact" match="accsPlac">
        <Contact>
            <label>
                <xsl:apply-templates mode="xmlLangAttr" select="." />
                <xsl:value-of select="."/>
            </label>
            <Description>
                <description>Access location</description>
            </Description>
            <AgentInfo>
                <OrganisationInfo>
                    <name>
                        <xsl:apply-templates mode="xmlLangAttr" select="." />
                        <xsl:value-of select="."/>
                    </name>
                    <xsl:if test="@URI">
                    <ContactInfo>
                        <url><xsl:value-of select="@URI"/></url>
                    </ContactInfo>
                    </xsl:if>
                </OrganisationInfo>
            </AgentInfo>
        </Contact>
    </xsl:template>
    
    <xsl:template mode="record.AccessInfo" match="stdyDscr">
        <AccessInfo>
            <xsl:apply-templates mode="record.AccessInfo.condition" select="dataAccs/useStmt/citReq" />
            <xsl:apply-templates mode="record.AccessInfo.condition" select="dataAccs/useStmt/deposReq" />
            <xsl:apply-templates mode="record.AccessInfo.condition" select="dataAccs/useStmt/conditions" />
            <xsl:apply-templates mode="record.AccessInfo.condition" select="dataAccs/useStmt/restrctn" />
            <xsl:apply-templates mode="record.AccessInfo.condition" select="dataAccs/useStmt/restrctn/@ID" />
            <xsl:apply-templates mode="record.AccessInfo.Contact" select="dataAccs/setAvail/accsPlac" />
        </AccessInfo>
    </xsl:template>
    
    <xsl:template mode="CitationInfo" match="citation[biblCit]">
        <CitationInfo>
            <xsl:for-each select="biblCit">
            <bibliographicCitation>
                <xsl:if test="@format">
                    <xsl:attribute name="format" select="@format" />
                </xsl:if>
                <xsl:value-of select="."/>
            </bibliographicCitation>
            </xsl:for-each>
        </CitationInfo>
    </xsl:template>
    
    <xsl:template mode="CitationInfo" match="citation">
        <!-- Construct single bibliographic citation from information in citation block -->
        <xsl:variable name="prodDate">
            <xsl:if test="prodStmt/prodDate">
                <xsl:value-of select="concat(normalize-space(prodStmt/prodDate), '. ')"/>
            </xsl:if>
        </xsl:variable>
        
        <xsl:variable name="prodPlac">
            <xsl:if test="prodStmt/prodPlac">
                <xsl:choose>
                    <xsl:when test="normalize-space($prodDate) != ''">
                        <xsl:value-of select="concat(normalize-space(prodStmt/prodPlac), ', ')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat(normalize-space(prodStmt/prodPlac), '. ')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:variable>
        
        <xsl:variable name="rsp">
            <xsl:for-each select="rspStmt">
                <xsl:value-of select="concat(normalize-space(.), '. ')"/>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:variable name="producer">
            <xsl:for-each select="prodStmt/producer">
                <xsl:value-of select="concat(normalize-space(.), '. ')"/>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:variable name="title">
            <xsl:if test="count(titlStmt/titl) = 1">
                <xsl:value-of select="normalize-space(titlStmt/titl)"/>
            </xsl:if>
        </xsl:variable>
        
        <xsl:variable name="bibliographicCitation" select="normalize-space(concat($rsp, $title, $producer, $prodPlac, $prodDate))"/>
        
        <xsl:if test="$bibliographicCitation != ''">
            <CitationInfo>
                <bibliographicCitation><xsl:value-of select="$bibliographicCitation"/></bibliographicCitation>
            </CitationInfo>
        </xsl:if>
    </xsl:template>
    
    <xsl:template mode="record.RelatedResource" match="relMat|otherMat" >
        <RelatedResource>
            <xsl:if test="@ID">
                <identifier><xsl:value-of select="@ID"/></identifier>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="citation/titlStmt/titl">
                    <xsl:for-each select="citation/titlStmt/titl">
                       <label>
                           <xsl:apply-templates mode="xmlLangAttr" select="." />
                           <xsl:value-of select="."/>
                       </label>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="@ID">
                    <label><xsl:value-of select="@ID"/></label>
                </xsl:when>
                <xsl:otherwise>
                    <label>Unspecified</label>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="citation/holdings[@URI]">
                <location><xsl:value-of select="ddi_cmd:resolve-to-base(citation/holdings/@URI)"/></location>
            </xsl:if>
            
            <xsl:apply-templates mode="CitationInfo" select="citation" />
        </RelatedResource>
    </xsl:template>
    
    <xsl:template mode="record.MetadataInfo" match="docDscr">
        <MetadataInfo>
            <xsl:if test="citation/titlStmt/IDNo">
                <IdentificationInfo>
                    <xsl:for-each select="citation/titlStmt/IDNo">
                        <identifier><xsl:value-of select="."/></identifier>
                    </xsl:for-each>
                </IdentificationInfo>
            </xsl:if>
            
            <xsl:if test="citation/titlStmt/titl | citation/titlStmt/parTitl">
                <TitleInfo>
                    <xsl:apply-templates mode="TitleInfo.title" select="citation/titlStmt/titl" />
                    <xsl:apply-templates mode="TitleInfo.title" select="citation/titlStmt/parTitl" />
                </TitleInfo>
            </xsl:if>
            
            <xsl:apply-templates mode="Creator" select="citation/rspStmt/AuthEnty" />
            
            <xsl:apply-templates mode="Contributor" select="citation/distStmt/distrbtr">
                <xsl:with-param name="role" select="'Distributor'" />
            </xsl:apply-templates>
            
            <xsl:apply-templates mode="CitationInfo" select="citation" />
            
            <!-- TODO: add conversion to CMDI activity -->
            <xsl:apply-templates mode="ProvenanceInfo" select="." />
            
            <xsl:apply-templates mode="FundingInfo" select="citation/prodStmt" />
        </MetadataInfo>
    </xsl:template>
    
    <!-- Helper templates -->
    
    <xsl:template mode="label" match="*">
        <label>
            <xsl:apply-templates mode="xmlLangAttr" select="." />
            <xsl:value-of select="."/>
        </label>
    </xsl:template>
    
    <xsl:template mode="xmlLangAttr" match="@xml:lang">
        <xsl:attribute name="xml:lang"><xsl:value-of select="."/></xsl:attribute>
    </xsl:template>
    
    <xsl:template mode="xmlLangAttr" match="node()">
        <xsl:if test="@xml:lang">
            <xsl:apply-templates mode="xmlLangAttr" select="@xml:lang" />
        </xsl:if>
    </xsl:template>
    
    <xsl:template mode="identifier" match="@* | node()">
        <xsl:param name="vocabUri" />
        <xsl:choose>
            <xsl:when test="ddi_cmd:isAbsoluteUri(.)">
                <identifier><xsl:value-of select="."/></identifier>
            </xsl:when>
            <xsl:when test="normalize-space($vocabUri) != ''">
                <identifier><xsl:value-of select="$vocabUri"/>:<xsl:value-of select="."/></identifier>
            </xsl:when>
        </xsl:choose>  
    </xsl:template>
    
    <!-- Custom functions -->
    
    <xsl:function name="ddi_cmd:toFullDate">
        <xsl:param name="value" />
        <xsl:choose>
            <xsl:when test="ddi_cmd:isDate($value)">
                <!-- full date, return as is -->
                <xsl:sequence select="$value" />
            </xsl:when>
            <xsl:when test="matches(string($value), '^\d{4}-[0-1]\d$')">
                <!-- only month; round to yyyy-mm-01 -->
                <xsl:sequence select="concat(string($value),'-01')" />
            </xsl:when>
            <xsl:when test="matches(string($value), '^\d{4}$')">
                <!-- only year; round to yyyy-01-01 -->
                <xsl:sequence select="concat(string($value),'-01-01')" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="''" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:template mode="makeFullDate" match="*">
        <xsl:param name="elementName" />
        <xsl:variable name="fullDate" select="ddi_cmd:toFullDate(@date)"/>
        <xsl:if test="$fullDate">
            <xsl:if test="@date != $fullDate">
                <xsl:comment>Original: '<xsl:value-of select="@date"/>'</xsl:comment>
            </xsl:if>
            <xsl:element name="{$elementName}"><xsl:value-of select="$fullDate"/></xsl:element>
        </xsl:if>
    </xsl:template>
    
    <xsl:function name="ddi_cmd:isAbsoluteUri">
        <xsl:param name="value" />
        <xsl:sequence select="matches($value,'^(http|https|hdl|doi):.*$')" />
    </xsl:function>
    
    <xsl:function name="ddi_cmd:isDate">
        <xsl:param name="value" />
        <xsl:sequence select="matches(string($value),'^\d{4}-[0-1]\d-[0-3]\d$')" />        
    </xsl:function>
    
    <xsl:function name="ddi_cmd:resolve-to-base">
        <xsl:param name="uri" required="yes" />
        <xsl:choose>
            <xsl:when test="normalize-space($resourceBaseUrl) != '' and not(ddi_cmd:isAbsoluteUri($uri))">
                <xsl:sequence select="resolve-uri($uri, $resourceBaseUrl)" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$uri" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
</xsl:stylesheet>