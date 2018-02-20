From: NeilBrown <neilb@suse.com>
Date: Tue, 20 Feb 2018 13:23:38 +1100
Subject: [lustre-devel] [PATCH 14/21] staging: lustre: fix assorted
 checkpatch errors
In-Reply-To: <151909308778.25814.9912662268627044409.stgit@noble>
References: <151909308778.25814.9912662268627044409.stgit@noble>
Message-ID: <151909341801.25814.16760126077741712102.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

Possible the most interesting is the for-loop with
no body.  I think it reads better as a while loop.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../lustre/lnet/klnds/socklnd/socklnd_lib.c        |    2 +-
 .../staging/lustre/lnet/libcfs/linux/linux-cpu.c   |    2 +-
 drivers/staging/lustre/lustre/include/obd_class.h  |    8 ++++----
 .../staging/lustre/lustre/include/obd_support.h    |    2 +-
 drivers/staging/lustre/lustre/llite/dcache.c       |    2 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    2 +-
 drivers/staging/lustre/lustre/lov/lov_request.c    |    2 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |    6 ++++--
 drivers/staging/lustre/lustre/ptlrpc/layout.c      |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/recover.c     |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/service.c     |    2 +-
 11 files changed, 17 insertions(+), 15 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
index cb28dd2baf2f..7941cfa526bc 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
@@ -189,7 +189,7 @@ ksocknal_lib_recv(struct ksock_conn *conn)
 	if (!(conn->ksnc_rx_to.type & ITER_BVEC) &&
 	     conn->ksnc_proto != &ksocknal_protocol_v2x)
 		return rc;
-		
+
 	/* accumulate checksum */
 	conn->ksnc_msg.ksm_csum = 0;
 	iov_iter_for_each_range(&conn->ksnc_rx_to, rc, lustre_csum, conn);
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
index c07165e0ad95..388521e4e354 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
@@ -743,7 +743,7 @@ cfs_cpt_table_create(int ncpt)
 		goto failed;
 	}
 
