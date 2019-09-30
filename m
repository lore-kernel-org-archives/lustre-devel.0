From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:35 -0400
Subject: [lustre-devel] [PATCH 136/151] lustre: uapi: replace FMODE_{READ,
 WRITE} with MDS_* equivs
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-137-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sebastien Buisson <sbuisson@ddn.com>

In UAPI header file lustre/lustre_user.h, replace direct
use of FMODE_READ and FMODE_WRITE with MDS_* equivalents.
That will avoid name clashes with the kernel symbols, and avoid
problems if their values ever change.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10483
Lustre-commit: 5185ba6381ac ("LU-10483 lustre: replace FMODE_{READ,WRITE} with MDS_* equivs")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/30824
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_lib.c                 | 8 ++++++--
 fs/lustre/mdc/mdc_locks.c               | 4 ++--
 fs/lustre/obdclass/genops.c             | 2 +-
 include/uapi/linux/lustre/lustre_user.h | 3 +++
 4 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/fs/lustre/mdc/mdc_lib.c b/fs/lustre/mdc/mdc_lib.c
index 1031a01..ba4eb3f 100644
--- a/fs/lustre/mdc/mdc_lib.c
+++ b/fs/lustre/mdc/mdc_lib.c
@@ -196,8 +196,12 @@ void mdc_create_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 
 static inline u64 mds_pack_open_flags(u64 flags)
 {
-	u64 cr_flags = (flags & (FMODE_READ | FMODE_WRITE |
-				   MDS_OPEN_FL_INTERNAL));
+	u64 cr_flags = (flags & MDS_OPEN_FL_INTERNAL);
+
+	if (flags & FMODE_READ)
+		cr_flags |= MDS_FMODE_READ;
+	if (flags & FMODE_WRITE)
+		cr_flags |= MDS_FMODE_WRITE;
 	if (flags & O_CREAT)
 		cr_flags |= MDS_OPEN_CREAT;
 	if (flags & O_EXCL)
diff --git a/fs/lustre/mdc/mdc_locks.c b/fs/lustre/mdc/mdc_locks.c
index 0787ba3..123f0f0 100644
--- a/fs/lustre/mdc/mdc_locks.c
+++ b/fs/lustre/mdc/mdc_locks.c
@@ -263,12 +263,12 @@ static int mdc_save_lovea(struct ptlrpc_request *req,
 	/* If inode is known, cancel conflicting OPEN locks. */
 	if (fid_is_sane(&op_data->op_fid2)) {
 		if (it->it_flags & MDS_OPEN_LEASE) { /* try to get lease */
-			if (it->it_flags & FMODE_WRITE)
+			if (it->it_flags & MDS_FMODE_WRITE)
 				mode = LCK_EX;
 			else
 				mode = LCK_PR;
 		} else {
-			if (it->it_flags & (FMODE_WRITE | MDS_OPEN_TRUNC))
+			if (it->it_flags & (MDS_FMODE_WRITE | MDS_OPEN_TRUNC))
 				mode = LCK_CW;
 			else if (it->it_flags & __FMODE_EXEC)
 				mode = LCK_PR;
diff --git a/fs/lustre/obdclass/genops.c b/fs/lustre/obdclass/genops.c
index f809d00c..5c9b3c4 100644
--- a/fs/lustre/obdclass/genops.c
+++ b/fs/lustre/obdclass/genops.c
@@ -1540,7 +1540,7 @@ static inline bool obd_skip_mod_rpc_slot(const struct lookup_intent *it)
 	if (it &&
 	    (it->it_op == IT_GETATTR || it->it_op == IT_LOOKUP ||
 	     it->it_op == IT_READDIR ||
-	     (it->it_op == IT_LAYOUT && !(it->it_flags & FMODE_WRITE))))
+	     (it->it_op == IT_LAYOUT && !(it->it_flags & MDS_FMODE_WRITE))))
 		return true;
 	return false;
 }
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 29be243..2c4f837 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -866,6 +866,9 @@ enum la_valid {
 	LA_REMOTE_ATTR_SET = (LA_UID | LA_GID | LA_PROJID | LA_LAYOUT_VERSION)
 };
 
+#define MDS_FMODE_READ		00000001
+#define MDS_FMODE_WRITE		00000002
+
 #define MDS_FMODE_CLOSED	00000000
 #define MDS_FMODE_EXEC		00000004
 /*	MDS_FMODE_EPOCH		01000000 obsolete since 2.8.0 */
-- 
1.8.3.1
