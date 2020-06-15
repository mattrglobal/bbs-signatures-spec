# Convert markdown to XML and HTML versions
docker run -v `pwd`:/data danielfett/markdown2rfc spec.md

# Delete XML version
rm bbs-signatures.xml

# Rename the HTML version for hosting with GH pages
mv bbs-signatures.html index.html