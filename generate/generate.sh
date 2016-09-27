#!/bin/bash

# Usage: generate.sh git_url developer_network_api_page_url breadcrumb_name
GIT_URL=$1
DN_URL=$2
CRUMB=$3

echo "Running generate script"
echo "Parameters:"
echo "GIT URL: $GIT_URL"
echo "DN URL: $DN_URL"
echo "Breadcrumb: $CRUMB"

rm -Rf /tmp/source
git clone $GIT_URL /tmp/source
cd /tmp/source


# Now we need to manipulate the templates to fit in with the developer network theme

# For the footer, we can just copy in a new version
cp /templates/footer.html _includes/footer.html

# Remove the logo from the sidebar
sed -i '/NHS Digital Logo/c\<!--  -->' _includes/sidebar.html

# Alter the CSS to fix some clashed with the main dev network styles
sed -i '/a\[href\^="http:\/\/"\]:after/c\\.apicontent > a\[href\^="http:\/\/"\]:after, a\[href\^="https:\/\/"\]:after {' css/customstyles.css
echo ".search_box #s { height: 33px; }" >> css/customstyles.css
echo ".main_nav .wrapper ul li a { height: 54px; }" >> css/customstyles.css
echo ".page_title hgroup { height: 160px; }" >> css/customstyles.css
echo ".page_title h1 { margin-top: 0px; }" >> css/customstyles.css
echo ".page_title h2 { margin-top: 0px; padding-top: 0px; }" >> css/customstyles.css

# Move the default page template to a different name
mv _layouts/default.html _layouts/default-old.html

# Now, get the API page from the dev network site
wget --convert-links --output-document=_layouts/devnet.html $DN_URL

# And manipulate it to add in the right bits from the github template

# Fix the breadcrumbs

NEW_CRUMBS="<span xmlns:v=\"http:\/\/rdf\.data-vocabulary\.org\/#\"><span typeof=\"v:Breadcrumb\"><a href=\"\/\" rel=\"v:url\" property=\"v:title\">Home<\/a>  <span class=\"bc_arrow\" aria-hidden=\"true\" data-icon=\"&#x2a;\"></span></li>    <li><span xmlns:v=\"http:\/\/rdf\.data-vocabulary\.org\/#\"><span typeof=\"v:Breadcrumb\"><a href=\"\/apis\/\" rel=\"v:url\" property=\"v:title\">APIs<\/a>  <span class=\"bc_arrow\" aria-hidden=\"true\" data-icon=\"&#x2a;\"><\/span><\/li>     <li> <strong class=\"breadcrumb_last\">$CRUMB<\/strong><\/span><\/span><\/li><\/ul>	<\/div><!--end wrapper-->"

sed -i '/typeof=\"v:Breadcrumb\"/c\'"$NEW_CRUMBS"'' _layouts/devnet.html

# Remove bits we don't want
sed -i '/<head>/c\<head> {% seo %} {% include head.html %} ' _layouts/devnet.html
sed -i '/<meta charset="utf-8">/,/<meta name="viewport"/d' _layouts/devnet.html
sed -i '/This site is optimized with the Yoast/,/\[endif\]/d' _layouts/devnet.html
sed -i '/jquery\.js?ver=1\.12\.4/,/scripts\/zilla-likes.js?ver/d' _layouts/devnet.html
sed -i '/1\.7\.1\/jquery\.min\.js/,/js\/script-ck\.js/d' _layouts/devnet.html

# Fix the APIs page URL which wget messed up
sed -i '/"devnet.html"/c\<li class="apis"><a href="\/apis">API Hub</a></li>' _layouts/devnet.html

# Alter the main page section wrappers
sed -i '/<div id="api_list">/c\<div class="wrapper cf container"><div class="content_wrap cf"><div class="apicontent">' _layouts/devnet.html
sed -i '/<!-- end api list -->/c\<!--end apicontent--></div></div></div>' _layouts/devnet.html

# Clear out page content
sed -i '/<div class="apicontent">/,/<!--end apicontent-->/{//!d}' _layouts/devnet.html

# Now, we need to cut up the two files (original and devnet) and assemble them again into a combined template page
sed -n '1,/fancybox\/fancybox.css/p' _layouts/devnet.html > _layouts/default.html
echo '<!-- FROM GITHUB TEMPLATE -->' >> _layouts/default.html
sed -n '/<script>/,/<\/head>/{x;p;d;}' _layouts/default-old.html >> _layouts/default.html
echo '<!-- END FROM GITHUB TEMPLATE -->' >> _layouts/default.html
sed -n '/<\/head>/,/<div class="apicontent">/p' _layouts/devnet.html >> _layouts/default.html
echo '<!-- FROM GITHUB TEMPLATE -->' >> _layouts/default.html
sed -n '/<!-- Page Content -->/,/<\/body>/{x;p;d;}' _layouts/default-old.html >> _layouts/default.html
echo '<!-- END FROM GITHUB TEMPLATE -->' >> _layouts/default.html
sed -n '/<!--end apicontent-->/,$p' _layouts/devnet.html >> _layouts/default.html

# Now, generate the output
bundle install
bundle exec jekyll build --destination /home/generator/output
