#!/bin/bash
#title           :java-install.sh
#description     :The script to install Java JDK x.x
#more            :http://miweb.net/java-jdk-installation.html
#author	         :Z3ttaByte
#date            :2015-10-24T17:14-0700
#usage           :/bin/bash java-install.sh <jdk_version> <rpm|tar> <32|64>
#tested-version  :10.0.0.CR3
#tested-distros  :Debian 7,8; Ubuntu 15.10; CentOS 7; Fedora 22 
# jdk_version: default 8
# Extencion: Default tar.gz
# architecture: Default 64 Bits
JDK_VERSION="8"
EXT="tar.gz"
ARCHITECTURE="x64"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root."
   exit 1
fi
#Para insertar parametros en un futuro
#if [ -n "$1" ]; then
#  if [ "$1" == "7" ]; then
#    JDK_VERSION="7"
#  fi
#fi

#if [ -n "$2" ]; then
#  if [ "$2" == "rpm" ]; then
#    EXT="rpm"
#  fi
#fi

#if [ -n "$3" ]; then
#  if [ "$3" == "32" ]; then
#    ARCHITECTURE="i586"
#  fi
#fi

URL="http://www.oracle.com"
JDK_DOWNLOAD_URL1="${URL}/technetwork/java/javase/downloads/index.html"
JDK_DOWNLOAD_URL2=`curl -s $JDK_DOWNLOAD_URL1 | grep -Po "\/technetwork\/java/\javase\/downloads\/jdk${JDK_VERSION}-downloads-.+?\.html" | head -1`
if [ -z "$JDK_DOWNLOAD_URL2" ]; then
  echo "Could not get jdk download url - $JDK_DOWNLOAD_URL1"
  exit 1
fi
JDK_DOWNLOAD_URL3="${URL}${JDK_DOWNLOAD_URL2}"
JDK_DOWNLOAD_URL4=`curl -s $JDK_DOWNLOAD_URL3 | egrep -o "http\:\/\/download.oracle\.com\/otn-pub\/java\/jdk\/[7-8]u[0-9]+\-(.*)+\/jdk-[7-8]u[0-9]+(.*)linux-${ARCHITECTURE}.${EXT}"`
mkdir /tmp/jdkinstall
echo ${JDK_DOWNLOAD_URL4} > /tmp/jdkinstall/jdkvar.txt;
cat /tmp/jdkinstall/jdkvar.txt | tr -c a-zA-Z-/-_-. '\n' > /tmp/jdkinstall/jdkvar2.txt;
sed -i '1d' /tmp/jdkinstall/jdkvar2.txt > /tmp/jdkinstall/jdkvar3.txt;
JDK_DOWNLOAD_URL5=`cat /tmp/jdkinstall/jdkvar2.txt`
cd /tmp/jdkinstall
wget --tries=5 --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" $JDK_DOWNLOAD_URL5
tar -zxvf *-linux-x64.tar.gz -C /tmp/jdkinstall/
rm /tmp/jdkinstall/*.tar.gz
rm /tmp/jdkinstall/*.txt
JDK_NAME=`ls /tmp/jdkinstall/`
touch /tmp/jdkinstall/$JDK_NAME/jdkversiontoupdate.txt
echo `cat $JDK_NAME > /tmp/jdkinstall/$JDK_NAME/jdkversiontoupdate.txt`
mv /tmp/jdkinstall/$JDK_NAME /opt/
update-alternatives --install /usr/bin/java java /opt/$JDK_NAME/bin/java 2
update-alternatives --config java
update-alternatives --install /usr/bin/jar jar /opt/$JDK_NAME/bin/jar 2
update-alternatives --install /usr/bin/javac javac /opt/$JDK_NAME/bin/javac 2
update-alternatives --set jar /opt/$JDK_NAME/bin/jar
update-alternatives --set javac /opt/$JDK_NAME/bin/javac
export JAVA_HOME=/opt/$JDK_NAME
export JRE_HOME=/opt/$JDK_NAME/jre
export PATH=$PATH:/opt/$JDK_NAME/bin:/opt/$JDK_NAME/jre/bin
#Limpieza
rm -Rf /tmp/jdkinstall
echo "Done."
