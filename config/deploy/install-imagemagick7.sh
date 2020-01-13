#!/bin/bash

##############################################################
# Title          : install-imagemagick7.sh                   #
# Description    : ImageMagick® 7 for Debian/Ubuntu,         #
#                  including (nearly) full delegate support. #
#                                                            #
# Author         : SoftCreatR Media <info@softcreatr.de>     #
# Date           : 2019-05-20 01:29:14                       #
# Version        : 2.0.0                                     #
# Usage          : bash install-imagemagick7.sh              #
##############################################################

# Create a temp directory as workspace
WORK_DIR=$(mktemp -d)

# check if temp directory was created
if [[ ! "$WORK_DIR" || ! -d "$WORK_DIR" ]]; then
  echo "Could not create temp directory $WORK_DIR"
  exit 1
fi

# deletes the temp directory
function cleanup {
  rm -rf "$WORK_DIR"
}

# call cleanup function on EXIT signal
trap cleanup EXIT

# Remove old imagemagick, if installed
apt remove imagemagick --autoremove --purge

# Update packages
apt-get update

# Install required packages
PKG_LIST="adwaita-icon-theme autopoint build-essential chrpath cm-super-minimal dconf-gsettings-backend dconf-service debhelper dh-autoreconf dh-strip-nondeterminism doxygen doxygen-latex fontconfig fontconfig-config fonts-dejavu-core gettext ghostscript gir1.2-freedesktop gir1.2-gdkpixbuf-2.0 gir1.2-pango-1.0 gir1.2-rsvg-2.0 git glib-networking glib-networking-common glib-networking-services graphviz gsettings-desktop-schemas gsfonts hicolor-icon-theme intltool-debian libarchive-zip-perl libatspi2.0-0 libavahi-client3 libbz2-dev libcdt5 libcgraph6 libcolord2 libcroco3 libcups2 libcupsimage2 libdatrie1 libdconf1 libdjvulibre-dev libepoxy0 libexpat1-dev libfftw3-bin libfftw3-dev libfftw3-double3 libfftw3-long3 libfftw3-quad3 libfftw3-single3 libfile-stripnondeterminism-perl libfontconfig1 libfontconfig1-dev libfreetype6-dev libfribidi-dev libgd3 libgdk-pixbuf2.0-0 libgdk-pixbuf2.0-common libgdk-pixbuf2.0-dev libglib2.0-bin libglib2.0-dev libgraphite2-3 libgraphviz-dev libgs-dev libgs9 libgs9-common libgtk-3-0 libgtk-3-common libgvc6 libgvpr2 libharfbuzz-dev libharfbuzz-gobject0 libijs-0.35 libjson-glib-1.0-0 libjson-glib-1.0-common libkpathsea6 liblcms2-2 liblcms2-dev liblqr-1-0 liblqr-1-0-dev libltdl-dev liblzma-dev libopenexr-dev libopenjp2-7-dev libpango-1.0-0 libpango1.0-dev libpangocairo-1.0-0 libpangoft2-1.0-0 libpangoxft-1.0-0 libpathplan4 libperl-dev libpixman-1-0 libpixman-1-dev libpotrace0 libproxy1v5 libptexenc1 libpthread-stubs0-dev libraw-dev librest-0.7-0 librsvg2-2 librsvg2-bin librsvg2-common librsvg2-dev libsynctex1 libtexlua52 libtexluajit2 libtiffxx5 libtimedate-perl libwayland-client0 libwayland-cursor0 libwebp-dev libwmf-dev libx11-dev libxaw7 libxcb-render0 libxcb-render0-dev libxcb-shm0 libxcomposite1 libxcursor1 libxdamage1 libxfixes3 libxi6 libxinerama1 libxkbcommon0 libxml2-dev libxmu6 libxpm4 libxrandr2 libzzip-0-13 pkg-config pkg-kde-tools po-debconf poppler-data preview-latex-style t1utils tex-common texlive-base texlive-binaries texlive-extra-utils texlive-latex-base texlive-latex-extra texlive-latex-recommended texlive-pictures x11-common x11proto-core-dev x11proto-xext-dev xdg-utils xorg-sgml-doctools xsltproc xtrans-dev"

if [ -n "$(cat /etc/os-release | grep Debian)" ]; then
  PKG_LIST+=" cpp-6 dh-exec fonts-lmodern g++-6 gcc-6 gir1.2-glib-2.0 gtk-doc-tools gtk-update-icon-cache libann0 libasan3 libclang1-3.9 libdrm2 libgcc-6-dev libgirepository-1.0-1 libglib2.0-data libgraphite2-dev libgts-0.7-5 libjpeg62-turbo libjpeg62-turbo-dev libllvm3.9 liblzo2-2 libmpfr4 libmpx2 libnspr4 libnss3 libopenjp2-7 libperl5.24 libpng-dev libpoppler64 libsigsegv2 libstdc++-6-dev libtool-bin libwebp6 libx11-6 libx11-data libxau6 libxcb1 libxdmcp6 libxdot4 libxext6 libxslt1.1 perl shared-mime-info libzstd-dev"
