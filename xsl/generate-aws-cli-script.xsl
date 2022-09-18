<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs"
  expand-text="yes">

  <xsl:output method="text"/>

  <xsl:template match="/">
    <xsl:apply-templates select="*/speech/stanza"/>
  </xsl:template>

  <xsl:template match="stanza">
    <xsl:result-document href="text-straight/{@id}.txt">
      <xsl:value-of select="string-join(line, ' ')"/>
    </xsl:result-document>
    aws polly synthesize-speech --text 'file://text-straight/{@id}.txt' \
                                --output-format=mp3 \
                                --voice-id <xsl:apply-templates mode="voice" select="."/> \
                                ../output/mp3-straight/{@id}.mp3
  </xsl:template>

  <xsl:template mode="voice" match="stanza[../@speaker eq 'BERNARD']">Matthew</xsl:template>
  <xsl:template mode="voice" match="stanza[../@speaker eq 'ELLEN']">Joanna</xsl:template>
  <xsl:template mode="voice" match="stanza[../@speaker eq 'DEAN']">Joey</xsl:template>

</xsl:stylesheet>
