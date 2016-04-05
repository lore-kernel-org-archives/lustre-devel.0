From: James Simmons <jsimmons@infradead.org>
Date: Mon,  4 Apr 2016 21:36:57 -0400
Subject: [lustre-devel] [PATCH 12/18] staging: lustre: mdc: document
	mdc_rpc_lock
In-Reply-To: <1459820223-24754-1-git-send-email-jsimmons@infradead.org>
References: <1459820223-24754-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459820223-24754-13-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Ned Bass <bass6@llnl.gov>, James Simmons <jsimmons@infradead.org>

From: Ned Bass <bass6@llnl.gov>

As this lock can be a bottleneck, clarifying why it is needed may be
helpful to those working on client performance.

Signed-off-by: Ned Bass <bass6@llnl.gov>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3443
Reviewed-on: http://review.whamcloud.com/6593
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Keith Mannthey <keith.mannthey@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lustre_mdc.h |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_mdc.h b/drivers/staging/lustre/lustre/include/lustre_mdc.h
index df94f9f..9e54790 100644
--- a/drivers/staging/lustre/lustre/include/lustre_mdc.h
+++ b/drivers/staging/lustre/lustre/include/lustre_mdc.h
@@ -64,9 +64,27 @@ struct obd_export;
 struct ptlrpc_request;
 struct obd_device;
 
+/**
+ * Serializes in-flight MDT-modifying RPC requests to preserve idempotency.
+ *
+ * This mutex is used to implement execute-once semantics on the MDT.
+ * The MDT stores the last transaction ID and result for every client in
+ * its last_rcvd file. If the client doesn't get a reply, it can safely
+ * resend the request and the MDT will reconstruct the reply being aware
+ * that the request has already been executed. Without this lock,
+ * execution status of concurrent in-flight requests would be
+ * overwritten.
+ *
+ * This design limits the extent to which we can keep a full pipeline of
+ * in-flight requests from a single client.  This limitation could be
+ * overcome by allowing multiple slots per client in the last_rcvd file.
+ */
 struct mdc_rpc_lock {
+	/** Lock protecting in-flight RPC concurrency. */
 	struct mutex		rpcl_mutex;
+	/** Intent associated with currently executing request. */
 	struct lookup_intent	*rpcl_it;
+	/** Used for MDS/RPC load testing purposes. */
 	int			rpcl_fakes;
 };
 
-- 
1.7.1
