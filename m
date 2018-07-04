From: NeilBrown <neilb@suse.com>
Date: Wed, 04 Jul 2018 14:43:50 +1000
Subject: [lustre-devel] [PATCH 08/11] lustre: protect updates to ll_flags.
In-Reply-To: <153067941050.30111.13691201276059352926.stgit@noble>
References: <153067941050.30111.13691201276059352926.stgit@noble>
Message-ID: <153067943083.30111.5879041126521058346.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

While individual flags in sbi->ll_flags are rarely
updates after the superblocks in initialised, it
is possible for these updates to race.
This could cause an update to be lost.

So protect all updates with a spinlock.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/llite/llite_lib.c   |    4 ++++
 drivers/staging/lustre/lustre/llite/lproc_llite.c |    6 ++++++
 drivers/staging/lustre/lustre/llite/xattr.c       |    4 ++++
 3 files changed, 14 insertions(+)

diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 7a414e2238a3..64cd69cb493d 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -2549,7 +2549,9 @@ void ll_compute_rootsquash_state(struct ll_sb_info *sbi)
 	/* Update norootsquash flag */
 	down_write(&squash->rsi_sem);
 	if (list_empty(&squash->rsi_nosquash_nids)) {
+		spin_lock(&sbi->ll_lock);
 		sbi->ll_flags &= ~LL_SBI_NOROOTSQUASH;
+		spin_unlock(&sbi->ll_lock);
 	} else {
 		/*
 		 * Do not apply root squash as soon as one of our NIDs is
@@ -2566,10 +2568,12 @@ void ll_compute_rootsquash_state(struct ll_sb_info *sbi)
 				break;
 			}
 		}
+		spin_lock(&sbi->ll_lock);
 		if (matched)
 			sbi->ll_flags |= LL_SBI_NOROOTSQUASH;
 		else
 			sbi->ll_flags &= ~LL_SBI_NOROOTSQUASH;
+		spin_unlock(&sbi->ll_lock);
 	}
 	up_write(&squash->rsi_sem);
 }
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 9dcbe648777e..617aabb1b59a 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -514,10 +514,12 @@ static ssize_t checksum_pages_store(struct kobject *kobj,
 	rc = kstrtoul(buffer, 10, &val);
 	if (rc)
 		return rc;
+	spin_lock(&sbi->ll_lock);
 	if (val)
 		sbi->ll_flags |= LL_SBI_CHECKSUM;
 	else
 		sbi->ll_flags &= ~LL_SBI_CHECKSUM;
+	spin_unlock(&sbi->ll_lock);
 
 	rc = obd_set_info_async(NULL, sbi->ll_dt_exp, sizeof(KEY_CHECKSUM),
 				KEY_CHECKSUM, sizeof(val), &val, NULL);
@@ -669,10 +671,12 @@ static ssize_t statahead_agl_store(struct kobject *kobj,
 	if (rc)
 		return rc;
 
+	spin_lock(&sbi->ll_lock);
 	if (val)
 		sbi->ll_flags |= LL_SBI_AGL_ENABLED;
 	else
 		sbi->ll_flags &= ~LL_SBI_AGL_ENABLED;
+	spin_unlock(&sbi->ll_lock);
 
 	return count;
 }
@@ -719,10 +723,12 @@ static ssize_t lazystatfs_store(struct kobject *kobj,
 	if (rc)
 		return rc;
 
+	spin_lock(&sbi->ll_lock);
 	if (val)
 		sbi->ll_flags |= LL_SBI_LAZYSTATFS;
 	else
 		sbi->ll_flags &= ~LL_SBI_LAZYSTATFS;
+	spin_unlock(&sbi->ll_lock);
 
 	return count;
 }
diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index 7fa0a419c094..5e27c85f104f 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -150,7 +150,9 @@ static int ll_xattr_set_common(const struct xattr_handler *handler,
 	if (rc) {
 		if (rc == -EOPNOTSUPP && handler->flags == XATTR_USER_T) {
 			LCONSOLE_INFO("Disabling user_xattr feature because it is not supported on the server\n");
+			spin_lock(&sbi->ll_lock);
 			sbi->ll_flags &= ~LL_SBI_USER_XATTR;
+			spin_unlock(&sbi->ll_lock);
 		}
 		return rc;
 	}
@@ -387,7 +389,9 @@ int ll_xattr_list(struct inode *inode, const char *name, int type, void *buffer,
 		LCONSOLE_INFO(
 			"%s: disabling user_xattr feature because it is not supported on the server: rc = %d\n",
 			ll_get_fsname(inode->i_sb, NULL, 0), rc);
+		spin_lock(&sbi->ll_lock);
 		sbi->ll_flags &= ~LL_SBI_USER_XATTR;
+		spin_unlock(&sbi->ll_lock);
 	}
 out:
 	ptlrpc_req_finished(req);
