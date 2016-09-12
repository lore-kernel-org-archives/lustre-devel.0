From: Masahiro Yamada <yamada.masahiro@socionext.com>
Date: Tue, 13 Sep 2016 03:57:48 +0900
Subject: [lustre-devel] [PATCH] staging: squash lines for simple wrapper
	functions
Message-ID: <1473706668-24216-1-git-send-email-yamada.masahiro@socionext.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg KH <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>, linux-fbdev@vger.kernel.org, Andreas Dilger <andreas.dilger@intel.com>, Sumit Semwal <sumit.semwal@linaro.org>, linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org, Larry Finger <Larry.Finger@lwfinger.net>, Teddy Wang <teddy.wang@siliconmotion.com>, Sudip Mukherjee <sudipm.mukherjee@gmail.com>, Laura Abbott <labbott@redhat.com>, =?UTF-8?q?Arve=20Hj=C3=B8nnev=C3=A5g?= <arve@android.com>, Jes Sorensen <Jes.Sorensen@redhat.com>, Riley Andrews <riandrews@android.com>, Oleg Drokin <oleg.drokin@intel.com>, lustre-devel@lists.lustre.org

Remove unneeded variables and assignments.

While we are here, clean up the following as well:
  - refactor rtl8723a_get_bcn_valid() a bit
  - remove unneeded casts in sii164Get{Vendor,Device}ID()

Signed-off-by: Masahiro Yamada <yamada.masahiro@socionext.com>
---

 drivers/staging/android/ion/ion.c                        |  6 +-----
 .../staging/lustre/lustre/obdclass/linux/linux-module.c  |  5 +----
 drivers/staging/lustre/lustre/ptlrpc/client.c            |  5 +----
 drivers/staging/lustre/lustre/ptlrpc/events.c            |  5 +----
 drivers/staging/rtl8723au/core/rtw_wlan_util.c           |  7 +------
 drivers/staging/rtl8723au/hal/hal_com.c                  |  6 +-----
 drivers/staging/sm750fb/ddk750_sii164.c                  | 16 ++++------------
 7 files changed, 10 insertions(+), 40 deletions(-)

diff --git a/drivers/staging/android/ion/ion.c b/drivers/staging/android/ion/ion.c
index a2cf93b..a07fc03 100644
--- a/drivers/staging/android/ion/ion.c
+++ b/drivers/staging/android/ion/ion.c
@@ -389,11 +389,7 @@ static void ion_handle_get(struct ion_handle *handle)
 
 static int ion_handle_put_nolock(struct ion_handle *handle)
 {
-	int ret;
-
-	ret = kref_put(&handle->ref, ion_handle_destroy);
-
-	return ret;
+	return kref_put(&handle->ref, ion_handle_destroy);
 }
 
 static int ion_handle_put(struct ion_handle *handle)
diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
index 33342bf..3f2dd95 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
@@ -152,10 +152,7 @@ EXPORT_SYMBOL(obd_ioctl_getdata);
 
 int obd_ioctl_popdata(void __user *arg, void *data, int len)
 {
-	int err;
-
-	err = copy_to_user(arg, data, len) ? -EFAULT : 0;
-	return err;
+	return copy_to_user(arg, data, len) ? -EFAULT : 0;
 }
 EXPORT_SYMBOL(obd_ioctl_popdata);
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index d4463d7..38cbf4a 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -417,10 +417,7 @@ void ptlrpc_request_cache_fini(void)
 
 struct ptlrpc_request *ptlrpc_request_cache_alloc(gfp_t flags)
 {
-	struct ptlrpc_request *req;
-
-	req = kmem_cache_zalloc(request_cache, flags);
-	return req;
+	return kmem_cache_zalloc(request_cache, flags);
 }
 
 void ptlrpc_request_cache_free(struct ptlrpc_request *req)
diff --git a/drivers/staging/lustre/lustre/ptlrpc/events.c b/drivers/staging/lustre/lustre/ptlrpc/events.c
index b1ce725..8821f4d 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/events.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/events.c
@@ -525,10 +525,7 @@ static void ptlrpc_ni_fini(void)
 
 static lnet_pid_t ptl_get_pid(void)
 {
-	lnet_pid_t pid;
-
-	pid = LNET_PID_LUSTRE;
-	return pid;
+	return LNET_PID_LUSTRE;
 }
 
 static int ptlrpc_ni_init(void)