-	if (!zalloc_cpumask_var(&mask, GFP_NOFS)){
+	if (!zalloc_cpumask_var(&mask, GFP_NOFS)) {
 		CERROR("Failed to allocate scratch cpumask\n");
 		goto failed;
 	}
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 531e8ddfa9e5..f24dd74ffa09 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -294,10 +294,10 @@ struct obdo;
 
 void obdo_to_ioobj(const struct obdo *oa, struct obd_ioobj *ioobj);
 
-#define OBT(dev)	(dev)->obd_type
-#define OBP(dev, op)    (dev)->obd_type->typ_dt_ops->op
-#define MDP(dev, op)    (dev)->obd_type->typ_md_ops->op
-#define CTXTP(ctxt, op) (ctxt)->loc_logops->lop_##op
+#define OBT(dev)	((dev)->obd_type)
+#define OBP(dev, op)    ((dev)->obd_type->typ_dt_ops->op)
+#define MDP(dev, op)    ((dev)->obd_type->typ_md_ops->op)
+#define CTXTP(ctxt, op) ((ctxt)->loc_logops->lop_##op)
 
 /*
  * Ensure obd_setup: used for cleanup which must be called
diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index 3f4fe290f6ea..8595091b8b86 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -516,7 +516,7 @@ extern char obd_jobid_var[];
 #define POISON_PTR(ptr)  ((void)0)
 #else
 #define POISON(ptr, c, s) memset(ptr, c, s)
-#define POISON_PTR(ptr)  (ptr) = (void *)0xdeadbeef
+#define POISON_PTR(ptr)  ((ptr) = (void *)0xdeadbeef)
 #endif
 
 #ifdef POISON_BULK
diff --git a/drivers/staging/lustre/lustre/llite/dcache.c b/drivers/staging/lustre/lustre/llite/dcache.c
index dc30b4582234..3e768f997172 100644
--- a/drivers/staging/lustre/lustre/llite/dcache.c
+++ b/drivers/staging/lustre/lustre/llite/dcache.c
@@ -100,7 +100,7 @@ static int ll_dcompare(const struct dentry *dentry,
 		return 0;
 
 	/* ensure exclusion against parallel lookup of the same name */
-	if (d_in_lookup((struct dentry*)dentry))
+	if (d_in_lookup((struct dentry *)dentry))
 		return 0;
 
 	if (d_lustre_invalid(dentry))
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index efbd551e7842..844182ad7dd7 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -2022,7 +2022,7 @@ void ll_umount_begin(struct super_block *sb)
 	 */
 	while (cnt < 10 && !may_umount(sbi->ll_mnt.mnt)) {
 		schedule_timeout_uninterruptible(HZ);
-		cnt ++;
+		cnt++;
 	}
 
 	schedule();
diff --git a/drivers/staging/lustre/lustre/lov/lov_request.c b/drivers/staging/lustre/lustre/lov/lov_request.c
index c1e58fcc30b3..051450d67524 100644
--- a/drivers/staging/lustre/lustre/lov/lov_request.c
+++ b/drivers/staging/lustre/lustre/lov/lov_request.c
@@ -126,7 +126,7 @@ static int lov_check_and_wait_active(struct lov_obd *lov, int ost_idx)
 
 	while (cnt < obd_timeout && !lov_check_set(lov, ost_idx)) {
 		schedule_timeout_uninterruptible(HZ);
-		cnt ++;
+		cnt++;
 	}
 	if (tgt->ltd_active)
 		return 1;
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index ab48746ce433..bde27acb0dd3 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -1060,8 +1060,10 @@ static void mdc_adjust_dirpages(struct page **pages, int cfs_pgs, int lu_pgs)
 
 		while (--lu_pgs > 0) {
 			ent = lu_dirent_start(dp);
-			for (end_dirent = ent; ent;
-			     end_dirent = ent, ent = lu_dirent_next(ent));
+			while (ent) {
+				end_dirent = ent;
+				ent = lu_dirent_next(ent);
+			}
 
 			/* Advance dp to next lu_dirpage. */
 			dp = (struct lu_dirpage *)((char *)dp + LU_PAGE_SIZE);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/layout.c b/drivers/staging/lustre/lustre/ptlrpc/layout.c
index 18769d335751..2855f38c8190 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/layout.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/layout.c
@@ -1555,7 +1555,7 @@ struct req_format RQF_OST_GET_INFO_FIEMAP =
 EXPORT_SYMBOL(RQF_OST_GET_INFO_FIEMAP);
 
 /* Convenience macro */
-#define FMT_FIELD(fmt, i, j) (fmt)->rf_fields[(i)].d[(j)]
+#define FMT_FIELD(fmt, i, j) ((fmt)->rf_fields[(i)].d[(j)])
 
 /**
  * Initializes the capsule abstraction by computing and setting the \a rf_idx
diff --git a/drivers/staging/lustre/lustre/ptlrpc/recover.c b/drivers/staging/lustre/lustre/ptlrpc/recover.c
index 7b5f2429d144..5bb9f9fe91d8 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/recover.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/recover.c
@@ -354,7 +354,7 @@ int ptlrpc_recover_import(struct obd_import *imp, char *new_uuid, int async)
 					     obd_timeout * HZ);
 		CDEBUG(D_HA, "%s: recovery finished\n",
 		       obd2cli_tgt(imp->imp_obd));
-		rc = rc? 0 : -ETIMEDOUT;
+		rc = rc ? 0 : -ETIMEDOUT;
 	}
 
 out:
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index 79d9f3860022..99aeb291f3f2 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -2670,7 +2670,7 @@ ptlrpc_service_unlink_rqbd(struct ptlrpc_service *svc)
 			       (rc = wait_event_idle_timeout(svcpt->scp_waitq,
 							     svcpt->scp_nrqbds_posted == 0,
 							     HZ)) == 0)
-				cnt ++;
+				cnt++;
 			if (rc == 0) {
 				CWARN("Service %s waiting for request buffers\n",
 				      svcpt->scp_service->srv_name);
