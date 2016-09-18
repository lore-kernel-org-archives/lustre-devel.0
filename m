From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:42 -0400
Subject: [lustre-devel] [PATCH 103/124] staging: lustre: llite: pack suppgid
	to MDS correctly
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-104-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Fan Yong <fan.yong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Fan Yong <fan.yong@intel.com>

The ll_lookup_it() may trigger IT_OPEN RPC to open a file by name.
But at that time, the client does not know the target file's GID,
so it cannot pack the necessary supplementary group ID in the RPC.
Because of missing the supplementary group ID, the RPC maybe fail
for open permission check on the MDS. Under such case, MDS should
return the target file's GID, if the current thread on the client
in the right group (according to the file's GID), the client will
try the IT_OPEN RPC again with the right supplementary group ID.

This patch is also helpful if some other(s) changed the file's GID
after current RPC sent to the MDS with the suppgid as the original
GID by race.

Signed-off-by: Fan Yong <fan.yong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5423
Reviewed-on: http://review.whamcloud.com/12476
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |    1 +
 drivers/staging/lustre/lustre/llite/namei.c        |   36 ++++++++++++++++++-
 2 files changed, 35 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index acb2806..72eaee9 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -1987,6 +1987,7 @@ void lustre_swab_generic_32s(__u32 *val);
 #define DISP_OPEN_LOCK       0x02000000
 #define DISP_OPEN_LEASE      0x04000000
 #define DISP_OPEN_STRIPE     0x08000000
+#define DISP_OPEN_DENY		0x10000000
 
 /* INODE LOCK PARTS */
 #define MDS_INODELOCK_LOOKUP 0x000001	/* For namespace, dentry etc, and also
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 1dd5df5..3960893 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -505,8 +505,8 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 	struct lookup_intent lookup_it = { .it_op = IT_LOOKUP };
 	struct dentry *save = dentry, *retval;
 	struct ptlrpc_request *req = NULL;
+	struct md_op_data *op_data = NULL;
 	struct inode *inode;
-	struct md_op_data *op_data;
 	__u32 opc;
 	int rc;
 
@@ -549,7 +549,36 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 
 	rc = md_intent_lock(ll_i2mdexp(parent), op_data, it, &req,
 			    &ll_md_blocking_ast, 0);
-	ll_finish_md_op_data(op_data);
+	/*
+	 * If the MDS allows the client to chgrp (CFS_SETGRP_PERM), but the
+	 * client does not know which suppgid should be sent to the MDS, or
+	 * some other(s) changed the target file's GID after this RPC sent
+	 * to the MDS with the suppgid as the original GID, then we should
+	 * try again with right suppgid.
+	 */
+	if (rc == -EACCES && it->it_op & IT_OPEN &&
+	    it_disposition(it, DISP_OPEN_DENY)) {
+		struct mdt_body *body;
+
+		LASSERT(req);
+
+		body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
+		if (op_data->op_suppgids[0] == body->mbo_gid ||
+		    op_data->op_suppgids[1] == body->mbo_gid ||
+		    !in_group_p(make_kgid(&init_user_ns, body->mbo_gid))) {
+			retval = ERR_PTR(-EACCES);
+			goto out;
+		}
+
+		fid_zero(&op_data->op_fid2);
+		op_data->op_suppgids[1] = body->mbo_gid;
+		ptlrpc_req_finished(req);
+		req = NULL;
+		ll_intent_release(it);
+		rc = md_intent_lock(ll_i2mdexp(parent), op_data, it, &req,
+				    ll_md_blocking_ast, 0);
+	}
+
 	if (rc < 0) {
 		retval = ERR_PTR(rc);
 		goto out;
@@ -575,6 +604,9 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 	else
 		retval = dentry;
 out:
+	if (op_data && !IS_ERR(op_data))
+		ll_finish_md_op_data(op_data);
+
 	ptlrpc_req_finished(req);
 	return retval;
 }
-- 
1.7.1
