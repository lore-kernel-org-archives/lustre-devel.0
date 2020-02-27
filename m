From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:35 -0500
Subject: [lustre-devel] [PATCH 527/622] lustre: pcc: Init saved dataset
 flags properly
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-528-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Qian Yingjin <qian@ddn.com>

When init a new inode, the saved flags is set wrongly with
PCC_DATASET_NONE which means that the file is known in NONE
of PCC dataset.
This patch corrects it with PCC_DATASET_INVALID.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13030
Lustre-commit: e467a421c7aa ("LU-13030 pcc: Init saved dataset flags properly")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/36923
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_lib.c |  2 +-
 fs/lustre/llite/pcc.c       | 13 +++++--------
 2 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index c2baf6a..384b55b 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -983,7 +983,7 @@ void ll_lli_init(struct ll_inode_info *lli)
 		mutex_init(&lli->lli_pcc_lock);
 		lli->lli_pcc_state = PCC_STATE_FL_NONE;
 		lli->lli_pcc_inode = NULL;
-		lli->lli_pcc_dsflags = PCC_DATASET_NONE;
+		lli->lli_pcc_dsflags = PCC_DATASET_INVALID;
 		lli->lli_pcc_generation = 0;
 		mutex_init(&lli->lli_group_mutex);
 		lli->lli_group_users = 0;
diff --git a/fs/lustre/llite/pcc.c b/fs/lustre/llite/pcc.c
index a0e31c8..3a2c8f2 100644
--- a/fs/lustre/llite/pcc.c
+++ b/fs/lustre/llite/pcc.c
@@ -1346,21 +1346,18 @@ static int pcc_try_datasets_attach(struct inode *inode, enum pcc_io_type iot,
 		 * from icache later.
 		 * Set the saved dataset flags with PCC_DATASET_NONE. Then this
 		 * file will skip from the candidates to try auto attach until
-		 * the file is attached ninto PCC again.
+		 * the file is attached into PCC again.
 		 *
 		 * If the file was never attached into PCC, or once attached but
 		 * its inode was evicted from icache (lli_pcc_generation == 0),
+		 * or the corresponding dataset was removed from the client,
 		 * set the saved dataset flags with PCC_DATASET_NONE.
 		 *
-		 * If the file was once attached into PCC but the corresponding
-		 * dataset was removed from the client, set the saved dataset
-		 * flags with PCC_DATASET_NONE.
-		 *
 		 * TODO: If the file was once attached into PCC but not try to
 		 * auto attach due to the change of the configuration parameters
 		 * for this dataset (i.e. change from auto attach enabled to
 		 * auto attach disabled for this dataset), update the saved
-		 * dataset flags witha the found one.
+		 * dataset flags with the found one.
 		 */
 		lli->lli_pcc_dsflags = PCC_DATASET_NONE;
 	}
@@ -1437,7 +1434,7 @@ static inline bool pcc_may_auto_attach(struct inode *inode,
 		return false;
 
 	/*
-	 * lli_pcc_generation = 0 means that the file was never attached into
+	 * lli_pcc_generation == 0 means that the file was never attached into
 	 * PCC, or may be once attached into PCC but detached as the inode is
 	 * evicted from icache (i.e. "echo 3 > /proc/sys/vm/drop_caches" or
 	 * icache shrinking due to the memory pressure), which will cause the
@@ -1446,7 +1443,7 @@ static inline bool pcc_may_auto_attach(struct inode *inode,
 	 */
 	/* lli_pcc_generation == 0, or the PCC setting was changed,
 	 * or there is no PCC setup on the client and the try will return
-	 * immediately in pcc_try_auto_attch().
+	 * immediately in pcc_try_auto_attach().
 	 */
 	if (super->pccs_generation != lli->lli_pcc_generation)
 		return true;
-- 
1.8.3.1
