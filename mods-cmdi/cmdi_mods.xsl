<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.clarin.eu/cmd/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:doc="http://www.lyncode.com/xoai"
	version="1.0">

    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

    <xsl:key name="iso-lookup" match="lang" use="sil"/>
    <xsl:key name="provider-lookup" match="prov" use="identifier"/>

	
	<xsl:output omit-xml-declaration="yes" method="xml" indent="yes" />
	<xsl:variable name="portnumber"><xsl:text>:8080</xsl:text></xsl:variable>

	<xsl:template match="/">
		<xsl:variable name="itemidentifier">
			<xsl:value-of select="doc:metadata/doc:element[@name='others']/doc:field[@name='identifier']/text()"/>
		</xsl:variable>
		<xsl:variable name="itempage">
			<xsl:value-of select="substring-after($itemidentifier, ':')" /> <!-- grieg.library.uu.nl:1874/1098 -->
		</xsl:variable>
		<xsl:variable name="domain">
			<xsl:value-of select="substring-before($itempage, ':')" /> <!-- grieg.library.uu.nl -->
		</xsl:variable>
		<xsl:variable name="handlepart">
			<xsl:value-of select="substring-after($itempage, ':')" /> <!-- 1874/1098 -->
		</xsl:variable>
		<xsl:variable name="itempagelink">
			<xsl:text>http://</xsl:text>
			<xsl:value-of select="$domain" />
			<!--<xsl:value-of select="$portnumber" /> add port number -->
			<xsl:text>/handle/</xsl:text>
			<xsl:value-of select="$handlepart" />
		</xsl:variable>


