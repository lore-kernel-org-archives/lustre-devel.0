From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:57 -0400
Subject: [lustre-devel] [PATCH 098/151] lustre: osc: migrate to 64 bit time
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-99-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Change od_contention_time from int to time64_t to make it clear
this field is in units of seconds. Change the *_contention_time
fields from jiffies to ktime_t to make it clear we are dealing
with time and ktime_t is consistent on any platform unlike
jiffies.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9019
Lustre-commit: 3ea899c9a611 ("LU-9019 osc: migrate to 64 bit time")
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/30607
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_osc.h |  6 +++---
 fs/lustre/mdc/lproc_mdc.c      |  2 +-
 fs/lustre/osc/lproc_osc.c      |  2 +-
 fs/lustre/osc/osc_cache.c      |  4 ++--
 fs/lustre/osc/osc_object.c     | 10 +++++-----
 fs/lustre/osc/osc_page.c       | 10 +++++-----
 6 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index cba9d43..38ae83a8 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -120,7 +120,7 @@ struct osc_device {
 	} od_stats;
 
 	/* configuration item(s) */
-	int			od_contention_time;
+	time64_t		od_contention_time;
 	int			od_lockless_truncate;
 };
 
@@ -264,7 +264,7 @@ struct osc_object {
 	 * True if locking against this stripe got -EUSERS.
 	 */
 	int			oo_contended;
-	unsigned long		oo_contention_time;
+	ktime_t			oo_contention_time;
 	/*
 	 * used by the osc to keep track of what objects to build into rpcs.
 	 * Protected by client_obd->cli_loi_list_lock.
@@ -532,7 +532,7 @@ struct osc_page {
 	/*
 	 * Submit time - the time when the page is starting RPC. For debugging.
 	 */
-	unsigned long		ops_submit_time;
+	ktime_t			ops_submit_time;
 };
 
 struct osc_brw_async_args {
diff --git a/fs/lustre/mdc/lproc_mdc.c b/fs/lustre/mdc/lproc_mdc.c
index 2af2e57..f09292e 100644
--- a/fs/lustre/mdc/lproc_mdc.c
+++ b/fs/lustre/mdc/lproc_mdc.c
@@ -154,7 +154,7 @@ static int mdc_contention_seconds_seq_show(struct seq_file *m, void *v)
 	struct obd_device *obd = m->private;
 	struct osc_device *od  = obd2osc_dev(obd);
 
-	seq_printf(m, "%u\n", od->od_contention_time);
+	seq_printf(m, "%lld\n", od->od_contention_time);
 	return 0;
 }
 
diff --git a/fs/lustre/osc/lproc_osc.c b/fs/lustre/osc/lproc_osc.c
index 6661092..df48138 100644
--- a/fs/lustre/osc/lproc_osc.c
+++ b/fs/lustre/osc/lproc_osc.c
@@ -506,7 +506,7 @@ static ssize_t contention_seconds_show(struct kobject *kobj,
 					      obd_kset.kobj);
 	struct osc_device *od = obd2osc_dev(obd);
 
