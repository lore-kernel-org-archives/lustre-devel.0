From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:04:54 -0500
Subject: [lustre-devel] [PATCH 26/60] staging: lustre: llite: Trust creates
	in revalidate too.
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-27-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

From: Oleg Drokin <oleg.drokin@intel.com>

By forcing creates to always go via lookup we lose some
important caching benefits too.
Instead let's trust creates with positive cached entries.

Then we have 3 possible outcomes:
1. Negative dentry - we go via atomic_open and do the create
   by name there.
2. Positive dentry, no contention - we just go straight to
   ll_intent_file_open and open by fid.
3. positive dentry, contention - by the time we reach the server,
   the inode is gone. We get ENOENT which is unacceptable to return
   from create. But since we know it's a create, we substitute it
   with ESTALE and VFS retries again with LOOKUP_REVAL set, we catch
   that in revalidate and force a lookup (same path as before this
   patch).

Signed-off-by: Oleg Drokin <oleg.drokin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8371
Reviewed-on: http://review.whamcloud.com/21168
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/dcache.c | 13 +++++--------
 drivers/staging/lustre/lustre/llite/file.c   | 11 +++++++++++
 2 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dcache.c b/drivers/staging/lustre/lustre/llite/dcache.c
index 65bf0c4..966f580 100644
--- a/drivers/staging/lustre/lustre/llite/dcache.c
+++ b/drivers/staging/lustre/lustre/llite/dcache.c
@@ -247,17 +247,14 @@ static int ll_revalidate_dentry(struct dentry *dentry,
 		return 1;
 
 	/*
-	 * if open&create is set, talk to MDS to make sure file is created if
-	 * necessary, because we can't do this in ->open() later since that's
-	 * called on an inode. return 0 here to let lookup to handle this.
+	 * VFS warns us that this is the second go around and previous
+	 * operation failed (most likely open|creat), so this time
+	 * we better talk to the server via the lookup path by name,
+	 * not by fid.
 	 */
-	if ((lookup_flags & (LOOKUP_OPEN | LOOKUP_CREATE)) ==
-	    (LOOKUP_OPEN | LOOKUP_CREATE))
+	if (lookup_flags & LOOKUP_REVAL)
 		return 0;
 
-	if (lookup_flags & (LOOKUP_PARENT | LOOKUP_OPEN | LOOKUP_CREATE))
-		return 1;
-
 	if (!dentry_may_statahead(dir, dentry))
 		return 1;
 
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index b681e15..0c83bd7 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -417,6 +417,17 @@ static int ll_intent_file_open(struct dentry *de, void *lmm, int lmmsize,
 	ptlrpc_req_finished(req);
 	ll_intent_drop_lock(itp);
 
+	/*
+	 * We did open by fid, but by the time we got to the server,
+	 * the object disappeared. If this is a create, we cannot really
+	 * tell the userspace that the file it was trying to create
+	 * does not exist. Instead let's return -ESTALE, and the VFS will
+	 * retry the create with LOOKUP_REVAL that we are going to catch
+	 * in ll_revalidate_dentry() and use lookup then.
+	 */
+	if (rc == -ENOENT && itp->it_op & IT_CREAT)
+		rc = -ESTALE;
+
 	return rc;
 }
 
-- 
1.8.3.1
