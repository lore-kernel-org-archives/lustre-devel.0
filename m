From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:04:58 -0500
Subject: [lustre-devel] [PATCH 30/60] staging: lustre: ptlrpc: comment for
	FLD_QUERY RPC reply swab
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-31-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Fan Yong <fan.yong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Fan Yong <fan.yong@intel.com>

The 'fld_read_server' uses 'RMF_GENERIC_DATA' to hold the 'FLD_QUERY'
RPC reply that is composed of 'struct lu_seq_range_array'. But there
is not registered swabber function for 'RMF_GENERIC_DATA'. So the RPC
peers need to handle the RPC reply with fixed little-endian format.

In theory, we can define new structure with some swabber registered
to handle the 'FLD_QUERY' RPC reply result automatically. But from
the implementation view, it is not easy to be done within current
'struct req_msg_field' framework. Because the sequence range array
in the RPC reply is not fixed length, instead, its length depends
on 'lu_seq_range' count, that is unknown when prepare the RPC buffer.
Generally, for such flexible length RPC usage, there will be a field
in the RPC layout to indicate the data length. But for the 'FLD_READ'
RPC, we have no way to do that unless we add new length filed that
will broken the on-wire RPC protocol and cause interoperability
trouble with old peer.

Signed-off-by: Fan Yong <fan.yong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6284
Reviewed-on: http://review.whamcloud.com/22309
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/layout.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/layout.c b/drivers/staging/lustre/lustre/ptlrpc/layout.c
index 99d7c66..2052848 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/layout.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/layout.c
@@ -1181,6 +1181,23 @@ struct req_format RQF_FLD_QUERY =
 	DEFINE_REQ_FMT0("FLD_QUERY", fld_query_client, fld_query_server);
 EXPORT_SYMBOL(RQF_FLD_QUERY);
 
+/*
+ * The 'fld_read_server' uses 'RMF_GENERIC_DATA' to hold the 'FLD_QUERY'
+ * RPC reply that is composed of 'struct lu_seq_range_array'. But there
+ * is not registered swabber function for 'RMF_GENERIC_DATA'. So the RPC
+ * peers need to handle the RPC reply with fixed little-endian format.
+ *
+ * In theory, we can define new structure with some swabber registered to
+ * handle the 'FLD_QUERY' RPC reply result automatically. But from the
+ * implementation view, it is not easy to be done within current "struct
+ * req_msg_field" framework. Because the sequence range array in the RPC
+ * reply is not fixed length, instead, its length depends on 'lu_seq_range'
+ * count, that is unknown when prepare the RPC buffer. Generally, for such
+ * flexible length RPC usage, there will be a field in the RPC layout to
+ * indicate the data length. But for the 'FLD_READ' RPC, we have no way to
+ * do that unless we add new length filed that will broken the on-wire RPC
+ * protocol and cause interoperability trouble with old peer.
+ */
 struct req_format RQF_FLD_READ =
 	DEFINE_REQ_FMT0("FLD_READ", fld_read_client, fld_read_server);
 EXPORT_SYMBOL(RQF_FLD_READ);
-- 
1.8.3.1
