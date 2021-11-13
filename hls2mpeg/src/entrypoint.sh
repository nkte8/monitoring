#!/bin/bash
owner=`ls -ld | awk '{ print $3 }'`
useradd -M -u ${owner} rstpusr

except=`date +'%Y-%m-%d'`
archivelist=$(find ${PWD} -mindepth 2 -maxdepth 2 -not -name "${except}" -type d | grep -e "[0-9]\{4\}-[0-9]\{1,2\}-[0-9]\{1,2\}" -)

for target_dir in ${archivelist}; do
    LOCK_FILE="$(dirname ${target_dir})/.$(basename ${target_dir}).lock"
    [[ -e ${LOCK_FILE} ]] && continue

    cnvvideo=$(find "$(dirname $target_dir)" -mindepth 1 -maxdepth 1 -name "$(basename $target_dir).mp4" -type f)
    [[ "$cnvvideo" != "" ]] && continue

    TARGET_PATH=${target_dir}
    break
done

echo "TARGET_PATH=${TARGET_PATH}"
if [[ $TARGET_PATH = "" ]] || [[ $LOCK_FILE = "" ]];then
    echo "> no file to convert:)"
    exit 0
fi
touch ${LOCK_FILE}

filelist=$(find ${TARGET_PATH} -type f -name '*.ts' | sort)
echo "> create file list... [/tmp/mylist.txt]"
touch /tmp/mylist.txt
for f in ${filelist};do
    su rstpusr -c "ffmpeg -v error -i $f -f null -  >/dev/null 2>&1"
    if [[ $? -eq 0 ]];then
        echo "file '$f'" | tee -a /tmp/mylist.txt
    fi
done

echo "> concat video..."
su rstpusr -c "ffmpeg -f concat -nostdin -safe 0 -i /tmp/mylist.txt -vcodec copy -an ${TARGET_PATH}-ts.mp4"
rc=$?; [[ $rc -ne 0 ]] && exit $rc
echo "> concat video finished."

# echo "> removing source segments..."
# rm -rf "${TARGET_PATH}"

echo "> convert x10 and lighter"
su rstpusr -c "ffmpeg -i ${TARGET_PATH}-ts.mp4 -r 30 -vf setpts=PTS/20.0 -crf 30 ${TARGET_PATH}.mp4"
rc=$?; [[ $rc -ne 0 ]] && exit $rc
echo "> convert video finished."
rm -rf "${TARGET_PATH}-ts.mp4"

echo "> finish convert of ${TARGET_PATH}"
rm -vf ${LOCK_FILE}
exit 0