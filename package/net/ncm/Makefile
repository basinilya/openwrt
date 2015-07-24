#
# Copyright (C) 2007-2013 OpenWrt.org
# Copyright (C) 2010 Vertical Communications
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

# Original package by Oskari Rauta <oskari.rauta at gmail.com>
# To see this package in menuconfig, first turn on Kernel modules/USB Support/kmod-usb-net

include $(TOPDIR)/rules.mk

PKG_NAME:=ncm
PKG_VERSION:=1.0.2a
PKG_RELEASE:=1
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)-$(PKG_RELEASE)

include $(INCLUDE_DIR)/package.mk

define Package/ncm/Default
  VERSION:=$(PKG_VERSION)-$(PKG_RELEASE)
  URL:=http://openwrt.org/
  MAINTAINER:=Ilya Basin <basinilya at gmail.com>
endef

define Package/ncm
$(call Package/ncm/Default)
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Protocol support for NCM
  PKGARCH:=all
  DEPENDS:=+comgt +kmod-usb-net-cdc-ncm +kmod-usb-serial
endef

define Package/ncm/description
 This package contains protocol support for NCM.
endef

define Package/ncm-huawei-e3276
$(call Package/ncm/Default)
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Huawei E3276 support for NCM protocol
  PKGARCH:=all
  DEPENDS:=+ncm +comgt +kmod-usb-serial
endef

define Package/ncm-huawei-e3276/description
 This package contains communication scripts for Huawei E3276
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile/Default
endef

Build/Compile = $(Build/Compile/Default)

define Package/ncm/install
	$(INSTALL_DIR) $(1)/lib
	$(INSTALL_DIR) $(1)/lib/netifd
	$(INSTALL_DIR) $(1)/lib/netifd/proto
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DIR) $(1)/etc/gcom
	$(INSTALL_DIR) $(1)/etc/gcom/ncm
	$(INSTALL_DIR) $(1)/etc/gcom/ncm/signal
	$(INSTALL_DIR) $(1)/etc/gcom/ncm/carrier
	$(INSTALL_DIR) $(1)/etc/gcom/ncm/setmode
	$(INSTALL_DIR) $(1)/etc/gcom/ncm/connect
	$(INSTALL_DIR) $(1)/etc/gcom/ncm/initscripts
	$(INSTALL_BIN) ./files/lib/netifd/proto/ncm.sh $(1)/lib/netifd/proto/
	$(INSTALL_DATA) ./files/etc/gcom/ncm/getcardinfo.gcom $(1)/etc/gcom/ncm/
endef

define Package/ncm-huawei-e3276/install
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DIR) $(1)/etc/gcom
	$(INSTALL_DIR) $(1)/etc/gcom/ncm
	$(INSTALL_DIR) $(1)/etc/gcom/ncm/signal
	$(INSTALL_DIR) $(1)/etc/gcom/ncm/carrier
	$(INSTALL_DIR) $(1)/etc/gcom/ncm/setmode
	$(INSTALL_DIR) $(1)/etc/gcom/ncm/connect
	$(INSTALL_DIR) $(1)/etc/gcom/ncm/initscripts
	$(INSTALL_DATA) ./files/etc/gcom/ncm/signal/huawei_e3276.gcom $(1)/etc/gcom/ncm/signal/
	$(INSTALL_DATA) ./files/etc/gcom/ncm/carrier/huawei_e3276.gcom $(1)/etc/gcom/ncm/carrier/
	$(INSTALL_DATA) ./files/etc/gcom/ncm/setmode/huawei_e3276.gcom $(1)/etc/gcom/ncm/setmode/
	$(INSTALL_DATA) ./files/etc/gcom/ncm/connect/huawei_e3276.gcom $(1)/etc/gcom/ncm/connect/
	$(INSTALL_DATA) ./files/etc/gcom/ncm/initscripts/huawei_e3276.gcom $(1)/etc/gcom/ncm/initscripts/
endef

$(eval $(call BuildPackage,ncm))
$(eval $(call BuildPackage,ncm-huawei-e3276))
