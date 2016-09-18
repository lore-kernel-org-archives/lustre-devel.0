From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:20 -0400
Subject: [lustre-devel] [PATCH 021/124] staging: lustre: build: bump build
	version warnings to x.y.53
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-22-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Emoly Liu <emoly.liu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Andreas Dilger <andreas.dilger@intel.com>

Move the LUSTRE_VERSION_CODE checks to trigger on x.y.53 instead of
x.y.50, so that it is into the development cycle that they are hit
instead of right at the start.

In many cases, the #warning has been removed (to prevent build errors)
and instead the code is just disabled outright.  The dead code can be
seen easily and removed in the future with less interruption to the
development process.

Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: Emoly Liu <emoly.liu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4217
Reviewed-on: http://review.whamcloud.com/8630
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Tested-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/include/lustre_import.h  |    2 ++
 drivers/staging/lustre/lustre/include/obd.h        |    2 +-
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |    4 +---
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |    4 +---
 drivers/staging/lustre/lustre/ptlrpc/import.c      |    4 +---
 5 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_import.h b/drivers/staging/lustre/lustre/include/lustre_import.h
index b7a7a74..5461ba3 100644
--- a/drivers/staging/lustre/lustre/include/lustre_import.h
+++ b/drivers/staging/lustre/lustre/include/lustre_import.h
@@ -285,8 +285,10 @@ struct obd_import {
 				  imp_resend_replay:1,
 				  /* disable normal recovery, for test only. */
 				  imp_no_pinger_recover:1,
+#if OBD_OCD_VERSION(3, 0, 53, 0) > LUSTRE_VERSION_CODE
 				  /* need IR MNE swab */
 				  imp_need_mne_swab:1,
+#endif
 				  /* import must be reconnected instead of
 				   * chosing new connection
 				   */
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 37a3acb..838a428 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -317,7 +317,7 @@ struct client_obd {
 	/* used by quotacheck when the servers are older than 2.4 */
 	int		      cl_qchk_stat; /* quotacheck stat of the peer */
 #define CL_NOT_QUOTACHECKED 1   /* client->cl_qchk_stat init value */
-#if LUSTRE_VERSION_CODE >= OBD_OCD_VERSION(2, 7, 50, 0)
+#if OBD_OCD_VERSION(2, 7, 53, 0) < LUSTRE_VERSION_CODE
 #warning "please consider removing quotacheck compatibility code"
 #endif
 
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 9d0bd47..f3d4f7f 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -1428,14 +1428,12 @@ again:
 	}
 
 	mne_swab = !!ptlrpc_rep_need_swab(req);
-#if LUSTRE_VERSION_CODE < OBD_OCD_VERSION(3, 2, 50, 0)
+#if OBD_OCD_VERSION(3, 0, 53, 0) > LUSTRE_VERSION_CODE
 	/* This import flag means the server did an extra swab of IR MNE
 	 * records (fixed in LU-1252), reverse it here if needed. LU-1644
 	 */
 	if (unlikely(req->rq_import->imp_need_mne_swab))
 		mne_swab = !mne_swab;
-#else
-#warning "LU-1644: Remove old OBD_CONNECT_MNE_SWAB fixup and imp_need_mne_swab"
 #endif
 
 	for (i = 0; i < nrpages && ealen > 0; i++) {
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index 0273768..0df1aa6 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -384,10 +384,8 @@ int lustre_start_mgc(struct super_block *sb)
 				  OBD_CONNECT_FULL20 | OBD_CONNECT_IMP_RECOV |
 				  OBD_CONNECT_LVB_TYPE;
 
-#if LUSTRE_VERSION_CODE < OBD_OCD_VERSION(3, 2, 50, 0)
+#if OBD_OCD_VERSION(3, 0, 53, 0) > LUSTRE_VERSION_CODE
 	data->ocd_connect_flags |= OBD_CONNECT_MNE_SWAB;
-#else
-#warning "LU-1644: Remove old OBD_CONNECT_MNE_SWAB fixup and imp_need_mne_swab"
 #endif
 
 	if (lmd_is_client(lsi->lsi_lmd) &&
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index 93b1e78..013a957 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -1042,7 +1042,7 @@ finish:
 			warned = true;
 		}
 
-#if LUSTRE_VERSION_CODE < OBD_OCD_VERSION(3, 2, 50, 0)
+#if OBD_OCD_VERSION(3, 0, 53, 0) > LUSTRE_VERSION_CODE
 		/* Check if server has LU-1252 fix applied to not always swab
 		 * the IR MNE entries. Do this only once per connection.  This
 		 * fixup is version-limited, because we don't want to carry the
@@ -1060,8 +1060,6 @@ finish:
 			imp->imp_need_mne_swab = 1;
 		else /* clear if server was upgraded since last connect */
 			imp->imp_need_mne_swab = 0;
-#else
-#warning "LU-1644: Remove old OBD_CONNECT_MNE_SWAB fixup and imp_need_mne_swab"
 #endif
 
 		if (ocd->ocd_connect_flags & OBD_CONNECT_CKSUM) {
-- 
1.7.1
