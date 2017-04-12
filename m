From: Jan Kara <jack@suse.cz>
Date: Wed, 12 Apr 2017 12:24:30 +0200
Subject: [lustre-devel] [PATCH 06/25] lustre: Convert to separately
	allocated bdi
In-Reply-To: <20170412102449.16901-1-jack@suse.cz>
References: <20170412102449.16901-1-jack@suse.cz>
Message-ID: <20170412102449.16901-7-jack@suse.cz>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, lustre-devel@lists.lustre.org

Allocate struct backing_dev_info separately instead of embedding it
inside superblock. This unifies handling of bdi among users.

CC: Oleg Drokin <oleg.drokin@intel.com>
CC: Andreas Dilger <andreas.dilger@intel.com>
CC: James Simmons <jsimmons@infradead.org>
CC: lustre-devel at lists.lustre.org
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 .../staging/lustre/lustre/include/lustre_disk.h    |  4 ----
 drivers/staging/lustre/lustre/llite/llite_lib.c    | 24 +++-------------------
 2 files changed, 3 insertions(+), 25 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_disk.h b/drivers/staging/lustre/lustre/include/lustre_disk.h
index 8886458748c1..a676bccabd43 100644
--- a/drivers/staging/lustre/lustre/include/lustre_disk.h
+++ b/drivers/staging/lustre/lustre/include/lustre_disk.h
@@ -133,13 +133,9 @@ struct lustre_sb_info {
 	struct obd_export	 *lsi_osd_exp;
 	char			  lsi_osd_type[16];
 	char			  lsi_fstype[16];
-	struct backing_dev_info   lsi_bdi;     /* each client mountpoint needs
-						* own backing_dev_info
-						*/
 };
 
 #define LSI_UMOUNT_FAILOVER	      0x00200000
-#define LSI_BDI_INITIALIZED	      0x00400000
 
 #define     s2lsi(sb)	((struct lustre_sb_info *)((sb)->s_fs_info))
 #define     s2lsi_nocast(sb) ((sb)->s_fs_info)
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index b229cbc7bb33..d483c44aafe5 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -863,15 +863,6 @@ void ll_lli_init(struct ll_inode_info *lli)
 	mutex_init(&lli->lli_layout_mutex);
 }
 
-static inline int ll_bdi_register(struct backing_dev_info *bdi)
-{
-	static atomic_t ll_bdi_num = ATOMIC_INIT(0);
-
-	bdi->name = "lustre";
-	return bdi_register(bdi, NULL, "lustre-%d",
-			    atomic_inc_return(&ll_bdi_num));
-}
-
 int ll_fill_super(struct super_block *sb, struct vfsmount *mnt)
 {
 	struct lustre_profile *lprof = NULL;
@@ -881,6 +872,7 @@ int ll_fill_super(struct super_block *sb, struct vfsmount *mnt)
 	char  *profilenm = get_profile_name(sb);
 	struct config_llog_instance *cfg;
 	int    err;
+	static atomic_t ll_bdi_num = ATOMIC_INIT(0);
 
 	CDEBUG(D_VFSTRACE, "VFS Op: sb %p\n", sb);
 
@@ -903,16 +895,11 @@ int ll_fill_super(struct super_block *sb, struct vfsmount *mnt)
 	if (err)
 		goto out_free;
 
-	err = bdi_init(&lsi->lsi_bdi);
-	if (err)
-		goto out_free;
-	lsi->lsi_flags |= LSI_BDI_INITIALIZED;
-	lsi->lsi_bdi.capabilities = 0;
-	err = ll_bdi_register(&lsi->lsi_bdi);
+	err = super_setup_bdi_name(sb, "lustre-%d",
+				   atomic_inc_return(&ll_bdi_num));
 	if (err)
 		goto out_free;
 
-	sb->s_bdi = &lsi->lsi_bdi;
 	/* kernel >= 2.6.38 store dentry operations in sb->s_d_op. */
 	sb->s_d_op = &ll_d_ops;
 
@@ -1033,11 +1020,6 @@ void ll_put_super(struct super_block *sb)
 	if (profilenm)
 		class_del_profile(profilenm);
 
-	if (lsi->lsi_flags & LSI_BDI_INITIALIZED) {
-		bdi_destroy(&lsi->lsi_bdi);
-		lsi->lsi_flags &= ~LSI_BDI_INITIALIZED;
-	}
-
 	ll_free_sbi(sb);
 	lsi->lsi_llsbi = NULL;
 
-- 
2.12.0
