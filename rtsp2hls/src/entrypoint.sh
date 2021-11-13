#!/bin/bash
owner=`ls -ld | awk '{ print $3 }'`
useradd -M -u ${owner} rstpusr

counter=$((0))
while [[ -e "/app/config.csv" ]]; do
    echo "read /app/config.csv" 
    for row in `cat /app/config.csv`;do
        dev_name=`echo ${row} | cut -d , -f 1`
        sleep $(($RANDOM % 10 * 10))
        [[ $(find . -maxdepth 1 -name ".${dev_name}.lock") = "" ]] && DEV_NAME=${dev_name}
        SEG_TIME=`echo ${row} | cut -d , -f 2`
        FRAME_ROTATE=`echo ${row} | cut -d , -f 3`
        [[ ${DEV_NAME} != "" ]] && break
    done
    if [[ ${DEV_NAME} != "" ]];then
        echo "DEV_NAME=$DEV_NAME, SEG_TIME=$SEG_TIME, FRAME_ROTATE=$FRAME_ROTATE"
        su rstpusr -c "touch .${DEV_NAME}.lock"
        break
    fi 
    counter=$((counter + 1))
    if [[ ${counter} -gt 15 ]];then
        echo "no more converter seems needed, exit."
        exit 0
    fi
    echo "enough converter already running. retry...[${counter}]"
    sleep 60s
done
counter=0
if [[ ! -e "/app/config.csv" ]];then
    echo "/app/config.csv not found."
    echo "use environment value DEV_NAME=$DEV_NAME SEG_TIME=${SEG_TIME:=5}"
    [[ $DEV_NAME = "" ]] && exit 1
    SEG_TIME=${SEG_TIME:=5}
fi    

python3 /app/printfps.py ${DEV_NAME} > /app/fps
if [[ $? -ne 0 ]];then
    echo "Video stream seems not active. wait a minute..."
    sleep 60s
    rm -vf .${DEV_NAME}.lock
    exit 0
fi 
source /app/fps
if [[ ${SEG_FPS} = "" ]];then
    echo "ERROR: Cannot get fps value by some problem..."
    rm -vf .${DEV_NAME}.lock
    exit 20
fi
echo "device name: ${DEV_NAME}, ${FRAME_ROTATE:=Rotate_0}"
while [[ $counter -le 3 ]];do
    su rstpusr -c "python3 /app/rtsp2frame.py ${DEV_NAME} ${FRAME_ROTATE} | ffmpeg -r ${SEG_FPS} -i - -c:v libx264 -strftime 1 -strftime_mkdir 1 -hls_segment_filename ${DEV_NAME}/%Y-%m-%d/v%H%M%S.ts -sc_threshold 0 -g ${SEG_FPS} -keyint_min $(awk "BEGIN { print $SEG_FPS * $SEG_TIME }") -hls_time ${SEG_TIME} ${DEV_NAME}.m3u8"
    counter=$((counter + 1))
    echo "> ffmpeg process finished[$counter]: rc=$?"
done
rm -vf .${DEV_NAME}.lock
exit 0