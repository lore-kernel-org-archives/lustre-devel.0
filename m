From: Oleg Drokin <green@linuxhacker.ru>
Date: Thu,  9 Jun 2016 22:35:14 -0400
Subject: [lustre-devel] [PATCH 4/8] staging/lustre/llite: Fix Multiple
	Assignments
In-Reply-To: <1465526118-521053-1-git-send-email-green@linuxhacker.ru>
References: <1465526118-521053-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1465526118-521053-5-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Nathaniel Clark <nathaniel.l.clark@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Nathaniel Clark <nathaniel.l.clark@intel.com>

Fix all multiple assignments on lustre/llite directory.

Signed-off-by: Nathaniel Clark <nathaniel.l.clark@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/llite_lib.c | 3 ++-
 drivers/staging/lustre/lustre/llite/namei.c     | 3 ++-
 drivers/staging/lustre/lustre/llite/vvp_io.c    | 3 ++-
 3 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 96c7e9f..b260f60 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -864,7 +864,8 @@ int ll_fill_super(struct super_block *sb, struct vfsmount *mnt)
 	try_module_get(THIS_MODULE);
 
 	/* client additional sb info */
-	lsi->lsi_llsbi = sbi = ll_init_sbi(sb);
+	sbi = ll_init_sbi(sb);
+	lsi->lsi_llsbi = sbi;
 	if (!sbi) {
 		module_put(THIS_MODULE);
 		kfree(cfg);
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 5eba0eb..95643bc 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -318,7 +318,8 @@ static struct dentry *ll_find_alias(struct inode *inode, struct dentry *dentry)
 	if (hlist_empty(&inode->i_dentry))
 		return NULL;
 
-	discon_alias = invalid_alias = NULL;
+	discon_alias = NULL;
+	invalid_alias = NULL;
 
 	ll_lock_dcache(inode);
 	hlist_for_each_entry(alias, &inode->i_dentry, d_u.d_alias) {
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index e26e0f8..763d336 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -954,7 +954,8 @@ static int vvp_io_write_start(const struct lu_env *env,
 		 * out-of-order writes.
 		 */
 		ll_merge_attr(env, inode);
-		pos = io->u.ci_wr.wr.crw_pos = i_size_read(inode);
+		pos = i_size_read(inode);
+		io->u.ci_wr.wr.crw_pos = pos;
 		vio->vui_iocb->ki_pos = pos;
 	} else {
 		LASSERT(vio->vui_iocb->ki_pos == pos);
-- 
2.7.4
