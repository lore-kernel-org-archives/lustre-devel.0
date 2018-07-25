From: NeilBrown <neilb@suse.com>
Date: Wed, 25 Jul 2018 12:17:27 +1000
Subject: [lustre-devel] [PATCH] lustre: fix inode refcount problem with
 fhandle access
Message-ID: <87sh48njns.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


ll_iget_for_nfs() currently calls d_obtain_alias() twice.
This decrements the refcount on the inode twice, and
increments it on the dentry twice.
In each case, only once is correct.
The result is that the refcounts are wrong and warnings
result.

Also, if the first d_obtain_alias() returns an error,
iput() is called.  As the comment at the second d_obtain_alias()
explains, this is incorrect.

Reported-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/llite/llite_nfs.c | 20 +++++++-------------
 1 file changed, 7 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_nfs.c b/drivers/staging/lustre/lustre/llite/llite_nfs.c
index 14172688d55f..9efb20e91476 100644
--- a/drivers/staging/lustre/lustre/llite/llite_nfs.c
+++ b/drivers/staging/lustre/lustre/llite/llite_nfs.c
@@ -150,10 +150,8 @@ ll_iget_for_nfs(struct super_block *sb,
 	}
 
 	result = d_obtain_alias(inode);
-	if (IS_ERR(result)) {
-		iput(inode);
+	if (IS_ERR(result))
 		return result;
-	}
 
 	/**
 	 * In case d_obtain_alias() found a disconnected dentry, always update
@@ -168,16 +166,12 @@ ll_iget_for_nfs(struct super_block *sb,
 		spin_unlock(&lli->lli_lock);
 	}
 
-	/* N.B. d_obtain_alias() drops inode ref on error */
-	result = d_obtain_alias(inode);
-	if (!IS_ERR(result)) {
-		/*
-		 * Need to signal to the ll_intent_file_open that
-		 * we came from NFS and so opencache needs to be
-		 * enabled for this one
-		 */
-		ll_d2d(result)->lld_nfs_dentry = 1;
-	}
+	/*
+	 * Need to signal to the ll_intent_file_open that
+	 * we came from NFS and so opencache needs to be
+	 * enabled for this one
+	 */
+	ll_d2d(result)->lld_nfs_dentry = 1;
 
 	return result;
 }
-- 
2.14.0.rc0.dirty

-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180725/0c66be35/attachment.sig>
