From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:22 -0500
Subject: [lustre-devel] [PATCH 034/622] lustre: mgc: remove obsolete IR
 swabbing workaround
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-35-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

The OBD_CONNECT_MNE_SWAB check was added to the MGC for compatibility
with servers in the 2.2.0-2.2.55 range (in 2012) with big-endian
clients.  2.2 was not an LTS release and is no longer being used.

Remove the checks on the client for OBD_CONNECT_MNE_SWAB being set,
and assume that the server does not have this bug.  This will allow
the removal of the rest of this workaround from the server code once
there are no more clients depending on the presence of this flag.

WC-bug-id: https://jira.whamcloud.com/browse/LU-1644
Lustre-commit: a0c644fde340 ("LU-1644 mgc: remove obsolete IR swabbing workaround")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32087
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_import.h |  4 ----
 fs/lustre/mgc/mgc_request.c       |  9 +--------
 fs/lustre/ptlrpc/import.c         | 21 ---------------------
 3 files changed, 1 insertion(+), 33 deletions(-)

diff --git a/fs/lustre/include/lustre_import.h b/fs/lustre/include/lustre_import.h
index 522e5b7..0d7bb0f 100644
--- a/fs/lustre/include/lustre_import.h
+++ b/fs/lustre/include/lustre_import.h
@@ -289,10 +289,6 @@ struct obd_import {
 					imp_resend_replay:1,
 					/* disable normal recovery, for test only. */
 					imp_no_pinger_recover:1,
-#if OBD_OCD_VERSION(3, 0, 53, 0) > LUSTRE_VERSION_CODE
-					/* need IR MNE swab */
-					imp_need_mne_swab:1,
-#endif
 					/* import must be reconnected instead of
 					 * chosing new connection
 					 */
diff --git a/fs/lustre/mgc/mgc_request.c b/fs/lustre/mgc/mgc_request.c
index ca4b8a9..c114aa8 100644
--- a/fs/lustre/mgc/mgc_request.c
+++ b/fs/lustre/mgc/mgc_request.c
@@ -1436,14 +1436,7 @@ static int mgc_process_recover_log(struct obd_device *obd,
 		goto out;
 	}
 
-	mne_swab = !!ptlrpc_rep_need_swab(req);
-#if OBD_OCD_VERSION(3, 0, 53, 0) > LUSTRE_VERSION_CODE
-	/* This import flag means the server did an extra swab of IR MNE
-	 * records (fixed in LU-1252), reverse it here if needed. LU-1644
-	 */
-	if (unlikely(req->rq_import->imp_need_mne_swab))
-		mne_swab = !mne_swab;
-#endif
+	mne_swab = ptlrpc_rep_need_swab(req);
 
 	for (i = 0; i < nrpages && ealen > 0; i++) {
 		int rc2;
diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index dca4aa0..f69b907 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -780,27 +780,6 @@ static int ptlrpc_connect_set_flags(struct obd_import *imp,
 		warned = true;
 	}
 
-#if LUSTRE_VERSION_CODE < OBD_OCD_VERSION(3, 0, 53, 0)
-	/*
-	 * Check if server has LU-1252 fix applied to not always swab
-	 * the IR MNE entries. Do this only once per connection.  This
-	 * fixup is version-limited, because we don't want to carry the
-	 * OBD_CONNECT_MNE_SWAB flag around forever, just so long as we
-	 * need interop with unpatched 2.2 servers.  For newer servers,
-	 * the client will do MNE swabbing only as needed.  LU-1644
-	 */
-	if (unlikely((ocd->ocd_connect_flags & OBD_CONNECT_VERSION) &&
-		     !(ocd->ocd_connect_flags & OBD_CONNECT_MNE_SWAB) &&
-		     OBD_OCD_VERSION_MAJOR(ocd->ocd_version) == 2 &&
-		     OBD_OCD_VERSION_MINOR(ocd->ocd_version) == 2 &&
-		     OBD_OCD_VERSION_PATCH(ocd->ocd_version) < 55 &&
-		     !strcmp(imp->imp_obd->obd_type->typ_name,
-			     LUSTRE_MGC_NAME)))
-		imp->imp_need_mne_swab = 1;
-	else /* clear if server was upgraded since last connect */
-		imp->imp_need_mne_swab = 0;
-#endif
-
 	if (ocd->ocd_connect_flags & OBD_CONNECT_CKSUM) {
 		/*
 		 * We sent to the server ocd_cksum_types with bits set
-- 
1.8.3.1
