From: James Simmons <jsimmons@infradead.org>
Date: Sun, 27 Mar 2016 20:26:29 -0400
Subject: [lustre-devel] [PATCH 9/9] staging: lustre: libcfs: remove
	cfs_workitem_t typedefs
In-Reply-To: <1459124789-20758-1-git-send-email-jsimmons@infradead.org>
References: <1459124789-20758-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459124789-20758-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Convert cfs_workitem_t to proper structure.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: http://review.whamcloud.com/17202
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/include/linux/libcfs/libcfs_hash.h      |    4 ++--
 .../lustre/include/linux/libcfs/libcfs_workitem.h  |   12 ++++++------
 drivers/staging/lustre/lnet/libcfs/hash.c          |    6 +++---
 drivers/staging/lustre/lnet/libcfs/workitem.c      |   12 ++++++------
 drivers/staging/lustre/lnet/selftest/selftest.h    |    4 ++--
 5 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
index c3f2332..119986b 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
@@ -245,7 +245,7 @@ struct cfs_hash {
 	/** # of iterators (caller of cfs_hash_for_each_*) */
 	__u32				hs_iterators;
 	/** rehash workitem */
-	cfs_workitem_t			hs_rehash_wi;
+	struct cfs_workitem		hs_rehash_wi;
 	/** refcount on this hash table */
 	atomic_t			hs_refcount;
 	/** rehash buckets-table */
@@ -262,7 +262,7 @@ struct cfs_hash {
 	/** bits when we found the max depth */
 	unsigned int			hs_dep_bits;
 	/** workitem to output max depth */
-	cfs_workitem_t			hs_dep_wi;
+	struct cfs_workitem		hs_dep_wi;
 #endif
 	/** name of htable */
 	char				hs_name[0];
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_workitem.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_workitem.h
index 5cc64f3..f9b20c5 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_workitem.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_workitem.h
@@ -73,7 +73,7 @@ int cfs_wi_sched_create(char *name, struct cfs_cpt_table *cptab, int cpt,
 struct cfs_workitem;
 
 typedef int (*cfs_wi_action_t) (struct cfs_workitem *);
-typedef struct cfs_workitem {
+struct cfs_workitem {
 	/** chain on runq or rerunq */
 	struct list_head       wi_list;
 	/** working function */
@@ -84,10 +84,10 @@ typedef struct cfs_workitem {
 	unsigned short   wi_running:1;
 	/** scheduled */
 	unsigned short   wi_scheduled:1;
-} cfs_workitem_t;
+};
 
 static inline void
-cfs_wi_init(cfs_workitem_t *wi, void *data, cfs_wi_action_t action)
+cfs_wi_init(struct cfs_workitem *wi, void *data, cfs_wi_action_t action)
 {
 	INIT_LIST_HEAD(&wi->wi_list);
 
@@ -97,9 +97,9 @@ cfs_wi_init(cfs_workitem_t *wi, void *data, cfs_wi_action_t action)
 	wi->wi_action    = action;
 }
 
-void cfs_wi_schedule(struct cfs_wi_sched *sched, cfs_workitem_t *wi);
-int  cfs_wi_deschedule(struct cfs_wi_sched *sched, cfs_workitem_t *wi);
-void cfs_wi_exit(struct cfs_wi_sched *sched, cfs_workitem_t *wi);
+void cfs_wi_schedule(struct cfs_wi_sched *sched, struct cfs_workitem *wi);
+int  cfs_wi_deschedule(struct cfs_wi_sched *sched, struct cfs_workitem *wi);
+void cfs_wi_exit(struct cfs_wi_sched *sched, struct cfs_workitem *wi);
 
 int  cfs_wi_startup(void);
 void cfs_wi_shutdown(void);
diff --git a/drivers/staging/lustre/lnet/libcfs/hash.c b/drivers/staging/lustre/lnet/libcfs/hash.c
index f60feb3..cc45ed8 100644
--- a/drivers/staging/lustre/lnet/libcfs/hash.c
+++ b/drivers/staging/lustre/lnet/libcfs/hash.c
@@ -942,10 +942,10 @@ cfs_hash_buckets_realloc(struct cfs_hash *hs, struct cfs_hash_bucket **old_bkts,
  * @flags    - CFS_HASH_REHASH enable synamic hash resizing
  *	     - CFS_HASH_SORT enable chained hash sort
  */
-static int cfs_hash_rehash_worker(cfs_workitem_t *wi);
+static int cfs_hash_rehash_worker(struct cfs_workitem *wi);
 
 #if CFS_HASH_DEBUG_LEVEL >= CFS_HASH_DEBUG_1
-static int cfs_hash_dep_print(cfs_workitem_t *wi)
+static int cfs_hash_dep_print(struct cfs_workitem *wi)
 {
 	struct cfs_hash *hs = container_of(wi, struct cfs_hash, hs_dep_wi);
 	int dep;
@@ -1847,7 +1847,7 @@ cfs_hash_rehash_bd(struct cfs_hash *hs, struct cfs_hash_bd *old)
 }
 
 static int
-cfs_hash_rehash_worker(cfs_workitem_t *wi)
+cfs_hash_rehash_worker(struct cfs_workitem *wi)
 {
 	struct cfs_hash *hs = container_of(wi, struct cfs_hash, hs_rehash_wi);
 	struct cfs_hash_bucket **bkts;
diff --git a/drivers/staging/lustre/lnet/libcfs/workitem.c b/drivers/staging/lustre/lnet/libcfs/workitem.c
index c72fe00..92236ae 100644
--- a/drivers/staging/lustre/lnet/libcfs/workitem.c
+++ b/drivers/staging/lustre/lnet/libcfs/workitem.c
@@ -111,7 +111,7 @@ cfs_wi_sched_cansleep(struct cfs_wi_sched *sched)
  * 1. when it returns no one shall try to schedule the workitem.
  */
 void
-cfs_wi_exit(struct cfs_wi_sched *sched, cfs_workitem_t *wi)
+cfs_wi_exit(struct cfs_wi_sched *sched, struct cfs_workitem *wi)
 {
 	LASSERT(!in_interrupt()); /* because we use plain spinlock */
 	LASSERT(!sched->ws_stopping);
@@ -138,7 +138,7 @@ EXPORT_SYMBOL(cfs_wi_exit);
  * cancel schedule request of workitem \a wi
  */
 int
-cfs_wi_deschedule(struct cfs_wi_sched *sched, cfs_workitem_t *wi)
+cfs_wi_deschedule(struct cfs_wi_sched *sched, struct cfs_workitem *wi)
 {
 	int	rc;
 
@@ -179,7 +179,7 @@ EXPORT_SYMBOL(cfs_wi_deschedule);
  * be added, and even dynamic creation of serialised queues might be supported.
  */
 void
-cfs_wi_schedule(struct cfs_wi_sched *sched, cfs_workitem_t *wi)
+cfs_wi_schedule(struct cfs_wi_sched *sched, struct cfs_workitem *wi)
 {
 	LASSERT(!in_interrupt()); /* because we use plain spinlock */
 	LASSERT(!sched->ws_stopping);
@@ -229,12 +229,12 @@ static int cfs_wi_scheduler(void *arg)
 	while (!sched->ws_stopping) {
 		int	     nloops = 0;
 		int	     rc;
-		cfs_workitem_t *wi;
+		struct cfs_workitem *wi;
 
 		while (!list_empty(&sched->ws_runq) &&
 		       nloops < CFS_WI_RESCHED) {
-			wi = list_entry(sched->ws_runq.next, cfs_workitem_t,
-					wi_list);
+			wi = list_entry(sched->ws_runq.next,
+					struct cfs_workitem, wi_list);
 			LASSERT(wi->wi_scheduled && !wi->wi_running);
 
 			list_del_init(&wi->wi_list);
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index 288522d..f50580e 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -176,7 +176,7 @@ typedef int (*swi_action_t) (struct swi_workitem *);
 
 typedef struct swi_workitem {
 	struct cfs_wi_sched *swi_sched;
-	cfs_workitem_t	    swi_workitem;
+	struct cfs_workitem swi_workitem;
 	swi_action_t	    swi_action;
 	int		    swi_state;
 } swi_workitem_t;
@@ -461,7 +461,7 @@ srpc_serv_is_framework(struct srpc_service *svc)
 }
 
 static inline int
-swi_wi_action(cfs_workitem_t *wi)
+swi_wi_action(struct cfs_workitem *wi)
 {
 	swi_workitem_t *swi = container_of(wi, swi_workitem_t, swi_workitem);
 
-- 
1.7.1
