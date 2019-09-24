#!/bin/bash
[ -f  /etc/init.d/functions ]&& . /etc/init.d/functions


if [ $UID -ne 0 ]
then
    echo "Current user is not root."
    exit
fi

check() {
    if [ $? -eq 0 ];then
        action "$1" /bin/true
    else
        action "$1" /bin/false
        exit 0
    fi
}

Repo() {
    [ `yum list installed  | grep -c wget` -ne 0 ] && yum -y install wget
    baserepo="/etc/yum.repos.d/CentOS-Base.repo"
    [ ! -f "${baserepo}.backup" ] && mv ${baserepo} ${baserepo}.backup
    wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
    if [ -f "${baserepo}" ]
    then
        yum makecache
    else
        action "Base repo is download faild."
    fi
    action "Repo base for aliyun complete." /buein/tr
}

Install_base_pkg() {
    pkg="iproute net-tools gcc-c++ make cmake libxml2-devel \
    openssl-devel git dos2unix lrzsz dstat xinetd rsync \
    tree autoconf automake zlib* libxml* fiex* ntpdate \
    curl zip unzip gcc perl-Net-SSLeay perl-IO-Socket-SSL \
    libmcrypt* libtool-ltdl-devel* tcpdump telnet python-devel"
    yum -y update
    yum -y install $pkg
    check "Base packages installed."
}

Ntpdate() {
    if [ `yum list installed  | grep -c ntpdate` -ne 0 ];then
        if [ `grep -c "aliyun.com" /etc/crontab` -eq 0 ];then
            echo "*/5 * * * * root /usr/sbin/ntpdate time1.aliyun.com &>/dev/null" >> /etc/crontab
            check "Ntpdate is set."
        else
            action "Ntpdate is already set." /bin/true
        fi
    else
        action "ntpdate package is not install."
        exit 0
    fi
}

Ulimit() {
read -p "please set ulimit's value: " ulimit_num
cmd=$(egrep -c "root soft nofile ${ulimit_num}|root hard nofile ${ulimit_num}" /etc/security/limits.conf)
if [ $cmd -eq 0 ];then
cat >> /etc/security/limits.conf <<EOF
root soft nofile ${ulimit_num}
root hard nofile ${ulimit_num}
* soft nproc ${ulimit_num}
* hard nproc ${ulimit_num}
* soft nofile ${ulimit_num}
* hard nofile ${ulimit_num}
EOF
fi
ulimit -n ${ulimit_num}
echo "${ulimit_num}" > /proc/sys/fs/file-max
check "Ulimit is set."
}

Core_parameter() {
cat > /etc/sysctl.conf <<EOF
# sysctl settings are defined through files in
# /usr/lib/sysctl.d/, /run/sysctl.d/, and /etc/sysctl.d/.
#
# Vendors settings live in /usr/lib/sysctl.d/.
# To override a whole file, create a new file with the same in
# /etc/sysctl.d/ and put new settings there. To override
# only specific settings, add a file with a lexically later
# name in /etc/sysctl.d/ and put new settings there.
#
# For more information, see sysctl.conf(5) and sysctl.d(5).
#关闭ipv6
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
# 避免放大攻击
net.ipv4.icmp_echo_ignore_broadcasts = 1
# 开启恶意icmp错误消息保护
net.ipv4.icmp_ignore_bogus_error_responses = 1
#关闭路由转发
net.ipv4.ip_forward = 1
net.ipv4.conf.all.send_redirects = 1
net.ipv4.conf.default.send_redirects = 1
#开启反向路径过滤
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
#处理无源路由的包
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
#关闭sysrq功能
kernel.sysrq = 0
#core文件名中添加pid作为扩展名
kernel.core_uses_pid = 1
# 开启SYN洪水攻击保护
net.ipv4.tcp_syncookies = 1
#修改消息队列长度
kernel.msgmnb = 65536
kernel.msgmax = 65536
#设置最大内存共享段大小bytes
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
#timewait的数量，默认180000
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_rmem = 4096        87380   4194304
net.ipv4.tcp_wmem = 4096        16384   4194304
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
#每个网络接口接收数据包的速率比内核处理这些包的速率快时，允许送到队列的数据包的最大数目
net.core.netdev_max_backlog = 262144
#限制仅仅是为了防止简单的DoS 攻击
net.ipv4.tcp_max_orphans = 3276800
#未收到客户端确认信息的连接请求的最大值
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_timestamps = 0
#内核放弃建立连接之前发送SYNACK 包的数量
net.ipv4.tcp_synack_retries = 1
#内核放弃建立连接之前发送SYN 包的数量
net.ipv4.tcp_syn_retries = 1
#启用timewait 快速回收
net.ipv4.tcp_tw_recycle = 1
#开启重用。允许将TIME-WAIT sockets 重新用于新的TCP 连接
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_fin_timeout = 2
#当keepalive 起用的时候，TCP 发送keepalive 消息的频度。缺省是2 小时
net.ipv4.tcp_keepalive_time = 1800
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_keepalive_intvl = 15
#允许系统打开的端口范围
net.ipv4.ip_local_port_range = 1024    65000
# 确保无人能修改路由表
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
vm.max_map_count = 655360
EOF
sysctl -p
check "sysctl is set."
}

