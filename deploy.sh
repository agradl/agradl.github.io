jekyll build
cp ./_config.yml _site/_config.yml
cd _site
git init
git add .
git commit -m "blog"
git push -f https://github.com/agradl/agradl.github.io.git HEAD:master
cd ..
rm -rf _site
