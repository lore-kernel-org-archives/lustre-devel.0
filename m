From: James Simmons <jsimmons@infradead.org>
Date: Thu,  4 Aug 2016 12:52:39 -0400
Subject: [lustre-devel] [PATCH 03/32] staging: lustre: llite: fix
	inconsistencies of root squash feature
In-Reply-To: <1470329587-18768-1-git-send-email-jsimmons@infradead.org>
References: <1470329587-18768-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1470329587-18768-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Gregoire Pichon <gregoire.pichon@bull.net>, James Simmons <jsimmons@infradead.org>

From: Gregoire Pichon <gregoire.pichon@bull.net>

Root squash exhibits inconsistent behaviour on a client when
enabled. If a file is not cached on the client, then root will get
a permission denied error when accessing the file. When
the file has recently been accessed by a regular user and is
still in cache, root will be able to access the file without error
because the permission check is only done by the client that
isn't aware of root squash.

While the only real security benefit from root squash is to deny
clients access to files owned by root itself, it also makes sense
to treat file access on the client in a consistent manner
regardless of whether the file is in cache or not.

This patch adds root squash settings to llite so that client is able
to apply root squashing when it is relevant.

Configuration of MDT root squash settings will automatically be
applied to llite config log as well.

Update cfs_str2num_check() routine by removing any modification
of the specified string parameter. Since string can come from ls_str
field of a lstr structure, this avoids inconsistent ls_len field.

Signed-off-by: Gregoire Pichon <gregoire.pichon@bull.net>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-1778
Reviewed-on: http://review.whamcloud.com/5700
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/libcfs_string.c |    2 -
 .../staging/lustre/lustre/include/lprocfs_status.h |    6 +
 drivers/staging/lustre/lustre/include/obd_class.h  |    9 ++
 drivers/staging/lustre/lustre/llite/file.c         |   44 ++++++
 .../staging/lustre/lustre/llite/llite_internal.h   |    6 +
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   47 +++++++
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |   68 ++++++++++
 .../lustre/lustre/obdclass/lprocfs_status.c        |  140 ++++++++++++++++++++
 8 files changed, 320 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_string.c b/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
