From: James Simmons <jsimmons@infradead.org>
Date: Mon, 20 May 2019 08:50:55 -0400
Subject: [lustre-devel] [PATCH v2 13/29] lustre: convert rsi_sem to a
 spinlock.
In-Reply-To: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
References: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1558356671-29599-14-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

This lock is never held over code that sleeps, and is
only ever held for short periods of time.
So a simple spinlock is best.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/lustre/include/obd_class.h       | 3 +--
 fs/lustre/llite/llite_lib.c         | 6 +++---
 fs/lustre/llite/lproc_llite.c       | 4 ++--
 fs/lustre/obdclass/lprocfs_status.c | 8 ++++----
 4 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index a3394b2..f78694c 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -1688,12 +1688,11 @@ static inline void class_uuid_unparse(class_uuid_t uu, struct obd_uuid *out)
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
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index ab7c84a..7d9a76e 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -130,7 +130,7 @@ static struct ll_sb_info *ll_init_sbi(void)
 	sbi->ll_squash.rsi_uid = 0;
 	sbi->ll_squash.rsi_gid = 0;
 	INIT_LIST_HEAD(&sbi->ll_squash.rsi_nosquash_nids);
-	init_rwsem(&sbi->ll_squash.rsi_sem);
+	spin_lock_init(&sbi->ll_squash.rsi_lock);
 
 	return sbi;
 }
@@ -2577,7 +2577,7 @@ void ll_compute_rootsquash_state(struct ll_sb_info *sbi)
 	int i;
 
 	/* Update norootsquash flag */
-	down_write(&squash->rsi_sem);
+	spin_lock(&squash->rsi_lock);
 	if (list_empty(&squash->rsi_nosquash_nids)) {
 		spin_lock(&sbi->ll_lock);
 		sbi->ll_flags &= ~LL_SBI_NOROOTSQUASH;
@@ -2605,7 +2605,7 @@ void ll_compute_rootsquash_state(struct ll_sb_info *sbi)
 			sbi->ll_flags &= ~LL_SBI_NOROOTSQUASH;
 		spin_unlock(&sbi->ll_lock);
 	}
-	up_write(&squash->rsi_sem);
+	spin_unlock(&squash->rsi_lock);
 }
 
 /**
diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index 91b0a50..8f89f3b 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -1152,7 +1152,7 @@ static int ll_nosquash_nids_seq_show(struct seq_file *m, void *v)
 	struct root_squash_info *squash = &sbi->ll_squash;
 	int len;
 
-	down_read(&squash->rsi_sem);
+	spin_lock(&squash->rsi_lock);
 	if (!list_empty(&squash->rsi_nosquash_nids)) {
 		len = cfs_print_nidlist(m->buf + m->count, m->size - m->count,
 					&squash->rsi_nosquash_nids);
@@ -1161,7 +1161,7 @@ static int ll_nosquash_nids_seq_show(struct seq_file *m, void *v)
 	} else {
 		seq_puts(m, "NONE\n");
 	}
-	up_read(&squash->rsi_sem);
+	spin_unlock(&squash->rsi_lock);
 
 	return 0;
 }
diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index 71bf409..29c6b5d 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -1751,10 +1751,10 @@ int lprocfs_wr_nosquash_nids(const char __user *buffer, unsigned long count,
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
@@ -1771,11 +1771,11 @@ int lprocfs_wr_nosquash_nids(const char __user *buffer, unsigned long count,
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
 
-- 
1.8.3.1
