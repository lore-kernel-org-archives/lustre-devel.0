From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:43 -0500
Subject: [lustre-devel] [PATCH 595/622] lustre: llite: eviction during
 ll_open_cleanup()
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-596-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andriy Skulysh <c17819@cray.com>

On error ll_open_cleanup() is called while
intent lock remains pinned. So eviction can
happen while close request waits for a mod rpc slot.

Release intent lock before ll_open_cleanup()

Cray-bug-id: LUS-8055
WC-bug-id: https://jira.whamcloud.com/browse/LU-13101
Lustre-commit: 6d5d7c6bdb4f ("LU-13101 llite: eviction during ll_open_cleanup()")
Signed-off-by: Andriy Skulysh <c17819@cray.com>
Reviewed-by: Alexander Boyko <c17825@cray.com>
Reviewed-by: Andrew Perepechko <c17827@cray.com>
Reviewed-by: Vitaly Fertman <c17818@cray.com>
Reviewed-on: https://review.whamcloud.com/37096
Reviewed-by: Alexandr Boyko <c17825@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_lib.c | 4 +++-
 fs/lustre/llite/namei.c     | 4 +++-
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 1a8a5ec..33ab3f7 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -2507,8 +2507,10 @@ int ll_prep_inode(struct inode **inode, struct ptlrpc_request *req,
 	/* cleanup will be done if necessary */
 	md_free_lustre_md(sbi->ll_md_exp, &md);
 
-	if (rc != 0 && it && it->it_op & IT_OPEN)
+	if (rc != 0 && it && it->it_op & IT_OPEN) {
+		ll_intent_drop_lock(it);
 		ll_open_cleanup(sb ? sb : (*inode)->i_sb, req);
+	}
 
 	return rc;
 }
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 13c1cf9..89317db 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -709,8 +709,10 @@ static int ll_lookup_it_finish(struct ptlrpc_request *request,
 	}
 
 out:
-	if (rc != 0 && it->it_op & IT_OPEN)
+	if (rc != 0 && it->it_op & IT_OPEN) {
+		ll_intent_drop_lock(it);
 		ll_open_cleanup((*de)->d_sb, request);
+	}
 
 	return rc;
 }
-- 
1.8.3.1
