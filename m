From: Oleg Drokin <green@linuxhacker.ru>
Date: Thu, 14 Jul 2016 23:40:21 -0400
Subject: [lustre-devel] [PATCH] staging/lustre/llite: Close atomic_open race
	with several openers
Message-ID: <1468554021-30080-1-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

Right now, if it's an open of a negative dentry, a race is possible
with several openers who all try to instantiate/rehash the same
dentry and would hit a BUG_ON in d_add.
But in fact if we got a negative dentry in atomic_open, that means
we just revalidated it so no point in talking to MDS at all,
just return ENOENT and make the race go away completely.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
This problem was introduced during current development cycle, with
parallel openers now possible for non-creates due to vfs changes,
so it would be great if this could go into Linus' tree separatel
in time for 4.7

 drivers/staging/lustre/lustre/llite/namei.c | 43 ++++++++++++++++-------------
 1 file changed, 24 insertions(+), 19 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 3664bfd..2c4dc69 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -388,6 +388,7 @@ static int ll_lookup_it_finish(struct ptlrpc_request *request,
 	struct inode *inode = NULL;
 	__u64 bits = 0;
 	int rc = 0;
+	struct dentry *alias;
 
 	/* NB 1 request reference will be taken away by ll_intent_lock()
 	 * when I return
@@ -412,26 +413,12 @@ static int ll_lookup_it_finish(struct ptlrpc_request *request,
 		 */
 	}
 
-	/* Only hash *de if it is unhashed (new dentry).
-	 * Atoimc_open may passing hashed dentries for open.
-	 */
-	if (d_unhashed(*de)) {
-		struct dentry *alias;
-
-		alias = ll_splice_alias(inode, *de);
-		if (IS_ERR(alias)) {
-			rc = PTR_ERR(alias);
-			goto out;
-		}
-		*de = alias;
-	} else if (!it_disposition(it, DISP_LOOKUP_NEG)  &&
-		   !it_disposition(it, DISP_OPEN_CREATE)) {
-		/* With DISP_OPEN_CREATE dentry will be
-		 * instantiated in ll_create_it.
-		 */
-		LASSERT(!d_inode(*de));
-		d_instantiate(*de, inode);
+	alias = ll_splice_alias(inode, *de);
+	if (IS_ERR(alias)) {
+		rc = PTR_ERR(alias);
+		goto out;
 	}
+	*de = alias;
 
 	if (!it_disposition(it, DISP_LOOKUP_NEG)) {
 		/* we have lookup look - unhide dentry */
@@ -587,6 +574,24 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 	       dentry, PFID(ll_inode2fid(dir)), dir, file, open_flags, mode,
 	       *opened);
 
+	/* Only negative dentries enter here */
+	LASSERT(!d_inode(dentry));
+
+	if (!d_in_lookup(dentry)) {
+		/* A valid negative dentry that just passed revalidation,
+		 * there's little point to try and open it server-side,
+		 * even though there's a minuscle chance it might succeed.
+		 * Either way it's a valid race to just return -ENOENT here.
+		 */
+		if (!(open_flags & O_CREAT))
+			return -ENOENT;
+
+		/* Otherwise we just unhash it to be rehashed afresh via
+		 * lookup if necessary
+		 */
+		d_drop(dentry);
+	}
+
 	it = kzalloc(sizeof(*it), GFP_NOFS);
 	if (!it)
 		return -ENOMEM;
-- 
2.7.4
