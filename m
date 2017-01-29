From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:04:59 -0500
Subject: [lustre-devel] [PATCH 31/60] staging: lustre: clio: sync write
	should update mtime
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-32-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Niu Yawei <yawei.niu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Niu Yawei <yawei.niu@intel.com>

Sync write should update m/ctime promptly, otherwise, stale m/ctime
could be updated on the OST object by the sync write RPC.

Signed-off-by: Niu Yawei <yawei.niu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7310
Reviewed-on: http://review.whamcloud.com/21063
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/osc/osc_io.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index 7e5cd3a..3e61f5e 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -210,6 +210,18 @@ static int osc_io_submit(const struct lu_env *env,
 	if (queued > 0)
 		result = osc_queue_sync_pages(env, osc, &list, cmd, brw_flags);
 
+	/* Update c/mtime for sync write. LU-7310 */
+	if (qout->pl_nr > 0 && !result) {
+		struct cl_attr *attr = &osc_env_info(env)->oti_attr;
+		struct cl_object *obj = ios->cis_obj;
+
+		cl_object_attr_lock(obj);
+		attr->cat_mtime = LTIME_S(CURRENT_TIME);
+		attr->cat_ctime = attr->cat_mtime;
+		cl_object_attr_update(env, obj, attr, CAT_MTIME | CAT_CTIME);
+		cl_object_attr_unlock(obj);
+	}
+
 	CDEBUG(D_INFO, "%d/%d %d\n", qin->pl_nr, qout->pl_nr, result);
 	return qout->pl_nr > 0 ? 0 : result;
 }
-- 
1.8.3.1
