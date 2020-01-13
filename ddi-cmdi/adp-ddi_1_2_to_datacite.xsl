<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://datacite.org/schema/kernel-4"
    xsi:schemaLocation="http://datacite.org/schema/kernel-4 http://schema.datacite.org/meta/kernel-4.3/metadata.xsd"
    exclude-result-prefixes="xs"
    xpath-default-namespace=""
    version="2.0">

    <!--
        DDI 1.2.2 to DataCite Kernel 4.3 conversion stylesheet
        Made for ADP use cases (Arhiv družboslovnih podatkov / Social Science Data Archives, Ljubljana, SI)
        Author: Twan Goosen (CLARIN ERIC) <twan@clarin.eu>
    -->

    <xsl:output indent="yes"></xsl:output>
    
    <xsl:template match="/codeBook">
    
    <resource xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns="http://datacite.org/schema/kernel-4"
        xsi:schemaLocation="http://datacite.org/schema/kernel-4 http://schema.datacite.org/meta/kernel-4.3/metadata.xsd">
                
        <!-- <identifier/> -->
        <identifier identifierType="codeBook"><xsl:value-of select="@ID"/></identifier>
        
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
        <xsl:if test="fileDscr/fileTxt/fileType">
            <formats>
                <xsl:apply-templates select="fileDscr/fileTxt/fileType" />
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
        
        <xsl:if test="normalize-space($geoLocations) != ''">
            <geoLocations>
                <xsl:copy-of select="$geoLocations" />
            </geoLocations>
        </xsl:if>

        <!-- <fundingReferences /> -->
        <xsl:if test="stdyDscr/citation/prodStmt/fundAg|stdyDscr/citation/prodStmt/grantNo">
            <fundingReferences>
                <fundingReference>
                    <funderName><xsl:value-of select="normalize-space(stdyDscr/citation/prodStmt/fundAg)"/></funderName>
                    <awardNumber><xsl:value-of select="normalize-space(stdyDscr/citation/prodStmt/grantNo)"/></awardNumber>
                </fundingReference>
            </fundingReferences>
        </xsl:if>       
    </resource>
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
    
    <xsl:template match="fileTxt/fileType">
        <format><xsl:value-of select="."/></format>
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

    <xsl:template match="codeBook" mode="cmd-header">
    <!-- 
        <cmd:Header>
            <cmd:MdCreator>{{/codeBook/docDscr/citation/verStmt/verResp}} Sergeja Masten, ADP</cmd:MdCreator>
            <cmd:MdCreationDate>{{/codeBook/docDscr/citation/prodStmt/prodDate/@date}}2017-12</cmd:MdCreationDate>
            <cmd:MdSelfLink>?????</cmd:MdSelfLink>
            <cmd:MdProfile>clarin.eu:cr1:p_xxxxxxxx</cmd:MdProfile>
            <cmd:MdCollectionDisplayName>????</cmd:MdCollectionDisplayName>
        </cmd:Header>
        <cmd:Resources>
            <cmd:ResourceProxyList>
               <cmd:ResourceProxy id="">
                <cmd:ResourceType>LandingPage</cmd:ResourceType>
                <cmd:ResourceRef>{/codeBook/stdyDscr/dataAccs/setAvail/accsPlac/@URI} http://www.adp.fdv.uni-lj.si/podatki/</cmd:ResourceRef>
               </cmd:ResourceProxy>
               <cmd:ResourceProxy id="F1">
                <cmd:ResourceType>Resource</cmd:ResourceType>
                <cmd:ResourceRef>{/codeBook/fileDscr/@URI} https://www.adp.fdv.uni-lj.si/opisi/dostop/</cmd:ResourceRef>
               </cmd:ResourceProxy>
            </cmd:ResourceProxyList>
        </cmd:Resources>
    -->
    </xsl:template>
    
</xsl:stylesheet>