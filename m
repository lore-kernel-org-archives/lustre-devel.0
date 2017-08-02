From: NeilBrown <neilb@suse.com>
Date: Wed, 02 Aug 2017 13:06:18 +1000
Subject: [lustre-devel] [PATCH 2/6] staging: lustre: llite: use
 d_splice_alias for directories.
In-Reply-To: <150164273003.13199.7841976922211510658.stgit@noble>
References: <150164273003.13199.7841976922211510658.stgit@noble>
Message-ID: <150164317822.13199.4133063936298364252.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <greg@kroah.com>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Lustre Development List <lustre-devel@lists.lustre.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

In the Linux dcache a directory only ever has one dentry,
so d_splice_alias() can be used by ll_splice_alias() for directories.
It will find the one dentry whether it is DCACHE_DISCONNECTED or
IS_ROOT() or d_lustre_invalid().
Separating out the directories from non-directories will allow us
to simplify the non-directory code.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/llite/namei.c |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index a208a8b02c2c..5ac340a8ad6f 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -432,7 +432,7 @@ static struct dentry *ll_find_alias(struct inode *inode, struct dentry *dentry)
  */
 struct dentry *ll_splice_alias(struct inode *inode, struct dentry *de)
 {
-	if (inode) {
+	if (inode && !S_ISDIR(inode->i_mode)) {
 		struct dentry *new = ll_find_alias(inode, de);
 
 		if (new) {
@@ -443,8 +443,13 @@ struct dentry *ll_splice_alias(struct inode *inode, struct dentry *de)
 			      new, d_inode(new), d_count(new), new->d_flags);
 			return new;
 		}
+		d_add(de, inode);
+	} else {
+		struct dentry *new = d_splice_alias(inode, de);
+
+		if (new)
+			de = new;
 	}
-	d_add(de, inode);
 	CDEBUG(D_DENTRY, "Add dentry %p inode %p refc %d flags %#x\n",
 	       de, d_inode(de), d_count(de), de->d_flags);
 	return de;
