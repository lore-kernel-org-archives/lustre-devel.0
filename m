From: Oleg Drokin <green@linuxhacker.ru>
Date: Sun, 19 Jun 2016 22:07:38 -0400
Subject: [lustre-devel] [PATCH 23/28] staging/lustre/llite: Restore proper
	opencache operations
In-Reply-To: <1466388463-1817551-1-git-send-email-green@linuxhacker.ru>
References: <1466388463-1817551-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1466388463-1817551-24-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <oleg.drokin@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <oleg.drokin@intel.com>

Mark dentries that came to us via NFS in a special way so that
we can tell them apart during open and activate open cache
(we really don't want to do open/close RPC for every NFS IO).

This became needed since dentry revlidate no longer reimplements
any RPCs for lookup, and as such if a dentry is valid,
ll_revalidate_dentry returns 1 and ll_lookup_it() is never visited
during opens, we get straght into ll_file_open() without a valid
intent/RPC. This used to be only true for NFS, so opencache was
engaged needlessly, and it carries a cost of it's own if there is
in fact no repetitive file opening-closing going on

Signed-off-by: Oleg Drokin <oleg.drokin@intel.com>
Reviewed-on: http://review.whamcloud.com/20354
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8019
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/file.c           | 14 +++++++++++++-
 drivers/staging/lustre/lustre/llite/llite_internal.h |  1 +
 drivers/staging/lustre/lustre/llite/llite_nfs.c      | 18 ++++++++++++++++++
 3 files changed, 32 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index a188366..6a5e8c7 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -411,7 +411,19 @@ static int ll_intent_file_open(struct dentry *dentry, void *lmm,
 	 * parameters. No need for the open lock
 	 */
 	if (!lmm && lmmsize == 0) {
-		itp->it_flags |= MDS_OPEN_LOCK;
+		struct ll_dentry_data *ldd = ll_d2d(dentry);
+		/*
+		 * If we came via ll_iget_for_nfs, then we need to request
+		 * struct ll_dentry_data *ldd = ll_d2d(file->f_dentry);
+		 *
+		 * NB: when ldd is NULL, it must have come via normal
+		 * lookup path only, since ll_iget_for_nfs always calls
+		 * ll_d_init().
+		 */
+		if (ldd && ldd->lld_nfs_dentry) {
+			ldd->lld_nfs_dentry = 0;
+			itp->it_flags |= MDS_OPEN_LOCK;
+		}
 		if (itp->it_flags & FMODE_WRITE)
 			opc = LUSTRE_OPC_CREATE;
 	}
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 3692102..1d4e91e 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -64,6 +64,7 @@ struct ll_dentry_data {
 	struct lookup_intent		*lld_it;
 	unsigned int			lld_sa_generation;
 	unsigned int			lld_invalid:1;
+	unsigned int			lld_nfs_dentry:1;
 	struct rcu_head			lld_rcu_head;
 };
 
diff --git a/drivers/staging/lustre/lustre/llite/llite_nfs.c b/drivers/staging/lustre/lustre/llite/llite_nfs.c
index d7878e5..65972c8 100644
--- a/drivers/staging/lustre/lustre/llite/llite_nfs.c
+++ b/drivers/staging/lustre/lustre/llite/llite_nfs.c
@@ -168,6 +168,24 @@ ll_iget_for_nfs(struct super_block *sb, struct lu_fid *fid, struct lu_fid *paren
 
 	/* N.B. d_obtain_alias() drops inode ref on error */
 	result = d_obtain_alias(inode);
+	if (!IS_ERR(result)) {
+		int rc;
+
+		rc = ll_d_init(result);
+		if (rc < 0) {
+			dput(result);
+			result = ERR_PTR(rc);
+		} else {
+			struct ll_dentry_data *ldd = ll_d2d(result);
+
+			/*
+			 * Need to signal to the ll_intent_file_open that
+			 * we came from NFS and so opencache needs to be
+			 * enabled for this one
+			 */
+			ldd->lld_nfs_dentry = 1;
+		}
+	}
 
 	return result;
 }
-- 
2.7.4
