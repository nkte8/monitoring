#!/bin/bash
owner=`ls -ld | awk '{ print $3 }'`
useradd -M -u ${owner} rstpusr

except=`date +'%Y-%m-%d'`

target_paths=$(find ${PWD} -mindepth 2 -maxdepth 2 -not -name "${except}" -type d | grep -e "[0-9]\{4\}-[0-9]\{1,2\}-[0-9]\{1,2\}" -)

for dir in ${target_paths}; do
    LOCK_FILE="$(dirname ${dir})/.$(basename ${dir}).lock"
    sleep $(($RANDOM % 10 * 10))
    [[ -e ${LOCK_FILE} ]] && continue
    TARGET_PATH=${dir}
    break
done

echo "TARGET_PATH=${TARGET_PATH}"
if [[ $TARGET_PATH = "" ]];then
    echo "> no file to convert:)"
    exit 0
fi
touch ${LOCK_FILE}

echo "> get file list..."
filelist=$(find ${TARGET_PATH} -type f -name '*.ts')
for f in ${filelist};do
    echo "file '$f'" >> /tmp/mylist.txt
done

echo "> concat video..."
su rstpusr -c "ffmpeg -f concat -safe 0 -i /tmp/mylist.txt -vcodec copy -an ${TARGET_PATH}.mp4"
rc=$?; [[ $rc -ne 0 ]] && exit $rc
echo "> concat video finished."
echo "> removing source segments..."
rm -rf "${TARGET_PATH}"

echo "> convert x10 and lighter"
su rstpusr -c "ffmpeg -i ${TARGET_PATH}.mp4 -vf setpts=PTS/16.0 -crf 30 ${TARGET_PATH}.mp4"
rc=$?; [[ $rc -ne 0 ]] && exit $rc

rm -f "${LOCK_FILE}"
echo "> finish convert."

exit 0