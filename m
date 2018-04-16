From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Apr 2018 00:14:51 -0400
Subject: [lustre-devel] [PATCH 02/22] staging: lustre: obd: create
 it_has_reply_body()
In-Reply-To: <1523852111-17321-1-git-send-email-jsimmons@infradead.org>
References: <1523852111-17321-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1523852111-17321-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Vitaly Fertman <vitaly.fertman@seagate.com>, Lustre Development List <lustre-devel@lists.lustre.org>

From: Vitaly Fertman <vitaly.fertman@seagate.com>

The lookup_intent it_op fields in many cases will be compared
to the settings of IT_OPEN | IT_UNLINK | IT_LOOKUP | IT_GETATTR.
Create a simple inline function for this common case.

Signed-off-by: Vitaly Fertman <vitaly.fertman@seagate.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7433
Seagate-bug-id: MRP-3072 MRP-3137
Reviewed-on: http://review.whamcloud.com/17220
Reviewed-by: Andrew Perepechko <andrew.perepechko@seagate.com>
Reviewed-by: Andriy Skulysh <andriy.skulysh@seagate.com>
Tested-by: Elena V. Gryaznova <elena.gryaznova@seagate.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h   | 10 ++++++++++
 drivers/staging/lustre/lustre/mdc/mdc_locks.c |  2 +-
 2 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index f1233ca..ea6056b 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -686,6 +686,16 @@ enum md_cli_flags {
 	CLI_MIGRATE	= BIT(4),
 };
 
+/**
+ * GETXATTR is not included as only a couple of fields in the reply body
+ * is filled, but not FID which is needed for common intent handling in
+ * mdc_finish_intent_lock()
+ */
+static inline bool it_has_reply_body(const struct lookup_intent *it)
+{
+	return it->it_op & (IT_OPEN | IT_UNLINK | IT_LOOKUP | IT_GETATTR);
+}
+
 struct md_op_data {
 	struct lu_fid	   op_fid1; /* operation fid1 (usually parent) */
 	struct lu_fid	   op_fid2; /* operation fid2 (usually child) */
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index 695ef44..309ead1 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -568,7 +568,7 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 		  it->it_op, it->it_disposition, it->it_status);
 
 	/* We know what to expect, so we do any byte flipping required here */
-	if (it->it_op & (IT_OPEN | IT_UNLINK | IT_LOOKUP | IT_GETATTR)) {
+	if (it_has_reply_body(it)) {
 		struct mdt_body *body;
 
 		body = req_capsule_server_get(pill, &RMF_MDT_BODY);
-- 
1.8.3.1
