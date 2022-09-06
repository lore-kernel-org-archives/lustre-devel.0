Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id F25EFC6FA89
	for <lustre-devel@archiver.kernel.org>; Tue,  6 Sep 2022 01:56:13 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MM7ld3JsXz1y6D;
	Mon,  5 Sep 2022 18:56:13 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MM7lJ05y6z1y68
 for <lustre-devel@lists.lustre.org>; Mon,  5 Sep 2022 18:55:56 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id E168C100B034;
 Mon,  5 Sep 2022 21:55:39 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id E065958994; Mon,  5 Sep 2022 21:55:39 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  5 Sep 2022 21:55:33 -0400
Message-Id: <1662429337-18737-21-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1662429337-18737-1-git-send-email-jsimmons@infradead.org>
References: <1662429337-18737-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 20/24] lustre: obdclass: use consistent stats
 units
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Andreas Dilger <adilger@whamcloud.com>

Use consistent stats units, since some were "usec" and others "usecs".
Most stats already use LPROCFS_TYPE_* to encode type stats type, so
use this to provide units for those stats, and only explicitly provide
strings for the few stats that don't match the commonly-used units.
This also reduces the number of repeat static strings in the modules.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15642
Lustre-commit: b515c6ec2ab84598c ("LU-15642 obdclass: use consistent stats units")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/46833
Reviewed-by: Jian Yu <yujian@whamcloud.com>
Reviewed-by: Ben Evans <beevans@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lprocfs_status.h  | 27 +++++++++++-------
 fs/lustre/ldlm/ldlm_pool.c          | 34 ++++++++++++++--------
 fs/lustre/ldlm/ldlm_resource.c      |  3 +-
 fs/lustre/llite/lproc_llite.c       | 31 ++++++++------------
 fs/lustre/obdclass/lprocfs_status.c | 56 +++++++++++++++++++++++++++++++++----
 fs/lustre/obdclass/lu_object.c      | 17 ++++-------
 fs/lustre/ptlrpc/lproc_ptlrpc.c     | 32 ++++++++++-----------
 7 files changed, 122 insertions(+), 78 deletions(-)

diff --git a/fs/lustre/include/lprocfs_status.h b/fs/lustre/include/lprocfs_status.h
index 3e86e8e..5cea77d 100644
--- a/fs/lustre/include/lprocfs_status.h
+++ b/fs/lustre/include/lprocfs_status.h
@@ -126,18 +126,22 @@ struct rename_stats {
  * multiply per counter increment.
  */
 
-enum {
+enum lprocfs_counter_config {
 	LPROCFS_CNTR_EXTERNALLOCK	= 0x0001,
 	LPROCFS_CNTR_AVGMINMAX		= 0x0002,
 	LPROCFS_CNTR_STDDEV		= 0x0004,
 
-	/* counter data type */
-	LPROCFS_TYPE_REQS		= 0x0100,
+	/* counter unit type */
+	LPROCFS_TYPE_REQS		= 0x0000, /* default if config = 0 */
 	LPROCFS_TYPE_BYTES		= 0x0200,
 	LPROCFS_TYPE_PAGES		= 0x0400,
-	LPROCFS_TYPE_USEC		= 0x0800,
+	LPROCFS_TYPE_LOCKS		= 0x0500,
+	LPROCFS_TYPE_LOCKSPS		= 0x0600,
+	LPROCFS_TYPE_SECS		= 0x0700,
+	LPROCFS_TYPE_USECS		= 0x0800,
+	LPROCFS_TYPE_MASK		= 0x0f00,
 
-	LPROCFS_TYPE_LATENCY		= LPROCFS_TYPE_USEC |
+	LPROCFS_TYPE_LATENCY		= LPROCFS_TYPE_USECS |
 					  LPROCFS_CNTR_AVGMINMAX |
 					  LPROCFS_CNTR_STDDEV,
 	LPROCFS_TYPE_BYTES_FULL		= LPROCFS_TYPE_BYTES |
@@ -148,9 +152,9 @@ enum {
 #define LC_MIN_INIT ((~(u64)0) >> 1)
 
 struct lprocfs_counter_header {
-	unsigned int	 lc_config;
-	const char	*lc_name;   /* must be static */
-	const char	*lc_units;  /* must be static */
+	enum lprocfs_counter_config	lc_config;
+	const char			*lc_name;   /* must be static */
+	const char			*lc_units;  /* must be static */
 };
 
 struct lprocfs_counter {
@@ -435,8 +439,11 @@ int ldebugfs_alloc_md_stats(struct obd_device *obd,
 			    unsigned int num_private_stats);
 void ldebugfs_free_md_stats(struct obd_device *obd);
 void lprocfs_counter_init(struct lprocfs_stats *stats, int index,
-			  unsigned int conf, const char *name,
-			  const char *units);
+			  enum lprocfs_counter_config config,
+			  const char *name);
+void lprocfs_counter_init_units(struct lprocfs_stats *stats, int index,
+				enum lprocfs_counter_config config,
+				const char *name, const char *units);
 extern const struct file_operations lprocfs_stats_seq_fops;
 
 /* lprocfs_status.c */
diff --git a/fs/lustre/ldlm/ldlm_pool.c b/fs/lustre/ldlm/ldlm_pool.c
index 155b585..8c6491d 100644
--- a/fs/lustre/ldlm/ldlm_pool.c
+++ b/fs/lustre/ldlm/ldlm_pool.c
@@ -605,27 +605,37 @@ static int ldlm_pool_debugfs_init(struct ldlm_pool *pl)
 	}
 
 	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_GRANTED_STAT,
-			     LPROCFS_CNTR_AVGMINMAX, "granted", "locks");
+			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_TYPE_LOCKS,
+			     "granted");
 	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_GRANT_STAT,
-			     LPROCFS_CNTR_AVGMINMAX, "grant", "locks");
+			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_TYPE_LOCKS,
+			     "grant");
 	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_CANCEL_STAT,
