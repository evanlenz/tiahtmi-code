java -cp "$CLASSPATH" net.sf.saxon.Transform -xsl:xsl/parse-script.xsl -s:xsl/parse-script.xsl -o:build/script.xml script-file-name=../source/ThereIsAHappiness.doc.txt
java -cp "$CLASSPATH" net.sf.saxon.Transform -xsl:xsl/render-to-html.xsl -s:build/script.xml -o:output/tiahtmi.html title='There Is a Happiness That Morning Is'
java -cp "$CLASSPATH" net.sf.saxon.Transform -xsl:xsl/render-to-html.xsl -s:build/script.xml -o:output/tiahtmi-viz.html title='There Is a Happiness That Morning Is' visualization=yes
java -cp "$CLASSPATH" net.sf.saxon.Transform -xsl:xsl/generate-aws-cli-script.xsl -s:build/script.xml -o:build/synthesize-all.sh

mkdir -p output/mp3-straight

#source build/synthesize-all.sh
