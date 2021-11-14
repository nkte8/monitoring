#!/bin/bash
owner=`ls -ld | awk '{ print $3 }'`
useradd -M -u ${owner} rstpusr

if [[ -e "/app/config.csv" ]];then
    echo "read /app/config.csv..." 
    for row in `cat /app/config.csv`;do
        dev_name=`echo ${row} | cut -d , -f 1`
        sleep $(($RANDOM % 60)) 
        if [[ $(find . -maxdepth 1 -name ".${dev_name}.lock") != "" ]];then 
            echo "lockfile found. skip ${dev_name}..."
            continue
        fi
        su rstpusr -c "touch .${dev_name}.lock"
        python3 /app/printfps.py ${dev_name} > /app/fps
        rc=$?
        if [[ $rc -ne 0 ]];then
            echo "${dev_name}: Video stream seems not active."
            rm -vf .${dev_name}.lock
            continue
        fi

        DEV_NAME=${dev_name}
        SEG_TIME=`echo ${row} | cut -d , -f 2`
        FRAME_ROTATE=`echo ${row} | cut -d , -f 3`
        break
    done
fi
if [[ $DEV_NAME = "" ]];then
    echo "Error: No video stream cannot use."
    exit 1
fi

source /app/fps
counter=0
trap "rm -vf .${DEV_NAME}.lock" 1 2 3 15 EXIT

echo "device name: ${DEV_NAME}, segment fps: ${SEG_FPS}, segment time: ${SEG_TIME}, frames rotation: ${FRAME_ROTATE:=Rotate_0}"
while [[ $counter -le 3 ]];do
    su rstpusr -c "python3 /app/rtsp2frame.py ${DEV_NAME} ${FRAME_ROTATE} | ffmpeg -r ${SEG_FPS} -i - -c:v libx264 -strftime 1 -strftime_mkdir 1 -hls_segment_filename ${DEV_NAME}/%Y-%m-%d/v%H%M%S.ts -sc_threshold 0 -g ${SEG_FPS} -keyint_min $(awk "BEGIN { print $SEG_FPS * $SEG_TIME }") -hls_time ${SEG_TIME} ${DEV_NAME}.m3u8"
    rc=$?
    counter=$((counter + 1))
    echo "> ffmpeg process finished[$counter]: rc=$rc"
done
exit $rc