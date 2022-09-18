<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs"
  expand-text="yes">

  <xsl:param name="script-file-name"/>

  <xsl:output indent="yes"/>

  <xsl:variable name="groups" as="element(group)*">
    <xsl:variable name="lines" as="element(line)*">
      <xsl:variable name="container">
        <xsl:for-each select="unparsed-text-lines($script-file-name)">
          <line>
            <xsl:sequence select="."/>
          </line>
        </xsl:for-each>
      </xsl:variable>
      <xsl:sequence select="$container/line"/>
    </xsl:variable>
    <xsl:variable name="groups-container">
      <xsl:for-each-group select="$lines"
                          group-starting-with="line[starts-with(.,'BERNARD') or
                                                    starts-with(.,'ELLEN') or
                                                    starts-with(.,'DEAN')]
                                                   [not(. eq 'BERNARD!')]">
        <group>
          <xsl:for-each select="current-group()">
            <xsl:sequence select="."/>
          </xsl:for-each>
        </group>
      </xsl:for-each-group>
    </xsl:variable>
    <xsl:sequence select="$groups-container/group"/>
  </xsl:variable>

  <xsl:template match="/">
    <xsl:variable name="first-pass">
      <xsl:apply-templates select="$groups"/>
    </xsl:variable>
    <play-script>
      <xsl:apply-templates mode="cleanup" select="$first-pass"/>
    </play-script>
  </xsl:template>

  <xsl:template mode="cleanup" match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates mode="#current" select="@* | node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template mode="cleanup" match="stanza[not(node())]" priority="1"/>

  <xsl:template mode="cleanup" match="stanza[not(string(.))] |
                                      line[stage][not(string(.))]">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <!-- Special (and presumptuous/brittle) rule to recognize that one multi-line direction -->
  <xsl:template mode="cleanup" match="stanza[starts-with(line[1], '(')]
                                            [ends-with(line[last()], ')')]">
    <stage directions="{string-join(line, ' ') ! substring-before(.,')') ! substring-after(.,'(')}"/>
  </xsl:template>

  <xsl:template match="group[1]">
    <before-matter>
      <xsl:sequence select="line"/>
    </before-matter>
  </xsl:template>

  <xsl:template match="group[last()]">
    <after-matter>
      <xsl:sequence select="line"/>
    </after-matter>
  </xsl:template>

  <xsl:template match="group">
    <xsl:variable name="speaker"
                  select="if (contains(line[1],' ')) then substring-before(line[1],' ') else string(line[1])"/>
    <speech speaker="{$speaker}">
      <xsl:if test="contains(line[1],' ')">
        <xsl:attribute name="stage-directions" select="translate(substring-after(line[1],' '), ')(', '')"/>
      </xsl:if>
      <xsl:for-each-group select="line[position() gt 1]" group-ending-with="line[. eq '']">
        <stanza>
          <xsl:apply-templates select="current-group()[string(.)]"/>
        </stanza>
      </xsl:for-each-group>
    </speech>
  </xsl:template>

  <!-- Single exception to the parentheses meaning stage directions -->
  <xsl:template match="line[. eq 'Either alone (out loud or in our head),']">
    <xsl:sequence select="."/>
  </xsl:template>

  <xsl:template match="line">
    <line>
      <xsl:analyze-string select="." regex="\(([^\)]*)\)">
        <xsl:matching-substring>
          <stage directions="{regex-group(1)}"/>
        </xsl:matching-substring>
        <xsl:non-matching-substring>
          <xsl:sequence select="."/>
        </xsl:non-matching-substring>
      </xsl:analyze-string>
    </line>
  </xsl:template>

</xsl:stylesheet>
