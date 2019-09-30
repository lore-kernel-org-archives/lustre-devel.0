From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:47 -0400
Subject: [lustre-devel] [PATCH 148/151] lustre: ptlrpc: discard a
 server-only waitq.
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-149-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

This is needed on the client.  The server should probably
be used wait_var_event() / wake_up_var().

Signed-off-by: NeilBrown <neilb@suse.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h | 1 -
 fs/lustre/ptlrpc/client.c      | 1 -
 2 files changed, 2 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index 8024367..23cd565 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -1235,7 +1235,6 @@ struct ptlrpc_bulk_desc {
 	/** Back pointer to the request */
 	struct ptlrpc_request		*bd_req;
 	const struct ptlrpc_bulk_frag_ops *bd_frag_ops;
-	wait_queue_head_t		bd_waitq;     /* server side only WQ */
 	int				bd_iov_count; /* # entries in bd_iov */
 	int				bd_max_iov;   /* allocated size of bd_iov */
 	int				bd_nob;	      /* # bytes covered */
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index 6086770..69c14d2 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -166,7 +166,6 @@ struct ptlrpc_bulk_desc *ptlrpc_new_bulk(unsigned int nfrags,
 	}
 
 	spin_lock_init(&desc->bd_lock);
-	init_waitqueue_head(&desc->bd_waitq);
 	desc->bd_max_iov = nfrags;
 	desc->bd_iov_count = 0;
 	desc->bd_portal = portal;
-- 
1.8.3.1
