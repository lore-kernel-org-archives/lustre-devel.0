From: Jan Kara <jack@suse.cz>
Date: Thu,  2 Feb 2017 18:34:02 +0100
Subject: [lustre-devel] [PATCH 04/24] fs: Provide infrastructure for dynamic
	BDIs in filesystems
In-Reply-To: <20170202173422.3240-1-jack@suse.cz>
References: <20170202173422.3240-1-jack@suse.cz>
Message-ID: <20170202173422.3240-5-jack@suse.cz>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-fsdevel@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>, linux-block@vger.kernel.org, Jan Kara <jack@suse.cz>, linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org, Petr Vandrovec <petr@vandrovec.name>, linux-nilfs@vger.kernel.org, cluster-devel@redhat.com, osd-dev@open-osd.org, codalist@coda.cs.cmu.edu, linux-afs@lists.infradead.org, ecryptfs@vger.kernel.org, linux-cifs@vger.kernel.org, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, v9fs-developer@lists.sourceforge.net, lustre-devel@lists.lustre.org

Provide helper functions for setting up dynamically allocated
backing_dev_info structures for filesystems and cleaning them up on
superblock destruction.

CC: linux-mtd at lists.infradead.org
CC: linux-nfs at vger.kernel.org
CC: Petr Vandrovec <petr@vandrovec.name>
CC: linux-nilfs at vger.kernel.org
CC: cluster-devel at redhat.com
CC: osd-dev at open-osd.org
CC: codalist at coda.cs.cmu.edu
CC: linux-afs at lists.infradead.org
CC: ecryptfs at vger.kernel.org
CC: linux-cifs at vger.kernel.org
CC: ceph-devel at vger.kernel.org
CC: linux-btrfs at vger.kernel.org
CC: v9fs-developer at lists.sourceforge.net
CC: lustre-devel at lists.lustre.org
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/super.c                       | 49 ++++++++++++++++++++++++++++++++++++++++
 include/linux/backing-dev-defs.h |  2 +-
 include/linux/fs.h               |  6 +++++
 3 files changed, 56 insertions(+), 1 deletion(-)

diff --git a/fs/super.c b/fs/super.c
index ea662b0e5e78..31dc4c6450ef 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -446,6 +446,11 @@ void generic_shutdown_super(struct super_block *sb)
 	hlist_del_init(&sb->s_instances);
 	spin_unlock(&sb_lock);
 	up_write(&sb->s_umount);
+	if (sb->s_iflags & SB_I_DYNBDI) {
+		bdi_put(sb->s_bdi);
+		sb->s_bdi = &noop_backing_dev_info;
+		sb->s_iflags &= ~SB_I_DYNBDI;
+	}
 }
 
 EXPORT_SYMBOL(generic_shutdown_super);
@@ -1249,6 +1254,50 @@ mount_fs(struct file_system_type *type, int flags, const char *name, void *data)
 }
 
 /*
+ * Setup private BDI for given superblock. I gets automatically cleaned up
+ * in generic_shutdown_super().
+ */
+int super_setup_bdi_name(struct super_block *sb, char *fmt, ...)
+{
+	struct backing_dev_info *bdi;
+	int err;
+	va_list args;
+
+	bdi = bdi_alloc(GFP_KERNEL);
+	if (!bdi)
+		return -ENOMEM;
+
+	bdi->name = sb->s_type->name;
+
+	va_start(args, fmt);
+	err = bdi_register_va(bdi, NULL, fmt, args);
+	va_end(args);
+	if (err) {
+		bdi_put(bdi);
+		return err;
+	}
+	WARN_ON(sb->s_bdi != &noop_backing_dev_info);
+	sb->s_bdi = bdi;
+	sb->s_iflags |= SB_I_DYNBDI;
+
+	return 0;
+}
+EXPORT_SYMBOL(super_setup_bdi_name);
+
+/*
+ * Setup private BDI for given superblock. I gets automatically cleaned up
+ * in generic_shutdown_super().
+ */
+int super_setup_bdi(struct super_block *sb)
+{
+	static atomic_long_t bdi_seq = ATOMIC_LONG_INIT(0);
+
+	return super_setup_bdi_name(sb, "%.28s-%ld", sb->s_type->name,
+				    atomic_long_inc_return(&bdi_seq));
+}
+EXPORT_SYMBOL(super_setup_bdi);
+
+/*
  * This is an internal function, please use sb_end_{write,pagefault,intwrite}
  * instead.
  */
diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index 2ecafc8a2d06..70080b4217f4 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -143,7 +143,7 @@ struct backing_dev_info {
 	congested_fn *congested_fn; /* Function pointer if device is md/dm */
 	void *congested_data;	/* Pointer to aux data for congested func */
 
-	char *name;
+	const char *name;
 
 	struct kref refcnt;	/* Reference counter for the structure */
 	unsigned int registered:1;	/* Is bdi registered? */
diff --git a/include/linux/fs.h b/include/linux/fs.h
index c930cbc19342..8ed8b6d1bc54 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1267,6 +1267,9 @@ struct mm_struct;
 /* sb->s_iflags to limit user namespace mounts */
 #define SB_I_USERNS_VISIBLE		0x00000010 /* fstype already mounted */
 
+/* Temporary flag until all filesystems are converted to dynamic bdis */
+#define SB_I_DYNBDI	0x00000100
+
 /* Possible states of 'frozen' field */
 enum {
 	SB_UNFROZEN = 0,		/* FS is unfrozen */
@@ -2103,6 +2106,9 @@ extern int vfs_ustat(dev_t, struct kstatfs *);
 extern int freeze_super(struct super_block *super);
 extern int thaw_super(struct super_block *super);
 extern bool our_mnt(struct vfsmount *mnt);
+extern __printf(2, 3)
+int super_setup_bdi_name(struct super_block *sb, char *fmt, ...);
+extern int super_setup_bdi(struct super_block *sb);
 
 extern int current_umask(void);
 
-- 
2.10.2
