From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Oct 2016 18:12:03 -0400
Subject: [lustre-devel] [PATCH 29/29] staging: lustre: llog: record the
	minimum record size
In-Reply-To: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
References: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1477606323-30325-30-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

The minimum record size will be recorded in llh_size, which is
only used by fixed size record llog now, and also add another
flag LLOG_F_IS_FIXSIZE to indicate the fix size record llog.

Signed-off-by: wang di <di.wang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7050
Reviewed-on: http://review.whamcloud.com/16103
Reviewed-by: Mike Pershin <mike.pershin@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |    7 +++++++
 drivers/staging/lustre/lustre/obdclass/llog.c      |    1 +
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 6896c37..db09f3b 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -3020,7 +3020,14 @@ enum llog_flag {
 	LLOG_F_IS_CAT		= 0x2,
 	LLOG_F_IS_PLAIN		= 0x4,
 	LLOG_F_EXT_JOBID        = BIT(3),
+	LLOG_F_IS_FIXSIZE	= BIT(4),
 
+	/*
+	 * Note: Flags covered by LLOG_F_EXT_MASK will be inherited from
+	 * catlog to plain log, so do not add LLOG_F_IS_FIXSIZE here,
+	 * because the catlog record is usually fixed size, but its plain
+	 * log record can be variable
+	 */
 	LLOG_F_EXT_MASK = LLOG_F_EXT_JOBID,
 };
 
diff --git a/drivers/staging/lustre/lustre/obdclass/llog.c b/drivers/staging/lustre/lustre/obdclass/llog.c
index 5c9447e..3bc1789 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog.c
@@ -193,6 +193,7 @@ int llog_init_handle(const struct lu_env *env, struct llog_handle *handle,
 		LASSERT(list_empty(&handle->u.chd.chd_head));
 		INIT_LIST_HEAD(&handle->u.chd.chd_head);
 		llh->llh_size = sizeof(struct llog_logid_rec);
+		llh->llh_flags |= LLOG_F_IS_FIXSIZE;
 	} else if (!(flags & LLOG_F_IS_PLAIN)) {
 		CERROR("%s: unknown flags: %#x (expected %#x or %#x)\n",
 		       handle->lgh_ctxt->loc_obd->obd_name,
-- 
1.7.1
