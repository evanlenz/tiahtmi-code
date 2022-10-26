<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:my="http://localhost"
  xmlns:amazon="dummy"
  exclude-result-prefixes="my xs"
  expand-text="yes">

  <xsl:output method="text"/>

  <xsl:template match="/">
    <xsl:result-document href="synthesize-straight.sh">
      <xsl:apply-templates select="*/speech/stanza">
        <xsl:with-param name="speech-type" select="'straight'"/>
      </xsl:apply-templates>
    </xsl:result-document>
    <xsl:result-document href="synthesize-no-punctuation.sh">
      <xsl:apply-templates select="*/speech/stanza">
        <xsl:with-param name="speech-type" select="'no-punctuation'"/>
      </xsl:apply-templates>
    </xsl:result-document>
    <xsl:result-document href="synthesize-last-word-only.sh">
      <xsl:apply-templates select="*/speech/stanza">
        <xsl:with-param name="speech-type" select="'last-word-only'"/>
      </xsl:apply-templates>
    </xsl:result-document>
    <xsl:result-document href="synthesize-two-line-cues.sh">
      <xsl:apply-templates select="*/speech/stanza">
        <xsl:with-param name="speech-type" select="'two-line-cues'"/>
      </xsl:apply-templates>
    </xsl:result-document>
    <xsl:result-document href="synthesize-one-line-cues.sh">
      <xsl:apply-templates select="*/speech/stanza">
        <xsl:with-param name="speech-type" select="'one-line-cues'"/>
      </xsl:apply-templates>
    </xsl:result-document>
    <xsl:result-document href="synthesize-line-boundaries.sh">
      <xsl:apply-templates select="*/speech/stanza">
        <xsl:with-param name="speech-type" select="'line-boundaries'"/>
      </xsl:apply-templates>
    </xsl:result-document>
  </xsl:template>

  <xsl:template match="stanza">
    <xsl:param name="speech-type"/>
    <xsl:result-document href="text-{$speech-type}/{@id}.xml" method="text">
      <xsl:variable name="output-document-in-wrapper-to-fool-broken-amazon">
        <foo>
          <speak>
            <xsl:sequence select="my:speech-text($speech-type, .)"/>
          </speak>
        </foo>
      </xsl:variable>
      <xsl:variable name="serialized-wrapper" select="serialize($output-document-in-wrapper-to-fool-broken-amazon)"/>
      <xsl:sequence select="substring-after(substring-before($serialized-wrapper, '&lt;/foo>'), '&lt;foo xmlns:amazon=&quot;dummy&quot;>')"/>
    </xsl:result-document>
    <xsl:variable name="output-path">../output/mp3-{$speech-type}/{@id}.mp3</xsl:variable>
    echo "Generating <xsl:value-of select="$output-path"/>"
    aws polly synthesize-speech --text 'file://text-{$speech-type}/{@id}.xml' \
                                --text-type ssml \
                                --output-format=mp3 \
                                --voice-id <xsl:apply-templates mode="voice" select="."/> \
                                <xsl:value-of select="$output-path"/>
  </xsl:template>

  <xsl:function name="my:speech-text">
    <xsl:param name="speech-type"/>
    <xsl:param name="stanza"/>
    <xsl:choose>
      <xsl:when test="$speech-type eq 'straight'">
        <xsl:value-of select="string-join($stanza/line, ' ')"/>
      </xsl:when>
      <xsl:when test="$speech-type eq 'no-punctuation'">
        <xsl:value-of select="string-join($stanza/line/my:strip-punctuation(.), ' ')"/>
      </xsl:when>
      <xsl:when test="$speech-type eq 'last-word-only'">
        <xsl:value-of select="string-join($stanza/line/tokenize(.,' ')[last()] ! my:strip-punctuation(.), ',')"/>
      </xsl:when>
      <xsl:when test="$speech-type eq 'two-line-cues'">
        <xsl:value-of select="string-join($stanza/line[position() ge last()-1]/my:strip-punctuation(.), ' ')"/>
      </xsl:when>
      <xsl:when test="$speech-type eq 'one-line-cues'">
        <xsl:value-of select="$stanza/line[last()] ! my:strip-punctuation(.)"/>
      </xsl:when>
      <xsl:when test="$speech-type eq 'line-boundaries'">
        <xsl:apply-templates mode="line-boundaries" select="$stanza/line"/>
      </xsl:when>
    </xsl:choose>
  </xsl:function>

  <xsl:template mode="line-boundaries" match="line">
    <xsl:variable name="words" select="tokenize(.,' ')"/>
    <xsl:value-of select="$words[1]"/>
    <xsl:text>, </xsl:text>
    <prosody amazon:max-duration=".8s" volume="-8dB">
      <xsl:value-of select="string-join($words[position() gt 1][position() ne last()], ' ')"/>
    </prosody>
    <xsl:value-of select="replace($words[last()], '[^a-zA-Z]', '')"/>
    <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:function name="my:strip-punctuation">
    <xsl:param name="text"/>
    <xsl:sequence select='replace($text, "[^a-zA-Z&apos; ]", " ")'/>
  </xsl:function>

  <xsl:template mode="voice" match="stanza[../@speaker eq 'BERNARD']">Matthew</xsl:template>
  <xsl:template mode="voice" match="stanza[../@speaker eq 'ELLEN']">Joanna</xsl:template>
  <xsl:template mode="voice" match="stanza[../@speaker eq 'DEAN']">Joey</xsl:template>

</xsl:stylesheet>
