From: NeilBrown <neilb@suse.com>
Date: Tue, 20 Feb 2018 13:23:38 +1100
Subject: [lustre-devel] [PATCH 16/21] staging: lustre: fid: convert
 lcs_mutex to a spinlock
In-Reply-To: <151909308778.25814.9912662268627044409.stgit@noble>
References: <151909308778.25814.9912662268627044409.stgit@noble>
Message-ID: <151909341810.25814.8461248924883891726.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

There is only one place where this lock is held
while the task might sleep - in
  ldebugfs_fid_space_seq_write()
while ldebugfs_fid_write_common() is called.

This call can easily be taken out of the locked region
by asking it to parse the user data into a local variable,
and then copying that variable into ->lcs_space while
holding the lock.

Note that ldebugfs_gid_write_common returns >0 on
success, so use that to gate updating ->lcs_space.

So make that change, and convert lcs_mutex to a spinlock
named lcs_lock.  spinlocks are slightly cheaper than mutexes
and using one makes is clear that the lock is only held for
a short time.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/fid/fid_request.c    |   24 ++++++++---------
 drivers/staging/lustre/lustre/fid/lproc_fid.c      |   29 +++++++++++---------
 drivers/staging/lustre/lustre/include/lustre_fid.h |    2 +
 3 files changed, 29 insertions(+), 26 deletions(-)

diff --git a/drivers/staging/lustre/lustre/fid/fid_request.c b/drivers/staging/lustre/lustre/fid/fid_request.c
index 009c2367f74e..6b9d024bd27b 100644
--- a/drivers/staging/lustre/lustre/fid/fid_request.c
+++ b/drivers/staging/lustre/lustre/fid/fid_request.c
@@ -198,24 +198,24 @@ static int seq_fid_alloc_prep(struct lu_client_seq *seq,
 	if (seq->lcs_update) {
 		add_wait_queue(&seq->lcs_waitq, link);
 		set_current_state(TASK_UNINTERRUPTIBLE);
-		mutex_unlock(&seq->lcs_mutex);
+		spin_unlock(&seq->lcs_lock);
 
 		schedule();
 
-		mutex_lock(&seq->lcs_mutex);
+		spin_lock(&seq->lcs_lock);
 		remove_wait_queue(&seq->lcs_waitq, link);
 		set_current_state(TASK_RUNNING);
 		return -EAGAIN;
 	}
 	++seq->lcs_update;
-	mutex_unlock(&seq->lcs_mutex);
+	spin_unlock(&seq->lcs_lock);
 	return 0;
 }
 
 static void seq_fid_alloc_fini(struct lu_client_seq *seq)
 {
 	LASSERT(seq->lcs_update == 1);
-	mutex_lock(&seq->lcs_mutex);
+	spin_lock(&seq->lcs_lock);
 	--seq->lcs_update;
 	wake_up(&seq->lcs_waitq);
 }
@@ -231,7 +231,7 @@ int seq_client_alloc_fid(const struct lu_env *env,
 	LASSERT(fid);
 
 	init_waitqueue_entry(&link, current);
-	mutex_lock(&seq->lcs_mutex);
+	spin_lock(&seq->lcs_lock);
 
 	if (OBD_FAIL_CHECK(OBD_FAIL_SEQ_EXHAUST))
 		seq->lcs_fid.f_oid = seq->lcs_width;
@@ -256,7 +256,7 @@ int seq_client_alloc_fid(const struct lu_env *env,
 			CERROR("%s: Can't allocate new sequence, rc %d\n",
 			       seq->lcs_name, rc);
 			seq_fid_alloc_fini(seq);
-			mutex_unlock(&seq->lcs_mutex);
+			spin_unlock(&seq->lcs_lock);
 			return rc;
 		}
 
@@ -278,7 +278,7 @@ int seq_client_alloc_fid(const struct lu_env *env,
 	}
 
 	*fid = seq->lcs_fid;
-	mutex_unlock(&seq->lcs_mutex);
+	spin_unlock(&seq->lcs_lock);
 
 	CDEBUG(D_INFO,
 	       "%s: Allocated FID " DFID "\n", seq->lcs_name,  PFID(fid));
@@ -296,16 +296,16 @@ void seq_client_flush(struct lu_client_seq *seq)
 
 	LASSERT(seq);
 	init_waitqueue_entry(&link, current);
-	mutex_lock(&seq->lcs_mutex);
+	spin_lock(&seq->lcs_lock);
 
 	while (seq->lcs_update) {
 		add_wait_queue(&seq->lcs_waitq, &link);
 		set_current_state(TASK_UNINTERRUPTIBLE);
-		mutex_unlock(&seq->lcs_mutex);
+		spin_unlock(&seq->lcs_lock);
 
 		schedule();
 
-		mutex_lock(&seq->lcs_mutex);
+		spin_lock(&seq->lcs_lock);
 		remove_wait_queue(&seq->lcs_waitq, &link);
 		set_current_state(TASK_RUNNING);
 	}
@@ -319,7 +319,7 @@ void seq_client_flush(struct lu_client_seq *seq)
 	seq->lcs_space.lsr_index = -1;
 
 	lu_seq_range_init(&seq->lcs_space);
-	mutex_unlock(&seq->lcs_mutex);
+	spin_unlock(&seq->lcs_lock);
 }
 EXPORT_SYMBOL(seq_client_flush);
 