-	return sprintf(buf, "%u\n", od->od_contention_time);
+	return sprintf(buf, "%lld\n", od->od_contention_time);
 }
 
 static ssize_t contention_seconds_store(struct kobject *kobj,
diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index 68498af..3189eb3 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -1307,7 +1307,7 @@ static int osc_make_ready(const struct lu_env *env, struct osc_async_page *oap,
 
 	result = cl_page_make_ready(env, page, CRT_WRITE);
 	if (result == 0)
-		opg->ops_submit_time = jiffies;
+		opg->ops_submit_time = ktime_get();
 
 	return result;
 }
@@ -1362,7 +1362,7 @@ static int osc_completion(const struct lu_env *env, struct osc_async_page *oap,
 	/* Clear opg->ops_transfer_pinned before VM lock is released. */
 	opg->ops_transfer_pinned = 0;
 
-	opg->ops_submit_time = 0;
+	opg->ops_submit_time = ktime_set(0, 0);
 	srvlock = oap->oap_brw_flags & OBD_BRW_SRVLOCK;
 
 	/* statistic */
diff --git a/fs/lustre/osc/osc_object.c b/fs/lustre/osc/osc_object.c
index 4cd6e15..fdee8fa 100644
--- a/fs/lustre/osc/osc_object.c
+++ b/fs/lustre/osc/osc_object.c
@@ -307,9 +307,8 @@ static int osc_object_fiemap(const struct lu_env *env, struct cl_object *obj,
 int osc_object_is_contended(struct osc_object *obj)
 {
 	struct osc_device *dev = lu2osc_dev(obj->oo_cl.co_lu.lo_dev);
-	int osc_contention_time = dev->od_contention_time;
-	unsigned long cur_time = jiffies;
-	unsigned long retry_time;
+	time64_t osc_contention_time = dev->od_contention_time;
+	ktime_t retry_time;
 
 	if (OBD_FAIL_CHECK(OBD_FAIL_OSC_OBJECT_CONTENTION))
 		return 1;
@@ -321,8 +320,9 @@ int osc_object_is_contended(struct osc_object *obj)
 	 * I like copy-paste. the code is copied from
 	 * ll_file_is_contended.
 	 */
-	retry_time = obj->oo_contention_time + osc_contention_time * HZ;
-	if (time_after(cur_time, retry_time)) {
+	retry_time = ktime_add_ns(obj->oo_contention_time,
+				  osc_contention_time * NSEC_PER_SEC);
+	if (ktime_after(ktime_get(), retry_time)) {
 		osc_object_clear_contended(obj);
 		return 0;
 	}
diff --git a/fs/lustre/osc/osc_page.c b/fs/lustre/osc/osc_page.c
index f5b6f73..96d1385 100644
--- a/fs/lustre/osc/osc_page.c
+++ b/fs/lustre/osc/osc_page.c
@@ -122,12 +122,12 @@ static const char *osc_list(struct list_head *head)
 	return list_empty(head) ? "-" : "+";
 }
 
-static inline unsigned long osc_submit_duration(struct osc_page *opg)
+static inline s64 osc_submit_duration(struct osc_page *opg)
 {
-	if (opg->ops_submit_time == 0)
+	if (ktime_to_ns(opg->ops_submit_time) == 0)
 		return 0;
 
-	return (jiffies - opg->ops_submit_time);
+	return ktime_ms_delta(ktime_get(), opg->ops_submit_time);
 }
 
 static int osc_page_print(const struct lu_env *env,
@@ -139,7 +139,7 @@ static int osc_page_print(const struct lu_env *env,
 	struct osc_object *obj = cl2osc(slice->cpl_obj);
 	struct client_obd *cli = &osc_export(obj)->exp_obd->u.cli;
 
-	return (*printer)(env, cookie, LUSTRE_OSC_NAME "-page@%p %lu: 1< %#x %d %s %s > 2< %llu %u %u %#x %#x | %p %p %p > 3< %d %lu %d > 4< %d %d %d %lu %s | %s %s %s %s > 5< %s %s %s %s | %d %s | %d %s %s>\n",
+	return (*printer)(env, cookie, LUSTRE_OSC_NAME "-page@%p %lu: 1< %#x %d %s %s > 2< %llu %u %u %#x %#x | %p %p %p > 3< %d %lld %d > 4< %d %d %d %lu %s | %s %s %s %s > 5< %s %s %s %s | %d %s | %d %s %s>\n",
 			  opg, osc_index(opg),
 			  /* 1 */
 			  oap->oap_magic, oap->oap_cmd,
@@ -303,7 +303,7 @@ void osc_page_submit(const struct lu_env *env, struct osc_page *opg,
 		oap->oap_cmd |= OBD_BRW_NOQUOTA;
 	}
 
-	opg->ops_submit_time = jiffies;
+	opg->ops_submit_time = ktime_get();
 	osc_page_transfer_get(opg, "transfer\0imm");
 	osc_page_transfer_add(env, opg, crt);
 }
-- 
1.8.3.1
