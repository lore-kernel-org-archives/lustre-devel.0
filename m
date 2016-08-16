From: James Simmons <jsimmons@infradead.org>
Date: Tue, 16 Aug 2016 16:19:27 -0400
Subject: [lustre-devel] [PATCH 74/80] staging: lustre: obd: implement
	md_read_page
In-Reply-To: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1471378773-24590-75-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

This patch adds md_read_page which is a new more
flexiable api that will replace md_readpage.

Signed-off-by: wang di <di.wang@intel.com>
Reviewed-on: http://review.whamcloud.com/10761
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4906
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h       |   13 ++++++++++++-
 drivers/staging/lustre/lustre/include/obd_class.h |   15 +++++++++++++++
 2 files changed, 27 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index e91f65a..92eebff 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -830,6 +830,15 @@ struct md_op_data {
 	struct lustre_handle	op_lease_handle;
 };
 
+#define op_stripe_offset       op_ioepoch
+#define op_max_pages           op_valid
+
+struct md_callback {
+	int (*md_blocking_ast)(struct ldlm_lock *lock,
+			       struct ldlm_lock_desc *desc,
+			       void *data, int flag);
+};
+
 enum op_cli_flags {
 	CLI_SET_MEA	= 1 << 0,
 	CLI_RM_ENTRY	= 1 << 1,
@@ -1039,7 +1048,9 @@ struct md_ops {
 		    struct ptlrpc_request **);
 	int (*readpage)(struct obd_export *, struct md_op_data *,
 			struct page **, struct ptlrpc_request **);
-
+	int (*read_page)(struct obd_export *, struct md_op_data *,
+			 struct md_callback *cb_op, __u64 hash_offset,
+			 struct page **ppage);
 	int (*unlink)(struct obd_export *, struct md_op_data *,
 		      struct ptlrpc_request **);
 
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 69b628b..daca5a0 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -1535,6 +1535,21 @@ static inline int md_readpage(struct obd_export *exp, struct md_op_data *opdata,
 	return rc;
 }
 
+static inline int md_read_page(struct obd_export *exp,
+			       struct md_op_data *op_data,
+			       struct md_callback *cb_op,
+			       __u64  hash_offset,
+			       struct page **ppage)
+{
+	int rc;
+
+	EXP_CHECK_MD_OP(exp, read_page);
+	EXP_MD_COUNTER_INCREMENT(exp, read_page);
+	rc = MDP(exp->exp_obd, read_page)(exp, op_data, cb_op, hash_offset,
+					  ppage);
+	return rc;
+}
+
 static inline int md_unlink(struct obd_export *exp, struct md_op_data *op_data,
 			    struct ptlrpc_request **request)
 {
-- 
1.7.1
