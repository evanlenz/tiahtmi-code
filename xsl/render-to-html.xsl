<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs">

  <xsl:param name="title"/>

  <xsl:param name="visualization" select="false()"/>

  <xsl:template match="/">
    <html>
      <head>
        <title>
          <xsl:value-of select="$title"/>
        </title>
        <style type="text/css">
          body { font-family: Cambria; <xsl:if test="$visualization">column-count: 15;</xsl:if> }
          .stanza { margin-top: 1em; margin-bottom: 1em }

          <xsl:if test="$visualization">
          .BERNARD .stanza { background-color: blue }
          .ELLEN .stanza { background-color: green }
          .DEAN .stanza { background-color: purple }
          </xsl:if>

          .BERNARD .stanza { color: blue; }
          .ELLEN .stanza { color: green; }
          .DEAN .stanza { color: purple; }
        </style>
        <script>
          window.onload = function() {
            document.querySelectorAll('audio').forEach(function(el) {
              el.playbackRate = 2
            })
          }

          function start(audioID) {
            if (audioID !== '') {
              var next = document.getElementById(audioID)
              next.currentTime = 0
              next.playbackRate = 2
              next.play()
            }
          }
        </script>
      </head>
      <body>
        <xsl:apply-templates/>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="speech">
    <div class="{@speaker}">
      <div class="speaker">
        <xsl:apply-templates select="@speaker, @stage-directions"/>
      </div>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="@stage-directions" priority="1">
    <xsl:text> </xsl:text>
    <xsl:next-match/>
  </xsl:template>

  <xsl:template match="stanza/stage | speech/stage">
    <p>
      <xsl:next-match/>
    </p>
  </xsl:template>

  <xsl:template match="stage">
    <xsl:apply-templates select="@directions"/>
  </xsl:template>

  <xsl:template match="@stage-directions | @directions">
    <em class="stageDirections">
      <xsl:text>(</xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>)</xsl:text>
    </em>
  </xsl:template>

  <xsl:template match="stanza">
    <div class="stanza">
      <xsl:if test="not($visualization)">
        <audio id="{@id}" controls="controls" onended="start('{following::stanza[1]/@id}')">
          <source src="mp3-straight/{@id}.mp3" type="audio/mpeg"/>
        </audio>
      </xsl:if>
      <xsl:apply-templates select="line"/>
    </div>
  </xsl:template>

  <xsl:template match="line">
    <div>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="before-matter">
    <div class="beforeMatter">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="after-matter">
    <div class="afterMatter">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

</xsl:stylesheet>