index fc697cd..56a614d 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
@@ -229,8 +229,6 @@ cfs_str2num_check(char *str, int nob, unsigned *num,
 	char *endp, cache;
 	int rc;
 
-	str = cfs_trimwhite(str);
-
 	/**
 	 * kstrouint can only handle strings composed
 	 * of only numbers. We need to scan the string
diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index d68e60e..ff35e63 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -681,6 +681,12 @@ static struct lustre_attr lustre_attr_##name = __ATTR(name, mode, show, store)
 
 extern const struct sysfs_ops lustre_sysfs_ops;
 
+struct root_squash_info;
+int lprocfs_wr_root_squash(const char *buffer, unsigned long count,
+			   struct root_squash_info *squash, char *name);
+int lprocfs_wr_nosquash_nids(const char *buffer, unsigned long count,
+			     struct root_squash_info *squash, char *name);
+
 /* all quota proc functions */
 int lprocfs_quota_rd_bunit(char *page, char **start,
 			   loff_t off, int count,
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index a288995..e86961c 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -1759,4 +1759,13 @@ extern spinlock_t obd_types_lock;
 /* prng.c */
 #define ll_generate_random_uuid(uuid_out) cfs_get_random_bytes(uuid_out, sizeof(class_uuid_t))
 
+/* root squash info */
+struct rw_semaphore;
+struct root_squash_info {
+	uid_t			rsi_uid;
+	gid_t			rsi_gid;
+	struct list_head	rsi_nosquash_nids;
+	struct rw_semaphore	rsi_sem;
+};
+
 #endif /* __LINUX_OBD_CLASS_H */
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 343f9b9..c34455b 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -41,6 +41,7 @@
 #include "../include/lustre_lite.h"
 #include <linux/pagemap.h>
 #include <linux/file.h>
+#include <linux/sched.h>
 #include <linux/mount.h>
 #include "llite_internal.h"
 #include "../include/lustre/ll_fiemap.h"
@@ -3289,6 +3290,12 @@ struct posix_acl *ll_get_acl(struct inode *inode, int type)
 
 int ll_inode_permission(struct inode *inode, int mask)
 {
+	struct ll_sb_info *sbi;
+	struct root_squash_info *squash;
+	const struct cred *old_cred = NULL;
+	struct cred *cred = NULL;
+	bool squash_id = false;
+	cfs_cap_t cap;
 	int rc = 0;
 
 	if (mask & MAY_NOT_BLOCK)
@@ -3308,9 +3315,46 @@ int ll_inode_permission(struct inode *inode, int mask)
 	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p), inode mode %x mask %o\n",
 	       PFID(ll_inode2fid(inode)), inode, inode->i_mode, mask);
 
+	/* squash fsuid/fsgid if needed */
+	sbi = ll_i2sbi(inode);
+	squash = &sbi->ll_squash;
+	if (unlikely(squash->rsi_uid &&
+		     uid_eq(current_fsuid(), GLOBAL_ROOT_UID) &&
+		     !(sbi->ll_flags & LL_SBI_NOROOTSQUASH))) {
+		squash_id = true;
+	}
+
+	if (squash_id) {
+		CDEBUG(D_OTHER, "squash creds (%d:%d)=>(%d:%d)\n",
+		       __kuid_val(current_fsuid()), __kgid_val(current_fsgid()),
+		       squash->rsi_uid, squash->rsi_gid);
+
+		/*
+		 * update current process's credentials
+		 * and FS capability
+		 */
+		cred = prepare_creds();
+		if (!cred)
+			return -ENOMEM;
+
+		cred->fsuid = make_kuid(&init_user_ns, squash->rsi_uid);
+		cred->fsgid = make_kgid(&init_user_ns, squash->rsi_gid);
+		for (cap = 0; cap < sizeof(cfs_cap_t) * 8; cap++) {
+			if ((1 << cap) & CFS_CAP_FS_MASK)
+				cap_lower(cred->cap_effective, cap);
+		}
+		old_cred = override_creds(cred);
+	}
+
 	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_INODE_PERM, 1);
 	rc = generic_permission(inode, mask);
 
