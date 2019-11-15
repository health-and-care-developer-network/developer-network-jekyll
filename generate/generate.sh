#!/bin/bash

# Usage: generate.sh git_url developer_network_api_page_url breadcrumb_name directory_name branch banner_html_file
GIT_URL=$1
DN_URL=$2
CRUMB=$3
DIR_NAME=$4
BRANCH=$5
BANNER_HTML_FILE=$6

ROOT_PATH="/content"
TEMP_PATH="/content/tmp"

echo "Running generate script"
echo "Parameters:"
echo "GIT URL: $GIT_URL"
echo "DN URL: $DN_URL"
echo "Breadcrumb: $CRUMB"
echo "Directory: $DIR_NAME"
echo "Branch: $BRANCH"
echo "Banner HTML FILE: $BANNER_HTML_FILE"

# Initialise ruby environment
export PATH="/home/generator/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# Prepare directories
rm -Rf $ROOT_PATH/$DIR_NAME
mkdir -p $ROOT_PATH/$DIR_NAME

rm -Rf $TEMP_PATH
git clone $GIT_URL $TEMP_PATH
cd $TEMP_PATH
git checkout $BRANCH

# Override Ruby Version of explicitly given in .ruby-version
[ -e /content/tmp/.ruby-version ] && echo "Overriding .ruby-version:$(head -1 /content/tmp/.ruby-version)" && rm /content/tmp/.ruby-version

# Now we need to manipulate the templates to fit in with the developer network theme

# For the footer, we can just copy in a new version
cp /templates/footer.html _includes/footer.html

# Remove the logo from the sidebar
sed -i '/NHS Digital Logo/c\<!--  -->' _includes/sidebar.html

# Alter the CSS to fix some clashes with the main dev network styles
sed -i '/a\[href\^="http:\/\/"\]:after/c\\.apicontent > a\[href\^="https:\/\/"\]:after, \.apicontent > a\[href\^="https:\/\/"\]:after {' css/customstyles.css

# Blat the customscripts.js file - it causes more issues than it solves
echo "" > js/customscripts.js

# Move the default page template to a different name
mv _layouts/default.html _layouts/default-old.html

# Now, get the API page from the dev network site
cat /developer-nhs-uk-snapshot.html > _layouts/devnet.html

# And manipulate it to add in the right bits from the github template

# Fix the breadcrumbs

NEW_CRUMBS="<span xmlns:v=\"https:\/\/rdf\.data-vocabulary\.org\/#\"><span typeof=\"v:Breadcrumb\"><a href=\"\/\" rel=\"v:url\" property=\"v:title\">Home<\/a>  <span class=\"bc_arrow\" aria-hidden=\"true\" data-icon=\"&#x2a;\"></span></li>    <li><span xmlns:v=\"https:\/\/rdf\.data-vocabulary\.org\/#\"><span typeof=\"v:Breadcrumb\"><a href=\"\/apis\/\" rel=\"v:url\" property=\"v:title\">APIs<\/a>  <span class=\"bc_arrow\" aria-hidden=\"true\" data-icon=\"&#x2a;\"><\/span><\/li>     <li> <strong class=\"breadcrumb_last\">$CRUMB<\/strong><\/span><\/span><\/li><\/ul>	<\/div><!--end wrapper-->"

sed -i '/typeof=\"v:Breadcrumb\"/c\'"$NEW_CRUMBS"'' _layouts/devnet.html

# Remove bits we don't want
sed -i '/<head>/c\<head> {% seo %} {% include head.html %} ' _layouts/devnet.html
sed -i '/<meta charset="utf-8">/,/<meta name="viewport"/d' _layouts/devnet.html
#sed -i '/This site is optimized with the Yoast/,/\[endif\]/d' _layouts/devnet.html
sed -i '/s.w.org/,/\[endif\]/d' _layouts/devnet.html
sed -i '/jquery\.js?ver=1\.12\.4/,/scripts\/zilla-likes.js?ver/d' _layouts/devnet.html
sed -i '/HDN\/js\/landing\/promise\.min\.js/,/HDN\/js\/script-ck\.js/d' _layouts/devnet.html

# Fix the APIs page URL which wget messed up
sed -i 'header__menu-item\"><a href=\"devnet.html/c\            <li class=\"header__menu-item\"><a href=\"/apis\">API Hub<\/a><\/li>' _layouts/devnet.html

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
cat /inline-styles.css >> _layouts/default.html # Inject some inline styles to tidy things up and resolve style clashes between Dev Net and Jekyll

sed -n '/<\/head>/,/<div class="apicontent">/p' _layouts/devnet.html >> _layouts/default.html

# If we need to add banner styling
if [ -n "$BANNER_HTML_FILE" ]
then
	echo '<!-- include HTML from parameterised file in body -->' >> _layouts/default.html
	cat $BANNER_HTML_FILE >> _layouts/default.html
fi

echo '<!-- FROM GITHUB TEMPLATE -->' >> _layouts/default.html
sed -n '/<!-- Page Content -->/,/<\/body>/{x;p;d;}' _layouts/default-old.html >> _layouts/default.html
echo '<!-- END FROM GITHUB TEMPLATE -->' >> _layouts/default.html
sed -n '/<!--end apicontent-->/,$p' _layouts/devnet.html >> _layouts/default.html

# Now, generate the output
bundle install

mkdir $TEMP_PATH/generated
bundle exec jekyll build --destination $TEMP_PATH/generated

# Delete the old content and move the new content in its place
rm -Rf $ROOT_PATH/$DIR_NAME
mv $TEMP_PATH/generated $ROOT_PATH/$DIR_NAME

# And clean up the temp files
rm -Rf $TEMP_PATH