diff --git a/drivers/staging/rtl8723au/core/rtw_wlan_util.c b/drivers/staging/rtl8723au/core/rtw_wlan_util.c
index 694cf17..7ab47f0 100644
--- a/drivers/staging/rtl8723au/core/rtw_wlan_util.c
+++ b/drivers/staging/rtl8723au/core/rtw_wlan_util.c
@@ -1202,12 +1202,7 @@ unsigned int update_supported_rate23a(unsigned char *ptn, unsigned int ptn_sz)
 
 unsigned int update_MSC_rate23a(struct ieee80211_ht_cap *pHT_caps)
 {
-	unsigned int mask;
-
-	mask = pHT_caps->mcs.rx_mask[0] << 12 |
-		pHT_caps->mcs.rx_mask[1] << 20;
-
-	return mask;
+	return pHT_caps->mcs.rx_mask[0] << 12 | pHT_caps->mcs.rx_mask[1] << 20;
 }
 
 int support_short_GI23a(struct rtw_adapter *padapter,
diff --git a/drivers/staging/rtl8723au/hal/hal_com.c b/drivers/staging/rtl8723au/hal/hal_com.c
index 9d7b11b..dfbeebe 100644
--- a/drivers/staging/rtl8723au/hal/hal_com.c
+++ b/drivers/staging/rtl8723au/hal/hal_com.c
@@ -708,11 +708,7 @@ void rtl8723a_bcn_valid(struct rtw_adapter *padapter)
 
 bool rtl8723a_get_bcn_valid(struct rtw_adapter *padapter)
 {
-	bool retval;
-
-	retval = (rtl8723au_read8(padapter, REG_TDECTRL + 2) & BIT(0)) ? true : false;
-
-	return retval;
+	return !!(rtl8723au_read8(padapter, REG_TDECTRL + 2) & BIT(0));
 }
 
 void rtl8723a_set_beacon_interval(struct rtw_adapter *padapter, u16 interval)
diff --git a/drivers/staging/sm750fb/ddk750_sii164.c b/drivers/staging/sm750fb/ddk750_sii164.c
index 67f36e7..28818e1 100644
--- a/drivers/staging/sm750fb/ddk750_sii164.c
+++ b/drivers/staging/sm750fb/ddk750_sii164.c
@@ -36,12 +36,8 @@ static char *gDviCtrlChipName = "Silicon Image SiI 164";
  */
 unsigned short sii164GetVendorID(void)
 {
-	unsigned short vendorID;
-
-	vendorID = ((unsigned short) i2cReadReg(SII164_I2C_ADDRESS, SII164_VENDOR_ID_HIGH) << 8) |
-		    (unsigned short) i2cReadReg(SII164_I2C_ADDRESS, SII164_VENDOR_ID_LOW);
-
-	return vendorID;
+	return (i2cReadReg(SII164_I2C_ADDRESS, SII164_VENDOR_ID_HIGH) << 8) |
+		i2cReadReg(SII164_I2C_ADDRESS, SII164_VENDOR_ID_LOW);
 }
 
 /*
@@ -53,12 +49,8 @@ unsigned short sii164GetVendorID(void)
  */
 unsigned short sii164GetDeviceID(void)
 {
-	unsigned short deviceID;
-
-	deviceID = ((unsigned short) i2cReadReg(SII164_I2C_ADDRESS, SII164_DEVICE_ID_HIGH) << 8) |
-		    (unsigned short) i2cReadReg(SII164_I2C_ADDRESS, SII164_DEVICE_ID_LOW);
-
-	return deviceID;
+	return (i2cReadReg(SII164_I2C_ADDRESS, SII164_DEVICE_ID_HIGH) << 8) |
+		i2cReadReg(SII164_I2C_ADDRESS, SII164_DEVICE_ID_LOW);
 }
 
 
-- 
1.9.1