-			     LPROCFS_CNTR_AVGMINMAX, "cancel", "locks");
+			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_TYPE_LOCKS,
+			     "cancel");
 	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_GRANT_RATE_STAT,
-			     LPROCFS_CNTR_AVGMINMAX, "grant_rate", "locks/s");
+			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_TYPE_LOCKSPS,
+			     "grant_rate");
 	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_CANCEL_RATE_STAT,
-			     LPROCFS_CNTR_AVGMINMAX, "cancel_rate", "locks/s");
+			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_TYPE_LOCKSPS,
+			     "cancel_rate");
 	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_GRANT_PLAN_STAT,
-			     LPROCFS_CNTR_AVGMINMAX, "grant_plan", "locks/s");
-	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_SLV_STAT,
-			     LPROCFS_CNTR_AVGMINMAX, "slv", "slv");
+			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_TYPE_LOCKSPS,
+			     "grant_plan");
+	lprocfs_counter_init_units(pl->pl_stats, LDLM_POOL_SLV_STAT,
+				   LPROCFS_CNTR_AVGMINMAX, "slv", "lock.secs");
 	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_SHRINK_REQTD_STAT,
-			     LPROCFS_CNTR_AVGMINMAX, "shrink_request", "locks");
+			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_TYPE_LOCKS,
+			     "shrink_request");
 	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_SHRINK_FREED_STAT,
-			     LPROCFS_CNTR_AVGMINMAX, "shrink_freed", "locks");
+			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_TYPE_LOCKS,
+			     "shrink_freed");
 	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_RECALC_STAT,
-			     LPROCFS_CNTR_AVGMINMAX, "recalc_freed", "locks");
+			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_TYPE_LOCKS,
+			     "recalc_freed");
 	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_TIMING_STAT,
-			     LPROCFS_CNTR_AVGMINMAX, "recalc_timing", "sec");
+			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_TYPE_SECS,
+			     "recalc_timing");
 	debugfs_create_file("stats", 0644, pl->pl_debugfs_entry, pl->pl_stats,
 			    &lprocfs_stats_seq_fops);
 
diff --git a/fs/lustre/ldlm/ldlm_resource.c b/fs/lustre/ldlm/ldlm_resource.c
index a189dbd..866f31d 100644
--- a/fs/lustre/ldlm/ldlm_resource.c
+++ b/fs/lustre/ldlm/ldlm_resource.c
@@ -455,7 +455,8 @@ static int ldlm_namespace_sysfs_register(struct ldlm_namespace *ns)
 	}
 
 	lprocfs_counter_init(ns->ns_stats, LDLM_NSS_LOCKS,
-			     LPROCFS_CNTR_AVGMINMAX, "locks", "locks");
+			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_TYPE_LOCKS,
+			     "locks");
 
 	return err;
 }
diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index 1391828..a57d7bb 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -36,6 +36,7 @@
 #include <obd_support.h>
 
 #include "llite_internal.h"
+#include "lprocfs_status.h"
 #include "vvp_internal.h"
 
 static struct kobject *llite_kobj;
@@ -1772,9 +1773,9 @@ static void sbi_kobj_release(struct kobject *kobj)
 };
 
 static const struct llite_file_opcode {
-	u32		opcode;
-	u32		type;
-	const char	*opname;
+	u32				lfo_opcode;
+	enum lprocfs_counter_config	lfo_config;
+	const char			*lfo_opname;
 } llite_opcode_table[LPROC_LL_FILE_OPCODES] = {
 	/* file operation */
 	{ LPROC_LL_READ_BYTES,	LPROCFS_TYPE_BYTES_FULL, "read_bytes" },
@@ -1790,8 +1791,7 @@ static void sbi_kobj_release(struct kobject *kobj)
 	{ LPROC_LL_LLSEEK,	LPROCFS_TYPE_LATENCY,	"seek" },
 	{ LPROC_LL_FSYNC,	LPROCFS_TYPE_LATENCY,	"fsync" },
 	{ LPROC_LL_READDIR,	LPROCFS_TYPE_LATENCY,	"readdir" },
-	{ LPROC_LL_INODE_OCOUNT, LPROCFS_TYPE_REQS |
-				 LPROCFS_CNTR_AVGMINMAX |
+	{ LPROC_LL_INODE_OCOUNT, LPROCFS_TYPE_REQS | LPROCFS_CNTR_AVGMINMAX |
 				 LPROCFS_CNTR_STDDEV,	"opencount" },
 	{ LPROC_LL_INODE_OPCLTM, LPROCFS_TYPE_LATENCY,	"openclosetime" },
 	/* inode operation */
@@ -1893,20 +1893,11 @@ int ll_debugfs_register_super(struct super_block *sb, const char *name)
 	}
 
 	/* do counter init */
-	for (id = 0; id < LPROC_LL_FILE_OPCODES; id++) {
-		u32 type = llite_opcode_table[id].type;
-		void *ptr = "unknown";
-
-		if (type & LPROCFS_TYPE_REQS)
-			ptr = "reqs";
-		else if (type & LPROCFS_TYPE_BYTES)
-			ptr = "bytes";
-		else if (type & LPROCFS_TYPE_USEC)
-			ptr = "usec";
+	for (id = 0; id < LPROC_LL_FILE_OPCODES; id++)
 		lprocfs_counter_init(sbi->ll_stats,
-				     llite_opcode_table[id].opcode, type,
-				     llite_opcode_table[id].opname, ptr);
-	}
+				     llite_opcode_table[id].lfo_opcode,
+				     llite_opcode_table[id].lfo_config,
+				     llite_opcode_table[id].lfo_opname);
 
 	debugfs_create_file("stats", 0644, sbi->ll_debugfs_entry, sbi->ll_stats,
 			    &lprocfs_stats_seq_fops);
@@ -1919,8 +1910,8 @@ int ll_debugfs_register_super(struct super_block *sb, const char *name)
 	}
 
 	for (id = 0; id < ARRAY_SIZE(ra_stat_string); id++)
-		lprocfs_counter_init(sbi->ll_ra_stats, id, 0,
-				     ra_stat_string[id], "pages");
+		lprocfs_counter_init(sbi->ll_ra_stats, id, LPROCFS_TYPE_PAGES,
+				     ra_stat_string[id]);
 
 	debugfs_create_file("read_ahead_stats", 0644, sbi->ll_debugfs_entry,
 			    sbi->ll_ra_stats, &lprocfs_stats_seq_fops);
diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index d80e7bd..7ce20b6 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -1448,9 +1448,41 @@ static int lprocfs_stats_seq_open(struct inode *inode, struct file *file)
 };
 EXPORT_SYMBOL_GPL(lprocfs_stats_seq_fops);
 
