From: Oleg Drokin <green@linuxhacker.ru>
Date: Sun, 19 Jun 2016 22:07:34 -0400
Subject: [lustre-devel] [PATCH 19/28] staging/lustre/llite: ensure obd is
	effective in onu_upcall
In-Reply-To: <1466388463-1817551-1-git-send-email-green@linuxhacker.ru>
References: <1466388463-1817551-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1466388463-1817551-20-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Yang Sheng <yang.sheng@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Yang Sheng <yang.sheng@intel.com>

The watched obd device may still not setup while onu_upcall
invoked. So we need verify it in cl_ocd_update.

Signed-off-by: Yang Sheng <yang.sheng@intel.com>
Reviewed-on: http://review.whamcloud.com/19597
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8027
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/lcommon_misc.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/lcommon_misc.c b/drivers/staging/lustre/lustre/llite/lcommon_misc.c
index 8a508ed..f6be105 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_misc.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_misc.c
@@ -96,7 +96,8 @@ int cl_ocd_update(struct obd_device *host,
 	__u64 flags;
 	int   result;
 
-	if (!strcmp(watched->obd_type->typ_name, LUSTRE_OSC_NAME)) {
+	if (!strcmp(watched->obd_type->typ_name, LUSTRE_OSC_NAME) &&
+	    watched->obd_set_up && !watched->obd_stopping) {
 		cli = &watched->u.cli;
 		lco = owner;
 		flags = cli->cl_import->imp_connect_data.ocd_connect_flags;
@@ -111,9 +112,10 @@ int cl_ocd_update(struct obd_device *host,
 		mutex_unlock(&lco->lco_lock);
 		result = 0;
 	} else {
-		CERROR("unexpected notification from %s %s!\n",
+		CERROR("unexpected notification from %s %s (setup:%d,stopping:%d)!\n",
 		       watched->obd_type->typ_name,
-		       watched->obd_name);
+		       watched->obd_name, watched->obd_set_up,
+		       watched->obd_stopping);
 		result = -EINVAL;
 	}
 	return result;
-- 
2.7.4
