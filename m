From: James Simmons <jsimmons@infradead.org>
Date: Sun, 21 Jul 2019 22:12:15 -0400
Subject: [lustre-devel] [PATCH 03/10] lustre: ptlrpc: make
 ptlrpc_bulk_frag_ops always const.
In-Reply-To: <1563761542-3708-1-git-send-email-jsimmons@infradead.org>
References: <1563761542-3708-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1563761542-3708-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

There is one place where a non-const pointer to this struct
exists, and that causes a cast to be required.

Make it always const, and discard the cast.

Signed-off-by: NeilBrown <neilb@suse.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-4423
Reviewed-on: https://review.whamcloud.com/35295
Reviewed-by: Petros Koutoupis <pkoutoupis@cray.com>
Reviewed-by: Shaun Tancheff <stancheff@cray.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h | 2 +-
 fs/lustre/ptlrpc/client.c      | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index 1cf0f12..83f8aff 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -1222,7 +1222,7 @@ struct ptlrpc_bulk_desc {
 	struct obd_import		*bd_import;
 	/** Back pointer to the request */
 	struct ptlrpc_request		*bd_req;
-	struct ptlrpc_bulk_frag_ops	*bd_frag_ops;
+	const struct ptlrpc_bulk_frag_ops *bd_frag_ops;
 	wait_queue_head_t		bd_waitq;     /* server side only WQ */
 	int				bd_iov_count; /* # entries in bd_iov */
 	int				bd_max_iov;   /* allocated size of bd_iov */
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index 364c61f..ff1fa68 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -150,7 +150,7 @@ struct ptlrpc_bulk_desc *ptlrpc_new_bulk(unsigned int nfrags,
 	desc->bd_portal = portal;
 	desc->bd_type = type;
 	desc->bd_md_count = 0;
-	desc->bd_frag_ops = (struct ptlrpc_bulk_frag_ops *)ops;
+	desc->bd_frag_ops = ops;
 	LASSERT(max_brw > 0);
 	desc->bd_md_max_brw = min(max_brw, PTLRPC_BULK_OPS_COUNT);
 	/*
-- 
1.8.3.1
