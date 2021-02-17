<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:cue="http://www.clarin.eu/cmdi/cues/1"
    xmlns:dcr="http://www.isocat.org/ns/dcr"
    xmlns:cmd="http://www.clarin.eu/cmd/1"
    xmlns:vc="http://www.w3.org/2007/XMLSchema-versioning"
    xmlns:datacite="http://datacite.org/schema/kernel-4"
    xmlns:ddi_cmd="http://www.clarin.eu/cmd/conversion/ddi/cmd"
    xmlns="http://www.clarin.eu/cmd/1/profiles/clarin.eu:cr1:p_1595321762428"
    xsi:schemaLocation="http://www.clarin.eu/cmd/1 https://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/1.x/profiles/clarin.eu:cr1:p_1595321762428/xsd"
    exclude-result-prefixes="xs"
    xpath-default-namespace="ddi:codebook:2_5"
    version="2.0">

    <!--
        DDI 2.5 to CMDI core components DDI profile conversion stylesheet
        Made for ADP use cases (Arhiv družboslovnih podatkov / Social Science Data Archives, Ljubljana, SI)
        Author: Twan Goosen (CLARIN ERIC) <twan@clarin.eu>
        
        Sheet that documents (part of) the mapping: https://docs.google.com/spreadsheets/d/1r-vAxoqoM1iezpc1xp2Y-9mkgh8aZy-2RR_FpJ1ZtQg/edit#gid=562368645
    -->

    <xsl:output indent="yes" encoding="UTF-8" />
    
    <xsl:template match="/*" priority="-1">
        <cmd:CMD CMDVersion="1.2">
            <error>Input document is not a DDI 2.5 document</error>
        </cmd:CMD>
    </xsl:template>
    
    <xsl:template match="/codeBook">
        <cmd:CMD CMDVersion="1.2" xsi:schemaLocation="http://www.clarin.eu/cmd/1 https://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/1.x/profiles/clarin.eu:cr1:p_1595321762428/xsd">
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
            <cmd:MdSelfLink><!-- TODO --></cmd:MdSelfLink>
            <cmd:MdProfile>clarin.eu:cr1:p_1595321762428</cmd:MdProfile>
            <cmd:MdCollectionDisplayName><!-- TODO --></cmd:MdCollectionDisplayName>
        </cmd:Header>
    </xsl:template>
    
    <xsl:template mode="header.MdCreator" match="verResp|AuthEnty">
        <cmd:MdCreator><xsl:value-of select="." /></cmd:MdCreator>
    </xsl:template>
    
    <xsl:template mode="header.MdCreationDate" match="@date">
        <!-- TODO: normalize date -->
        <cmd:MdCreationDate><xsl:value-of select="." /></cmd:MdCreationDate> 
    </xsl:template>
    
    <!-- RESOURCE PROXIES -->
    
    <xsl:template mode="resourceProxies" match="codeBook">
        <cmd:Resources>
            <cmd:ResourceProxyList>
                <!-- TODO -->
                
               <!--     <cmd:ResourceProxy id="">
                        <cmd:ResourceType>LandingPage</cmd:ResourceType>
                        <cmd:ResourceRef>{/codeBook/stdyDscr/dataAccs/setAvail/accsPlac/@URI} http://www.adp.fdv.uni-lj.si/podatki/</cmd:ResourceRef>
                    </cmd:ResourceProxy>
                    <cmd:ResourceProxy id="F1">
                        <cmd:ResourceType>Resource</cmd:ResourceType>
                        <cmd:ResourceRef>{/codeBook/fileDscr/@URI} https://www.adp.fdv.uni-lj.si/opisi/dostop/</cmd:ResourceRef>
                    </cmd:ResourceProxy>-->
                
                
            </cmd:ResourceProxyList>
        </cmd:Resources>
    </xsl:template>
    
    <!-- COMPONENT SECTION -->
    
    <xsl:template mode="record.IdentificationInfo.identifier" match="*">
        <identifier><xsl:value-of select="."/></identifier>
    </xsl:template>
    
    <xsl:template mode="record.IdentificationInfo.internalIdentifier" match="*">
        <internalIdentifier><xsl:value-of select="."/></internalIdentifier>
    </xsl:template>
    
    <xsl:template mode="record.TitleInfo.title" match="*">
        <title>
            <xsl:if test="@xml:lang"><xsl:attribute name="xml:lang" select="@xml:lang" /></xsl:if>
            <xsl:value-of select="."/>
        </title>
    </xsl:template>
    
    <xsl:template mode="record.Description.description" match="*">
        <Description>
            <description xml:lang="en-GB">
                <xsl:if test="@xml:lang"><xsl:attribute name="xml:lang" select="@xml:lang" /></xsl:if>
                <xsl:value-of select="."/>
            </description>
        </Description>
    </xsl:template>    
    
    <xsl:template mode="record.ResourceType" match="dataKind">
        <ResourceType>
            <xsl:if test="./concept">
                <xsl:choose>
                    <xsl:when test="ddi_cmd:isUri(./concept/text())">
                        <identifier><xsl:value-of select="./concept/text()"/></identifier>
                    </xsl:when>
                    <xsl:when test="./concept/@vocabURI">
                        <identifier><xsl:value-of select="./concept/@vocabURI"/>:<xsl:value-of select="./concept/text()"/></identifier>
                    </xsl:when>
                </xsl:choose>                
            </xsl:if>
            <label>
                <xsl:if test="@xml:lang"><xsl:attribute name="xml:lang" select="@xml:lang" /></xsl:if>
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
    
    <xsl:template mode="record.Creator" match="AuthEnty">
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
    
    <xsl:template mode="record.Contributor" match="othId">
        <Contributor>
            <label><xsl:value-of select="descendant-or-self::text()[normalize-space() != '']"/></label>
            <xsl:if test="@role">
                <role><xsl:value-of select="@role"/></role>
            </xsl:if>
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
                    <label><xsl:value-of select="."/></label>
                    <xsl:if test="@date">
                        <label><xsl:value-of select="@date"/></label>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </When>
    </xsl:template>
    
    <xsl:template mode="ActivityInfo.When" match="*[@event='start' or @event='end']">
        <!-- TODO: support range via <start> and/or <end> of core component -->
        <When>
            <xsl:if test="@date">
                <label><xsl:value-of select="@event"/>: <xsl:value-of select="@date"/></label>
            </xsl:if>
            <xsl:if test="normalize-space(.) != ''">
                <label><xsl:value-of select="@event"/>: <xsl:value-of select="."/></label>
            </xsl:if>            
        </When>
    </xsl:template>
    
    <xsl:template mode="ActivityInfo" match="prodStmt">
        <ActivityInfo>
            <method>Production</method>
            <xsl:for-each select="prodPlac">
                <note>prodPlac = <xsl:value-of select="."/></note>
            </xsl:for-each>
            <xsl:if test="count(prodDate) = 1">
              <xsl:apply-templates mode="ActivityInfo.When" select="prodDate" />
            </xsl:if>
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
    
    <xsl:template mode="record.ProvenanceInfo" match="codeBook">
        <ProvenanceInfo>
            <xsl:if test="stdyDscr/citation/prodStmt">
                <Creation>
                    <xsl:apply-templates mode="ActivityInfo" select="stdyDscr/citation/prodStmt" />
                </Creation>
            </xsl:if>
            <xsl:if test="stdyDscr/stdyInfo/sumDscr/collDate">
                <Collection>
                    <xsl:apply-templates mode="ActivityInfo" select="stdyDscr/stdyInfo/sumDscr/collDate" />
                </Collection>
            </xsl:if>
        </ProvenanceInfo>
    </xsl:template>
    
    <xsl:template mode="record.DistributionInfo" match="distStmt">
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
    
    <xsl:template mode="components" match="/codeBook">
        <cmd:Components>
           <ADP-DDI>
               
               <xsl:if test="stdyDscr/citation/titlStmt/IDNo">
                   <IdentificationInfo>
                       <xsl:apply-templates mode="record.IdentificationInfo.identifier" select="stdyDscr/citation/titlStmt/IDNo[contains(text(), '/doi.org/')]" />
                       <xsl:apply-templates mode="record.IdentificationInfo.internalIdentifier" select="stdyDscr/citation/titlStmt/IDNo[not(contains(text(), '/doi.org/'))]" />
                   </IdentificationInfo>
               </xsl:if>
               
               <xsl:if test="stdyDscr/citation/titlStmt/titl|codeBook/stdyDscr/citation/titlStmt/parTitl">
                  <TitleInfo>
                      <xsl:apply-templates mode="record.TitleInfo.title" select="stdyDscr/citation/titlStmt/titl" />
                      <xsl:apply-templates mode="record.TitleInfo.title" select="stdyDscr/citation/titlStmt/parTitl" />
                  </TitleInfo>
               </xsl:if>
               
               <!-- <Description> -->
               <xsl:apply-templates mode="record.Description.description" select="stdyDscr/stdyInfo/abstract" />
                
               <!-- <ResourceType> -->
               <xsl:apply-templates mode="record.ResourceType" select="stdyDscr/stdyInfo/sumDscr/dataKind" />
               
               <!-- <Creator> -->
               <xsl:apply-templates mode="record.Creator" select="stdyDscr/citation/rspStmt/AuthEnty" />
               
               <!-- <Contributor> -->
               <xsl:apply-templates mode="record.Contributor" select="stdyDscr/citation/rspStmt/othId" />
               
               <Publisher> <!-- ?? TODO -->
                   <identifier>http://www.oxygenxml.com/</identifier>
                   <identifier>http://www.oxygenxml.com/</identifier>
                   <name>name8</name>
                   <ContactInfo>
                       <email>email0</email>
                       <email>email1</email>
                   </ContactInfo>
               </Publisher>
               
               <!-- <ProvenanceInfo> -->
               <xsl:apply-templates mode="record.ProvenanceInfo" select="." />
               
               <!-- <DistributionInfo -->
               <xsl:apply-templates mode="record.DistributionInfo" select="stdyDscr/citation/distStmt" />
               
               <!-- /codeBook/stdyDscr/stdyInfo/subject/topcClas -->
               <Subject>
                   <label>OTHER</label>
               </Subject>
               <!-- /codeBook/stdyDscr/stdyInfo/subject/topcClas -->
               <Subject>
                   <label>Development cooperation</label>
               </Subject>
               <!-- /codeBook/stdyDscr/stdyInfo/subject/topcClas -->
               <Subject>
                   <label>ORGANISATIONAL CULTURE OF ENTERPRISES AND INSTITUTIONS</label>
               </Subject>
               <!--
                   ..
                   some subjects skipped
                   ..
               -->
               <!-- /codeBook/stdyDscr/stdyInfo/subject/keyword -->
               <Keyword>
                   <label>regional development</label>
               </Keyword>
               <!-- /codeBook/stdyDscr/stdyInfo/subject/keyword -->
               <Keyword>
                   <label>innovative cores</label>
               </Keyword>
               <!--
                   ..
                   some keywords skipped
                   ..
               -->
               <!-- /codeBook/stdyDscr/stdyInfo/subject/keyword -->
               <Keyword>
                   <identifier>ELSST_7d7f66dd-f5bb-440e-b1d1-71c9b4c5087c</identifier>
                   <label xml:lang="en-GB">DEVELOPMENT</label>
               </Keyword>
               <!-- /codeBook/stdyDscr/stdyInfo/subject/keyword -->
               <Keyword>
                   <identifier>ELSST_b43e57e4-e01d-432e-b41b-ecaebbad3f6f</identifier>
                   <label xml:lang="en-GB">DEVELOPMENT PROGRAMMES</label>
               </Keyword>
               <!--
                   ..
                   some keywords skipped
                   ..
               -->
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
               <FundingInfo>
                   <Funding>
                       <!-- /codeBook/stdyDscr/citation/prodStmt/grantNo -->
                       <grantNumber>L5-0654</grantNumber>
                   </Funding>
                   <Funding>
                       <FundingAgency>
                           <!-- /codeBook/stdyDscr/citation/prodStmt/fundAg -->
                           <label xml:lang="en-GB">Agencija za raziskovalno dejavnost Republike Slovenije= Slovenian Research Agency</label>
                           <label>ARRS</label>
                       </FundingAgency>
                   </Funding>
                   <Funding>
                       <FundingAgency>
                           <!-- /codeBook/stdyDscr/citation/prodStmt/fundAg -->
                           <label xml:lang="en-GB">Služba Vlade RS za lokalno samoupravo in regionalno politiko = Government Office for Local Self-Government and Regional Policy</label>
                           <label>SVLR</label>
                       </FundingAgency>
                   </Funding>
               </FundingInfo>
               <TemporalCoverage>
                   <!-- /codeBook/stdyDscr/stdyInfo/sumDscr/timePrd -->
                   <label>November 2008 - November 2009</label>
                   <Start>
                       <!-- /codeBook/stdyDscr/stdyInfo/sumDscr/timePrd/@date -->
                       <date>2008-11-01</date>
                       <!-- /codeBook/stdyDscr/stdyInfo/sumDscr/timePrd -->
                       <label>November 2008</label>
                   </Start>
                   <End>
                       <!-- /codeBook/stdyDscr/stdyInfo/sumDscr/timePrd/@date -->
                       <date>2009-11-30</date>
                       <!-- /codeBook/stdyDscr/stdyInfo/sumDscr/timePrd -->
                       <label>November 2009</label>
                   </End>
               </TemporalCoverage>
               <GeographicCoverage>
                   <GeoLocation>
                       <!-- /codeBook/stdyDscr/stdyInfo/sumDscr/geogCover -->
                       <label>Central Slovenia</label>
                   </GeoLocation>
                   <GeoLocation>
                       <!-- /codeBook/stdyDscr/stdyInfo/sumDscr/geogCover -->
                       <label>Goriska region</label>
                   </GeoLocation>
                   <GeoLocation>
                       <!-- /codeBook/stdyDscr/stdyInfo/sumDscr/geogCover -->
                       <label>Coastal-Carsic region</label>
                   </GeoLocation>
                   <GeoLocation>
                       <!-- /codeBook/stdyDscr/stdyInfo/sumDscr/geogCover -->
                       <label>Southeastern region</label>
                   </GeoLocation>
               </GeographicCoverage>
               <AccessInfo>
                   <!-- /codeBook/stdyDscr/dataAccs/useStmt/citReq -->
                   <condition xml:lang="en-GB">The users should acknowledge in any publication both the original depositors and the Archive.</condition>
                   <!-- /codeBook/stdyDscr/dataAccs/useStmt/deposReq -->
                   <condition xml:lang="en-GB">Users are requested to deposit with the Archive two copies of any published work or report based wholly or in part on such materials and to notify the Archive of any errors discovered in the materials.</condition>
                   <!-- /codeBook/stdyDscr/dataAccs/useStmt/conditions -->
                   <condition xml:lang="en-GB">In case of ambiguity the users of the data set are advised to contact principal investigators or Archive.</condition>
                   <!-- /codeBook/stdyDscr/dataAccs/useStmt/restrctn -->
                   <condition xml:lang="en-GB">The users should use the materials only for the purposes specified in Ordering form, to act at all times so as to preserve the confidentiality of individuals and institutions recorded in the materials.</condition>
                   <!-- /codeBook/stdyDscr/dataAccs/useStmt/restrctn/@ID -->
                   <condition>ccby</condition>
                   <Contact>
                       <!-- /codeBook/stdyDscr/dataAccs/setAvail/accsPlac -->
                       <label>Arhiv družboslovnih podatkov = Social Science Data Archive</label>
                       <Description>
                           <!-- /codeBook/stdyDscr/dataAccs/setAvail/accsPlac -->
                           <description>Access location</description>
                       </Description>
                       <AgentInfo>
                           <OrganisationInfo>
                               <!-- /codeBook/stdyDscr/dataAccs/setAvail/accsPlac -->
                               <name>Arhiv družboslovnih podatkov = Social Science Data Archive</name>
                               <ContactInfo>
                                   <!-- /codeBook/stdyDscr/dataAccs/setAvail/accsPlac/@URI -->
                                   <url>http://www.adp.fdv.uni-lj.si/podatki/</url>
                               </ContactInfo>
                           </OrganisationInfo>
                       </AgentInfo>
                   </Contact>
               </AccessInfo>
               <CitationInfo>
                   <!-- /codeBook/stdyDscr/citation/biblCit -->
                   <!-- /codeBook/stdyDscr/citation/biblCit/@format -->
                   <bibliographicCitation format="MRDF">Adam, Frane et al. Local and regional developmental cores [data file]. Slovenia, Ljubljana: Inštitut za razvojne in strateške analize = The institute for developmental and strategic analysis / Slovenia, Nova Gorica: Fakulteta za uporabne družbene študije v Novi Gorici = School of Advanced Social Studies in Nova Gorica [production], 2010. Slovenia, Ljubljana: Univerza v Ljubljani = University of Ljubljana, Arhiv družboslovnih podatkov = Social Science Data Archive [distribution], 2010.</bibliographicCitation>
               </CitationInfo>
               
               <!-- @cmd:ref = /codeBook/fileDscr/@ID -->
               <Subresource> <!--cmd:ref="IDGradiva1874">-->
                   <SubresourceDescription>
                       <!-- /codeBook/fileDscr/fileTxt/fileName -->
                       <label xml:lang="sl-SI">RAZJED10 - Goriška regija - transkripti (intervjuji, fokusna skupina) [data file], 2010</label>
                       <!-- /codeBook/fileDscr/dimensns/caseQnty -->
                       <description>caseQnty: 9</description>
                   </SubresourceDescription>
               </Subresource>
               <!-- @cmd:ref = /codeBook/fileDscr/@ID -->
               <Subresource><!-- cmd:ref="IDGradiva1876">-->
                   <SubresourceDescription>
                       <!-- /codeBook/fileDscr/fileTxt/fileName -->
                       <label xml:lang="sl-SI">RAZJED10 - Jugovzhodna regija - transkripti (intervjuji, fokusna skupina) [data file], 2010</label>
                       <!-- /codeBook/fileDscr/dimensns/caseQnty -->
                       <description>caseQnty: 3</description>
                   </SubresourceDescription>
               </Subresource>
               <!-- @cmd:ref = /codeBook/fileDscr/@ID -->
               <Subresource><!-- cmd:ref="IDGradiva1878">-->
                   <SubresourceDescription>
                       <!-- /codeBook/fileDscr/fileTxt/fileName -->
                       <label xml:lang="sl-SI">RAZJED10 - Obalno-kraška regija - transkripti (intervjuji, fokusna skupina) [data file], 2010</label>
                       <!-- /codeBook/fileDscr/dimensns/caseQnty -->
                       <description>caseQnty: 7</description>
                   </SubresourceDescription>
               </Subresource>
               <!-- @cmd:ref = /codeBook/fileDscr/@ID -->
               <Subresource><!-- cmd:ref="IDGradiva1880">-->
                   <SubresourceDescription>
                       <!-- /codeBook/fileDscr/fileTxt/fileName -->
                       <label xml:lang="sl-SI">RAZJED10 - Osrednjeslovenska regija - transkript (fokusna skupina) [data file], </label>
                       <!-- /codeBook/fileDscr/dimensns/caseQnty -->
                       <description>caseQnty: 7</description>
                   </SubresourceDescription>
               </Subresource>
               <!-- @cmd:ref = /codeBook/fileDscr/@ID -->
               <Subresource><!-- cmd:ref="IDGradiva1882">-->
                   <SubresourceDescription>
                       <!-- /codeBook/fileDscr/fileTxt/fileName -->
                       <label xml:lang="sl-SI">RAZJED10 - Pomurje - transkript (fokusna skupina) [data file], 2010</label>
                       <!-- /codeBook/fileDscr/dimensns/caseQnty -->
                       <description>caseQnty: 1</description>
                   </SubresourceDescription>
               </Subresource>
               
               <RelatedResource>
                   <!-- /codeBook/stdyDscr/othrStdyMat/relMat/citation/titlStmt/titl -->
                   <label>RAZJED10 - Lokalna in regionalna razvojna jedra, poročilo [other documents]</label>
                   <!-- /codeBook/stdyDscr/othrStdyMat/relMat/citation/holdings/@URI -->
                   <location>https://www.adp.fdv.uni-lj.si/media/podatki/razjed10/razjed10-porocilo.pdf</location>
               </RelatedResource>
               <RelatedResource>
                   <!-- /codeBook/otherMat/citation/titlStmt/titl -->
                   <label>RAZJED10 - Lokalna in regionalna razvojna jedra [Questionnaire]</label>
                   <!-- /codeBook/otherMat/@URI + /codeBook/otherMat/citation/holdings -->
                   <location>http://www.adp.fdv.uni-lj.si/podatki/razjed10/razjed10-vp.pdf</location>
                   <CitationInfo>
                       <!-- /codeBook/otherMat/citation/rspStmt + /codeBook/otherMat/citation/prodStmt -->
                       <bibliographicCitation>Adam, Frane. 2010. IRSA, Ljubljana</bibliographicCitation>
                   </CitationInfo>
               </RelatedResource>
               <!-- Skipped 10 additional related resources from /codeBook/otherMat -->
               
               <MetadataInfo>
                   <IdentificationInfo>
                       <identifier>RAZJED10</identifier>
                   </IdentificationInfo>
                   <TitleInfo>
                       <!-- /codeBook/docDscr/citation/titlStmt/titl -->
                       <title xml:lang="en-GB">Local and regional developmental cores</title>
                       <title xml:lang="sl-SI">Lokalna in regionalna razvojna jedra</title>
                   </TitleInfo>
                   <Creator>
                       <!-- /codeBook/docDscr/citation/rspStmt/AuthEnty -->
                       <label>Adam, Frane</label>
                       <AgentInfo>
                           <PersonInfo>
                               <!-- /codeBook/docDscr/citation/rspStmt/AuthEnty -->
                               <name>Adam, Frane</name>
                               <!-- /codeBook/docDscr/citation/rspStmt/AuthEnty/@affiliation -->
                               <affiliation>Inštitut za razvojne in strateške analize = The institute for developmental and strategic analysis</affiliation>
                           </PersonInfo>
                       </AgentInfo>
                   </Creator>
                   <Contributor>
                       <!-- /codeBook/docDscr/citation/distStmt -->
                       <label>Arhiv družboslovnih podatkov = Social Science Data Archive</label>
                       <role>Distributor</role>
                   </Contributor>
                   <CitationInfo>
                       <!-- /codeBook/docDscr/citation/biblCit -->
                       <!-- @format = /codeBook/docDscr/citation/biblCit/@format -->
                       <bibliographicCitation format="MRDF">Adam, Frane et al. Local and regional developmental cores [codebook file]. Slovenia, Ljubljana: Univerza v Ljubljani = University of Ljubljana, Arhiv družboslovnih podatkov = Social Science Data Archive [production, distribution], 2010.</bibliographicCitation>
                   </CitationInfo>
                   <ProvenanceInfo>
                       <Creation>
                           <ActivityInfo>
                               <!-- /codeBook/docDscr/citation/prodStmt/software -->
                               <method>&lt;oXygen/&gt; - XML edito</method>
                               <!-- /codeBook/docDscr/citation/prodStmt/copyright -->
                               <note>Copyright ADP, 2010</note>
                               <When>
                                   <!-- /codeBook/docDscr/citation/prodStmt/prodDate -->
                                   <label>May 2010</label>
                                   <date>2010-05-01</date>
                               </When>
                               <Responsible>
                                   <!-- /codeBook/docDscr/citation/prodStmt/producer -->
                                   <label>Arhiv družboslovnih podatkov = Social Science Data Archive</label>
                               </Responsible>
                           </ActivityInfo>
                       </Creation>
                   </ProvenanceInfo>
                   <FundingInfo>
                       <Funding>
                           <!-- /codeBook/docDscr/citation/prodStmt/grantNo -->
                           <grantNumber>1000-09-160510 (IRC)</grantNumber>
                           <FundingAgency>
                               <!-- /codeBook/docDscr/citation/prodStmt/fundAg -->
                               <label>Agencija za raziskovalno dejavnost Republike Slovenije= Slovenian Research Agency</label>
                           </FundingAgency>
                       </Funding>
                   </FundingInfo>
               </MetadataInfo>
           </ADP-DDI>
        </cmd:Components>
    </xsl:template>

    <!-- OLD -->
    <xsl:template mode="to-datacite" match="/codeBook">
        
        <!-- <identifier/> -->
        <!-- TODO: AlternateIdentifier ?? -->
        <xsl:choose>
            <xsl:when test="stdyDscr/citation/titlStmt/IDNo[contains(.,'doi.org')]">
                <identifier identifierType="DOI"><xsl:value-of select="stdyDscr/citation/titlStmt/IDNo[contains(.,'doi.org')][1]"/></identifier>
            </xsl:when>
            <xsl:when test="stdyDscr/citation/titlStmt/IDNo">
                <identifier>
                    <xsl:attribute name="identifierType"><xsl:value-of select="stdyDscr/citation/titlStmt/IDNo[1]/@agency"/></xsl:attribute>
                    <xsl:value-of select="stdyDscr/citation/titlStmt/IDNo[1]"/></identifier>
            </xsl:when>
            <xsl:when test="docDscr/citation/titlStmt/IDNo">
                <identifier>
                    <xsl:attribute name="identifierType"><xsl:value-of select="docDscr/citation/titlStmt/IDNo[1]/@agency"/></xsl:attribute>
                    <xsl:value-of select="docDscr/citation/titlStmt/IDNo[1]"/></identifier>
            </xsl:when>
            <xsl:otherwise>
                <identifier identifierType="none">-</identifier>
                <xsl:message>WARNING: No identifier found</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
        
        <!-- <creators/> -->
        <xsl:if test="stdyDscr/citation/rspStmt/AuthEnty">
            <creators>
                <xsl:apply-templates select="stdyDscr/citation/rspStmt/AuthEnty" />
            </creators>
        </xsl:if>
        
        <!-- <titles/> -->
        <titles>
            <xsl:apply-templates select="stdyDscr/citation/titlStmt/titl" />
            <xsl:apply-templates select="stdyDscr/citation/titlStmt/parTitl" />
        </titles>
        
        <!-- <publisher/> -->
        <xsl:apply-templates select="stdyDscr/citation/distStmt/distrbtr" />

        <!-- <publicationYear/> -->
        <xsl:apply-templates select="stdyDscr/citation/distStmt/distDate" mode="publication-year" />
        
        <!-- <resourceType/> -->
        <xsl:choose>
            <xsl:when test="count(stdyDscr/stdyInfo/sumDscr/dataKind) = 1">
                <xsl:apply-templates select="stdyDscr/stdyInfo/sumDscr/dataKind" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="stdyDscr/stdyInfo/sumDscr/dataKind[1]">
                    <xsl:with-param name="concatenated"  select="string-join(stdyDscr/stdyInfo/sumDscr/dataKind, ';')" />
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
        
        
        
        <!-- <subjects/> -->
        <xsl:if test="stdyDscr/stdyInfo/subject">
            <subjects>
                <xsl:apply-templates select="stdyDscr/stdyInfo/subject/keyword" />
                <xsl:apply-templates select="stdyDscr/stdyInfo/subject/topcClas" />
            </subjects>
        </xsl:if>
        
        <!-- <contributors/> -->
        <xsl:variable name="contributors">
            <xsl:apply-templates select="docDscr/citation/prodStmt/producer" />
            <xsl:apply-templates select="docDscr/citation/verStmt/verResp" />
            <xsl:apply-templates select="stdyDscr/citation/prodStmt/producer" />
            <xsl:apply-templates select="stdyDscr/citation/distStmt/depositr" />
            <xsl:apply-templates select="stdyDscr/dataAccs/useStmt/contact" />
        </xsl:variable>
        
        <xsl:if test="normalize-space($contributors) != ''">
            <contributors>
                <xsl:copy-of select="$contributors" />
            </contributors>
        </xsl:if>
        
        <!-- <dates/> -->
        <xsl:variable name="dates">
            <xsl:apply-templates select="stdyDscr/citation/distStmt/depDate" />
            <xsl:apply-templates select="stdyDscr/citation/distStmt/distDate" />
            <xsl:apply-templates select="stdyDscr/stdyInfo/sumDscr/collDate" />
        </xsl:variable>

        <xsl:if test="normalize-space($dates) != ''">
            <dates>
                <xsl:copy-of select="$dates" />
            </dates>
        </xsl:if>
        
        <!-- <relatedIdentifiers/> -->
        <xsl:variable name="relatedIdentifiers">
            <xsl:apply-templates select="." mode="related-identifier-md" />
            <xsl:apply-templates select="stdyDscr/dataAccs/setAvail/accsPlac/@URI" />
            <xsl:apply-templates select="fileDscr" mode="related-identifier" />
            <xsl:apply-templates select="otherMat" mode="related-identifier" />
            <xsl:apply-templates select="stdyDscr/othrStdyMat/relPubl/citation" mode="related-identifier" />
        </xsl:variable>
        
        <xsl:if test="normalize-space($relatedIdentifiers) != ''">
            <relatedIdentifiers>
                <xsl:copy-of select="$relatedIdentifiers" />
            </relatedIdentifiers>
        </xsl:if>
        
        <!-- <sizes/> -->
        <xsl:if test="fileDscr/fileTxt/dimensns">
            <sizes>
                <xsl:apply-templates select="fileDscr/fileTxt/dimensns" />
            </sizes>
        </xsl:if>
        
        <!-- <formats/> -->
        <xsl:if test="count(fileDscr/fileTxt/fileType) > 0">
            <formats>
                <!-- only output distinct values, therefore group by value -->
                <xsl:for-each-group select="fileDscr/fileTxt/fileType" group-by="text()">
                    <format><xsl:value-of select="current-grouping-key()"/></format>
                </xsl:for-each-group>
            </formats>
        </xsl:if>

        <!-- <version/> -->
        <xsl:if test="count(fileDscr/fileTxt/verStmt/version) = 1">
            <version><xsl:value-of select="fileDscr/fileTxt/verStmt/version"/></version> <!-- of the file -->    
        </xsl:if>
        
        <!-- <rightsList/> -->
        <xsl:apply-templates select="stdyDscr/dataAccs/useStmt" />
                
        <!-- <descriptions/> -->
        <xsl:variable name="descriptions">
            <xsl:apply-templates select="stdyDscr/stdyInfo/abstract" />
            <xsl:apply-templates select="stdyDscr/method" />
        </xsl:variable>
        
        <xsl:if test="normalize-space($descriptions) != ''">
            <descriptions>
                <xsl:copy-of select="$descriptions" />
            </descriptions>
        </xsl:if>
        
        <!-- <geoLocations /> -->
            
        <xsl:variable name="geoLocations">
            <xsl:apply-templates select="stdyDscr/stdyInfo/sumDscr/nation" />
            <xsl:apply-templates select="stdyDscr/stdyInfo/sumDscr/geogCover" />
        </xsl:variable>
        
        <xsl:if test="count($geoLocations/datacite:geoLocation) > 0">
            <geoLocations>
                <!-- only output distinct values, therefore group by value -->
                <xsl:for-each-group select="$geoLocations/datacite:geoLocation" group-by="concat(datacite:geoLocationPlace/@xml:lang, datacite:geoLocationPlace)">
                    <xsl:sequence select="."/>
                </xsl:for-each-group>
            </geoLocations>
        </xsl:if>

        <!-- <fundingReferences /> -->
        <xsl:if test="stdyDscr/citation/prodStmt/fundAg|stdyDscr/citation/prodStmt/grantNo">
            <fundingReferences>
                <fundingReference>
                    <xsl:apply-templates select="stdyDscr/citation/prodStmt/fundAg" />
                    <xsl:apply-templates select="stdyDscr/citation/prodStmt/grantNo" />
                </fundingReference>
            </fundingReferences>
        </xsl:if>      
    </xsl:template>
    
    <xsl:template match="stdyDscr/citation/prodStmt/fundAg">
        <funderName><xsl:value-of select="normalize-space(.)"/></funderName>
    </xsl:template>
    
    <xsl:template match="stdyDscr/citation/prodStmt/grantNo">
        <awardNumber><xsl:value-of select="normalize-space(.)"/></awardNumber>
    </xsl:template>
    
    <xsl:template match="stdyDscr/citation/rspStmt/AuthEnty">
        <creator>
            <creatorName><xsl:value-of select="."/></creatorName>
            <affiliation><xsl:value-of select="@affiliation"/></affiliation>
        </creator>        
    </xsl:template>
    
    <xsl:template match="titlStmt/titl">
        <title>
            <xsl:if test="@xml:lang"><xsl:attribute name="xml:lang" select="@xml:lang" /></xsl:if>
            <xsl:value-of select="normalize-space(.)"/>
        </title>
    </xsl:template>

    <xsl:template match="titlStmt/parTitl">
        <title titleType="TranslatedTitle">
            <xsl:if test="@xml:lang"><xsl:attribute name="xml:lang" select="@xml:lang" /></xsl:if>
            <xsl:value-of select="normalize-space(.)"/>
        </title>
    </xsl:template>

    <xsl:template match="stdyDscr/citation/distStmt/distrbtr">
        <publisher><xsl:value-of select="."/></publisher>
    </xsl:template>
    
    <xsl:template match="stdyDscr/citation/distStmt/distDate" mode="publication-year">
        <!-- value for <publicationYear> -->
        <xsl:choose>
            <xsl:when test="@date and matches(normalize-space(@date),'^\d{4}(-.+)*$')">
                <!-- only render if there is a @date property with format yyyy[-...] -->
                <publicationYear>
                    <xsl:value-of select="substring(normalize-space(@date),1,4)"/>
                </publicationYear>
            </xsl:when>
            <xsl:otherwise>
                <!-- render a comment with the original value --> 
                <xsl:comment>&lt;publicationYear&gt;&lt;distDate date=&quot;<xsl:value-of select="@date"/>&quot;&gt;<xsl:value-of select="." />&lt;/distDate&gt;&lt;/publicationYear&gt;</xsl:comment>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="stdyDscr/stdyInfo/sumDscr/dataKind">
        <xsl:param name="concatenated" />
        <xsl:choose>
            <xsl:when test="normalize-space($concatenated) != ''">
                <resourceType resourceTypeGeneral="Dataset"><xsl:value-of select="$concatenated"/></resourceType>        
            </xsl:when>
            <xsl:otherwise>
                <resourceType resourceTypeGeneral="Dataset"><xsl:value-of select="."/></resourceType>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="stdyDscr/stdyInfo/subject/keyword">
        <subject><xsl:value-of select="normalize-space(.)"/></subject>
    </xsl:template>
    
    <xsl:template match="stdyDscr/stdyInfo/subject/topcClas">
        <subject>
            <xsl:if test="@vocabURI">
                <xsl:attribute name="schemeURI" select="@vocabURI"></xsl:attribute>
            </xsl:if>
            <xsl:value-of select="normalize-space(.)"/>
        </subject>
    </xsl:template>

    <xsl:template match="docDscr/citation/prodStmt/producer">
        <contributor contributorType="Other"> <!-- metadata producer -->
            <contributorName nameType="Organizational"><xsl:value-of select="normalize-space(.)"/></contributorName>
        </contributor>
    </xsl:template>
    
    <xsl:template match="docDscr/citation/verStmt/verResp">
        <contributor contributorType="Other"> <!-- metadata version responsible -->
            <contributorName><xsl:value-of select="normalize-space(.)"/></contributorName>
        </contributor>
    </xsl:template>
    
    <xsl:template match="stdyDscr/citation/prodStmt/producer">
       <contributor contributorType="DataManager"> <!-- study producer (financially/administratively responsible) -->
           <contributorName><xsl:value-of select="normalize-space(.)"/></contributorName>
       </contributor>
    </xsl:template>
    
    <xsl:template match="stdyDscr/citation/distStmt/depositr">
        <contributor contributorType="DataCurator"> <!-- depositor -->
            <contributorName nameType="Organizational"><xsl:value-of select="normalize-space(.)"/></contributorName>
        </contributor>
    </xsl:template>
    
    <xsl:template match="stdyDscr/dataAccs/useStmt/contact">
        <contributor contributorType="RightsHolder"> <!-- depositor -->
            <contributorName nameType="Organizational"><xsl:value-of select="normalize-space(.)"/></contributorName>
            <xsl:if test="@affiliation">
                <affiliation><xsl:value-of select="normalize-space(@affiliation)"/></affiliation>
            </xsl:if>
        </contributor>
    </xsl:template>

    <xsl:template match="stdyDscr/citation/distStmt/depDate">
        <date dateType="Submitted"><xsl:apply-templates select="." mode="date-element" /></date>
    </xsl:template>

    <xsl:template match="stdyDscr/citation/distStmt/distDate">
        <date dateType="Issued"><xsl:apply-templates select="." mode="date-element" /></date>
    </xsl:template>

    <xsl:template match="stdyDscr/stdyInfo/sumDscr/collDate">
        <date dateType="Collected"><xsl:apply-templates select="." mode="date-element" /></date>
    </xsl:template>
    
    <xsl:template match="node()" mode="date-element">
        <xsl:if test="@event">
            <xsl:attribute name="dateInformation"><xsl:value-of select="@event"/></xsl:attribute>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="@date"><xsl:value-of select="@date"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="*" mode="related-identifier-md">
        <!-- TODO -->
        <relatedIdentifier relatedIdentifierType="URL" relationType="HasMetadata"><xsl:value-of select="document-uri()"/></relatedIdentifier>
    </xsl:template>
    
    <xsl:template match="stdyDscr/dataAccs/setAvail/accsPlac/@URI">
        <relatedIdentifier relatedIdentifierType="URL" relationType="IsReferencedBy"><xsl:value-of select="."/></relatedIdentifier> <!-- Landing page in CMDI -->
    </xsl:template>
    
    <xsl:template match="fileDscr" mode="related-identifier">
        <xsl:if test="@URI">
            <relatedIdentifier relatedIdentifierType="URL" relationType="Describes"><xsl:value-of select="@URI"/></relatedIdentifier> <!-- Resource proxy in CMDI -->
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="otherMat" mode="related-identifier">
        <xsl:if test="@URI">
            <relatedIdentifier relatedIdentifierType="URL" relationType="IsSupplementedBy"><xsl:value-of select="@URI"/></relatedIdentifier> <!-- Resource proxy in CMDI -->
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="stdyDscr/othrStdyMat/relPubl/citation" mode="related-identifier">
        <xsl:choose>
            <xsl:when test="titlStmt/IDNo/@agency='DOI'">
                <relatedIdentifier relatedIdentifierType="DOI" relationType="References"><xsl:value-of select="titlStmt/IDNo[@agency='DOI']"/></relatedIdentifier>        
            </xsl:when>
            <xsl:when test="titlStmt/IDNo/@agency='ISSN'">
                <relatedIdentifier relatedIdentifierType="ISSN" relationType="References"><xsl:value-of select="titlStmt/IDNo[@agency='ISSN']"/></relatedIdentifier>
            </xsl:when>
            <xsl:when test="titlStmt/IDNo/@agency='ISBN'">
                <relatedIdentifier relatedIdentifierType="ISBN" relationType="References"><xsl:value-of select="titlStmt/IDNo[@agency='ISBN']"/></relatedIdentifier>
            </xsl:when>
            <xsl:when test="holdings/@URI">
                <relatedIdentifier relatedIdentifierType="URL" relationType="References"><xsl:value-of select="holdings/@URI"/></relatedIdentifier>
            </xsl:when>
        </xsl:choose>       
    </xsl:template>
    
    <xsl:template match="fileTxt/dimensns">
        <xsl:if test="caseQnty and number(caseQnty)">
            <size><xsl:value-of select="caseQnty"/> cases</size>
        </xsl:if>
        <xsl:if test="varQnty and number(varQnty)">
            <size><xsl:value-of select="varQnty"/> variables</size>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="stdyDscr/dataAccs/useStmt">
        <rightsList>
            <xsl:if test="restrctn">
                <rights>
                    <xsl:if test="restrctn/@ID">
                        <xsl:attribute name="rightsIdentifier"><xsl:value-of select="restrctn/@ID"/></xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="normalize-space(restrctn)"/></rights>
            </xsl:if>
            <xsl:apply-templates select="citReq" />
            <xsl:apply-templates select="deposReq" />
            <xsl:apply-templates select="conditions" />
        </rightsList>
    </xsl:template>
    
    <xsl:template match="useStmt/citReq|useStmt/deposReq|useStmt/conditions">
        <rights><xsl:value-of select="."/></rights>
    </xsl:template>
    
    <xsl:template match="stdyDscr/stdyInfo/abstract">
        <description descriptionType="Abstract">
            <xsl:if test="@xml:lang"><xsl:attribute name="xml:lang"><xsl:value-of select="@xml:lang"/></xsl:attribute></xsl:if>
            <xsl:value-of select="normalize-space(.)"/>
        </description>
    </xsl:template>
    
    
    <xsl:template match="stdyDscr/method">
        <!-- TODO -->
        <xsl:comment>
            &lt;description descriptionType="Methods"&gt;
                <xsl:sequence select="." />
            &lt;/description&gt;
        </xsl:comment>
    </xsl:template>

    <xsl:template match="stdyInfo/sumDscr/nation|stdyInfo/sumDscr/geogCover">
        <geoLocation>
            <geoLocationPlace>
                <xsl:if test="@xml:lang"><xsl:attribute name="xml:lang"><xsl:value-of select="@xml:lang"/></xsl:attribute></xsl:if>
                <xsl:value-of select="normalize-space(.)"/></geoLocationPlace>
        </geoLocation>
    </xsl:template>
    
    <!-- Custom functions -->
    
    <xsl:function name="ddi_cmd:toFullDate">
        <xsl:param name="value" />
        <xsl:choose>
            <xsl:when test="ddi_cmd:isDate($value)">
                <!-- full date, return as is -->
                <xsl:sequence select="$value" />
            </xsl:when>
            <xsl:when test="matches($value, '^\d{4}-[0-1]\d$')">
                <!-- only month; round to yyyy-mm-01 -->
                <xsl:sequence select="concat($value,'-01')" />
            </xsl:when>
            <xsl:when test="matches($value, '^\d{4}$')">
                <!-- only year; round to yyyy-01-01 -->
                <xsl:sequence select="concat($value,'-01-01')" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="false()" />
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
    
    <xsl:function name="ddi_cmd:isUri">
        <xsl:param name="value" />
        <xsl:sequence select="matches($value,'^(http|https|hdl|doi):.*$')" />
    </xsl:function>
    
    <xsl:function name="ddi_cmd:isDate">
        <xsl:param name="value" />
        <xsl:sequence select="matches($value,'^\d{4}-[0-1]\d-[0-3]\d$')" />
    </xsl:function>
    
</xsl:stylesheet>