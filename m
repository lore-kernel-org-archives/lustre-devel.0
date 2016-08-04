From: James Simmons <jsimmons@infradead.org>
Date: Thu,  4 Aug 2016 12:53:01 -0400
Subject: [lustre-devel] [PATCH 25/32] staging: lustre: llog: keep llog ctxt
	indices constant
In-Reply-To: <1470329587-18768-1-git-send-email-jsimmons@infradead.org>
References: <1470329587-18768-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1470329587-18768-26-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Mikhail Pershin <mike.pershin@intel.com>, James Simmons <jsimmons@infradead.org>

From: Mikhail Pershin <mike.pershin@intel.com>

The llog context id table cannot be shrunk easily because that
will cause index shifting and incompatibility between old client
and new server and vice versa.

Patch moves llog_ctxt_id table to the lustre_idl.h because this is
wire protocol data, these values are added to the wirecheck.

Signed-off-by: Mikhail Pershin <mike.pershin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5218
Reviewed-on: http://review.whamcloud.com/10758
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |   24 +++++++++++++++++++-
 drivers/staging/lustre/lustre/include/obd.h        |   21 -----------------
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |   13 ++++++++++
 3 files changed, 36 insertions(+), 22 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 4a7ccc8..05fe359 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -2936,7 +2936,29 @@ enum obd_cmd {
 };
 #define OBD_FIRST_OPC OBD_PING
 
-/* catalog of log objects */
+/**
+ * llog contexts indices.
+ *
+ * There is compatibility problem with indexes below, they are not
+ * continuous and must keep their numbers for compatibility needs.
+ * See LU-5218 for details.
+ */
+enum llog_ctxt_id {
+	LLOG_CONFIG_ORIG_CTXT  =  0,
+	LLOG_CONFIG_REPL_CTXT = 1,
+	LLOG_MDS_OST_ORIG_CTXT = 2,
+	LLOG_MDS_OST_REPL_CTXT = 3, /* kept just to avoid re-assignment */
+	LLOG_SIZE_ORIG_CTXT = 4,
+	LLOG_SIZE_REPL_CTXT = 5,
+	LLOG_TEST_ORIG_CTXT = 8,
+	LLOG_TEST_REPL_CTXT = 9, /* kept just to avoid re-assignment */
+	LLOG_CHANGELOG_ORIG_CTXT = 12, /**< changelog generation on mdd */
+	LLOG_CHANGELOG_REPL_CTXT = 13, /**< changelog access on clients */
+	/* for multiple changelog consumers */
+	LLOG_CHANGELOG_USER_ORIG_CTXT = 14,
+	LLOG_AGENT_ORIG_CTXT = 15, /**< agent requests generation on cdt */
+	LLOG_MAX_CTXTS
+};
 
 /** Identifier for a single log object */
 struct llog_logid {
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index b7bdd07..e7e03be 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -172,27 +172,6 @@ struct brw_page {
 	u32 flag;
 };
 
-/* llog contexts */
-enum llog_ctxt_id {
-	LLOG_CONFIG_ORIG_CTXT  =  0,
-	LLOG_CONFIG_REPL_CTXT,
-	LLOG_MDS_OST_ORIG_CTXT,
-	LLOG_MDS_OST_REPL_CTXT,
-	LLOG_SIZE_ORIG_CTXT,
-	LLOG_SIZE_REPL_CTXT,
-	LLOG_RD1_ORIG_CTXT,
-	LLOG_RD1_REPL_CTXT,
-	LLOG_TEST_ORIG_CTXT,
-	LLOG_TEST_REPL_CTXT,
-	LLOG_LOVEA_ORIG_CTXT,
-	LLOG_LOVEA_REPL_CTXT,
-	LLOG_CHANGELOG_ORIG_CTXT,	/**< changelog generation on mdd */
-	LLOG_CHANGELOG_REPL_CTXT,	/**< changelog access on clients */
-	LLOG_CHANGELOG_USER_ORIG_CTXT,	/**< for multiple changelog consumers */
-	LLOG_AGENT_ORIG_CTXT,		/**< agent requests generation on cdt */
-	LLOG_MAX_CTXTS
-};
-
 struct timeout_item {
 	enum timeout_event ti_event;
 	unsigned long	 ti_timeout;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index 2c718e0..31d3326 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -3483,6 +3483,19 @@ void lustre_assert_wire_constants(void)
 	CLASSERT(LLOG_ORIGIN_HANDLE_DESTROY == 509);
 	CLASSERT(LLOG_FIRST_OPC == 501);
 	CLASSERT(LLOG_LAST_OPC == 510);
+	CLASSERT(LLOG_CONFIG_ORIG_CTXT == 0);
+	CLASSERT(LLOG_CONFIG_REPL_CTXT == 1);
+	CLASSERT(LLOG_MDS_OST_ORIG_CTXT == 2);
+	CLASSERT(LLOG_MDS_OST_REPL_CTXT == 3);
+	CLASSERT(LLOG_SIZE_ORIG_CTXT == 4);
+	CLASSERT(LLOG_SIZE_REPL_CTXT == 5);
+	CLASSERT(LLOG_TEST_ORIG_CTXT == 8);
+	CLASSERT(LLOG_TEST_REPL_CTXT == 9);
+	CLASSERT(LLOG_CHANGELOG_ORIG_CTXT == 12);
+	CLASSERT(LLOG_CHANGELOG_REPL_CTXT == 13);
+	CLASSERT(LLOG_CHANGELOG_USER_ORIG_CTXT == 14);
+	CLASSERT(LLOG_AGENT_ORIG_CTXT == 15);
+	CLASSERT(LLOG_MAX_CTXTS == 16);
 
 	/* Checks for struct llogd_conn_body */
 	LASSERTF((int)sizeof(struct llogd_conn_body) == 40, "found %lld\n",
-- 
1.7.1
