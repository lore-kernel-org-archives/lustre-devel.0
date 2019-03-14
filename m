From: NeilBrown <neilb@suse.com>
Date: Thu, 14 Mar 2019 11:11:48 +1100
Subject: [lustre-devel] [PATCH 03/32] lustre: ptlrpc: make
 ptlrpc_bulk_frag_ops always const.
In-Reply-To: <155252182126.26912.1842463462595601611.stgit@noble.brown>
References: <155252182126.26912.1842463462595601611.stgit@noble.brown>
Message-ID: <155252230877.26912.4034098065399872858.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

There is one place where a non-const pointer to this struct
exists, and that causes a cast to be required.

Make it always const, and discard the cast.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/lustre_net.h |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/client.c      |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index bb251769bf72..430ad8bb2226 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -1222,7 +1222,7 @@ struct ptlrpc_bulk_desc {
 	struct obd_import		*bd_import;
 	/** Back pointer to the request */
 	struct ptlrpc_request		*bd_req;
-	struct ptlrpc_bulk_frag_ops	*bd_frag_ops;
+	const struct ptlrpc_bulk_frag_ops *bd_frag_ops;
 	wait_queue_head_t		bd_waitq;     /* server side only WQ */
 	int				bd_iov_count; /* # entries in bd_iov */
 	int				bd_max_iov;   /* allocated size of bd_iov */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 7170a2ce1bb6..c17fde56d004 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -150,7 +150,7 @@ struct ptlrpc_bulk_desc *ptlrpc_new_bulk(unsigned int nfrags,
 	desc->bd_portal = portal;
 	desc->bd_type = type;
 	desc->bd_md_count = 0;
-	desc->bd_frag_ops = (struct ptlrpc_bulk_frag_ops *)ops;
+	desc->bd_frag_ops = ops;
 	LASSERT(max_brw > 0);
 	desc->bd_md_max_brw = min(max_brw, PTLRPC_BULK_OPS_COUNT);
 	/*
