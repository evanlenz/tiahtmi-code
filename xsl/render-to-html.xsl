<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs">

  <xsl:param name="title"/>

  <xsl:param name="characters" as="element(character)+">
    <character name="BERNARD" red="0" green="0" blue="255"/>
    <character name="ELLEN" red="0" green="128" blue="0"/>
    <character name="DEAN" red="128" green="0" blue="128"/>
  </xsl:param>

  <xsl:param name="speech-styles" as="element(speech)+">
    <speech style="straight"/>
    <speech style="no-punctuation" default="yes"/>
    <speech style="last-word-only"/>
    <speech style="two-line-cues"/>
    <speech style="one-line-cues"/>
    <speech style="line-boundaries"/>
  </xsl:param>

  <xsl:template match="/">
    <html>
      <head>
        <title>
          <xsl:value-of select="$title"/>
        </title>
        <style type="text/css">

          body { width: 100vw; height; 100vh; padding: 0; margin: 0; font-family: Cambria; }

          #controls { height: 110px; column-count: <xsl:value-of select="count($characters)"/> }
          #play_script { position: absolute; top: 110px; left: 0; right: 0; bottom: 0;
                         overflow: auto; column-count: 15;
                         font-size: 3.54pt;
                       }

          .stanza { cursor: pointer; margin-top: 1em; margin-bottom: 1em }

          <xsl:for-each select="$characters" expand-text="yes">
            .{@name} .stanza {{ background-color: rgb({@red}, {@green}, {@blue}) }}
          </xsl:for-each>

          #controls { font-weight: bold }

          <xsl:for-each select="$characters" expand-text="yes">
            .{@name} .stanza {{ color: rgb({@red}, {@green}, {@blue}) }}

            #controls .{@name} {{
              background-color: rgba({@red}, {@green}, {@blue}, 0.25);
              padding: 10px
            }}
          </xsl:for-each>

          .highlighted { border-color: black; border-width: 15px; border-style: solid }
        </style>
        <script>

          // https://stackoverflow.com/a/31133401/98316
          Object.defineProperty(HTMLMediaElement.prototype, 'playing', {
            get: function(){
              return !!(this.currentTime > 0 &amp;&amp; !this.paused &amp;&amp; !this.ended &amp;&amp; this.readyState > 2);
            }
          })

          function updatePlaybackRates(character) {
            document.querySelectorAll('.audio_'+character).forEach(function(el) {
              el.playbackRate = document.getElementById('playbackRateSlider_'+character).value;
            })
          }

          function updateVolume(character) {
            document.querySelectorAll('.audio_'+character).forEach(function(el) {
              el.volume = document.getElementById('volumeSlider_'+character).value;
            })
          }

          function updateSpeechStyle(character) {
            document.querySelectorAll('.audio_'+character).forEach(function(el) {
              let wasPlaying = el.playing;
              el.src = 'mp3-' + document.getElementById('speech_style_'+character).value + '/' + el.id + '.mp3';
              if (wasPlaying) start(el.id);
            })
            updatePlaybackRates(character);
          }

          window.onload = function() {
            <xsl:for-each select="$characters">
              updatePlaybackRates('<xsl:value-of select="@name"/>');
              updateSpeechStyle('<xsl:value-of select="@name"/>');
            </xsl:for-each>
          }

          function end(audioID) {
            var current = document.getElementById(audioID)
            current.parentElement.classList.remove("highlighted")
          }
          function toggleStanza(audioID) {
            var current = document.getElementById(audioID)
            if (current.paused)
              start(audioID)
            else {
              current.pause()
              end(audioID)
            }
          }
          function start(audioID) {
            document.querySelectorAll('audio').forEach(function(el) {
              el.pause();
              el.parentElement.classList.remove("highlighted")
            });
            if (audioID !== '') {
              var next = document.getElementById(audioID)
              next.currentTime = 0
              next.play()
              next.parentElement.classList.add("highlighted")
            }
          }
        </script>
      </head>
      <body>
        <div id="controls">
          <xsl:apply-templates mode="controls" select="$characters"/>
        </div>
        <div id="play_script">
          <xsl:apply-templates/>
        </div>
      </body>
    </html>
  </xsl:template>

          <xsl:template mode="controls" match="character">
            <div class="{@name}">
              <div>
                <xsl:value-of select="@name"/>
              </div>
              <div>
                Speed: <input id="playbackRateSlider_{@name}" type="range" min=".5" max="5" value="1" step=".1"
                              oninput="updatePlaybackRates('{@name}')"/>
              </div>
              <div>
                Volume: <input id="volumeSlider_{@name}" type="range" min="0" max="1" value=".5" step=".02"
                               oninput="updateVolume('{@name}')"/>
              </div>
              <div>
                Style:
                <select id="speech_style_{@name}" onchange="updateSpeechStyle('{@name}')">
                  <xsl:for-each select="$speech-styles">
                    <option>
                      <xsl:if test="@default eq 'yes'">
                        <xsl:attribute name="selected" select="'selected'"/>
                      </xsl:if>
                      <xsl:value-of select="@style"/>
                    </option>
                  </xsl:for-each>
                </select>
              </div>
            </div>
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
    <div class="stanza" onclick="toggleStanza('{@id}')">
      <audio id="{@id}" class="audio_{../@speaker}" onended="end('{@id}'); start('{following::stanza[1]/@id}')">
        <source type="audio/mpeg"/>
      </audio>
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
