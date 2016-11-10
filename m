From: James Simmons <jsimmons@infradead.org>
Date: Thu, 10 Nov 2016 12:30:49 -0500
Subject: [lustre-devel] [PATCH 19/35] staging: lustre: obdclass: remove
	structure holes to reduce memory
In-Reply-To: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
References: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1478799065-24841-20-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

From: Andreas Dilger <andreas.dilger@intel.com>

Fix the alignment of fields in commonly-used structures to reduce
memory usage on the client and server.  Structures fixed:

ptlrpc_reply_state: reduced by 8 bytes
obd_device:         reduced by 16 bytes
niobuf_local:       reduced by 8 bytes

Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3281
Reviewed-on: http://review.whamcloud.com/16692
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lustre_net.h |    7 ++--
 drivers/staging/lustre/lustre/include/obd.h        |   38 ++++++++++----------
 2 files changed, 23 insertions(+), 22 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index 7f549a3..d2cbec3 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -438,6 +438,10 @@ struct ptlrpc_reply_state {
 	unsigned long	  rs_committed:1;/* the transaction was committed
 					  * and the rs was dispatched
 					  */
+	atomic_t		rs_refcount;	/* number of users */
+	/** Number of locks awaiting client ACK */
+	int			rs_nlocks;
+
 	/** Size of the state */
 	int		    rs_size;
 	/** opcode */
@@ -450,7 +454,6 @@ struct ptlrpc_reply_state {
 	struct ptlrpc_service_part *rs_svcpt;
 	/** Lnet metadata handle for the reply */
 	lnet_handle_md_t       rs_md_h;
-	atomic_t	   rs_refcount;
 
 	/** Context for the service thread */
 	struct ptlrpc_svc_ctx *rs_svc_ctx;
@@ -467,8 +470,6 @@ struct ptlrpc_reply_state {
 	 */
 	struct lustre_msg     *rs_msg;	  /* reply message */
 
-	/** Number of locks awaiting client ACK */
-	int		    rs_nlocks;
 	/** Handles of locks awaiting client reply ACK */
 	struct lustre_handle   rs_locks[RS_MAX_LOCKS];
 	/** Lock modes of locks in \a rs_locks */
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index ffe09a3..a346312 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -428,9 +428,9 @@ struct niobuf_local {
 	__u32		lnb_page_offset;
 	__u32		lnb_len;
 	__u32		lnb_flags;
+	int		lnb_rc;
 	struct page	*lnb_page;
 	void		*lnb_data;
-	int		lnb_rc;
 };
 
 #define LUSTRE_FLD_NAME	 "fld"
@@ -531,15 +531,14 @@ struct lvfs_run_ctxt {
 
 struct obd_device {
 	struct obd_type	*obd_type;
-	__u32		   obd_magic;
+	u32			 obd_magic; /* OBD_DEVICE_MAGIC */
+	int			 obd_minor; /* device number: lctl dl */
+	struct lu_device	*obd_lu_dev;
 
 	/* common and UUID name of this device */
-	char		    obd_name[MAX_OBD_NAME];
-	struct obd_uuid	 obd_uuid;
+	struct obd_uuid		 obd_uuid;
+	char			 obd_name[MAX_OBD_NAME];
 
-	struct lu_device       *obd_lu_dev;
-
-	int		     obd_minor;
 	/* bitfield modification is protected by obd_dev_lock */
 	unsigned long obd_attached:1,      /* finished attach */
 		      obd_set_up:1,	/* finished setup */
@@ -563,22 +562,22 @@ struct obd_device {
 	unsigned long obd_recovery_expired:1;
 	/* uuid-export hash body */
 	struct cfs_hash	     *obd_uuid_hash;
-	atomic_t	    obd_refcount;
 	wait_queue_head_t	     obd_refcount_waitq;
 	struct list_head	      obd_exports;
 	struct list_head	      obd_unlinked_exports;
 	struct list_head	      obd_delayed_exports;
+	atomic_t			obd_refcount;
 	int		     obd_num_exports;
 	spinlock_t		obd_nid_lock;
 	struct ldlm_namespace  *obd_namespace;
 	struct ptlrpc_client	obd_ldlm_client; /* XXX OST/MDS only */
 	/* a spinlock is OK for what we do now, may need a semaphore later */
 	spinlock_t		obd_dev_lock; /* protect OBD bitfield above */
-	struct mutex		obd_dev_mutex;
-	__u64			obd_last_committed;
 	spinlock_t		obd_osfs_lock;
 	struct obd_statfs	obd_osfs;       /* locked by obd_osfs_lock */
 	__u64			obd_osfs_age;
+	u64			obd_last_committed;
+	struct mutex		obd_dev_mutex;
 	struct lvfs_run_ctxt	obd_lvfs_ctxt;
 	struct obd_llog_group	obd_olg;	/* default llog group */
 	struct obd_device	*obd_observer;
@@ -592,12 +591,13 @@ struct obd_device {
 		struct lov_obd lov;
 		struct lmv_obd lmv;
 	} u;
+
 	/* Fields used by LProcFS */
-	unsigned int	   obd_cntr_base;
-	struct lprocfs_stats  *obd_stats;
+	struct lprocfs_stats	*obd_stats;
+	unsigned int		 obd_cntr_base;
 
-	unsigned int	   md_cntr_base;
-	struct lprocfs_stats  *md_stats;
+	struct lprocfs_stats	*md_stats;
+	unsigned int		 md_cntr_base;
 
 	struct dentry		*obd_debugfs_entry;
 	struct dentry		*obd_svc_debugfs_entry;
@@ -609,9 +609,11 @@ struct obd_device {
 	/**
 	 * Ldlm pool part. Save last calculated SLV and Limit.
 	 */
-	rwlock_t		obd_pool_lock;
-	int		    obd_pool_limit;
-	__u64		  obd_pool_slv;
+	rwlock_t		 obd_pool_lock;
+	u64			 obd_pool_slv;
+	int			 obd_pool_limit;
+
+	int			 obd_conn_inprogress;
 
 	/**
 	 * A list of outstanding class_incref()'s against this obd. For
@@ -619,8 +621,6 @@ struct obd_device {
 	 */
 	struct lu_ref	  obd_reference;
 
-	int		       obd_conn_inprogress;
-
 	struct kobject		obd_kobj; /* sysfs object */
 	struct completion	obd_kobj_unregister;
 };
-- 
1.7.1
