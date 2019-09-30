From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:08 -0400
Subject: [lustre-devel] [PATCH 049/151] lustre: mdc: add IO stats in mdc
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-50-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhal Pershin <mpershin@whamcloud.com>

Add IO statistic into MDC like in OSC

WC-bug-id: https://jira.whamcloud.com/browse/LU-3285
Lustre-commit: 2f103489f614 ("LU-3285 mdc: add IO stats in mdc")
Signed-off-by: Mikhal Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/28019
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_dlm.h |  29 ++++
 fs/lustre/include/lustre_osc.h |   2 +
 fs/lustre/ldlm/ldlm_request.c  |  22 +++
 fs/lustre/mdc/lproc_mdc.c      | 318 ++++++++++++++++++++++++++++++++++++++++-
 fs/lustre/obdclass/genops.c    |   2 +
 fs/lustre/osc/osc_internal.h   |   2 -
 fs/lustre/osc/osc_page.c       |   1 +
 7 files changed, 367 insertions(+), 9 deletions(-)

diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index 8f92225..feef43a 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -1206,6 +1206,35 @@ void ldlm_namespace_free_prior(struct ldlm_namespace *ns,
 void ldlm_debugfs_setup(void);
 void ldlm_debugfs_cleanup(void);
 
+static inline void ldlm_svc_get_eopc(const struct ldlm_request *dlm_req,
+				      struct lprocfs_stats *srv_stats)
+{
+	int lock_type = 0, op = 0;
+
+	lock_type = dlm_req->lock_desc.l_resource.lr_type;
+
+	switch (lock_type) {
+	case LDLM_PLAIN:
+		op = PTLRPC_LAST_CNTR + LDLM_PLAIN_ENQUEUE;
+		break;
+	case LDLM_EXTENT:
+		op = PTLRPC_LAST_CNTR + LDLM_EXTENT_ENQUEUE;
+		break;
+	case LDLM_FLOCK:
+		op = PTLRPC_LAST_CNTR + LDLM_FLOCK_ENQUEUE;
+		break;
+	case LDLM_IBITS:
+		op = PTLRPC_LAST_CNTR + LDLM_IBITS_ENQUEUE;
+		break;
+	default:
+		op = 0;
+		break;
+	}
+
+	if (op != 0)
+		lprocfs_counter_incr(srv_stats, op);
+}
+
 /* resource.c - internal */
 struct ldlm_resource *ldlm_resource_get(struct ldlm_namespace *ns,
 					struct ldlm_resource *parent,
diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index ecca719..2a16197 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -558,6 +558,8 @@ void osc_index2policy(union ldlm_policy_data *policy,
 void osc_page_submit(const struct lu_env *env, struct osc_page *opg,
 		     enum cl_req_type crt, int brw_flags);
 int lru_queue_work(const struct lu_env *env, void *data);
+long osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
+		    long target, bool force);
 
 /* osc_cache.c */
 int osc_set_async_flags(struct osc_object *obj, struct osc_page *opg,
diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index 09be016..6089ac4 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -754,6 +754,28 @@ int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
 	body->lock_flags = ldlm_flags_to_wire(*flags);
 	body->lock_handle[0] = *lockh;
 
+	/* extended LDLM opcodes in client stats */
+	if (exp->exp_obd->obd_svc_stats != NULL) {
+		bool glimpse = *flags & LDLM_FL_HAS_INTENT;
+
+		/* OST glimpse has no intent buffer */
+		if (req_capsule_has_field(&req->rq_pill, &RMF_LDLM_INTENT,
+					  RCL_CLIENT)) {
+			struct ldlm_intent *it;
+
+			it = req_capsule_client_get(&req->rq_pill,
+						    &RMF_LDLM_INTENT);
+			glimpse = (it && (it->opc == IT_GLIMPSE));
+		}
+
+		if (!glimpse)
+			ldlm_svc_get_eopc(body, exp->exp_obd->obd_svc_stats);
+		else
+			lprocfs_counter_incr(exp->exp_obd->obd_svc_stats,
+					     PTLRPC_LAST_CNTR +
+					     LDLM_GLIMPSE_ENQUEUE);
+	}
+
 	if (async) {
 		LASSERT(reqp);
 		return 0;
diff --git a/fs/lustre/mdc/lproc_mdc.c b/fs/lustre/mdc/lproc_mdc.c
index ffc1085..9092a97 100644
--- a/fs/lustre/mdc/lproc_mdc.c
+++ b/fs/lustre/mdc/lproc_mdc.c
@@ -35,8 +35,175 @@
 #include <linux/vfs.h>
 #include <obd_class.h>
 #include <lprocfs_status.h>
+#include <lustre_osc.h>
+#include <cl_object.h>
+
 #include "mdc_internal.h"
 
+static int mdc_max_dirty_mb_seq_show(struct seq_file *m, void *v)
+{
+	struct obd_device *dev = m->private;
+	struct client_obd *cli = &dev->u.cli;
+	unsigned long val;
+
+	spin_lock(&cli->cl_loi_list_lock);
+	val = cli->cl_dirty_max_pages >> (20 - PAGE_SHIFT);
+	spin_unlock(&cli->cl_loi_list_lock);
+
+	seq_printf(m, "%lu\n", val);
+	return 0;
+}
+
+static ssize_t mdc_max_dirty_mb_seq_write(struct file *file,
+					  const char __user *buffer,
+					  size_t count, loff_t *off)
+{
+	struct seq_file *sfl = file->private_data;
+	struct obd_device *dev = sfl->private;
+	struct client_obd *cli = &dev->u.cli;
+	__s64 pages_number;
+	int rc;
+
+	rc = lprocfs_write_frac_u64_helper(buffer, count, &pages_number,
+					   1 << (20 - PAGE_SHIFT));
+	if (rc)
+		return rc;
+
+	pages_number >>= PAGE_SHIFT;
+
+	if (pages_number <= 0 ||
+	    pages_number >= OSC_MAX_DIRTY_MB_MAX << (20 - PAGE_SHIFT) ||
+	    pages_number > totalram_pages() / 4) /* 1/4 of RAM */
+		return -ERANGE;
+
+	spin_lock(&cli->cl_loi_list_lock);
+	cli->cl_dirty_max_pages = pages_number;
+	osc_wake_cache_waiters(cli);
+	spin_unlock(&cli->cl_loi_list_lock);
+
+	return count;
+}
+LPROC_SEQ_FOPS(mdc_max_dirty_mb);
+
+static int mdc_cached_mb_seq_show(struct seq_file *m, void *v)
+{
+	struct obd_device *dev = m->private;
+	struct client_obd *cli = &dev->u.cli;
+	int shift = 20 - PAGE_SHIFT;
+
+	seq_printf(m, "used_mb: %ld\n"
+		   "busy_cnt: %ld\n"
+		   "reclaim: %llu\n",
+		   (atomic_long_read(&cli->cl_lru_in_list) +
+		    atomic_long_read(&cli->cl_lru_busy)) >> shift,
+		    atomic_long_read(&cli->cl_lru_busy),
+		   cli->cl_lru_reclaim);
+
+	return 0;
+}
+
+/* shrink the number of caching pages to a specific number */
+static ssize_t
+mdc_cached_mb_seq_write(struct file *file, const char __user *buffer,
+			size_t count, loff_t *off)
+{
+	struct seq_file *sfl = file->private_data;
+	struct obd_device *dev = sfl->private;
+	struct client_obd *cli = &dev->u.cli;
+	u64 pages_number;
+	long rc;
+	char kernbuf[128];
+
+	if (count >= sizeof(kernbuf))
+		return -EINVAL;
+
+	if (copy_from_user(kernbuf, buffer, count))
+		return -EFAULT;
+	kernbuf[count] = 0;
+
+	buffer += lprocfs_find_named_value(kernbuf, "used_mb:", &count) -
+		  kernbuf;
+	rc = lprocfs_write_frac_u64_helper(buffer, count, &pages_number,
+					   1 << (20 - PAGE_SHIFT));
+	if (rc)
+		return rc;
+
+	pages_number >>= PAGE_SHIFT;
+
+	if (pages_number < 0)
+		return -ERANGE;
+
+	rc = atomic_long_read(&cli->cl_lru_in_list) - pages_number;
+	if (rc > 0) {
+		struct lu_env *env;
+		u16 refcheck;
+
+		env = cl_env_get(&refcheck);
+		if (!IS_ERR(env)) {
+			(void)osc_lru_shrink(env, cli, rc, true);
+			cl_env_put(env, &refcheck);
+		}
+	}
+
+	return count;
+}
+LPROC_SEQ_FOPS(mdc_cached_mb);
+
+static int mdc_contention_seconds_seq_show(struct seq_file *m, void *v)
+{
+	struct obd_device *obd = m->private;
+	struct osc_device *od  = obd2osc_dev(obd);
+
+	seq_printf(m, "%u\n", od->od_contention_time);
+	return 0;
+}
+
+static ssize_t mdc_contention_seconds_seq_write(struct file *file,
+						const char __user *buffer,
+						size_t count, loff_t *off)
+{
+	struct seq_file *sfl = file->private_data;
+	struct obd_device *obd = sfl->private;
+	struct osc_device *od  = obd2osc_dev(obd);
+	int rc;
+	char kernbuf[128];
+	s64 val;
+
+	if (count >= sizeof(kernbuf))
+		return -EINVAL;
+
+	if (copy_from_user(kernbuf, buffer, count))
+		return -EFAULT;
+	kernbuf[count] = 0;
+
+	rc = kstrtos64(kernbuf, count, &val);
+	if (rc)
+		return rc;
+	if (val < 0 || val > INT_MAX)
+		return -ERANGE;
+
+	od->od_contention_time = val;
+
+	return count;
+}
+LPROC_SEQ_FOPS(mdc_contention_seconds);
+
+static int mdc_unstable_stats_seq_show(struct seq_file *m, void *v)
+{
+	struct obd_device *dev = m->private;
+	struct client_obd *cli = &dev->u.cli;
+	long pages;
+	int mb;
+
+	pages = atomic_long_read(&cli->cl_unstable_count);
+	mb    = (pages * PAGE_SIZE) >> 20;
+
+	seq_printf(m, "unstable_pages: %20ld\n"
+		   "unstable_mb:              %10d\n", pages, mb);
+	return 0;
+}
+LPROC_SEQ_FOPS_RO(mdc_unstable_stats);
+
 static ssize_t active_show(struct kobject *kobj, struct attribute *attr,
 			   char *buf)
 {
@@ -139,13 +306,6 @@ static ssize_t max_mod_rpcs_in_flight_store(struct kobject *kobj,
 #define mdc_conn_uuid_show conn_uuid_show
 LUSTRE_RO_ATTR(mdc_conn_uuid);
 
-static int mdc_rpc_stats_seq_show(struct seq_file *seq, void *v)
-{
-	struct obd_device *dev = seq->private;
-
-	return obd_mod_rpc_stats_seq_show(&dev->u.cli, seq);
-}
-
 static ssize_t mdc_rpc_stats_seq_write(struct file *file,
 				       const char __user *buf,
 				       size_t len, loff_t *off)
@@ -156,10 +316,144 @@ static ssize_t mdc_rpc_stats_seq_write(struct file *file,
 
 	lprocfs_oh_clear(&cli->cl_mod_rpcs_hist);
 
+	lprocfs_oh_clear(&cli->cl_read_rpc_hist);
+	lprocfs_oh_clear(&cli->cl_write_rpc_hist);
+	lprocfs_oh_clear(&cli->cl_read_page_hist);
+	lprocfs_oh_clear(&cli->cl_write_page_hist);
+	lprocfs_oh_clear(&cli->cl_read_offset_hist);
+	lprocfs_oh_clear(&cli->cl_write_offset_hist);
+
 	return len;
 }
+
+#define pct(a, b) (b ? a * 100 / b : 0)
+static int mdc_rpc_stats_seq_show(struct seq_file *seq, void *v)
+{
+	struct obd_device *dev = seq->private;
+	struct client_obd *cli = &dev->u.cli;
+	unsigned long read_tot = 0, write_tot = 0, read_cum, write_cum;
+	int i;
+
+	obd_mod_rpc_stats_seq_show(&dev->u.cli, seq);
+
+	spin_lock(&cli->cl_loi_list_lock);
+
+	seq_printf(seq, "\nread RPCs in flight:  %d\n",
+		   cli->cl_r_in_flight);
+	seq_printf(seq, "write RPCs in flight: %d\n",
+		   cli->cl_w_in_flight);
+	seq_printf(seq, "pending write pages:  %d\n",
+		   atomic_read(&cli->cl_pending_w_pages));
+	seq_printf(seq, "pending read pages:   %d\n",
+		   atomic_read(&cli->cl_pending_r_pages));
+
+	seq_puts(seq, "\n\t\t\tread\t\t\twrite\n");
+	seq_puts(seq, "pages per rpc         rpcs   %% cum %% |");
+	seq_puts(seq, "       rpcs   %% cum %%\n");
+
+	read_tot = lprocfs_oh_sum(&cli->cl_read_page_hist);
+	write_tot = lprocfs_oh_sum(&cli->cl_write_page_hist);
+
+	read_cum = 0;
+	write_cum = 0;
+	for (i = 0; i < OBD_HIST_MAX; i++) {
+		unsigned long r = cli->cl_read_page_hist.oh_buckets[i];
+		unsigned long w = cli->cl_write_page_hist.oh_buckets[i];
+
+		read_cum += r;
+		write_cum += w;
+		seq_printf(seq, "%d:\t\t%10lu %3lu %3lu   | %10lu %3lu %3lu\n",
+			   1 << i, r, pct(r, read_tot),
+			   pct(read_cum, read_tot), w,
+			   pct(w, write_tot),
+			   pct(write_cum, write_tot));
+		if (read_cum == read_tot && write_cum == write_tot)
+			break;
+	}
+
+	seq_puts(seq, "\n\t\t\tread\t\t\twrite\n");
+	seq_puts(seq, "rpcs in flight        rpcs   %% cum %% |");
+	seq_puts(seq, "       rpcs   %% cum %%\n");
+
+	read_tot = lprocfs_oh_sum(&cli->cl_read_rpc_hist);
+	write_tot = lprocfs_oh_sum(&cli->cl_write_rpc_hist);
+
+	read_cum = 0;
+	write_cum = 0;
+	for (i = 0; i < OBD_HIST_MAX; i++) {
+		unsigned long r = cli->cl_read_rpc_hist.oh_buckets[i];
+		unsigned long w = cli->cl_write_rpc_hist.oh_buckets[i];
+
+		read_cum += r;
+		write_cum += w;
+		seq_printf(seq, "%d:\t\t%10lu %3lu %3lu   | %10lu %3lu %3lu\n",
+			   i, r, pct(r, read_tot), pct(read_cum, read_tot), w,
+			   pct(w, write_tot), pct(write_cum, write_tot));
+		if (read_cum == read_tot && write_cum == write_tot)
+			break;
+	}
+
+	seq_puts(seq, "\n\t\t\tread\t\t\twrite\n");
+	seq_puts(seq, "offset                rpcs   %% cum %% |");
+	seq_puts(seq, "       rpcs   %% cum %%\n");
+
+	read_tot = lprocfs_oh_sum(&cli->cl_read_offset_hist);
+	write_tot = lprocfs_oh_sum(&cli->cl_write_offset_hist);
+
+	read_cum = 0;
+	write_cum = 0;
+	for (i = 0; i < OBD_HIST_MAX; i++) {
+		unsigned long r = cli->cl_read_offset_hist.oh_buckets[i];
+		unsigned long w = cli->cl_write_offset_hist.oh_buckets[i];
+
+		read_cum += r;
+		write_cum += w;
+		seq_printf(seq, "%d:\t\t%10lu %3lu %3lu   | %10lu %3lu %3lu\n",
+			   (i == 0) ? 0 : 1 << (i - 1),
+			   r, pct(r, read_tot), pct(read_cum, read_tot),
+			   w, pct(w, write_tot), pct(write_cum, write_tot));
+		if (read_cum == read_tot && write_cum == write_tot)
+			break;
+	}
+	spin_unlock(&cli->cl_loi_list_lock);
+
+	return 0;
+}
+#undef pct
 LPROC_SEQ_FOPS(mdc_rpc_stats);
 
+static int mdc_stats_seq_show(struct seq_file *seq, void *v)
+{
+	struct timespec64 now;
+	struct obd_device *dev = seq->private;
+	struct osc_stats *stats = &obd2osc_dev(dev)->od_stats;
+
+	ktime_get_real_ts64(&now);
+
+	seq_printf(seq, "snapshot_time:         %lld.%09lu (secs.nsecs)\n",
+		   (s64)now.tv_sec, now.tv_nsec);
+	seq_printf(seq, "lockless_write_bytes\t\t%llu\n",
+		   stats->os_lockless_writes);
+	seq_printf(seq, "lockless_read_bytes\t\t%llu\n",
+		   stats->os_lockless_reads);
+	seq_printf(seq, "lockless_truncate\t\t%llu\n",
+		   stats->os_lockless_truncates);
+	return 0;
+}
+
+static ssize_t mdc_stats_seq_write(struct file *file,
+				   const char __user *buf,
+				   size_t len, loff_t *off)
+{
+	struct seq_file *seq = file->private_data;
+	struct obd_device *dev = seq->private;
+	struct osc_stats *stats = &obd2osc_dev(dev)->od_stats;
+
+	memset(stats, 0, sizeof(*stats));
+	return len;
+}
+LPROC_SEQ_FOPS(mdc_stats);
+
 LPROC_SEQ_FOPS_WR_ONLY(mdc, ping);
 
 LPROC_SEQ_FOPS_RO_TYPE(mdc, connect_flags);
@@ -177,8 +471,14 @@ static ssize_t mdc_rpc_stats_seq_write(struct file *file,
 	  .fops	=	&mdc_connect_flags_fops		},
 	{ .name	=	"mds_server_uuid",
 	  .fops	=	&mdc_server_uuid_fops,		},
+	{ .name	=	"max_dirty_mb",
+	  .fops	=	&mdc_max_dirty_mb_fops		},
+	{ .name	=	"mdc_cached_mb",
+	  .fops	=	&mdc_cached_mb_fops		},
 	{ .name	=	"timeouts",
 	  .fops	=	&mdc_timeouts_fops		},
+	{ .name	=	"contention_seconds",
+	  .fops	=	&mdc_contention_seconds_fops	},
 	{ .name	=	"import",
 	  .fops	=	&mdc_import_fops		},
 	{ .name	=	"state",
@@ -187,6 +487,10 @@ static ssize_t mdc_rpc_stats_seq_write(struct file *file,
 	  .fops	=	&mdc_pinger_recov_fops		},
 	{ .name =	"rpc_stats",
 	  .fops =	&mdc_rpc_stats_fops		},
+	{ .name	=	"unstable_stats",
+	  .fops	=	&mdc_unstable_stats_fops	},
+	{ .name	=	"mdc_stats",
+	  .fops	=	&mdc_stats_fops			},
 	{ NULL }
 };
 
diff --git a/fs/lustre/obdclass/genops.c b/fs/lustre/obdclass/genops.c
index 68d267f..1ecceeb 100644
--- a/fs/lustre/obdclass/genops.c
+++ b/fs/lustre/obdclass/genops.c
@@ -1391,6 +1391,8 @@ int obd_set_max_rpcs_in_flight(struct client_obd *cli, u32 max)
 	spin_lock(&cli->cl_loi_list_lock);
 	old = cli->cl_max_rpcs_in_flight;
 	cli->cl_max_rpcs_in_flight = max;
+	client_adjust_max_dirty(cli);
+
 	diff = max - old;
 
 	/* We increase the max_rpcs_in_flight, then wakeup some waiters. */
diff --git a/fs/lustre/osc/osc_internal.h b/fs/lustre/osc/osc_internal.h
index 8f89443..65f52f9 100644
--- a/fs/lustre/osc/osc_internal.h
+++ b/fs/lustre/osc/osc_internal.h
@@ -78,8 +78,6 @@ int osc_ladvise_base(struct obd_export *exp, struct obdo *oa,
 int osc_process_config_base(struct obd_device *obd, struct lustre_cfg *cfg);
 int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 		  struct list_head *ext_list, int cmd);
-long osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
-		    long target, bool force);
 unsigned long osc_lru_reserve(struct client_obd *cli, unsigned long npages);
 void osc_lru_unreserve(struct client_obd *cli, unsigned long npages);
 
diff --git a/fs/lustre/osc/osc_page.c b/fs/lustre/osc/osc_page.c
index 45b18f1..4e41b26 100644
--- a/fs/lustre/osc/osc_page.c
+++ b/fs/lustre/osc/osc_page.c
@@ -663,6 +663,7 @@ long osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
 	}
 	return count > 0 ? count : rc;
 }
+EXPORT_SYMBOL(osc_lru_shrink);
 
 /**
  * Reclaim LRU pages by an IO thread. The caller wants to reclaim at least
-- 
1.8.3.1
