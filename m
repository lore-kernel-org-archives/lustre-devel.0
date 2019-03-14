From: NeilBrown <neilb@suse.com>
Date: Thu, 14 Mar 2019 11:11:50 +1100
Subject: [lustre-devel] [PATCH 21/32] lustre: ptlrpc: discard a server-only
 waitq.
In-Reply-To: <155252182126.26912.1842463462595601611.stgit@noble.brown>
References: <155252182126.26912.1842463462595601611.stgit@noble.brown>
Message-ID: <155252231091.26912.12605371247748026264.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This is needed on the client.  The server should probably
be used wait_var_event() / wake_up_var().

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/lustre_net.h |    1 -
 drivers/staging/lustre/lustre/ptlrpc/client.c      |    1 -
 2 files changed, 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index d14840b4aeb0..73d50fe39501 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -1209,7 +1209,6 @@ struct ptlrpc_bulk_desc {
 	/** Back pointer to the request */
 	struct ptlrpc_request		*bd_req;
 	const struct ptlrpc_bulk_frag_ops *bd_frag_ops;
-	wait_queue_head_t		bd_waitq;     /* server side only WQ */
 	int				bd_iov_count; /* # entries in bd_iov */
 	int				bd_max_iov;   /* allocated size of bd_iov */
 	int				bd_nob;	      /* # bytes covered */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index a148b1e54712..baf2b05e2f5c 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -155,7 +155,6 @@ struct ptlrpc_bulk_desc *ptlrpc_new_bulk(unsigned int nfrags,
 		goto free_desc;
 
 	spin_lock_init(&desc->bd_lock);
-	init_waitqueue_head(&desc->bd_waitq);
 	desc->bd_max_iov = nfrags;
 	desc->bd_iov_count = 0;
 	desc->bd_portal = portal;
