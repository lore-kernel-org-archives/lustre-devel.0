From: Bhumika Goyal <bhumirks@gmail.com>
Date: Sat, 23 Jan 2016 18:41:53 +0530
Subject: [lustre-devel] [PATCH] Staging:lustre:lustre:llite:Remove explicit
	NULL comparision
Message-ID: <1453554713-6895-1-git-send-email-bhumirks@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: gregkh@linuxfoundation.org, oleg.drokin@intel.com, andreas.dilger@intel.com
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, Bhumika Goyal <bhumirks@gmail.com>

Replaced explicit NULL comparision with its simplier form.
Found using coccinelle:

@replace_rule@
expression e;
@@

-e == NULL
+ !e

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 drivers/staging/lustre/lustre/llite/dcache.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dcache.c b/drivers/staging/lustre/lustre/llite/dcache.c
index 3d6745e..bc179e5 100644
--- a/drivers/staging/lustre/lustre/llite/dcache.c
+++ b/drivers/staging/lustre/lustre/llite/dcache.c
@@ -62,7 +62,7 @@ static void ll_release(struct dentry *de)
 
 	LASSERT(de != NULL);
 	lld = ll_d2d(de);
-	if (lld == NULL) /* NFS copies the de->d_op methods (bug 4655) */
+	if (!lld) /* NFS copies the de->d_op methods (bug 4655) */
 		return;
 
 	if (lld->lld_it) {
@@ -131,7 +131,7 @@ static int find_cbdata(struct inode *inode)
 		return rc;
 
 	lsm = ccc_inode_lsm_get(inode);
-	if (lsm == NULL)
+	if (!lsm)
 		return rc;
 
 	rc = obd_find_cbdata(sbi->ll_dt_exp, lsm, return_if_equal, NULL);
@@ -184,13 +184,13 @@ int ll_d_init(struct dentry *de)
 		de, de, de->d_parent, d_inode(de),
 		d_count(de));
 
-	if (de->d_fsdata == NULL) {
+	if (!de->d_fsdata) {
 		struct ll_dentry_data *lld;
 
 		lld = kzalloc(sizeof(*lld), GFP_NOFS);
 		if (likely(lld)) {
 			spin_lock(&de->d_lock);
-			if (likely(de->d_fsdata == NULL)) {
+			if (likely(!de->d_fsdata)) {
 				de->d_fsdata = lld;
 				__d_lustre_invalidate(de);
 			} else {
@@ -328,7 +328,7 @@ static int ll_revalidate_dentry(struct dentry *dentry,
 	if (lookup_flags & LOOKUP_RCU)
 		return -ECHILD;
 
-	do_statahead_enter(dir, &dentry, d_inode(dentry) == NULL);
+	do_statahead_enter(dir, &dentry, !d_inode(dentry));
 	ll_statahead_mark(dir, dentry);
 	return 1;
 }
-- 
1.9.1
