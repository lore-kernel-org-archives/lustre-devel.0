From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:29 -0500
Subject: [lustre-devel] [PATCH 461/622] lustre: ptlrpc: remove
 bd_import_generation field.
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-462-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.com>

This field is set, but never accessed. So remove it.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: 531bbc669d66 ("LU-6142 ptlrpc: remove bd_import_generation field.")
Signed-off-by: Mr NeilBrown <neilb@suse.com>
Reviewed-on: https://review.whamcloud.com/35880
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Shaun Tancheff <stancheff@cray.com>
Reviewed-by: Arshad Hussain <arshad.super@gmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h | 2 --
 fs/lustre/ptlrpc/client.c      | 1 -
 2 files changed, 3 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index faf15e9..bec92cf 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -1251,8 +1251,6 @@ struct ptlrpc_bulk_desc {
 	unsigned long			bd_registered:1;
 	/** For serialization with callback */
 	spinlock_t			bd_lock;
-	/** Import generation when request for this bulk was sent */
-	int				bd_import_generation;
 	/** {put,get}{source,sink}{kvec,kiov} */
 	enum ptlrpc_bulk_op_type	bd_type;
 	/** LNet portal for this bulk */
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index d2e5e04..478ba85 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -210,7 +210,6 @@ struct ptlrpc_bulk_desc *ptlrpc_prep_bulk_imp(struct ptlrpc_request *req,
 	if (!desc)
 		return NULL;
 
-	desc->bd_import_generation = req->rq_import_generation;
 	desc->bd_import = class_import_get(imp);
 	desc->bd_req = req;
 
-- 
1.8.3.1
