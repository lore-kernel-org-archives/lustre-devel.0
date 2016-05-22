From: Tobin C Harding <me@tobin.cc>
Date: Mon, 23 May 2016 07:52:17 +1000
Subject: [lustre-devel] [PATCH] staging: lustre: llite: kzalloc/copy_to_user
	to memdup_user
Message-ID: <1463953938-17192-1-git-send-email-me@tobin.cc>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: patrik.r.jakobsson@gmail.com
Cc: Dmitry Eremin <dmitry.eremin@intel.com>, Abdul Hussain <habdul@visteon.com>, David Airlie <airlied@linux.ie>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Nunez <james.a.nunez@intel.com>, "open list:DRM DRIVERS FOR GMA500 Poulsbo, Moorestown and...,
 linux-kernel@vger.kernel.org open list,
 lustre-devel@lists.lustre.org moderated list:STAGING - LUSTRE PARALLEL
 FILESYSTEM, devel@driverdev.osuosl.org open list:STAGING SUBSYSTEM" <dri-devel@lists.freedesktop.org>, Oleg Drokin <oleg.drokin@intel.com>, Julia Lawall <Julia.Lawall@lip6.fr>, Al Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <andreas.dilger@intel.com>, "John L. Hammond" <john.hammond@intel.com>, Frank Zago <fzago@cray.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Tobin C Harding <me@tobin.cc>

kzalloc call followed by copy_to_user can be replaced by call to memdup_user.

Signed-off-by: Tobin C Harding <me@tobin.cc>
---
 drivers/gpu/drm/gma500/gma_display.c      |  2 +-
 drivers/staging/lustre/lustre/llite/dir.c | 22 +++++++---------------
 2 files changed, 8 insertions(+), 16 deletions(-)

diff --git a/drivers/gpu/drm/gma500/gma_display.c b/drivers/gpu/drm/gma500/gma_display.c
index 5bf765d..8a1fb25 100644
--- a/drivers/gpu/drm/gma500/gma_display.c
+++ b/drivers/gpu/drm/gma500/gma_display.c
@@ -285,7 +285,7 @@ void gma_crtc_dpms(struct drm_crtc *crtc, int mode)
 
 		/* Wait for vblank for the disable to take effect */
 		gma_wait_for_vblank(dev);
-
+l
 		/* Disable plane */
 		temp = REG_READ(map->cntr);
 		if ((temp & DISPLAY_PLANE_ENABLE) != 0) {
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 4b00d1a..b0eb102 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -1076,19 +1076,14 @@ static int copy_and_ioctl(int cmd, struct obd_export *exp,
 	void *copy;
 	int rc;
 
-	copy = kzalloc(size, GFP_NOFS);
-	if (!copy)
-		return -ENOMEM;
-
-	if (copy_from_user(copy, data, size)) {
-		rc = -EFAULT;
+	copy = memdup_user(data, size);
+	if (IS_ERR(copy)) {
+		rc = PTR_ERR(copy);
 		goto out;
 	}
 
 	rc = obd_iocontrol(cmd, exp, size, copy, NULL);
 out:
-	kfree(copy);
-
 	return rc;
 }
 
@@ -1689,12 +1684,9 @@ out_poll:
 	case LL_IOC_QUOTACTL: {
 		struct if_quotactl *qctl;
 
-		qctl = kzalloc(sizeof(*qctl), GFP_NOFS);
-		if (!qctl)
-			return -ENOMEM;
-
-		if (copy_from_user(qctl, (void __user *)arg, sizeof(*qctl))) {
-			rc = -EFAULT;
+		qctl = memdup_user((void __user *)arg, sizeof(*qctl));
+		if (IS_ERR(qctl)) {
+			rc = PTR_ERR(qctl);
 			goto out_quotactl;
 		}
 
@@ -1704,8 +1696,8 @@ out_poll:
 					    sizeof(*qctl)))
 			rc = -EFAULT;
 
-out_quotactl:
 		kfree(qctl);
+out_quotactl:
 		return rc;
 	}
 	case OBD_IOC_GETDTNAME:
-- 
2.8.2
