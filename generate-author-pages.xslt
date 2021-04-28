<?xml version="1.0" encoding="UTF-8" ?>

<xsl:stylesheet version="2.0" exclude-result-prefixes="xs xdt err fn" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xdt="http://www.w3.org/2005/xpath-datatypes" xmlns:err="http://www.w3.org/2005/xqt-errors">
	<xsl:output method="html" indent="yes"  use-character-maps="html-illegal-chars"/>
	<xsl:character-map name="html-illegal-chars">
		<xsl:output-character character="&#150;" string=" "/>
	</xsl:character-map>

	<!-- ************************** Section 1 : Variables ************************* -->

	<xsl:variable name="AuthorSelection">
		<xsl:for-each select="*/*/author | */*/editor">
			<xsl:element name="author">
				<xsl:value-of select="."/>
			</xsl:element>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="dblps">
		<xsl:for-each select="*/*">
			<xsl:element name="dblp">
				<xsl:copy-of select="."/>
			</xsl:element>
		</xsl:for-each>
	</xsl:variable>
	<xsl:template match="/">
		<!-- *************************** Section 2 : MAIN *************************************** -->

		<xsl:for-each-group select="$AuthorSelection/author | $AuthorSelection/editor" group-by=".">
			<xsl:if test="position() ne 1"/>
			<xsl:variable name="AuthorName">
				<xsl:value-of select="."/>
			</xsl:variable>
			<xsl:variable name="Last_Name">
				<xsl:value-of select="replace(tokenize(.,' ')[last()], '[^a-zA-Z0-9 -.]','=')"/>
			</xsl:variable>
			<xsl:variable name="first_Name">
				<xsl:value-of select="substring-before(replace(replace(., '[^a-zA-Z0-9 -.]', '='), ' ','_'),$Last_Name)"/>
			</xsl:variable>
			<xsl:variable name="first_Letter">
				<xsl:value-of select="translate(substring($Last_Name, 1, 1), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/>
			</xsl:variable>
			<xsl:result-document method="html" href="a-tree/{$first_Letter}/{$Last_Name}.{$first_Name}.html">
				<html>
					<head>
						<title>
							Publication of <xsl:value-of select="$AuthorName"/>
						</title>
					</head>
					<body>
						<h1>
							<a href="../">HOME </a>
						</h1>
						<h1>
							<xsl:value-of select="$AuthorName"/>
						</h1>
						<table border="1">
							<xsl:call-template name="SelectionYear">
								<xsl:with-param name="P_AuthorName" select="$AuthorName"/>
							</xsl:call-template>
						</table>
						<h1> Co-author index </h1>
						<table border="1">
							<xsl:call-template name="CoAuthorSelection">
								<xsl:with-param name="P_AuthorName" select="$AuthorName"/>
								<xsl:with-param name="P_Last_Name" select="$Last_Name"/>
								<xsl:with-param name="P_first_Name" select="$first_Name"/>
							</xsl:call-template>
						</table>
					</body>
				</html>
			</xsl:result-document>
		</xsl:for-each-group>
	</xsl:template>

	<!-- ********************************************* Section 3: List of templates ############################ -->
	<!-- saves the list of names of the co authors of the selected author  -->
	<xsl:template name="AuthorList">
		<xsl:for-each select="author | editor">
			<xsl:element name="Author">
				<xsl:value-of select="."/>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>

	<!-- The template displays and sorts by date the information from the first table -->
	<xsl:template name="SelectionYear">
		<xsl:param name="P_AuthorName"/>
		<xsl:variable name="GroupYears">
			<xsl:for-each select="$dblps/dblp">
				<xsl:for-each select="*[author=$P_AuthorName] | *[editor=$P_AuthorName]">
					<xsl:element name="GroupYear">
						<xsl:element name="year">
							<xsl:value-of select="year"/>
						</xsl:element>
						<xsl:element name="title">
							<xsl:value-of select="title"/>
						</xsl:element>
						<xsl:element name="booktitle">
							<xsl:value-of select="booktitle"/>
						</xsl:element>
						<xsl:element name="isbn">
							<xsl:value-of select="isbn"/>
						</xsl:element>
						<xsl:element name="journal">
							<xsl:value-of select="journal"/>
						</xsl:element>
						<xsl:element name="pages">
							<xsl:value-of select="pages"/>
						</xsl:element>
						<xsl:element name="volume">
							<xsl:value-of select="volume"/>
						</xsl:element>
						<xsl:element name="number">
							<xsl:value-of select="number"/>
						</xsl:element>
						<xsl:element name="CoAuthors">
							<xsl:call-template name="AuthorList"/>
						</xsl:element>
						<xsl:element name="ee">
							<xsl:value-of select="ee"/>
						</xsl:element>
					</xsl:element>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:variable>
		<xsl:for-each-group select="$GroupYears/GroupYear/year" group-by="replace(., '\.$', '')">
			<xsl:sort select="." data-type="number" order="descending"/>
			<xsl:variable name="Indexs" select="position()"/>
			<xsl:if test="position() ne 1"/>
			<xsl:variable name="Isyear" select="replace(., '\.$', '')"/>
			<tr>
				<th colspan="3" bgcolor="#FFFFCC">
					<xsl:value-of select="$Isyear"/>
				</th>
			</tr>
			<xsl:for-each select="$GroupYears">
				<xsl:for-each select="GroupYear[year=$Isyear]">
					<xsl:sort select="title" />
					<tr>
						<td align="right" valign="top">
							<xsl:variable name="Index" select="$Indexs + position() - 1"/>
							<xsl:for-each select="number(count($GroupYears/GroupYear/year))">
								<xsl:variable name="TotalPublisher" select="."/>
								<xsl:value-of select="$TotalPublisher - $Index + 1"/>
							</xsl:for-each>
						</td>
						<td>
							<xsl:if test="ee !='' ">
								<xsl:variable name="Test">
									<xsl:value-of select="ee"/>
								</xsl:variable>
								<a href="{$Test}">
									<img alt="Electronic Edition" title="Electronic Edition" src="http://www.informatik.uni-trier.de/~ley/db/ee.gif" border="0" height="16" width="16"/>
								</a>
							</xsl:if>
						</td>
						<td>
							<xsl:for-each select="CoAuthors">

								<xsl:for-each select="Author">
									<xsl:variable name="Last_Name">
										<xsl:value-of select="replace(tokenize(.,' ')[last()], '[^a-zA-Z0-9 -.]','=')"/>
									</xsl:variable>
									<xsl:variable name="first_Name">
										<xsl:value-of select="substring-before(replace(replace(., '[^a-zA-Z0-9 -.]', '='), ' ','_'),$Last_Name)"/>
									</xsl:variable>
									<xsl:variable name="first_Letter">
										<xsl:value-of select="translate(substring($Last_Name, 1, 1), 'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
									</xsl:variable>
									<xsl:choose>
										<xsl:when test="$P_AuthorName != .">
											<a href="../{$first_Letter}/{$Last_Name}.{$first_Name}.html">
												<xsl:value-of select="."/>
											</a>,
