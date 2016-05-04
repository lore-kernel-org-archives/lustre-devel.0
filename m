From: James Simmons <jsimmons@infradead.org>
Date: Wed,  4 May 2016 10:28:52 -0400
Subject: [lustre-devel] [PATCH 1/9] staging: lustre: nfs: don't panic NFS
	server if MDS fails to find FID
In-Reply-To: <1462372140-27880-1-git-send-email-jsimmons@infradead.org>
References: <1462372140-27880-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1462372140-27880-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bobi Jam <bobijam.xu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Bobi Jam <bobijam.xu@intel.com>

When MDS fails to retrive the parent's fid, we'd handle it without
crashing the NFS server.

Signed-off-by: Bobi Jam <bobijam.xu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3952
Reviewed-on: http://review.whamcloud.com/8459
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: wangdi <di.wang@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/llite_nfs.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_nfs.c b/drivers/staging/lustre/lustre/llite/llite_nfs.c
index 61cb5ff..c1eef61 100644
--- a/drivers/staging/lustre/lustre/llite/llite_nfs.c
+++ b/drivers/staging/lustre/lustre/llite/llite_nfs.c
@@ -322,11 +322,14 @@ static struct dentry *ll_get_parent(struct dentry *dchild)
 		return ERR_PTR(rc);
 	}
 	body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
-	LASSERT(body->valid & OBD_MD_FLID);
-
-	CDEBUG(D_INFO, "parent for " DFID " is " DFID "\n",
-	       PFID(ll_inode2fid(dir)), PFID(&body->fid1));
-
+	/*
+	 * LU-3952: MDT may lost the FID of its parent, we should not crash
+	 * the NFS server, ll_iget_for_nfs() will handle the error.
+	 */
+	if (body->valid & OBD_MD_FLID) {
+		CDEBUG(D_INFO, "parent for " DFID " is " DFID "\n",
+		       PFID(ll_inode2fid(dir)), PFID(&body->fid1));
+	}
 	result = ll_iget_for_nfs(dir->i_sb, &body->fid1, NULL);
 
 	ptlrpc_req_finished(req);
-- 
2.7.4