elif [ -n "$(cat /etc/os-release | grep 16\.04)" ]; then
    PKG_LIST+=" automake cpp-5 g++-5 gcc-5 gtk-doc-tools hardening-includes libasan2 libboost-filesystem1.58.0 libboost-system1.58.0 libcapnp-0.5.3 libclang1-3.6 libcupsfilters1 libdata-alias-perl libdrm-amdgpu1 libdrm-intel1 libdrm-nouveau2 libdrm-radeon1 libegl1-mesa libgbm1 libgcc-5-dev libgl1-mesa-dri libglapi-mesa libgtk-3-bin libisl15 libjasper-dev libjasper1 libjs-jquery libllvm3.6v5 libmirclient9 libmircommon7 libmircore1 libmirprotobuf3 libmpx0 libobjc-5-dev libobjc4 libpciaccess0 libpng12-dev libpoppler58 libprotobuf-lite9v5 libsensors4 libstdc++-5-dev libunistring0 libvpx3 libwayland-egl1-mesa libwayland-server0 libx11-xcb1 libxcb-dri2-0 libxcb-dri3-0 libxcb-present0 libxcb-sync1 libxcb-xfixes0 libxshmfence1 x11proto-input-dev x11proto-kb-dev x11proto-render-dev libzstd1-dev"
elif [ -n "$(cat /etc/os-release | grep 18\.04)" ]; then
  PKG_LIST+=" binutils-common binutils-x86-64-linux-gnu cpp-7 dh-exec fonts-lmodern g++-7 gcc-7 gcc-7-base gir1.2-harfbuzz-0.0 gtk-update-icon-cache libann0 libasan4 libbinutils libclang1-6.0 libgcc-7-dev libglib2.0-dev-bin libgraphite2-dev libgts-0.7-5 libicu-le-hb-dev libicu-le-hb0 libiculx60 libisl19 liblab-gamut1 libmime-charset-perl libmpx2 libnspr4 libnss3 libpng-dev libpoppler73 libraqm-dev libsombok3 libstdc++-7-dev libtiff-dev libtool-bin libunicode-linebreak-perl libwayland-egl1 libwebp6 libxml-libxml-perl libxml-namespacesupport-perl libxml-sax-base-perl libxml-sax-perl libxml-simple-perl perl-openssl-defaults python3-distutils python3-lib2to3 x11proto-dev zlib1g-dev libzstd1-dev"
else
   echo "Unsupported OS."
   cat /etc/os-release
   uname -a
   exit 1
fi

#######################
# Installer functions #
#######################

# libheif (v1.4.0)
function install_libheif {
  cd $WORK_DIR && \
  git clone https://github.com/strukturag/libheif.git && \
  cd libheif && \
  git checkout "fca25874bb8021dede702bb7023a22af1a8a06ab" && \
  ./autogen.sh && \
  ./configure && \
  make install
}

# libfpx (v1.3.1-10)
function install_libfpx {
  cd $WORK_DIR && \
  wget https://imagemagick.org/download/delegates/libfpx-1.3.1-10.tar.gz && \
  tar xfvz libfpx-1.3.1-10.tar.gz && \
  cd libfpx-1.3.1-10 && \
  ./configure && \
  make install
}

# libraqm (v0.7.0)
function install_libraqm {
  cd $WORK_DIR && \
  git clone https://github.com/HOST-Oman/libraqm.git && \
  cd libraqm && \
  git checkout "f209035a6cdeb68bdc1317d655060b3f7478991c" && \
  ./autogen.sh && \
  ./configure && \
  make install
}

# ImageMagick
function install_imagemagick {
  cd $WORK_DIR && \
  wget https://imagemagick.org/download/ImageMagick.tar.gz && \
  tar xfvz ImageMagick.tar.gz

  # Unfortunately, there's no beautiful way to determine, what version we are going to install.
  # So we have to perform some magic to find it out.
  # This can change at any time, but for now, it works. Yay!
  IMAGICK_DIR=$(tar -tzf ImageMagick.tar.gz | head -1 | cut -f1 -d"/")

  cd $IMAGICK_DIR && \
  ./configure CFLAGS=-O5 CXXFLAGS=-O5 --prefix=/usr/local --with-modules --with-perl --disable-static --with-gslib --with-rsvg --with-wmf --with-gvc --with-freetype=yes --with-djvu=yes --with-fontpath=/usr/share/fonts/truetype --with-dejavu-font-dir=/usr/share/fonts/truetype/ttf-dejavu && \
  make -j5 && \
  make install && \
  ldconfig
}

######################
# Install everything #
######################

apt-get install -y $PKG_LIST && install_libheif && install_libfpx

# Install OS specific stuff (if there's any)
if [ -n "$(uname -a | grep Debian)" ]; then
  install_libraqm
elif [ -n "$(lsb_release -a | grep 16\.04)" ]; then
  install_libraqm
fi

# Finally, install ImageMagick
install_imagemagick

##########
# Finish #
##########

echo -e "\n\nInstallation successful:\n"
identify -version
echo -e "\n\n"

exit 0