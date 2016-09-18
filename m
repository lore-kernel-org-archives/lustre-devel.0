From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:26 -0400
Subject: [lustre-devel] [PATCH 087/124] staging: lustre: ptlrpc: Suppress
	error message when imp_sec is freed
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-88-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Amir Shehata <amir.shehata@intel.com>, James Simmons <jsimmons@infradead.org>

From: Amir Shehata <amir.shehata@intel.com>

There is a race condition on client reconnect when the import
is being destroyed.  Some outstanding client bound requests
are being processed when the imp_sec has alread been freed.
Ensure to suppress the error message in import_sec_validate_get()
in that case

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3353
Reviewed-on: http://review.whamcloud.com/10200
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/sec.c |   19 +++++++++++++++++--
 1 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec.c b/drivers/staging/lustre/lustre/ptlrpc/sec.c
index 523579f..5d3995d 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec.c
@@ -311,6 +311,19 @@ static int import_sec_check_expire(struct obd_import *imp)
 	return sptlrpc_import_sec_adapt(imp, NULL, NULL);
 }
 
+/**
+ * Get and validate the client side ptlrpc security facilities from
+ * \a imp. There is a race condition on client reconnect when the import is
+ * being destroyed while there are outstanding client bound requests. In
+ * this case do not output any error messages if import secuity is not
+ * found.
+ *
+ * \param[in] imp obd import associated with client
+ * \param[out] sec client side ptlrpc security
+ *
+ * \retval 0 if security retrieved successfully
+ * \retval -ve errno if there was a problem
+ */
 static int import_sec_validate_get(struct obd_import *imp,
 				   struct ptlrpc_sec **sec)
 {
@@ -323,9 +336,11 @@ static int import_sec_validate_get(struct obd_import *imp,
 	}
 
 	*sec = sptlrpc_import_sec_ref(imp);
+	/* Only output an error when the import is still active */
 	if (!*sec) {
-		CERROR("import %p (%s) with no sec\n",
-		       imp, ptlrpc_import_state_name(imp->imp_state));
+		if (list_empty(&imp->imp_zombie_chain))
+			CERROR("import %p (%s) with no sec\n",
+			       imp, ptlrpc_import_state_name(imp->imp_state));
 		return -EACCES;
 	}
 
-- 
1.7.1
