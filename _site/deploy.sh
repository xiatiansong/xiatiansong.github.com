#!/bin/bash

echo `date`

msg="update:$*"


qrsync qiniu-images.conf

cd _posts

sed -i "" 's/\/static\/images/http:\/\/xiaotian120\-rs\.qiniudn\.com\/images/g' */*

cd ..

rm -rf _site/*
jekyll build

git add --all ./*
git commit -m "$msg"
git push origin master

#rm -rf ../javachen.gitcafe.com/{20*,page*,*.html,*.xml,*.txt,*.sh}
#cp -r _site/* ../javachen.gitcafe.com/

#cd ../javachen.gitcafe.com
#git add --all ./*
#git commit -m "$msg"
#git push origin gitcafe-pages

echo `date`
exit 0
