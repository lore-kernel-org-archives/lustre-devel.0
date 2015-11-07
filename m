From: Shraddha Barke <shraddha.6596@gmail.com>
Date: Sat,  7 Nov 2015 15:14:24 +0530
Subject: [lustre-devel] [PATCH] Staging: lustre: lustre_mds: Remove unused
	md_should_create
Message-ID: <1446889464-21260-1-git-send-email-shraddha.6596@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

md_should_create has been defined in header file but not used.
Thus remove it.

Signed-off-by: Shraddha Barke <shraddha.6596@gmail.com>
---
 drivers/staging/lustre/lustre/include/lustre_mds.h | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_mds.h b/drivers/staging/lustre/lustre/include/lustre_mds.h
index a16eb8b..95d27dd 100644
--- a/drivers/staging/lustre/lustre/include/lustre_mds.h
+++ b/drivers/staging/lustre/lustre/include/lustre_mds.h
@@ -62,12 +62,6 @@ struct mds_group_info {
 #define MDD_OBD_NAME     "mdd_obd"
 #define MDD_OBD_UUID     "mdd_obd_uuid"
 
-static inline int md_should_create(__u64 flags)
-{
-       return !(flags & MDS_OPEN_DELAY_CREATE ||
-	       !(flags & FMODE_WRITE));
-}
-
 /* these are local flags, used only on the client, private */
 #define M_CHECK_STALE	   0200000000
 
-- 
2.1.4
