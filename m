From: James Simmons <jsimmons@infradead.org>
Date: Wed,  3 Jun 2015 16:43:25 -0400
Subject: [lustre-devel] [PATCH v3 6/8] staging:lustre: fix camel case for
	LNetInit and LNetFini
In-Reply-To: <1433364207-14307-1-git-send-email-jsimmons@infradead.org>
References: <1433364207-14307-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1433364207-14307-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

For the functions LNetInit and LNetFini move away from
camel case to lnet_init and lnet_fini.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/api.h    |    3 ---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    3 +++
 .../staging/lustre/include/linux/lnet/lib-types.h  |    2 +-
 drivers/staging/lustre/lnet/lnet/api-ni.c          |   16 ++++++++--------
 drivers/staging/lustre/lnet/lnet/module.c          |    6 +++---
 5 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/api.h b/drivers/staging/lustre/include/linux/lnet/api.h
index c4dc1b2..dee7f27 100644
--- a/drivers/staging/lustre/include/linux/lnet/api.h
+++ b/drivers/staging/lustre/include/linux/lnet/api.h
@@ -52,9 +52,6 @@
 /** \defgroup lnet_init_fini Initialization and cleanup
  * The LNet must be properly initialized before any LNet calls can be made.
  * @{ */
-int LNetInit(void);
-void LNetFini(void);
-
 int LNetNIInit(lnet_pid_t requested_pid);
 int LNetNIFini(void);
 /** @} lnet_init_fini */
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 2750570..15e6a2e 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -434,6 +434,9 @@ lnet_ni_t *lnet_nid2ni_locked(lnet_nid_t nid, int cpt);
 lnet_ni_t *lnet_net2ni_locked(__u32 net, int cpt);
 lnet_ni_t *lnet_net2ni(__u32 net);
 
+int lnet_init(void);
+void lnet_fini(void);
+
 int lnet_notify(lnet_ni_t *ni, lnet_nid_t peer, int alive, unsigned long when);
 void lnet_notify_locked(lnet_peer_t *lp, int notifylnd, int alive,
 			unsigned long when);
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index fdf94dd..8e8e725 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -575,7 +575,7 @@ typedef struct {
 
 	struct mutex			ln_api_mutex;
 	struct mutex			ln_lnd_mutex;
-	int				ln_init;	/* LNetInit() called? */
+	int				ln_init;	/* lnet_init() called? */
 	/* Have I called LNetNIInit myself? */
 	int				ln_niinit_self;
 	/* LNetNIInit/LNetNIFini counter */
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 57e9752..d14fe70 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1101,14 +1101,14 @@ lnet_startup_lndnis(void)
  * Initialize LNet library.
  *
  * Only userspace program needs to call this function - it's automatically
- * called in the kernel at module loading time. Caller has to call LNetFini()
- * after a call to LNetInit(), if and only if the latter returned 0. It must
+ * called in the kernel at module loading time. Caller has to call lnet_fini()
+ * after a call to lnet_init(), if and only if the latter returned 0. It must
  * be called exactly once.
  *
  * \return 0 on success, and -ve on failures.
  */
 int
-LNetInit(void)
+lnet_init(void)
 {
 	int rc;
 
@@ -1161,7 +1161,7 @@ LNetInit(void)
 	lnet_register_lnd(&the_lolnd);
 	return 0;
 }
-EXPORT_SYMBOL(LNetInit);
+EXPORT_SYMBOL(lnet_init);
 
 /**
  * Finalize LNet library.
@@ -1169,11 +1169,11 @@ EXPORT_SYMBOL(LNetInit);
  * Only userspace program needs to call this function. It can be called
  * at most once.
  *
- * \pre LNetInit() called with success.
+ * \pre lnet_init() called with success.
  * \pre All LNet users called LNetNIFini() for matching LNetNIInit() calls.
  */
 void
-LNetFini(void)
+lnet_fini(void)
 {
 	LASSERT(the_lnet.ln_init);
 	LASSERT(the_lnet.ln_refcount == 0);
@@ -1185,12 +1185,12 @@ LNetFini(void)
 
 	the_lnet.ln_init = 0;
 }
-EXPORT_SYMBOL(LNetFini);
+EXPORT_SYMBOL(lnet_fini);
 
 /**
  * Set LNet PID and start LNet interfaces, routing, and forwarding.
  *
- * Userspace program should call this after a successful call to LNetInit().
+ * Userspace program should call this after a successful call to lnet_init().
  * Users must call this function at least once before any other functions.
  * For each successful call there must be a corresponding call to
  * LNetNIFini(). For subsequent calls to LNetNIInit(), \a requested_pid is
diff --git a/drivers/staging/lustre/lnet/lnet/module.c b/drivers/staging/lustre/lnet/lnet/module.c
index 6881b9c..576201a 100644
--- a/drivers/staging/lustre/lnet/lnet/module.c
+++ b/drivers/staging/lustre/lnet/lnet/module.c
@@ -117,9 +117,9 @@ init_lnet(void)
 
 	mutex_init(&lnet_config_mutex);
 
-	rc = LNetInit();
+	rc = lnet_init();
 	if (rc != 0) {
-		CERROR("LNetInit: error %d\n", rc);
+		CERROR("lnet_init: error %d\n", rc);
 		return rc;
 	}
 
@@ -143,7 +143,7 @@ fini_lnet(void)
 	rc = libcfs_deregister_ioctl(&lnet_ioctl_handler);
 	LASSERT(rc == 0);
 
-	LNetFini();
+	lnet_fini();
 }
 
 MODULE_AUTHOR("Peter J. Braam <braam@clusterfs.com>");
-- 
1.7.1
