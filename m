From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:27 -0500
Subject: [lustre-devel] [PATCH 399/622] lustre: llite: create obd_device
 with usercopy whitelist
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-400-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Li Dongyang <dongyangli@ddn.com>

Since kernel 4.16 hardened usercopy has been added,
whitelist the struct obd_device to silence the warning.

Bad or missing usercopy whitelist? Kernel memory exposure attempt
detected from SLUB object 'll_obd_dev_cache' (offset 1256, size 40)!
WARNING: CPU: 1 PID: 17534 at mm/usercopy.c:83 usercopy_warn+0x7d/0xa0
Call Trace:
  __check_object_size+0xfa/0x181
  lmv_iocontrol+0x1146/0x1880 [lmv]
  ll_obd_statfs+0x356/0x860 [lustre]
  ll_dir_ioctl+0x1e37/0x6760 [lustre]
  do_vfs_ioctl+0xa4/0x630

Linux-commit: 8eb8284b412906181357c2b0110d879d5af95e52

WC-bug-id: https://jira.whamcloud.com/browse/LU-12331
Lustre-commit: e34c59812abf ("LU-12331 llite: create obd_device with usercopy whitelist")
Signed-off-by: Li Dongyang <dongyangli@ddn.com>
Reviewed-on: https://review.whamcloud.com/34946
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/genops.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/obdclass/genops.c b/fs/lustre/obdclass/genops.c
index 2b1175f..49db077 100644
--- a/fs/lustre/obdclass/genops.c
+++ b/fs/lustre/obdclass/genops.c
@@ -648,9 +648,11 @@ void obd_cleanup_caches(void)
 int obd_init_caches(void)
 {
 	LASSERT(!obd_device_cachep);
-	obd_device_cachep = kmem_cache_create("ll_obd_dev_cache",
-					      sizeof(struct obd_device),
-					      0, 0, NULL);
+	obd_device_cachep = kmem_cache_create_usercopy("ll_obd_dev_cache",
+						       sizeof(struct obd_device),
+						       0, 0, 0,
+						       sizeof(struct obd_device),
+						       NULL);
 	if (!obd_device_cachep)
 		goto out;
 
-- 
1.8.3.1