-void lprocfs_counter_init(struct lprocfs_stats *stats, int index,
-			  unsigned int conf, const char *name,
-			  const char *units)
+static const char *lprocfs_counter_config_units(const char *name,
+						enum lprocfs_counter_config config)
+{
+	const char *units;
+
+	switch (config & LPROCFS_TYPE_MASK) {
+	default:
+		units = "reqs";
+		break;
+	case LPROCFS_TYPE_BYTES:
+		units = "bytes";
+		break;
+	case LPROCFS_TYPE_PAGES:
+		units = "pages";
+		break;
+	case LPROCFS_TYPE_LOCKS:
+		units = "locks";
+		break;
+	case LPROCFS_TYPE_LOCKSPS:
+		units = "locks/s";
+		break;
+	case LPROCFS_TYPE_SECS:
+		units = "secs";
+		break;
+	case LPROCFS_TYPE_USECS:
+		units = "usecs";
+		break;
+	}
+
+	return units;
+}
+
+void lprocfs_counter_init_units(struct lprocfs_stats *stats, int index,
+				enum lprocfs_counter_config config,
+				const char *name, const char *units)
 {
 	struct lprocfs_counter_header *header;
 	struct lprocfs_counter *percpu_cntr;
@@ -1462,7 +1494,7 @@ void lprocfs_counter_init(struct lprocfs_stats *stats, int index,
 	LASSERTF(header, "Failed to allocate stats header:[%d]%s/%s\n",
 		 index, name, units);
 
-	header->lc_config = conf;
+	header->lc_config = config;
 	header->lc_name = name;
 	header->lc_units = units;
 
@@ -1481,6 +1513,15 @@ void lprocfs_counter_init(struct lprocfs_stats *stats, int index,
 	}
 	lprocfs_stats_unlock(stats, LPROCFS_GET_NUM_CPU, &flags);
 }
+EXPORT_SYMBOL(lprocfs_counter_init_units);
+
+void lprocfs_counter_init(struct lprocfs_stats *stats, int index,
+			  enum lprocfs_counter_config config,
+			  const char *name)
+{
+	lprocfs_counter_init_units(stats, index, config, name,
+				   lprocfs_counter_config_units(name, config));
+}
 EXPORT_SYMBOL(lprocfs_counter_init);
 
 static const char * const mps_stats[] = {
@@ -1524,7 +1565,8 @@ int ldebugfs_alloc_md_stats(struct obd_device *obd,
 		return -ENOMEM;
 
 	for (i = 0; i < ARRAY_SIZE(mps_stats); i++) {
-		lprocfs_counter_init(stats, i, 0, mps_stats[i], "reqs");
+		lprocfs_counter_init(stats, i, LPROCFS_TYPE_REQS,
+				     mps_stats[i]);
 		if (!stats->ls_cnt_header[i].lc_name) {
 			CERROR("Missing md_stat initializer md_op operation at offset %d. Aborting.\n",
 			       i);
@@ -1577,7 +1619,9 @@ s64 lprocfs_read_helper(struct lprocfs_counter *lc,
 		ret = lc->lc_max;
 		break;
 	case LPROCFS_FIELDS_FLAGS_AVG:
-		ret = (lc->lc_max - lc->lc_min) / 2;
+		ret = div64_u64((flags & LPROCFS_STATS_FLAG_IRQ_SAFE ?
+				 lc->lc_sum_irq : 0) + lc->lc_sum,
+				lc->lc_count);
 		break;
 	case LPROCFS_FIELDS_FLAGS_SUMSQUARE:
 		ret = lc->lc_sumsquare;
diff --git a/fs/lustre/obdclass/lu_object.c b/fs/lustre/obdclass/lu_object.c
index 25b47d8..7ecd0c4 100644
--- a/fs/lustre/obdclass/lu_object.c
+++ b/fs/lustre/obdclass/lu_object.c
@@ -1099,18 +1099,13 @@ int lu_site_init(struct lu_site *s, struct lu_device *top)
 		return -ENOMEM;
 	}
 
-	lprocfs_counter_init(s->ls_stats, LU_SS_CREATED,
-			     0, "created", "created");
-	lprocfs_counter_init(s->ls_stats, LU_SS_CACHE_HIT,
-			     0, "cache_hit", "cache_hit");
-	lprocfs_counter_init(s->ls_stats, LU_SS_CACHE_MISS,
-			     0, "cache_miss", "cache_miss");
-	lprocfs_counter_init(s->ls_stats, LU_SS_CACHE_RACE,
-			     0, "cache_race", "cache_race");
+	lprocfs_counter_init(s->ls_stats, LU_SS_CREATED, 0, "created");
+	lprocfs_counter_init(s->ls_stats, LU_SS_CACHE_HIT, 0, "cache_hit");
+	lprocfs_counter_init(s->ls_stats, LU_SS_CACHE_MISS, 0, "cache_miss");
+	lprocfs_counter_init(s->ls_stats, LU_SS_CACHE_RACE, 0, "cache_race");
 	lprocfs_counter_init(s->ls_stats, LU_SS_CACHE_DEATH_RACE,
-			     0, "cache_death_race", "cache_death_race");
-	lprocfs_counter_init(s->ls_stats, LU_SS_LRU_PURGED,
-			     0, "lru_purged", "lru_purged");
+			     0, "cache_death_race");
+	lprocfs_counter_init(s->ls_stats, LU_SS_LRU_PURGED, 0, "lru_purged");
 
 	INIT_LIST_HEAD(&s->ls_linkage);
 	s->ls_top_dev = top;
diff --git a/fs/lustre/ptlrpc/lproc_ptlrpc.c b/fs/lustre/ptlrpc/lproc_ptlrpc.c
index b2daf1f..52010cb 100644
--- a/fs/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/fs/lustre/ptlrpc/lproc_ptlrpc.c
@@ -191,9 +191,9 @@ static const char *ll_eopcode2str(u32 opcode)
 {
 	struct dentry *svc_debugfs_entry;
 	struct lprocfs_stats *svc_stats;
+	enum lprocfs_counter_config config = LPROCFS_CNTR_AVGMINMAX |
+					     LPROCFS_CNTR_STDDEV;
 	int i;
-	unsigned int svc_counter_config = LPROCFS_CNTR_AVGMINMAX |
-					  LPROCFS_CNTR_STDDEV;
 
 	LASSERT(!*debugfs_root_ret);
 	LASSERT(!*stats_ret);
@@ -209,37 +209,33 @@ static const char *ll_eopcode2str(u32 opcode)
 		svc_debugfs_entry = root;
 
 	lprocfs_counter_init(svc_stats, PTLRPC_REQWAIT_CNTR,
-			     svc_counter_config, "req_waittime", "usec");
+			     config | LPROCFS_TYPE_USECS, "req_waittime");
 	lprocfs_counter_init(svc_stats, PTLRPC_REQQDEPTH_CNTR,
-			     svc_counter_config, "req_qdepth", "reqs");
+			     config | LPROCFS_TYPE_REQS, "req_qdepth");
 	lprocfs_counter_init(svc_stats, PTLRPC_REQACTIVE_CNTR,
-			     svc_counter_config, "req_active", "reqs");
+			     config | LPROCFS_TYPE_REQS, "req_active");
 	lprocfs_counter_init(svc_stats, PTLRPC_TIMEOUT,
-			     svc_counter_config, "req_timeout", "sec");
-	lprocfs_counter_init(svc_stats, PTLRPC_REQBUF_AVAIL_CNTR,
-			     svc_counter_config, "reqbuf_avail", "bufs");
+			     config | LPROCFS_TYPE_SECS, "req_timeout");
+	lprocfs_counter_init_units(svc_stats, PTLRPC_REQBUF_AVAIL_CNTR,
+				   config, "reqbuf_avail", "bufs");
 	for (i = 0; i < EXTRA_LAST_OPC; i++) {
-		char *units;
+		enum lprocfs_counter_config extra_type = LPROCFS_TYPE_REQS;
 
 		switch (i) {
 		case BRW_WRITE_BYTES:
 		case BRW_READ_BYTES:
-			units = "bytes";
-			break;
-		default:
-			units = "reqs";
+			extra_type = LPROCFS_TYPE_BYTES;
 			break;
 		}
 		lprocfs_counter_init(svc_stats, PTLRPC_LAST_CNTR + i,
-				     svc_counter_config,
-				     ll_eopcode2str(i), units);
+				     config | extra_type, ll_eopcode2str(i));
 	}
 	for (i = 0; i < LUSTRE_MAX_OPCODES; i++) {
 		u32 opcode = ll_rpc_opcode_table[i].opcode;
 
-		lprocfs_counter_init(svc_stats,
-				     EXTRA_MAX_OPCODES + i, svc_counter_config,
-				     ll_opcode2str(opcode), "usec");
+		lprocfs_counter_init(svc_stats, EXTRA_MAX_OPCODES + i,
+				     config | LPROCFS_TYPE_USECS,
+				     ll_opcode2str(opcode));
 	}
 
 	debugfs_create_file("stats", 0644, svc_debugfs_entry, svc_stats,
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
