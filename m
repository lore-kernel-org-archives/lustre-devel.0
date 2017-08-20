From: James Simmons <jsimmons@infradead.org>
Date: Sat, 19 Aug 2017 22:26:14 -0400
Subject: [lustre-devel] [PATCH 20/64 v2] staging: lustre: uapi: style
	cleanups for lustre_param.h
In-Reply-To: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
References: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1503196018-24500-21-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Remove the white space in the lustre_param.h header and
align the code so its easier to read.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6401
Reviewed-on: https://review.whamcloud.com/24325
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../include/uapi/linux/lustre/lustre_param.h       | 67 +++++++++++-----------
 1 file changed, 34 insertions(+), 33 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_param.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_param.h
index cab0056..1eab2ce 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_param.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_param.h
@@ -44,49 +44,50 @@
 
 /****************** User-settable parameter keys *********************/
 /* e.g.
-	tunefs.lustre --param="failover.node=192.168.0.13 at tcp0" /dev/sda
-	lctl conf_param testfs-OST0000 failover.node=3 at elan,192.168.0.3 at tcp0
-		    ... testfs-MDT0000.lov.stripesize=4M
-		    ... testfs-OST0000.ost.client_cache_seconds=15
-		    ... testfs.sys.timeout=<secs>
-		    ... testfs.llite.max_read_ahead_mb=16
-*/
+ *	tunefs.lustre --param="failover.node=192.168.0.13 at tcp0" /dev/sda
+ *	lctl conf_param testfs-OST0000 failover.node=3 at elan,192.168.0.3 at tcp0
+ *		    ... testfs-MDT0000.lov.stripesize=4M
+ *		    ... testfs-OST0000.ost.client_cache_seconds=15
+ *		    ... testfs.sys.timeout=<secs>
+ *		    ... testfs.llite.max_read_ahead_mb=16
+ */
 
 /* System global or special params not handled in obd's proc
  * See mgs_write_log_sys()
  */
-#define PARAM_TIMEOUT	      "timeout="	  /* global */
-#define PARAM_LDLM_TIMEOUT	 "ldlm_timeout="     /* global */
-#define PARAM_AT_MIN	       "at_min="	   /* global */
-#define PARAM_AT_MAX	       "at_max="	   /* global */
-#define PARAM_AT_EXTRA	     "at_extra="	 /* global */
-#define PARAM_AT_EARLY_MARGIN      "at_early_margin="  /* global */
-#define PARAM_AT_HISTORY	   "at_history="       /* global */
-#define PARAM_JOBID_VAR		   "jobid_var="	       /* global */
-#define PARAM_MGSNODE	      "mgsnode="	  /* only at mounttime */
-#define PARAM_FAILNODE	     "failover.node="    /* add failover nid */
-#define PARAM_FAILMODE	     "failover.mode="    /* initial mount only */
-#define PARAM_ACTIVE	       "active="	   /* activate/deactivate */
-#define PARAM_NETWORK	      "network="	  /* bind on nid */
-#define PARAM_ID_UPCALL		"identity_upcall="  /* identity upcall */
+#define PARAM_TIMEOUT		"timeout="	   /* global */
+#define PARAM_LDLM_TIMEOUT	"ldlm_timeout="	   /* global */
+#define PARAM_AT_MIN		"at_min="	   /* global */
+#define PARAM_AT_MAX		"at_max="	   /* global */
+#define PARAM_AT_EXTRA		"at_extra="	   /* global */
+#define PARAM_AT_EARLY_MARGIN	"at_early_margin=" /* global */
+#define PARAM_AT_HISTORY	"at_history="	   /* global */
+#define PARAM_JOBID_VAR		"jobid_var="	   /* global */
+#define PARAM_MGSNODE		"mgsnode="	   /* only at mounttime */
+#define PARAM_FAILNODE		"failover.node="   /* add failover nid */
+#define PARAM_FAILMODE		"failover.mode="   /* initial mount only */
+#define PARAM_ACTIVE		"active="	   /* activate/deactivate */
+#define PARAM_NETWORK		"network="	   /* bind on nid */
+#define PARAM_ID_UPCALL		"identity_upcall=" /* identity upcall */
 
 /* Prefixes for parameters handled by obd's proc methods (XXX_process_config) */
-#define PARAM_OST		  "ost."
+#define PARAM_OST		"ost."
 #define PARAM_OSD		"osd."
-#define PARAM_OSC		  "osc."
-#define PARAM_MDT		  "mdt."
-#define PARAM_MDD		  "mdd."
-#define PARAM_MDC		  "mdc."
+#define PARAM_OSC		"osc."
+#define PARAM_MDT		"mdt."
+#define PARAM_HSM		"mdt.hsm."
+#define PARAM_MDD		"mdd."
+#define PARAM_MDC		"mdc."
 #define PARAM_LLITE		"llite."
-#define PARAM_LOV		  "lov."
+#define PARAM_LOV		"lov."
 #define PARAM_LOD		"lod."
 #define PARAM_OSP		"osp."
-#define PARAM_SYS		  "sys."	      /* global */
-#define PARAM_SRPC		 "srpc."
-#define PARAM_SRPC_FLVR	    "srpc.flavor."
-#define PARAM_SRPC_UDESC	   "srpc.udesc.cli2mdt"
-#define PARAM_SEC		  "security."
-#define PARAM_QUOTA		"quota."	    /* global */
+#define PARAM_SYS		"sys."		/* global */
+#define PARAM_SRPC		"srpc."
+#define PARAM_SRPC_FLVR		"srpc.flavor."
+#define PARAM_SRPC_UDESC	"srpc.udesc.cli2mdt"
+#define PARAM_SEC		"security."
+#define PARAM_QUOTA		"quota."	/* global */
 
 /** @} param */
 
-- 
1.8.3.1