</xsl:when>
										<xsl:when test="$P_AuthorName = .">
											<xsl:value-of select="."/>,
</xsl:when>
									</xsl:choose>
								</xsl:for-each>
							</xsl:for-each>
												: <xsl:value-of select="title"/>

												<xsl:if test="booktitle !='' ">
													 <xsl:text> </xsl:text><xsl:value-of select="booktitle"/>
												</xsl:if>

											<xsl:text> </xsl:text><xsl:value-of select="year"/>

												<xsl:if test="isbn !='' ">
													: <xsl:value-of select="isbn"/>
												</xsl:if>
												<xsl:if test="journal !='' ">
													<xsl:text> </xsl:text><xsl:value-of select="journal"/>
													<xsl:text> </xsl:text><xsl:value-of select="volume"/>
													(<xsl:value-of select="number"/>)
												</xsl:if>
												<xsl:if test="pages !='' ">
													: <xsl:value-of select="pages"/>
												</xsl:if>
						</td>
					</tr>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:for-each-group>
	</xsl:template>

<!-- Displays the list of co authors and gathers the information in table 2  -->

	<xsl:template name="CoAuthorSelection">
		<xsl:param name="P_AuthorName"/>
		<xsl:param name="P_Last_Name"/>
		<xsl:param name="P_first_Name"/>
		<xsl:variable name="Co_authors">
			<xsl:for-each select="$dblps/dblp">
				<xsl:for-each select="*[author=$P_AuthorName] | *[editor=$P_AuthorName] ">
					<xsl:element name="List_of_CoAuthors">
						<xsl:for-each select="author | editor">
							<xsl:if test="not(node()= $P_AuthorName)">
								<xsl:element name="Co_author">
									<xsl:value-of select="."/>
								</xsl:element>
							</xsl:if>
						</xsl:for-each>
					</xsl:element>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:variable>
		<xsl:for-each-group select="$Co_authors/List_of_CoAuthors/Co_author" group-by="replace(., '\.$', '')">
			<xsl:sort select="." order="ascending"/>

			<xsl:if test="position() ne 1"/>
			<xsl:variable name="IsCo_author" select="replace(., '\.$', '')"/>
			<tr>
				<td align="right">
					<xsl:variable name="Last_Name">
						<xsl:value-of select="replace(tokenize(.,' ')[last()], '[^a-zA-Z0-9 -.]','=')"/>
					</xsl:variable>
					<xsl:variable name="first_NameCo">
						<xsl:value-of select="substring-before(replace(replace(., '[^a-zA-Z0-9 -.]', '='), ' ','_'),$Last_Name)"/>
					</xsl:variable>
					<xsl:variable name="first_LetterCo">
						<xsl:value-of select="translate(substring($Last_Name, 1, 1), 'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
					</xsl:variable>
					<a href="../{$first_LetterCo}/{$Last_Name}.{$first_NameCo}.html">
						<xsl:value-of select="$IsCo_author"/>
					</a>
				</td>
				<td align="left">
					<xsl:for-each select="number(count($dblps/*/*[author=$P_AuthorName] | $dblps/*/*[editor=$P_AuthorName] ))">
						<xsl:variable name="TotalCo_author" select="."/>
						<xsl:for-each select="$Co_authors/List_of_CoAuthors">
							<xsl:variable name="Indexs" select="position()"/>
							<xsl:for-each select="Co_author">
								<xsl:variable name="PageArticle" select="$TotalCo_author - $Indexs + 1"/>
								<xsl:if test="$IsCo_author = .">
					[<a href="{$P_Last_Name}.{$P_first_Name}.html#p{$PageArticle}">
									<xsl:value-of select="$PageArticle"/>
					 </a>]<xsl:text> </xsl:text>
				 		</xsl:if>
		</xsl:for-each>
	</xsl:for-each>
</xsl:for-each>

			</td>
			</tr>
		</xsl:for-each-group>
	</xsl:template>
</xsl:stylesheet>

