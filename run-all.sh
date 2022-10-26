mkdir -p build
cd build

java -cp "$CLASSPATH" net.sf.saxon.Transform -xsl:../xsl/parse-script.xsl -s:../xsl/parse-script.xsl -o:script.xml script-file-name=../source/ThereIsAHappiness.doc.txt
java -cp "$CLASSPATH" net.sf.saxon.Transform -xsl:../xsl/render-to-html.xsl -s:script.xml -o:../output/index.html title='There Is a Happiness That Morning Is'
java -cp "$CLASSPATH" net.sf.saxon.Transform -xsl:../xsl/generate-aws-cli-script.xsl -s:script.xml

mkdir -p ../output/mp3-straight
mkdir -p ../output/mp3-no-punctuation
mkdir -p ../output/mp3-last-word-only
mkdir -p ../output/mp3-two-line-cues
mkdir -p ../output/mp3-one-line-cues
mkdir -p ../output/mp3-line-boundaries

source synthesize-straight.sh
source synthesize-no-punctuation.sh
source synthesize-last-word-only.sh
source synthesize-two-line-cues.sh
source synthesize-one-line-cues.sh
source synthesize-line-boundaries.sh
