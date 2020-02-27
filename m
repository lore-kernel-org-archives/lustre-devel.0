From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:45 -0500
Subject: [lustre-devel] [PATCH 237/622] lustre: ptlrpc: Change static
 defines to use macro for sec_gc.c
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-238-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Arshad Hussain <arshad.super@gmail.com>

This patch replaces all mutex, locks, and wait qeueues
which are defined statically in file fs/lustre/ptlrpc/sec_gc.c
with kernel provided macro.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9010
Lustre-commit: 50c01e02506f ("LU-9010 ptlrpc: Change static defines to use macro for sec_gc.c")
Signed-off-by: Arshad Hussain <arshad.super@gmail.com>
Reviewed-on: https://review.whamcloud.com/33937
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/sec_gc.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/fs/lustre/ptlrpc/sec_gc.c b/fs/lustre/ptlrpc/sec_gc.c
index d5edcec..3baed8c 100644
--- a/fs/lustre/ptlrpc/sec_gc.c
+++ b/fs/lustre/ptlrpc/sec_gc.c
@@ -48,12 +48,12 @@
 
 #define SEC_GC_INTERVAL (30 * 60)
 
-static struct mutex sec_gc_mutex;
+static DEFINE_MUTEX(sec_gc_mutex);
 static LIST_HEAD(sec_gc_list);
-static spinlock_t sec_gc_list_lock;
+static DEFINE_SPINLOCK(sec_gc_list_lock);
 
 static LIST_HEAD(sec_gc_ctx_list);
-static spinlock_t sec_gc_ctx_list_lock;
+static DEFINE_SPINLOCK(sec_gc_ctx_list_lock);
 
 static atomic_t sec_gc_wait_del = ATOMIC_INIT(0);
 
@@ -176,10 +176,6 @@ static void sec_gc_main(struct work_struct *ws)
 
 int sptlrpc_gc_init(void)
 {
-	mutex_init(&sec_gc_mutex);
-	spin_lock_init(&sec_gc_list_lock);
-	spin_lock_init(&sec_gc_ctx_list_lock);
-
 	schedule_delayed_work(&sec_gc_work, 0);
 	return 0;
 }
-- 
1.8.3.1
