#!/bin/bash

# 如果 DISPLAY 已经存在，则假定使用宿主机的 X11 显示
if [[ -n "$DISPLAY" ]]; then
    echo "Using host X11 display at $DISPLAY"
    xauth nlist "$DISPLAY" | sed -e 's/^..../ffff/' | xauth -f /root/.Xauthority nmerge -
else
    # 启动 xdummy 虚拟显示器的配置文件
    cat <<EOF > /etc/X11/xorg.conf
Section "Device"
    Identifier  "DummyDevice"
    Driver      "dummy"
    VideoRam    256000
EndSection

Section "Monitor"
    Identifier  "DummyMonitor"
    HorizSync   28-80
    VertRefresh 48-75
EndSection

Section "Screen"
    Identifier "DummyScreen"
    Device     "DummyDevice"
    Monitor    "DummyMonitor"
    DefaultDepth 24
    SubSection "Display"
        Depth     24
        Modes     "1024x768"
    EndSubSection
EndSection

Section "ServerLayout"
    Identifier "DummyLayout"
    Screen     "DummyScreen"
EndSection
EOF

    # 启动 xdummy 虚拟显示器
    Xorg -noreset +extension GLX +extension RANDR +extension RENDER -logfile /var/log/xorg.log -config /etc/X11/xorg.conf :0 &
    export DISPLAY=:0
fi

# 执行传入的命令
exec wine "$@"