+	/* restore current process's credentials and FS capability */
+	if (squash_id) {
+		revert_creds(old_cred);
+		put_cred(cred);
+	}
+
 	return rc;
 }
 
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index e101dd8..500b5ec 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -412,6 +412,7 @@ enum stats_track_type {
 #define LL_SBI_LAYOUT_LOCK    0x20000 /* layout lock support */
 #define LL_SBI_USER_FID2PATH  0x40000 /* allow fid2path by unprivileged users */
 #define LL_SBI_XATTR_CACHE    0x80000 /* support for xattr cache */
+#define LL_SBI_NOROOTSQUASH	0x100000 /* do not apply root squash */
 
 #define LL_SBI_FLAGS {	\
 	"nolck",	\
@@ -434,6 +435,7 @@ enum stats_track_type {
 	"layout",	\
 	"user_fid2path",\
 	"xattr",	\
+	"norootsquash",	\
 }
 
 struct ll_sb_info {
@@ -500,6 +502,9 @@ struct ll_sb_info {
 	dev_t			  ll_sdev_orig; /* save s_dev before assign for
 						 * clustered nfs
 						 */
+	/* root squash */
+	struct root_squash_info	  ll_squash;
+
 	__kernel_fsid_t		  ll_fsid;
 	struct kobject		 ll_kobj; /* sysfs object */
 	struct super_block	*ll_sb; /* struct super_block (for sysfs code)*/
@@ -798,6 +803,7 @@ struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 void ll_finish_md_op_data(struct md_op_data *op_data);
 int ll_get_obd_name(struct inode *inode, unsigned int cmd, unsigned long arg);
 char *ll_get_fsname(struct super_block *sb, char *buf, int buflen);
+void ll_compute_rootsquash_state(struct ll_sb_info *sbi);
 void ll_open_cleanup(struct super_block *sb, struct ptlrpc_request *open_req);
 
 /* llite/llite_nfs.c */
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index a3b4c97..0a28925 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -119,6 +119,12 @@ static struct ll_sb_info *ll_init_sbi(struct super_block *sb)
 	atomic_set(&sbi->ll_agl_total, 0);
 	sbi->ll_flags |= LL_SBI_AGL_ENABLED;
 
+	/* root squash */
+	sbi->ll_squash.rsi_uid = 0;
+	sbi->ll_squash.rsi_gid = 0;
+	INIT_LIST_HEAD(&sbi->ll_squash.rsi_nosquash_nids);
+	init_rwsem(&sbi->ll_squash.rsi_sem);
+
 	sbi->ll_sb = sb;
 
 	return sbi;
@@ -129,6 +135,8 @@ static void ll_free_sbi(struct super_block *sb)
 	struct ll_sb_info *sbi = ll_s2sbi(sb);
 
 	if (sbi->ll_cache) {
+		if (!list_empty(&sbi->ll_squash.rsi_nosquash_nids))
+			cfs_free_nidlist(&sbi->ll_squash.rsi_nosquash_nids);
 		cl_cache_decref(sbi->ll_cache);
 		sbi->ll_cache = NULL;
 	}
@@ -2496,3 +2504,42 @@ void ll_dirty_page_discard_warn(struct page *page, int ioret)
 	if (buf)
 		free_page((unsigned long)buf);
 }
+
+/*
+ * Compute llite root squash state after a change of root squash
+ * configuration setting or add/remove of a lnet nid
+ */
+void ll_compute_rootsquash_state(struct ll_sb_info *sbi)
+{
+	struct root_squash_info *squash = &sbi->ll_squash;
+	lnet_process_id_t id;
+	bool matched;
+	int i;
+
+	/* Update norootsquash flag */
+	down_write(&squash->rsi_sem);
+	if (list_empty(&squash->rsi_nosquash_nids)) {
+		sbi->ll_flags &= ~LL_SBI_NOROOTSQUASH;
+	} else {
+		/*
+		 * Do not apply root squash as soon as one of our NIDs is
+		 * in the nosquash_nids list
+		 */
+		matched = false;
+		i = 0;
+
+		while (LNetGetId(i++, &id) != -ENOENT) {
+			if (LNET_NETTYP(LNET_NIDNET(id.nid)) == LOLND)
+				continue;
+			if (cfs_match_nid(id.nid, &squash->rsi_nosquash_nids)) {
+				matched = true;
+				break;
+			}
+		}
+		if (matched)
+			sbi->ll_flags |= LL_SBI_NOROOTSQUASH;
+		else
+			sbi->ll_flags &= ~LL_SBI_NOROOTSQUASH;
+	}
+	up_write(&squash->rsi_sem);
+}
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index e86bf3c..2f1f389 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -833,6 +833,71 @@ static ssize_t unstable_stats_show(struct kobject *kobj,
 }
 LUSTRE_RO_ATTR(unstable_stats);
 
+static ssize_t root_squash_show(struct kobject *kobj, struct attribute *attr,
+				char *buf)
+{
+	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
+					      ll_kobj);
+	struct root_squash_info *squash = &sbi->ll_squash;
+
+	return sprintf(buf, "%u:%u\n", squash->rsi_uid, squash->rsi_gid);
+}
+
+static ssize_t root_squash_store(struct kobject *kobj, struct attribute *attr,
+				 const char *buffer, size_t count)
+{
+	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
+					      ll_kobj);
+	struct root_squash_info *squash = &sbi->ll_squash;
+
+	return lprocfs_wr_root_squash(buffer, count, squash,
+				      ll_get_fsname(sbi->ll_sb, NULL, 0));
+}
+LUSTRE_RW_ATTR(root_squash);
+
+static int ll_nosquash_nids_seq_show(struct seq_file *m, void *v)
+{
+	struct super_block *sb = m->private;
+	struct ll_sb_info *sbi = ll_s2sbi(sb);
+	struct root_squash_info *squash = &sbi->ll_squash;
+	int len;
+
+	down_read(&squash->rsi_sem);
+	if (!list_empty(&squash->rsi_nosquash_nids)) {
+		len = cfs_print_nidlist(m->buf + m->count, m->size - m->count,
+					&squash->rsi_nosquash_nids);
+		m->count += len;
+		seq_puts(m, "\n");
+	} else {
+		seq_puts(m, "NONE\n");
+	}
+	up_read(&squash->rsi_sem);
+
+	return 0;
+}
+
+static ssize_t ll_nosquash_nids_seq_write(struct file *file,
+					  const char __user *buffer,
+					  size_t count, loff_t *off)
+{
+	struct seq_file *m = file->private_data;
+	struct super_block *sb = m->private;
+	struct ll_sb_info *sbi = ll_s2sbi(sb);
+	struct root_squash_info *squash = &sbi->ll_squash;
+	int rc;
+
+	rc = lprocfs_wr_nosquash_nids(buffer, count, squash,
+				      ll_get_fsname(sb, NULL, 0));
+	if (rc < 0)
+		return rc;
+
+	ll_compute_rootsquash_state(sbi);
+
+	return rc;
+}
+
+LPROC_SEQ_FOPS(ll_nosquash_nids);
+
 static struct lprocfs_vars lprocfs_llite_obd_vars[] = {
 	/* { "mntpt_path",   ll_rd_path,	     0, 0 }, */
 	{ "site",	  &ll_site_stats_fops,    NULL, 0 },
@@ -840,6 +905,8 @@ static struct lprocfs_vars lprocfs_llite_obd_vars[] = {
 	{ "max_cached_mb",    &ll_max_cached_mb_fops, NULL },
 	{ "statahead_stats",  &ll_statahead_stats_fops, NULL, 0 },
 	{ "sbi_flags",	      &ll_sbi_flags_fops, NULL, 0 },
+	{ .name =		"nosquash_nids",
+	  .fops =		&ll_nosquash_nids_fops		},
 	{ NULL }
 };
 
@@ -869,6 +936,7 @@ static struct attribute *llite_attrs[] = {
 	&lustre_attr_default_easize.attr,
 	&lustre_attr_xattr_cache.attr,
 	&lustre_attr_unstable_stats.attr,
+	&lustre_attr_root_squash.attr,
 	NULL,
 };
 
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index 279b625..c83d28e 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -1547,6 +1547,146 @@ void lprocfs_oh_clear(struct obd_histogram *oh)
 }
 EXPORT_SYMBOL(lprocfs_oh_clear);
 
