From: NeilBrown <neilb@suse.com>
Date: Tue, 20 Feb 2018 13:23:37 +1100
Subject: [lustre-devel] [PATCH 09/21] staging: lustre: discard
 libcfs_kvzalloc_cpt()
In-Reply-To: <151909308778.25814.9912662268627044409.stgit@noble>
References: <151909308778.25814.9912662268627044409.stgit@noble>
Message-ID: <151909341783.25814.12309771139592565643.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

This function is used precisely once, and is sufficiently
trivial that it may as well be open-coded.

Doing so helpfully highlights the similarity
between the new kvzalloc_node() call and the already existing
kzalloc_node() call in the same function.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/libcfs/libcfs.h   |    2 --
 .../staging/lustre/lnet/libcfs/linux/linux-mem.c   |    7 -------
 drivers/staging/lustre/lustre/ptlrpc/service.c     |    8 ++++----
 3 files changed, 4 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index 4f8c65e6d883..039205763021 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -113,8 +113,6 @@ static inline void *__container_of(void *ptr, unsigned long shift)
 #define _LIBCFS_H
 
 void *libcfs_kvzalloc(size_t size, gfp_t flags);
-void *libcfs_kvzalloc_cpt(struct cfs_cpt_table *cptab, int cpt, size_t size,
-			  gfp_t flags);
 
 extern struct miscdevice libcfs_dev;
 /**
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-mem.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-mem.c
index 963df0ef4afb..f2c001bac303 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-mem.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-mem.c
@@ -42,10 +42,3 @@ void *libcfs_kvzalloc(size_t size, gfp_t flags)
 	return ret;
 }
 EXPORT_SYMBOL(libcfs_kvzalloc);
-
-void *libcfs_kvzalloc_cpt(struct cfs_cpt_table *cptab, int cpt, size_t size,
-			  gfp_t flags)
-{
-	return kvzalloc_node(size, flags, cfs_cpt_spread_node(cptab, cpt));
-}
-EXPORT_SYMBOL(libcfs_kvzalloc_cpt);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index 29fdb54f16ca..57e41e2cd30a 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -83,10 +83,10 @@ ptlrpc_alloc_rqbd(struct ptlrpc_service_part *svcpt)
 	rqbd->rqbd_cbid.cbid_fn = request_in_callback;
 	rqbd->rqbd_cbid.cbid_arg = rqbd;
 	INIT_LIST_HEAD(&rqbd->rqbd_reqs);
-	rqbd->rqbd_buffer = libcfs_kvzalloc_cpt(svc->srv_cptable,
-						svcpt->scp_cpt,
-						svc->srv_buf_size,
-						GFP_KERNEL);
+	rqbd->rqbd_buffer = kvzalloc_node(svc->srv_buf_size, GFP_KERNEL,
+					  cfs_cpt_spread_node(svc->srv_cptable,
+							      svcpt->scp_cpt));
+
 	if (!rqbd->rqbd_buffer) {
 		kfree(rqbd);
 		return NULL;