@@ -382,7 +382,7 @@ static int seq_client_init(struct lu_client_seq *seq,
 
 	seq->lcs_type = type;
 
-	mutex_init(&seq->lcs_mutex);
+	spin_lock_init(&seq->lcs_lock);
 	if (type == LUSTRE_SEQ_METADATA)
 		seq->lcs_width = LUSTRE_METADATA_SEQ_MAX_WIDTH;
 	else
diff --git a/drivers/staging/lustre/lustre/fid/lproc_fid.c b/drivers/staging/lustre/lustre/fid/lproc_fid.c
index 083419f77697..e05487662afd 100644
--- a/drivers/staging/lustre/lustre/fid/lproc_fid.c
+++ b/drivers/staging/lustre/lustre/fid/lproc_fid.c
@@ -98,20 +98,23 @@ ldebugfs_fid_space_seq_write(struct file *file,
 			     size_t count, loff_t *off)
 {
 	struct lu_client_seq *seq;
+	struct lu_seq_range range;
 	int rc;
 
 	seq = ((struct seq_file *)file->private_data)->private;
 
-	mutex_lock(&seq->lcs_mutex);
-	rc = ldebugfs_fid_write_common(buffer, count, &seq->lcs_space);
+	rc = ldebugfs_fid_write_common(buffer, count, &range);
+
+	spin_lock(&seq->lcs_lock);
+	if (rc > 0)
+		seq->lcs_space = range;
+	spin_unlock(&seq->lcs_lock);
 
 	if (rc == 0) {
 		CDEBUG(D_INFO, "%s: Space: " DRANGE "\n",
-		       seq->lcs_name, PRANGE(&seq->lcs_space));
+		       seq->lcs_name, PRANGE(&range));
 	}
 
-	mutex_unlock(&seq->lcs_mutex);
-
 	return count;
 }
 
@@ -120,9 +123,9 @@ ldebugfs_fid_space_seq_show(struct seq_file *m, void *unused)
 {
 	struct lu_client_seq *seq = (struct lu_client_seq *)m->private;
 
-	mutex_lock(&seq->lcs_mutex);
+	spin_lock(&seq->lcs_lock);
 	seq_printf(m, "[%#llx - %#llx]:%x:%s\n", PRANGE(&seq->lcs_space));
-	mutex_unlock(&seq->lcs_mutex);
+	spin_unlock(&seq->lcs_lock);
 
 	return 0;
 }
@@ -142,7 +145,7 @@ ldebugfs_fid_width_seq_write(struct file *file,
 	if (rc)
 		return rc;
 
-	mutex_lock(&seq->lcs_mutex);
+	spin_lock(&seq->lcs_lock);
 	if (seq->lcs_type == LUSTRE_SEQ_DATA)
 		max = LUSTRE_DATA_SEQ_MAX_WIDTH;
 	else
@@ -155,7 +158,7 @@ ldebugfs_fid_width_seq_write(struct file *file,
 		       seq->lcs_width);
 	}
 
-	mutex_unlock(&seq->lcs_mutex);
+	spin_unlock(&seq->lcs_lock);
 
 	return count;
 }
@@ -165,9 +168,9 @@ ldebugfs_fid_width_seq_show(struct seq_file *m, void *unused)
 {
 	struct lu_client_seq *seq = (struct lu_client_seq *)m->private;
 
-	mutex_lock(&seq->lcs_mutex);
+	spin_lock(&seq->lcs_lock);
 	seq_printf(m, "%llu\n", seq->lcs_width);
-	mutex_unlock(&seq->lcs_mutex);
+	spin_unlock(&seq->lcs_lock);
 
 	return 0;
 }
@@ -177,9 +180,9 @@ ldebugfs_fid_fid_seq_show(struct seq_file *m, void *unused)
 {
 	struct lu_client_seq *seq = (struct lu_client_seq *)m->private;
 
-	mutex_lock(&seq->lcs_mutex);
+	spin_lock(&seq->lcs_lock);
 	seq_printf(m, DFID "\n", PFID(&seq->lcs_fid));
-	mutex_unlock(&seq->lcs_mutex);
+	spin_unlock(&seq->lcs_lock);
 
 	return 0;
 }
diff --git a/drivers/staging/lustre/lustre/include/lustre_fid.h b/drivers/staging/lustre/lustre/include/lustre_fid.h
index d19c7a27ee48..094ad282de2c 100644
--- a/drivers/staging/lustre/lustre/include/lustre_fid.h
+++ b/drivers/staging/lustre/lustre/include/lustre_fid.h
@@ -324,7 +324,7 @@ enum lu_mgr_type {
 struct lu_client_seq {
 	/* Sequence-controller export. */
 	struct obd_export      *lcs_exp;
-	struct mutex		lcs_mutex;
+	spinlock_t		lcs_lock;
 
 	/*
 	 * Range of allowed for allocation sequences. When using lu_client_seq on
