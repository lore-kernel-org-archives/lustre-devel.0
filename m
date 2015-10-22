From: James Simmons <jsimmons@infradead.org>
Date: Wed, 21 Oct 2015 21:52:41 -0400
Subject: [lustre-devel] [PATCH 03/11] staging: lustre: remove
	libcfs_init_string function
In-Reply-To: <1445478769-21203-1-git-send-email-jsimmons@infradead.org>
References: <1445478769-21203-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1445478769-21203-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

All the function libcfs_init_string did was initialize
a spinlock. We can initialize the spinlock statically
instead.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/linux/libcfs/libcfs.h   |    2 --
 drivers/staging/lustre/lnet/lnet/nidstrings.c      |    8 +-------
 drivers/staging/lustre/lustre/libcfs/module.c      |    2 --
 3 files changed, 1 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index 385ced1..4d74e8a 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -152,8 +152,6 @@ extern struct miscdevice libcfs_dev;
 extern char lnet_upcall[1024];
 extern char lnet_debug_log_upcall[1024];
 
-extern void libcfs_init_nidstrings(void);
-
 extern struct cfs_psdev_ops libcfs_psdev_ops;
 
 extern struct cfs_wi_sched *cfs_sched_rehash;
diff --git a/drivers/staging/lustre/lnet/lnet/nidstrings.c b/drivers/staging/lustre/lnet/lnet/nidstrings.c
index 81ec3a8..fdbdf06 100644
--- a/drivers/staging/lustre/lnet/lnet/nidstrings.c
+++ b/drivers/staging/lustre/lnet/lnet/nidstrings.c
@@ -61,13 +61,7 @@
 static char      libcfs_nidstrings[LNET_NIDSTR_COUNT][LNET_NIDSTR_SIZE];
 static int       libcfs_nidstring_idx;
 
-static spinlock_t libcfs_nidstring_lock;
-
-void libcfs_init_nidstrings(void)
-{
-	spin_lock_init(&libcfs_nidstring_lock);
-}
-EXPORT_SYMBOL(libcfs_init_nidstrings);
+static DEFINE_SPINLOCK(libcfs_nidstring_lock);
 
 char *
 libcfs_next_nidstring(void)
diff --git a/drivers/staging/lustre/lustre/libcfs/module.c b/drivers/staging/lustre/lustre/libcfs/module.c
index 0d9b223..50e8fd2 100644
--- a/drivers/staging/lustre/lustre/libcfs/module.c
+++ b/drivers/staging/lustre/lustre/libcfs/module.c
@@ -701,8 +701,6 @@ static int init_libcfs_module(void)
 {
 	int rc;
 
-	libcfs_init_nidstrings();
-
 	rc = libcfs_debug_init(5 * 1024 * 1024);
 	if (rc < 0) {
 		pr_err("LustreError: libcfs_debug_init: %d\n", rc);
-- 
1.7.1
