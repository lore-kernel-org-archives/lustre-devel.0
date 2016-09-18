From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:31 -0400
Subject: [lustre-devel] [PATCH 032/124] staging: lustre: llite: remove
	lookup_flags from ll_lookup_it()
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-33-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

Remove the effectively unused lookup_flags parameter from
ll_lookup_it().

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2675
Reviewed-on: http://review.whamcloud.com/10769
Reviewed-by: Yang Sheng <yang.sheng@intel.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/namei.c |   14 +++++---------
 1 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index b7d448f..2037c7c 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -502,7 +502,7 @@ out:
 }
 
 static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
-				   struct lookup_intent *it, int lookup_flags)
+				   struct lookup_intent *it)
 {
 	struct lookup_intent lookup_it = { .it_op = IT_LOOKUP };
 	struct dentry *save = dentry, *retval;
@@ -541,8 +541,7 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 		opc = LUSTRE_OPC_ANY;
 
 	op_data = ll_prep_md_op_data(NULL, parent, NULL, dentry->d_name.name,
-				     dentry->d_name.len, lookup_flags, opc,
-				     NULL);
+				     dentry->d_name.len, 0, opc, NULL);
 	if (IS_ERR(op_data))
 		return (void *)op_data;
 
@@ -606,7 +605,7 @@ static struct dentry *ll_lookup_nd(struct inode *parent, struct dentry *dentry,
 		itp = NULL;
 	else
 		itp = &it;
-	de = ll_lookup_it(parent, dentry, itp, 0);
+	de = ll_lookup_it(parent, dentry, itp);
 
 	if (itp)
 		ll_intent_release(itp);
@@ -624,7 +623,6 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 {
 	struct lookup_intent *it;
 	struct dentry *de;
-	long long lookup_flags = LOOKUP_OPEN;
 	int rc = 0;
 
 	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, dir="DFID"(%p),file %p,open_flags %x,mode %x opened %d\n",
@@ -654,16 +652,14 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 		return -ENOMEM;
 
 	it->it_op = IT_OPEN;
-	if (open_flags & O_CREAT) {
+	if (open_flags & O_CREAT)
 		it->it_op |= IT_CREAT;
-		lookup_flags |= LOOKUP_CREATE;
-	}
 	it->it_create_mode = (mode & S_IALLUGO) | S_IFREG;
 	it->it_flags = (open_flags & ~O_ACCMODE) | OPEN_FMODE(open_flags);
 	it->it_flags &= ~MDS_OPEN_FL_INTERNAL;
 
 	/* Dentry added to dcache tree in ll_lookup_it */
-	de = ll_lookup_it(dir, dentry, it, lookup_flags);
+	de = ll_lookup_it(dir, dentry, it);
 	if (IS_ERR(de))
 		rc = PTR_ERR(de);
 	else if (de)
-- 
1.7.1
