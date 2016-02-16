From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 16 Feb 2016 00:46:33 -0500
Subject: [lustre-devel] [PATCH 01/45] staging/lustre/ptlrpc: Get rid of
	/proc references in comments
In-Reply-To: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
References: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455601637-3847710-2-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Now that the sysfs conversion is complete, also convert all the
remaining comments

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre_dlm.h | 2 +-
 drivers/staging/lustre/lustre/include/lustre_net.h | 2 +-
 drivers/staging/lustre/lustre/ptlrpc/recover.c     | 2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    | 2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index 9b319f1..11a841a 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -373,7 +373,7 @@ struct ldlm_namespace {
 
 	/**
 	 * Namespace connect flags supported by server (may be changed via
-	 * /proc, LRU resize may be disabled/enabled).
+	 * sysfs, LRU resize may be disabled/enabled).
 	 */
 	__u64			ns_connect_flags;
 
diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index d834ddd..d9c7267 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -1947,7 +1947,7 @@ struct ptlrpc_service_ops {
  * or general metadata service for MDS.
  */
 struct ptlrpc_service {
-	/** serialize /proc operations */
+	/** serialize sysfs operations */
 	spinlock_t			srv_lock;
 	/** most often accessed fields */
 	/** chain thru all services */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/recover.c b/drivers/staging/lustre/lustre/ptlrpc/recover.c
index db6626c..4359cac 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/recover.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/recover.c
@@ -260,7 +260,7 @@ void ptlrpc_request_handle_notconn(struct ptlrpc_request *failed_req)
  * Administratively active/deactive a client.
  * This should only be called by the ioctl interface, currently
  *  - the lctl deactivate and activate commands
- *  - echo 0/1 >> /proc/osc/XXX/active
+ *  - echo 0/1 >> /sys/fs/lustre/osc/XXX/active
  *  - client umount -f (ll_umount_begin)
  */
 int ptlrpc_set_import_active(struct obd_import *imp, int active)
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
index 22621c7..52a6c51 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
@@ -120,7 +120,7 @@ static struct ptlrpc_enc_page_pool {
 } page_pools;
 
 /*
- * /proc/fs/lustre/sptlrpc/encrypt_page_pools
+ * /sys/kernel/debug/lustre/sptlrpc/encrypt_page_pools
  */
 int sptlrpc_proc_enc_pool_seq_show(struct seq_file *m, void *v)
 {
-- 
2.1.0
