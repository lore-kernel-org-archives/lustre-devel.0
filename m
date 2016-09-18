From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:39 -0400
Subject: [lustre-devel] [PATCH 100/124] staging: lustre: obd: change type of
	cl_conn_count to size_t
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-101-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, James Simmons <jsimmons@infradead.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

Change type of cl_conn_count to size_t.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5577
Reviewed-on: http://review.whamcloud.com/13125
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h   |    2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 5f0f1e3..986c6e9 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -202,7 +202,7 @@ struct client_obd {
 	struct rw_semaphore  cl_sem;
 	struct obd_uuid	  cl_target_uuid;
 	struct obd_import       *cl_import; /* ptlrpc connection state */
-	int		      cl_conn_count;
+	size_t			 cl_conn_count;
 	/* max_mds_easize is purely a performance thing so we don't have to
 	 * call obd_size_diskmd() all the time.
 	 */
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
index 9a5f56a..153e990 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
@@ -536,7 +536,7 @@ int client_disconnect_export(struct obd_export *exp)
 	imp = cli->cl_import;
 
 	down_write(&cli->cl_sem);
-	CDEBUG(D_INFO, "disconnect %s - %d\n", obd->obd_name,
+	CDEBUG(D_INFO, "disconnect %s - %zu\n", obd->obd_name,
 	       cli->cl_conn_count);
 
 	if (!cli->cl_conn_count) {
-- 
1.7.1
