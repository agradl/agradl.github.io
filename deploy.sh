jekyll build
cp ./_config.yml ./_site/_config.yml
cp ./CNAME ./_site/CNAME
cd _site
git init
git add --all
git commit -m "update"
git push -f https://github.com/agradl/agradl.github.io.git master
cd ../
rm -rf _site