# 定义基础镜像和 Wine 分支的构建参数
ARG BASE_IMAGE_TAG="20.04"
FROM ubuntu:${BASE_IMAGE_TAG}

# 环境变量设置，避免交互并设置默认语言环境
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8

# 安装必要的工具和设置
RUN apt-get update && \
    apt-get install -y software-properties-common wget apt-transport-https gnupg2 locales x11-xserver-utils xauth x11-apps xserver-xorg-video-dummy && \
    locale-gen en_US.UTF-8

# 配置 WineHQ 的仓库和安装 Wine，支持参数化选择 Wine 版本
ARG WINE_BRANCH="stable"
RUN wget -nv -O- https://dl.winehq.org/wine-builds/winehq.key | APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 apt-key add - \
    && echo "deb https://dl.winehq.org/wine-builds/ubuntu/ $(grep VERSION_CODENAME= /etc/os-release | cut -d= -f2) main" >> /etc/apt/sources.list \
    && dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --install-recommends winehq-${WINE_BRANCH} \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 安装 winetricks
RUN wget -nv -O /usr/bin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
    && chmod +x /usr/bin/winetricks

# 复制并执行下载 gecko 和 mono 的脚本
COPY download_gecko_and_mono.sh /root/download_gecko_and_mono.sh
RUN chmod +x /root/download_gecko_and_mono.sh \
    && /root/download_gecko_and_mono.sh "$(wine --version | sed -E 's/^wine-//')"

# 复制入口脚本到容器中
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# 设置默认的工作目录
WORKDIR /root

# 使用独立的入口脚本
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
