From: NeilBrown <neilb@suse.com>
Date: Mon, 21 May 2018 14:35:12 +1000
Subject: [lustre-devel] [PATCH 07/30] staging: lustre: simplify capability
 dropping.
In-Reply-To: <152687724799.24196.7718555295926047576.stgit@noble>
References: <152687724799.24196.7718555295926047576.stgit@noble>
Message-ID: <152687731262.24196.18346433737169784278.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

Lustre has a 'squash credentials' concept similar to the "anon_uid"
for nfsd.  When accessing a file with squashed credentials, we
need to also drop capabilities.
Linux has cap_drop_fs_set() and cap_drop_nfsd_set().  Rather than
taking a completely different approach, this patch changes lustre
to use this same cap_drop_*_set() approach.

With this change we also drop CAP_MKNOD and CAP_MAC_OVERRIDE
which are probably appropriate, and don't drop
CAP_SYS_ADMIN or CAP_SYS_BOOT which should be irrelevant for
file permission checking

Calling both cap_drop_*_set() seems a bit clumsy, but gets
the job done.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/libcfs/curproc.h  |   10 ----------
 drivers/staging/lustre/lustre/llite/file.c         |    8 +++-----
 2 files changed, 3 insertions(+), 15 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/curproc.h b/drivers/staging/lustre/include/linux/libcfs/curproc.h
index 83526f84495d..fc6f6eb2d5fe 100644
--- a/drivers/staging/lustre/include/linux/libcfs/curproc.h
+++ b/drivers/staging/lustre/include/linux/libcfs/curproc.h
@@ -50,16 +50,6 @@
 
 typedef u32 cfs_cap_t;
 
-#define CFS_CAP_FS_MASK (BIT(CAP_CHOWN) |		\
-			 BIT(CAP_DAC_OVERRIDE) |	\
-			 BIT(CAP_DAC_READ_SEARCH) |	\
-			 BIT(CAP_FOWNER) |		\
-			 BIT(CAP_FSETID) |		\
-			 BIT(CAP_LINUX_IMMUTABLE) | \
-			 BIT(CAP_SYS_ADMIN) |	\
-			 BIT(CAP_SYS_BOOT) |	\
-			 BIT(CAP_SYS_RESOURCE))
-
 static inline cfs_cap_t cfs_curproc_cap_pack(void)
 {
 	/* cfs_cap_t is only the first word of kernel_cap_t */
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 0026fde81ad3..a77cadcd9d48 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -3050,7 +3050,6 @@ int ll_inode_permission(struct inode *inode, int mask)
 	const struct cred *old_cred = NULL;
 	struct cred *cred = NULL;
 	bool squash_id = false;
-	cfs_cap_t cap;
 	int rc = 0;
 
 	if (mask & MAY_NOT_BLOCK)
@@ -3094,10 +3093,9 @@ int ll_inode_permission(struct inode *inode, int mask)
 
 		cred->fsuid = make_kuid(&init_user_ns, squash->rsi_uid);
 		cred->fsgid = make_kgid(&init_user_ns, squash->rsi_gid);
-		for (cap = 0; cap < sizeof(cfs_cap_t) * 8; cap++) {
-			if ((1 << cap) & CFS_CAP_FS_MASK)
-				cap_lower(cred->cap_effective, cap);
-		}
+		cred->cap_effective = cap_drop_nfsd_set(cred->cap_effective);
+		cred->cap_effective = cap_drop_fs_set(cred->cap_effective);
+
 		old_cred = override_creds(cred);
 	}
 
