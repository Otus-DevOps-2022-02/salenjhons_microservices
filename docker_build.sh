!/bin/bash

# echo `git show --format="%h" HEAD | head -1` > build_info.txt
# echo `gti rev-parse --abbrev=ref HEAD` >> build_info.txt

# docker build -t $USER_NAME/ui

export USER_NAME='johntelegin'

cd ./src/ui && bash docker_build.sh && docker push $USER_NAME/ui
cd ../post-py && bash docker_build.sh && docker push $USER_NAME/post
cd ../comment && bash docker_build.sh && docker push $USER_NAME/comment