+int lprocfs_wr_root_squash(const char __user *buffer, unsigned long count,
+			   struct root_squash_info *squash, char *name)
+{
+	char kernbuf[64], *tmp, *errmsg;
+	unsigned long uid, gid;
+	int rc;
+
+	if (count >= sizeof(kernbuf)) {
+		errmsg = "string too long";
+		rc = -EINVAL;
+		goto failed_noprint;
+	}
+	if (copy_from_user(kernbuf, buffer, count)) {
+		errmsg = "bad address";
+		rc = -EFAULT;
+		goto failed_noprint;
+	}
+	kernbuf[count] = '\0';
+
+	/* look for uid gid separator */
+	tmp = strchr(kernbuf, ':');
+	if (!tmp) {
+		errmsg = "needs uid:gid format";
+		rc = -EINVAL;
+		goto failed;
+	}
+	*tmp = '\0';
+	tmp++;
+
+	/* parse uid */
+	if (kstrtoul(kernbuf, 0, &uid) != 0) {
+		errmsg = "bad uid";
+		rc = -EINVAL;
+		goto failed;
+	}
+	/* parse gid */
+	if (kstrtoul(tmp, 0, &gid) != 0) {
+		errmsg = "bad gid";
+		rc = -EINVAL;
+		goto failed;
+	}
+
+	squash->rsi_uid = uid;
+	squash->rsi_gid = gid;
+
+	LCONSOLE_INFO("%s: root_squash is set to %u:%u\n",
+		      name, squash->rsi_uid, squash->rsi_gid);
+	return count;
+
+failed:
+	if (tmp) {
+		tmp--;
+		*tmp = ':';
+	}
+	CWARN("%s: failed to set root_squash to \"%s\", %s, rc = %d\n",
+	      name, kernbuf, errmsg, rc);
+	return rc;
+failed_noprint:
+	CWARN("%s: failed to set root_squash due to %s, rc = %d\n",
+	      name, errmsg, rc);
+	return rc;
+}
+EXPORT_SYMBOL(lprocfs_wr_root_squash);
+
+int lprocfs_wr_nosquash_nids(const char __user *buffer, unsigned long count,
+			     struct root_squash_info *squash, char *name)
+{
+	char *kernbuf = NULL, *errmsg;
+	struct list_head tmp;
+	int len = count;
+	int rc;
+
+	if (count > 4096) {
+		errmsg = "string too long";
+		rc = -EINVAL;
+		goto failed;
+	}
+
+	kernbuf = kzalloc(count + 1, GFP_NOFS);
+	if (!kernbuf) {
+		errmsg = "no memory";
+		rc = -ENOMEM;
+		goto failed;
+	}
+
+	if (copy_from_user(kernbuf, buffer, count)) {
+		errmsg = "bad address";
+		rc = -EFAULT;
+		goto failed;
+	}
+	kernbuf[count] = '\0';
+
+	if (count > 0 && kernbuf[count - 1] == '\n')
+		len = count - 1;
+
+	if ((len == 4 && !strncmp(kernbuf, "NONE", len)) ||
+	    (len == 5 && !strncmp(kernbuf, "clear", len))) {
+		/* empty string is special case */
+		down_write(&squash->rsi_sem);
+		if (!list_empty(&squash->rsi_nosquash_nids))
+			cfs_free_nidlist(&squash->rsi_nosquash_nids);
+		up_write(&squash->rsi_sem);
+		LCONSOLE_INFO("%s: nosquash_nids is cleared\n", name);
+		kfree(kernbuf);
+		return count;
+	}
+
+	INIT_LIST_HEAD(&tmp);
+	if (cfs_parse_nidlist(kernbuf, count, &tmp) <= 0) {
+		errmsg = "can't parse";
+		rc = -EINVAL;
+		goto failed;
+	}
+	LCONSOLE_INFO("%s: nosquash_nids set to %s\n",
+		      name, kernbuf);
+	kfree(kernbuf);
+	kernbuf = NULL;
+
+	down_write(&squash->rsi_sem);
+	if (!list_empty(&squash->rsi_nosquash_nids))
+		cfs_free_nidlist(&squash->rsi_nosquash_nids);
+	list_splice(&tmp, &squash->rsi_nosquash_nids);
+	up_write(&squash->rsi_sem);
+
+	return count;
+
+failed:
+	if (kernbuf) {
+		CWARN("%s: failed to set nosquash_nids to \"%s\", %s rc = %d\n",
+		      name, kernbuf, errmsg, rc);
+		kfree(kernbuf);
+		kernbuf = NULL;
+	} else {
+		CWARN("%s: failed to set nosquash_nids due to %s rc = %d\n",
+		      name, errmsg, rc);
+	}
+	return rc;
+}
+EXPORT_SYMBOL(lprocfs_wr_nosquash_nids);
+
 static ssize_t lustre_attr_show(struct kobject *kobj,
 				struct attribute *attr, char *buf)
 {
-- 
1.7.1
