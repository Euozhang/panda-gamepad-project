#!/system/bin/sh
SDK=$(echo $(getprop ro.build.version.sdk))
echo $SDK
O=26

if [ $SDK -lt $O ]; then
    PS_ARGS=""
else
    PS_ARGS="-A"
fi

set a=`ps $PS_ARGS | grep com.android.adnap:daemon`;
if [ $2 ]; then
    echo '1'
    kill $2
    kill -9 $2
fi

TMP_PATH=/data/local/tmp/2
CACHE_PATH=/sdcard/.chaozhuo.gameassistant2

INJECT_SH=inject.sh
INJECT_WRAPPER_SH=inject_wrapper.sh
CONFIG_INI=config.ini
DAEMON_DEX=daemon.dex
INJECT_DEX=inject.dex
SO_FILENAME=libinject.so

mkdir $TMP_PATH
cp -r $CACHE_PATH/$INJECT_SH $TMP_PATH;
cp -r $CACHE_PATH/$INJECT_WRAPPER_SH $TMP_PATH;
cp -r $CACHE_PATH/$CONFIG_INI $TMP_PATH;
cp -r $CACHE_PATH/$DAEMON_DEX $TMP_PATH;

export a=`cat $TMP_PATH/$CONFIG_INI`;
echo $a
arr=(${a//,/ })
for data in ${arr[@]}
do
    set a=`ps $PS_ARGS | grep $data:i`;
    if [ $2 ]; then
        echo '2'
        kill $2
        kill -9 $2
    fi
done

for data in ${arr[@]}
do
    cp -r $CACHE_PATH/$data$INJECT_DEX $TMP_PATH
    cp -r $CACHE_PATH/$data$SO_FILENAME $TMP_PATH
done

sleep 1

chmod -R 777 $TMP_PATH

if [ -f /system/bin/app_process32 ]; then
    APP_PROCESS="app_process32"
else
    APP_PROCESS="app_process"
fi

for data in ${arr[@]}
do
    if [ -e $TMP_PATH/$data$INJECT_DEX ]; then
        (nohup $APP_PROCESS -Djava.class.path=$TMP_PATH/$data$INJECT_DEX $TMP_PATH/ com.chaozhuo.gameassistant.inject.InjectService > /dev/null 2>&1 &)
    fi
done

(nohup $APP_PROCESS -Djava.class.path=$TMP_PATH/$DAEMON_DEX $TMP_PATH/ com.chaozhuo.gameassistant.daemon.DaemonService > /dev/null 2>&1 &)

sleep 2

SUCCESS=0
for data in ${arr[@]}
do
    set a=`ps $PS_ARGS | grep $data:i`;
    if [ $2 ]; then
    SUCCESS=1
    fi
done

if [ $SUCCESS -eq 0 ]; then
    APP_PROCESS="app_process"
    for data in ${arr[@]}
    do
        if [ -e $TMP_PATH/$data$INJECT_DEX ]; then
            (nohup $APP_PROCESS -Djava.class.path=$TMP_PATH/$data$INJECT_DEX $TMP_PATH/ com.chaozhuo.gameassistant.inject.InjectService > /dev/null 2>&1 &)
        fi
    done

    (nohup $APP_PROCESS -Djava.class.path=$TMP_PATH/$DAEMON_DEX $TMP_PATH/ com.chaozhuo.gameassistant.daemon.DaemonService > /dev/null 2>&1 &)
fi