<!-- see http://www.clarin.eu/faq-page/273#t273n3462 for some stuff on the Resources section -->
<!-- and see http://www.clarin.eu/node/3014 for an example -->
        <CMD CMDVersion="1.1" xsi:schemaLocation="http://www.clarin.eu/cmd/ http://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/profiles/clarin.eu:cr1:p_1381926654437/xsd">
            <Header>
                <MdCreator>cmdi_mods.xsl</MdCreator>
                <MdCreationDate>
					<xsl:variable name="longdate">
						<xsl:value-of select="doc:metadata/doc:element[@name='others']/doc:field[@name='lastModifyDate']/text()"/>
					</xsl:variable>
					<xsl:value-of select="substring($longdate,1,10)" />
					<!--<xsl:for-each select="doc:metadata/doc:element[@name='others']/doc:field[@name='lastModifyDate']/text()">
						<xsl:value-of select="." />
					</xsl:for-each>-->
                </MdCreationDate>
                <MdSelfLink>
					<xsl:for-each select="doc:metadata/doc:element[@name='others']/doc:field[@name='identifier']/text()">
						<xsl:value-of select="." />
					</xsl:for-each>
                </MdSelfLink>
                <MdProfile>clarin.eu:cr1:p_1381926654437</MdProfile>
                <MdCollectionDisplayName> <!-- or real name of set? -->
                	UBU Clarin Set
                </MdCollectionDisplayName>
            </Header>
            <Resources>
                <ResourceProxyList>
					<xsl:variable name="proxyid">
						<xsl:text>h.</xsl:text>
						<xsl:value-of select="translate($handlepart, '/', '.')" />
					</xsl:variable>
					<ResourceProxy id="{$proxyid}">
						<ResourceType mimetype="text/html">LandingPage</ResourceType>
						<ResourceRef>
								<xsl:value-of select="$itempagelink"/>
						</ResourceRef>
					</ResourceProxy>
					
					<xsl:for-each select="doc:metadata/doc:element[@name='bundles']/doc:element[@name='bundle']">
						<xsl:if test="(doc:field[@name='name']/text() = 'ORIGINAL') or (doc:field[@name='name']/text() = 'CONTENT')">
							<xsl:for-each select="doc:element[@name='bitstreams']/doc:element">
								<xsl:variable name="mimetype" select="doc:field[@name='format']/text()"/>
								<xsl:variable name="bitstreamid" select="doc:field[@name='name']/text()"/>
								<xsl:variable name="sequenceid" select="doc:field[@name='sid']/text()" />
								<!-- see if we can find the bitstream sequence id-->
								<ResourceProxy>
									<xsl:attribute name="id">
										<xsl:text>h.</xsl:text>
										<xsl:value-of select="translate($handlepart, '/', '.')" />
										<xsl:text>.</xsl:text>
										<!--<xsl:value-of select="translate($bitstreamid, ' ', '.')" />-->
										<xsl:value-of select="$sequenceid"/>
										
									</xsl:attribute>
									<ResourceType mimetype="{$mimetype}">Resource</ResourceType>
									<ResourceRef>
										<xsl:value-of select="doc:field[@name='url']/text()"/>
									</ResourceRef>
								</ResourceProxy>
							</xsl:for-each>
						</xsl:if>
					</xsl:for-each>
             	</ResourceProxyList>
                <JournalFileProxyList/>
                <ResourceRelationList/>
            </Resources>
            <Components>
				<mods version="3.2">

					<edboOverlap>
						<xsl:text>no</xsl:text>
					</edboOverlap>
					
					<machineReadable>
						<xsl:text>unknown</xsl:text>
					</machineReadable>

					<!-- CLARIN demands that elements without subelements come first -->
					<!-- type of resource = type.physical; if none is given, use 'text' -->
					<typeOfResource>
						<xsl:choose>
							<xsl:when test="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element[@name='physical']/doc:element/doc:field[@name='value']">
								<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element[@name='physical']/doc:element/doc:field[@name='value']/text()" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>text</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</typeOfResource>
					
					<!-- genre; type.content plus a mapping-->
					<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element[@name='content']/doc:element/doc:field[@name='value']">
						<genre>
							<xsl:text>info:eu-repo/semantics/</xsl:text>
							<xsl:call-template name="genremapping">
								<xsl:with-param name="typecontent">
									<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element[@name='content']/doc:element/doc:field[@name='value']/text()" />
								</xsl:with-param>
							</xsl:call-template>
						</genre>
					</xsl:if>
			
					<!-- abstract -->
					<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='abstract']/doc:element/doc:field[@name='value']">
						<abstract><xsl:value-of select="." /></abstract>
					</xsl:for-each>
					
					<!--audience, if any is given -->
					<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='audience']/doc:element/doc:field[@name='value']">
						<targetAudience>
							<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='audience']/doc:element/doc:field[@name='value']/text()" />
						</targetAudience>
					</xsl:if>
					
					<!--annotation = description.note, if any is given-->
					<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='note']/doc:element/doc:field[@name='value']">
						<note>
							<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='note']/doc:element/doc:field[@name='value']/text()"/>
						</note>
					</xsl:if>
					
					<!-- classification = subject.discipline-->
					<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element[@name='discipline']/doc:element/doc:field[@name='value']">
						<classification>
							<xsl:value-of select="." />
						</classification>
					</xsl:for-each>
					
					<!-- isbn (if the item is not part of a monograph, isbn is in a different field than if it is) -->
					<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='isbn']/doc:element/doc:field[@name='value']">
						<identifier>
							<xsl:attribute name="type"><xsl:text>uri</xsl:text></xsl:attribute>
							<xsl:text>URN:ISBN:</xsl:text>
							<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='isbn']/doc:element/doc:field[@name='value']/text()" />
						</identifier>
					</xsl:if>
					
											
					<!-- and now the other elements -->
					<!-- title info -->
					<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element/doc:field[@name='value']">
						<titleInfo>
							<title><xsl:value-of select="." /></title>
						</titleInfo>
					</xsl:for-each>
					
					<!-- author info; role and ID; ID is n[handle]_[role]_position() -->
					<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='author']/doc:element/doc:field[@name='value']">
						<xsl:call-template name="contributors">
							<xsl:with-param name="contributorName"><xsl:value-of select="."/></xsl:with-param>
							<xsl:with-param name="handle"><xsl:value-of select="//doc:field[@name='handle']"/></xsl:with-param>
							<xsl:with-param name="role"><xsl:text>aut</xsl:text></xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
					
					<!--thesis advisor; similar to author, with different role -->
					<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='advisor']/doc:element/doc:field[@name='value']">
						<xsl:call-template name="contributors">
							<xsl:with-param name="contributorName"><xsl:value-of select="."/></xsl:with-param>
							<xsl:with-param name="handle"><xsl:value-of select="//doc:field[@name='handle']"/></xsl:with-param>
							<xsl:with-param name="role"><xsl:text>ths</xsl:text></xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>								
					
					<!--if thesis-->
					<xsl:variable name="typecontent" select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element[@name='content']/doc:element/doc:field[@name='value']/text()"/>
					<xsl:if test="substring($typecontent,1,4) = 'Diss'">
						<name type="corporate">
							<namePart>University Utrecht</namePart>
							<role>
								<roleTerm authority="marcrelator" type="code">dgg</roleTerm>
							</role>
						</name>
					</xsl:if>
					
					<!--conference as author -->
					<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='creator']/doc:element[@name='congress']/doc:element/doc:field[@name='value']">
						<name>
							<xsl:attribute name="type"><xsl:text>corporate</xsl:text></xsl:attribute>
							<namePart>
								<xsl:value-of select="." />
							</namePart>
							<role>
								<roleTerm>
									<xsl:attribute name="authority"><xsl:text>marcrelator</xsl:text></xsl:attribute>
									<xsl:attribute name="type"><xsl:text>code</xsl:text></xsl:attribute>
									<xsl:text>aut</xsl:text>
								</roleTerm>
							</role>
						</name>
					</xsl:for-each>
					
					<!-- corporate authors -->
					<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='creator']/doc:element[@name='corporation']/doc:element/doc:field[@name='value']">
						<name>
							<xsl:attribute name="type"><xsl:text>corporate</xsl:text></xsl:attribute>
							<namePart>
								<xsl:value-of select="." />
							</namePart>
							<role>
								<roleTerm>
									<xsl:attribute name="authority"><xsl:text>marcrelator</xsl:text></xsl:attribute>
									<xsl:attribute name="type"><xsl:text>code</xsl:text></xsl:attribute>
									<xsl:text>aut</xsl:text>
								</roleTerm>
							</role>
						</name>
					</xsl:for-each>
					
					<!--corporations in other roles; for example digitizers -->
					<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='digitizer']/doc:element/doc:field[@name='value']">
						<name>
							<xsl:attribute name="type"><xsl:text>corporate</xsl:text></xsl:attribute>
							<namePart>
								<xsl:value-of select="." />
							</namePart>
							<role>
								<roleTerm>
									<xsl:attribute name="authority"><xsl:text>marcrelator</xsl:text></xsl:attribute>
									<xsl:attribute name="type"><xsl:text>code</xsl:text></xsl:attribute>
									<xsl:text>oth</xsl:text>
								</roleTerm>
							</role>
						</name>
					</xsl:for-each>								
					
					<!-- origin info; show place and publisher only if not ispartofmonograph and not ispartofseries; else that info goes into related item -->
					<!-- edition if there is one -->
					<originInfo>
						<xsl:if test="not (doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='ispartofseries']/doc:element/doc:field[@name='value']) and not (doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='ispartofmonograph']/doc:element/doc:field[@name='value'])">

							<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element/doc:field[@name='value']">
								<publisher>
									<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element/doc:field[@name='value']/text()" />
								</publisher>
							</xsl:if>
						</xsl:if>
						
						<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='created']/doc:element/doc:field[@name='value']">
							<xsl:variable name="datecreated">
								<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='created']/doc:element/doc:field[@name='value']/text()" />
							</xsl:variable>
							<xsl:variable name="showdatecreated">
								<xsl:value-of select="substring($datecreated,1,10)" />
							</xsl:variable>
							<dateCreated encoding="iso8601">
								<xsl:value-of select="$showdatecreated"/>
							</dateCreated>
						</xsl:if>
						
						<xsl:variable name="dateissued">
							<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field[@name='value']/text()"/>
						</xsl:variable>
						<xsl:variable name="showdateissued">
							<xsl:value-of select="substring($dateissued,1,10)" />
						</xsl:variable>
						<!-- CLARIN demands dateCreated
						<dateIssued encoding="iso8601">
							<xsl:value-of select="$showdateissued" />
						</dateIssued>-->
						<dateCreated encoding="iso8601">
							<xsl:value-of select="$showdateissued" />
						</dateCreated>

						<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='edition']/doc:element/doc:element/doc:field[@name='value']">
							<edition>
								<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='edition']/doc:element/doc:element/doc:field[@name='value']/text()" />
							</edition>
						</xsl:if>
						
						<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element[@name='placeofpublication']/doc:element/doc:field[@name='value']">
							<place>
								<placeTerm>
									<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element[@name='placeofpublication']/doc:element/doc:field[@name='value']/text()" />
								</placeTerm>
							</place>
						</xsl:if>
					</originInfo>
					
					<!-- language -->
					<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='language']/doc:element/doc:element/doc:field[@name='value']">
						<language>
							<languageTerm authority="rfc3066" type="code"><xsl:value-of select="." /></languageTerm>
						</language>
					</xsl:for-each>
					
					<!-- subject = keywords; plus add coverage spatial and coverage temporal if present -->
					<subject>
						<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element[@name='keywords']/doc:element/doc:field[@name='value']">
							<topic><xsl:value-of select="." /></topic>
						</xsl:for-each>
						<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='coverage']/doc:element[@name='spatial']/doc:element/doc:field[@name='value']">
							<geographic>
								<xsl:value-of select="." />
							</geographic>
						</xsl:for-each>
						<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='coverage']/doc:element[@name='temporal']/doc:element/doc:field[@name='value']">
							<temporal>
								<xsl:value-of select="." />
							</temporal>
						</xsl:for-each>
					</subject>								
					
					<!-- ispartofmonograph or ispartofseries-->
					<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='ispartofseries']/doc:element/doc:field[@name='value'] or doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='ispartofmonograph']/doc:element/doc:field[@name='value']">
						<relatedItem>
							<xsl:attribute name="type">
								<xsl:text>host</xsl:text>
							</xsl:attribute>
							<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='ispartofissn']/doc:element/doc:field[@name='value']">
								<identifier type="uri">
									<xsl:text>URN:ISSN:</xsl:text>
									<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='ispartofissn']/doc:element/doc:field[@name='value']/text()" />
								</identifier>
							</xsl:if>
							<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='ispartofisbn']/doc:element/doc:field[@name='value']">
								<identifier type="uri">
									<xsl:text>URN:ISBN:</xsl:text>
									<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='ispartofisbn']/doc:element/doc:field[@name='value']/text()" />
								</identifier>
							</xsl:if>
							<titleInfo>
								<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='ispartofseries']/doc:element/doc:field[@name='value']">
									<title>
										<xsl:value-of select="." />
									</title>
								</xsl:for-each>
								<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='ispartofmonograph']/doc:element/doc:field[@name='value']">
									<title>
										<xsl:value-of select="." />
									</title>
								</xsl:for-each>
							</titleInfo>
							<originInfo>
								<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element/doc:field[@name='value']">
									<publisher>
										<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element/doc:field[@name='value']/text()" />
									</publisher>
								</xsl:if>
								<!--use another date if there is no date.issued -->
								<xsl:variable name="date">
									<xsl:choose>
										<xsl:when test="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='created']/doc:element/doc:field[@name='value']">
											<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='created']/doc:element/doc:field[@name='value']/text()"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field[@name='value']/text()"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								<xsl:variable name="showdate">
									<xsl:value-of select="substring($date,1,10)" />
								</xsl:variable>
								<dateCreated encoding="iso8601">
									<xsl:value-of select="$showdate" />
								</dateCreated>
								<!--
								<dateIssued encoding="iso8601">
									<xsl:value-of select="$showdate" />
								</dateIssued>-->
								
								<!--place if one is given -->
								<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element[@name='placeofpublication']/doc:element/doc:field[@name='value']">
									<place>
										<placeTerm>
											<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element[@name='placeofpublication']/doc:element/doc:field[@name='value']/text()" />
										</placeTerm>
									</place>
								</xsl:if>
							</originInfo>

							<part>
								<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='ispartofvolume']/doc:element/doc:field[@name='value']">
									<detail type="volume">
										<number>
											<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='ispartofvolume']/doc:element/doc:field[@name='value']/text()" />
										</number>
									</detail>
								</xsl:if>
								<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='ispartofissue']/doc:element/doc:field[@name='value']">
									<detail type="issue">
										<number>
											<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='ispartofissue']/doc:element/doc:field[@name='value']/text()" />
										</number>
									</detail>
								</xsl:if>
								<extent unit="page">
									<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='ispartofstartpage']/doc:element/doc:field[@name='value']">
										<start>
											<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='ispartofstartpage']/doc:element/doc:field[@name='value']/text()" />
										</start>
									</xsl:if>
									<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='ispartofendpage]']/doc:element/doc:field[@name='value']">
										<end>
											<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='ispartofendpage]']/doc:element/doc:field[@name='value']/text()" />
										</end>
									</xsl:if>
								</extent>
							</part>
						</relatedItem>
					</xsl:if>




				</mods>

						
           </Components>
        </CMD>
    </xsl:template>
			
	<xsl:template name="contributors">
		<xsl:param name="contributorName"/>
		<xsl:param name="handle" />
		<xsl:param name="role" />
		
		<xsl:variable name="familyName">
			<xsl:value-of select="substring-before($contributorName, ',')" />;
		</xsl:variable>
		<xsl:variable name="givenName">
			<xsl:value-of select="substring-after($contributorName, ',')" />;
		</xsl:variable>

		<xsl:variable name="handlenumber">
			<xsl:value-of select="substring-after($handle, '/')" />
		</xsl:variable>
		
		<xsl:variable name="authorID">
			<xsl:text>n</xsl:text>
			<xsl:value-of select="$handlenumber" />
			<xsl:text>_</xsl:text>
			<xsl:value-of select="$role" />
			<xsl:text>_</xsl:text>
			<xsl:value-of select="position()" />
		</xsl:variable>
		<name>
			<xsl:attribute name="type"><xsl:text>personal</xsl:text></xsl:attribute>
			<xsl:attribute name="ID"><xsl:value-of select="$authorID" /></xsl:attribute>
			<!-- for some reason, there's often a ; after the names; let's get rid of that -->
			<namePart type="family"><xsl:value-of select="substring-before($familyName, ';')" /></namePart>
			<namePart type="given"><xsl:value-of select="substring-before($givenName, ';')" /></namePart>
			<role>
				<roleTerm>
					<xsl:attribute name="authority"><xsl:text>marcrelator</xsl:text></xsl:attribute>
					<xsl:attribute name="type"><xsl:text>code</xsl:text></xsl:attribute>
					<xsl:value-of select="$role" />
				</roleTerm>
			</role>
		</name>
	</xsl:template>			

	<!--boring mapping of internal type.content formats to standard formats -->
	<!-- TODO: find all forms that actually occur in the database -->
	<xsl:template name="genremapping">
		<xsl:param name="typecontent" />
		
		<xsl:choose>
			<xsl:when test="substring($typecontent,1,4) = 'Anno'">
				<xsl:text>annotation</xsl:text>
			</xsl:when>
			<xsl:when test="substring($typecontent,1,4) = 'Arti'">
				<xsl:text>article</xsl:text>
			</xsl:when>
			<xsl:when test="substring($typecontent,1,4) = 'Bach'">
				<xsl:text>bachelorThesis</xsl:text>
			</xsl:when>
			<xsl:when test="$typecontent = 'Book review'">
				<xsl:text>bookReview</xsl:text>
			</xsl:when>
			<xsl:when test="substring($typecontent,1,4) = 'Book'">
				<xsl:text>book</xsl:text>
			</xsl:when>
			<xsl:when test="substring($typecontent,1,4) = 'Digi'"><!--digitized book; check database to see if this still occurs -->
				<xsl:text>book</xsl:text>
			</xsl:when>
			<xsl:when test="substring($typecontent,1,4) = 'Part'">
				<xsl:text>bookPart</xsl:text>
			</xsl:when>
			<xsl:when test="substring($typecontent,1,4) = 'Doct'">
				<xsl:text>doctoralThesis</xsl:text>
			</xsl:when>
			<xsl:when test="substring($typecontent,1,4) = 'Diss'">
				<xsl:text>doctoralThesis</xsl:text>
			</xsl:when>
			<xsl:when test="substring($typecontent,1,4) = 'Cont'">
				<xsl:text>contributionToPeriodical</xsl:text>
			</xsl:when>
			<xsl:when test="substring($typecontent,1,4) = 'News'">
				<xsl:text>contributionToPeriodical</xsl:text>
			</xsl:when>
			<xsl:when test="$typecontent = 'Conference report'">
				<xsl:text>report</xsl:text>
			</xsl:when>
			<xsl:when test="substring($typecontent,1,4) = 'Conf'">
				<xsl:text>lecture</xsl:text>
			</xsl:when>
			<xsl:when test="substring($typecontent,1,4) = 'Educ'">
				<xsl:text>lecture</xsl:text>
			</xsl:when>
			<xsl:when test="substring($typecontent,1,4) = 'Lect'">
				<xsl:text>lecture</xsl:text>
			</xsl:when>
			<xsl:when test="substring($typecontent,1,4) = 'Inau'">
				<xsl:text>lecture</xsl:text>
			</xsl:when>
			<xsl:when test="substring($typecontent,1,4) = 'Work'">
				<xsl:text>lecture</xsl:text>
			</xsl:when>
			<xsl:when test="substring($typecontent,1,4) = 'Mast'">
				<xsl:text>masterThesis</xsl:text>
			</xsl:when>
			<xsl:when test="substring($typecontent,1,4) = 'Pate'">
				<xsl:text>patent</xsl:text>
			</xsl:when>
			<!-- pamphlet as used by UvH -->
			<!--
			<xsl:when test="substring($typecontent,0,4) = 'Pamp'"> 
				<xsl:text>conferencePaper</xsl:text>
			</xsl:when>
			-->
			<xsl:when test="substring($typecontent,1,4) = 'Prep'">
				<xsl:text>preprint</xsl:text>
			</xsl:when>
			<xsl:when test="substring($typecontent,1,4) = 'Comm'">
				<xsl:text>report</xsl:text>
			</xsl:when>
			<xsl:when test="substring($typecontent,1,4) = 'Conf'">
				<xsl:text>report</xsl:text>
			</xsl:when>
			<xsl:when test="substring($typecontent,1,4) = 'Exte'">
				<xsl:text>report</xsl:text>
			</xsl:when>
			<xsl:when test="substring($typecontent,1,4) = 'Inte'">
				<xsl:text>report</xsl:text>
			</xsl:when>
			<xsl:when test="substring($typecontent,1,4) = 'Stat'">
				<xsl:text>report</xsl:text>
			</xsl:when>
			<xsl:when test="substring($typecontent,1,4) = 'Stud'">
				<xsl:text>studentThesis</xsl:text>
			</xsl:when>
			<xsl:when test="substring($typecontent,1,4) = 'Tech'">
				<xsl:text>technicalDocumentation</xsl:text>
			</xsl:when>
			<xsl:when test="substring($typecontent,1,4) = 'Rese'">
				<xsl:text>workingPaper</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>other</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	
</xsl:stylesheet>
