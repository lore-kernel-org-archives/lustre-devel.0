From: NeilBrown <neilb@suse.com>
Date: Tue, 13 Feb 2018 08:30:48 +1100
Subject: [lustre-devel] [PATCH 2/5] staging: lustre: llite: use
 d_splice_alias for directories.
In-Reply-To: <151847081541.26699.3911837371411314092.stgit@noble>
References: <151847081541.26699.3911837371411314092.stgit@noble>
Message-ID: <151847104797.26699.15971881529877617500.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Al Viro <viro@ZenIV.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

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
index a2687f46a16d..60fb18f83bf8 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -434,7 +434,7 @@ static struct dentry *ll_find_alias(struct inode *inode, struct dentry *dentry)
  */
 struct dentry *ll_splice_alias(struct inode *inode, struct dentry *de)
 {
-	if (inode) {
+	if (inode && !S_ISDIR(inode->i_mode)) {
 		struct dentry *new = ll_find_alias(inode, de);
 
 		if (new) {
@@ -445,8 +445,13 @@ struct dentry *ll_splice_alias(struct inode *inode, struct dentry *de)
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
