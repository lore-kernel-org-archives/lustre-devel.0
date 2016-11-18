From: James Simmons <jsimmons@infradead.org>
Date: Fri, 18 Nov 2016 11:48:37 -0500
Subject: [lustre-devel] [PATCH 03/10] staging: lustre: libcfs: name
	parameters for function prototypes
In-Reply-To: <1479487724-20386-1-git-send-email-jsimmons@infradead.org>
References: <1479487724-20386-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1479487724-20386-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Give the parameters names for the function
prototypes in the libcfs headers.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/linux/libcfs/libcfs.h   |    4 ++--
 .../lustre/include/linux/libcfs/libcfs_hash.h      |   15 ++++++++-------
 .../lustre/include/linux/libcfs/libcfs_private.h   |    4 ++--
 .../lustre/include/linux/libcfs/libcfs_workitem.h  |    4 ++--
 4 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index 3b92d38..70eb08e 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -61,7 +61,7 @@
 sigset_t cfs_block_allsigs(void);
 sigset_t cfs_block_sigs(unsigned long sigs);
 sigset_t cfs_block_sigsinv(unsigned long sigs);
-void cfs_restore_sigs(sigset_t);
+void cfs_restore_sigs(sigset_t sigset);
 void cfs_clear_sigpending(void);
 
 /*
@@ -71,7 +71,7 @@
 /* returns a random 32-bit integer */
 unsigned int cfs_rand(void);
 /* seed the generator */
-void cfs_srand(unsigned int, unsigned int);
+void cfs_srand(unsigned int seed1, unsigned int seed2);
 void cfs_get_random_bytes(void *buf, int size);
 
 #include "libcfs_debug.h"
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
index 28937d5..2f56707 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
@@ -708,25 +708,26 @@ typedef int (*cfs_hash_for_each_cb_t)(struct cfs_hash *hs,
 void *
 cfs_hash_lookup(struct cfs_hash *hs, const void *key);
 void
-cfs_hash_for_each(struct cfs_hash *hs, cfs_hash_for_each_cb_t, void *data);
+cfs_hash_for_each(struct cfs_hash *hs, cfs_hash_for_each_cb_t cb, void *data);
 void
-cfs_hash_for_each_safe(struct cfs_hash *hs, cfs_hash_for_each_cb_t, void *data);
+cfs_hash_for_each_safe(struct cfs_hash *hs, cfs_hash_for_each_cb_t cb,
+		       void *data);
 int
-cfs_hash_for_each_nolock(struct cfs_hash *hs, cfs_hash_for_each_cb_t,
+cfs_hash_for_each_nolock(struct cfs_hash *hs, cfs_hash_for_each_cb_t cb,
 			 void *data, int start);
 int
-cfs_hash_for_each_empty(struct cfs_hash *hs, cfs_hash_for_each_cb_t,
+cfs_hash_for_each_empty(struct cfs_hash *hs, cfs_hash_for_each_cb_t cb,
 			void *data);
 void
 cfs_hash_for_each_key(struct cfs_hash *hs, const void *key,
-		      cfs_hash_for_each_cb_t, void *data);
+		      cfs_hash_for_each_cb_t cb, void *data);
 typedef int (*cfs_hash_cond_opt_cb_t)(void *obj, void *data);
 void
-cfs_hash_cond_del(struct cfs_hash *hs, cfs_hash_cond_opt_cb_t, void *data);
+cfs_hash_cond_del(struct cfs_hash *hs, cfs_hash_cond_opt_cb_t cb, void *data);
 
 void
 cfs_hash_hlist_for_each(struct cfs_hash *hs, unsigned int hindex,
-			cfs_hash_for_each_cb_t, void *data);
+			cfs_hash_for_each_cb_t cb, void *data);
 int  cfs_hash_is_empty(struct cfs_hash *hs);
 __u64 cfs_hash_size_get(struct cfs_hash *hs);
 
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
index 523e8f4..93bff1b 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
@@ -75,7 +75,7 @@
 
 #define KLASSERT(e) LASSERT(e)
 
-void __noreturn lbug_with_loc(struct libcfs_debug_msg_data *);
+void __noreturn lbug_with_loc(struct libcfs_debug_msg_data *msg);
 
 #define LBUG()							  \
 do {								    \
@@ -170,7 +170,7 @@
 #endif
 
 void libcfs_run_upcall(char **argv);
-void libcfs_run_lbug_upcall(struct libcfs_debug_msg_data *);
+void libcfs_run_lbug_upcall(struct libcfs_debug_msg_data *msg);
 void libcfs_debug_dumplog(void);
 int libcfs_debug_init(unsigned long bufsize);
 int libcfs_debug_cleanup(void);
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_workitem.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_workitem.h
index a7e1340..2accd9a 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_workitem.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_workitem.h
@@ -62,9 +62,9 @@
 
 struct cfs_wi_sched;
 
-void cfs_wi_sched_destroy(struct cfs_wi_sched *);
+void cfs_wi_sched_destroy(struct cfs_wi_sched *sched);
 int cfs_wi_sched_create(char *name, struct cfs_cpt_table *cptab, int cpt,
-			int nthrs, struct cfs_wi_sched **);
+			int nthrs, struct cfs_wi_sched **sched_pp);
 
 struct cfs_workitem;
 
-- 
1.7.1
