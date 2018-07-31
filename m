From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Jul 2018 22:26:19 -0400
Subject: [lustre-devel] [PATCH 27/31] lustre: llite: handle client racy case
 during create
In-Reply-To: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
References: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1533003983-29311-28-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bruno Faccini <bruno.faccini@intel.com>

Some very infrequent situations exists on client side
able to cause a race during create when concurrent access
by fid occurs. The result of the race can allow a d_alias
to be already present when it was not expected when original
code/LBUG has been written.

One of the identified scenario is when a concurrent access of
inode thru the .lustre/fid/<[FID]> method occurs.

Final fix is to remove inaccurate
LASSERT(hlist_empty(&inode->i_dentry)); in ll_create_node().

Signed-off-by: Bruno Faccini <bruno.faccini@intel.com>
WC-id: https://jira.whamcloud.com/browse/LU-8907
Reviewed-on: https://review.whamcloud.com/25296
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd_support.h | 1 +
 drivers/staging/lustre/lustre/llite/namei.c         | 3 ++-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index 80b9935..1832193 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -441,6 +441,7 @@
 #define OBD_FAIL_MAKE_LOVEA_HOLE		    0x1406
 #define OBD_FAIL_LLITE_LOST_LAYOUT		    0x1407
 #define OBD_FAIL_GETATTR_DELAY			    0x1409
+#define OBD_FAIL_LLITE_CREATE_NODE_PAUSE	    0x140c
 
 #define OBD_FAIL_FID_INDIR	0x1501
 #define OBD_FAIL_FID_INLMA	0x1502
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index e541f78..da5854e 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -802,7 +802,8 @@ static struct inode *ll_create_node(struct inode *dir, struct lookup_intent *it)
 		goto out;
 	}
 
-	LASSERT(hlist_empty(&inode->i_dentry));
+	/* Pause to allow for a race with concurrent access by fid */
+	OBD_FAIL_TIMEOUT(OBD_FAIL_LLITE_CREATE_NODE_PAUSE, cfs_fail_val);
 
 	/* We asked for a lock on the directory, but were granted a
 	 * lock on the inode.  Since we finally have an inode pointer,
-- 
1.8.3.1
