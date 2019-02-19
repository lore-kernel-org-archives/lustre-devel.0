From: NeilBrown <neilb@suse.com>
Date: Tue, 19 Feb 2019 11:09:05 +1100
Subject: [lustre-devel] [PATCH 20/37] lustre: convert rsi_sem to a spinlock.
In-Reply-To: <155053473693.24125.6976971762921761309.stgit@noble.brown>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
Message-ID: <155053494585.24125.10207641299012244855.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This lock is never held over code that sleeps, and is
only ever held for short periods of time.
So a simple spinlock is best.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/obd_class.h  |    3 +--
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    6 +++---
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |    4 ++--
 .../lustre/lustre/obdclass/lprocfs_status.c        |    8 ++++----
 4 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 7c2e248a8110..dd480501d7df 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -1688,12 +1688,11 @@ void statfs_pack(struct obd_statfs *osfs, struct kstatfs *sfs);
 void statfs_unpack(struct kstatfs *sfs, struct obd_statfs *osfs);
 
 /* root squash info */
-struct rw_semaphore;
 struct root_squash_info {
 	uid_t			rsi_uid;
 	gid_t			rsi_gid;
 	struct list_head	rsi_nosquash_nids;
-	struct rw_semaphore	rsi_sem;
+	spinlock_t		rsi_lock;	/* protects rsi_nosquash_nids */
 };
 
 /* linux-module.c */
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index e2417cd5aaed..d97abbfddccf 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -130,7 +130,7 @@ static struct ll_sb_info *ll_init_sbi(void)
 	sbi->ll_squash.rsi_uid = 0;
 	sbi->ll_squash.rsi_gid = 0;
 	INIT_LIST_HEAD(&sbi->ll_squash.rsi_nosquash_nids);
-	init_rwsem(&sbi->ll_squash.rsi_sem);
+	spin_lock_init(&sbi->ll_squash.rsi_lock);
 
 	return sbi;
 }
@@ -2578,7 +2578,7 @@ void ll_compute_rootsquash_state(struct ll_sb_info *sbi)
 	int i;
 
 	/* Update norootsquash flag */
-	down_write(&squash->rsi_sem);
+	spin_lock(&squash->rsi_lock);
 	if (list_empty(&squash->rsi_nosquash_nids)) {
 		spin_lock(&sbi->ll_lock);
 		sbi->ll_flags &= ~LL_SBI_NOROOTSQUASH;
@@ -2606,7 +2606,7 @@ void ll_compute_rootsquash_state(struct ll_sb_info *sbi)
 			sbi->ll_flags &= ~LL_SBI_NOROOTSQUASH;
 		spin_unlock(&sbi->ll_lock);
 	}
-	up_write(&squash->rsi_sem);
+	spin_unlock(&squash->rsi_lock);
 }
 
 /**
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 78ec0fa65c58..db2fbf1f3a50 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -1133,7 +1133,7 @@ static int ll_nosquash_nids_seq_show(struct seq_file *m, void *v)
 	struct root_squash_info *squash = &sbi->ll_squash;
 	int len;
 
-	down_read(&squash->rsi_sem);
+	spin_lock(&squash->rsi_lock);
 	if (!list_empty(&squash->rsi_nosquash_nids)) {
 		len = cfs_print_nidlist(m->buf + m->count, m->size - m->count,
 					&squash->rsi_nosquash_nids);
@@ -1142,7 +1142,7 @@ static int ll_nosquash_nids_seq_show(struct seq_file *m, void *v)
 	} else {
 		seq_puts(m, "NONE\n");
 	}
-	up_read(&squash->rsi_sem);
+	spin_unlock(&squash->rsi_lock);
 
 	return 0;
 }
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index 27d73c95403d..aed33068ff3c 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -1720,10 +1720,10 @@ int lprocfs_wr_nosquash_nids(const char __user *buffer, unsigned long count,
 	if ((len == 4 && !strncmp(kernbuf, "NONE", len)) ||
 	    (len == 5 && !strncmp(kernbuf, "clear", len))) {
 		/* empty string is special case */
-		down_write(&squash->rsi_sem);
+		spin_lock(&squash->rsi_lock);
 		if (!list_empty(&squash->rsi_nosquash_nids))
 			cfs_free_nidlist(&squash->rsi_nosquash_nids);
-		up_write(&squash->rsi_sem);
+		spin_unlock(&squash->rsi_lock);
 		LCONSOLE_INFO("%s: nosquash_nids is cleared\n", name);
 		kfree(kernbuf);
 		return count;
@@ -1740,11 +1740,11 @@ int lprocfs_wr_nosquash_nids(const char __user *buffer, unsigned long count,
 	kfree(kernbuf);
 	kernbuf = NULL;
 
-	down_write(&squash->rsi_sem);
+	spin_lock(&squash->rsi_lock);
 	if (!list_empty(&squash->rsi_nosquash_nids))
 		cfs_free_nidlist(&squash->rsi_nosquash_nids);
 	list_splice(&tmp, &squash->rsi_nosquash_nids);
-	up_write(&squash->rsi_sem);
+	spin_unlock(&squash->rsi_lock);
 
 	return count;
 
