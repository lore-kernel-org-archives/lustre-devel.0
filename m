From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:44 -0400
Subject: [lustre-devel] [PATCH 085/151] lustre: scrub: general framework for
 OI scrub
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-86-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Fan Yong <fan.yong@intel.com>

Reconstruct OI scrub code to make some data structure and
functions can be shared between osd-ldiskfs and osd-ZFS.
This cleanup is mainly server side but it does lead to a
enum removal since in the linux client.

WC-bug-id: https://jira.whamcloud.com/browse/LU-7585
Lustre-commit: 7e21ea59edcc ("LU-7585 scrub: general framework for OI scrub")
Signed-off-by: Fan Yong <fan.yong@intel.com>
Reviewed-on: https://review.whamcloud.com/28607
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_fid.h | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/fs/lustre/include/lustre_fid.h b/fs/lustre/include/lustre_fid.h
index 5108864..b469295 100644
--- a/fs/lustre/include/lustre_fid.h
+++ b/fs/lustre/include/lustre_fid.h
@@ -195,13 +195,6 @@ enum {
 	LUSTRE_SEQ_SUPER_WIDTH = ((1ULL << 30ULL) * LUSTRE_SEQ_META_WIDTH)
 };
 
-enum {
-	/** 2^6 FIDs for OI containers */
-	OSD_OI_FID_OID_BITS     = 6,
-	/** reserve enough FIDs in case we want more in the future */
-	OSD_OI_FID_OID_BITS_MAX = 10,
-};
-
 /** special OID for local objects */
 enum local_oid {
 	/** \see fld_mod_init */
-- 
1.8.3.1