Optimize_ssh() {
    read -p "pls enter ssh port: (default is 22)" port
    if [ $port != "" ];then
        sed -i "s/#Port 22/Port $port/g" /etc/ssh/sshd_config
    fi
    sed -i 's/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config
    sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/g' /etc/ssh/sshd_config
    systemctl restart sshd
    check "ssh is set."
}

Bash_mode() {
    echo 'PS1="\[\e[37;40m\][\[\e[32;40m\]\u\[\e[37;40m\]@\h \[\e[36;40m\]\w\[\e[0m\]]\\$ "' >> /root/.bashrc
    check "bash mode is set."
}

History_message() {
    export PROMPT_COMMAND='{ msg=$(history 1 | { read x y ; echo $y ;});logger "[euid=$(whoami)]":$(who am i):[`pwd`]" $msg";}'
    check "History record is set."
}

Hostname() {
    read -p "Please input your hostname: " HostName
    hostnamectl set-hostname $HostName
    hostname $HostName
    check "Hostname is set."
}
Other() {
    systemctl disable firewalld
    systemctl stop firewalld
    sed -i 's/SELINUX=.*/SELINUX=disabled/g' /etc/sysconfig/selinux
    setenforce 0
    check "Other is set."
}

Excute_all() {
    menu=(
    Repo \
    Install_base_pkg \
    Ntpdate \
    Ulimit \
    Core_parameter \
    Optimize_ssh \
    Bash_mode \
    History_message \
    Hostname \
    Other
    )
    for cmd in ${menu[@]}
    do
        $cmd
        sleep 1
    done
}

menu_list() {
   echo "######################################### "
   echo "#            Options list               # "
   echo "######################################### "
   echo "   [ 0 ]   Excute all options             "
   echo "   [ 1 ]   Set Repo                       "
   echo "   [ 2 ]   Install Base packages          "
   echo "   [ 3 ]   Set ntpdate                    "
   echo "   [ 4 ]   Set ulimit                     "
   echo "   [ 5 ]   Set Core_parameter             "
   echo "   [ 6 ]   Optimize ssh                   "
   echo "   [ 7 ]   Set bash mode                  "
   echo "   [ 8 ]   Set History recor              "
   echo "   [ 9 ]   Set hostname                   "
   echo "   [ 10 ]  Set Other options              "
   echo "   [ 11 ]  exits                          "
   echo "##########################################"
   read  -p  "Please input your choice: [0-11]：" number;
}

menus() {
while :
do
    menu_list;
    case $number in
    0)
       Excute_all;;
    1)
       Repo;;
    2)
       Install_base_pkg;;
    3)
       Ntpdate;;
    4)
       Ulimit;;
    5)
       Core_parameter;;
    6)
       Optimize_ssh;;
    7)
       Bash_mode;;
    8)
       History_message;;
    9)
       Hostname;;
    10)
       Other;;
    11)
        break;;
   esac
done
}

helplist(){
    echo " 使用menus选项 打开菜单 选择安装项 ";
    echo " 使用all选项  默认安装 所有安全项 ";
    echo " 使用向导 sh $0 menus ";
}

setall() {
   if [ -z $1 ]
   then
      echo "参数错误"
      helplist;
   elif [ $1 = "menus" ]
   then
       menus;
   elif [ $1 = "all" ]
   then
       Excute_all;
   fi
}

setall $1
