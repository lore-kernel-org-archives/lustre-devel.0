From: James Simmons <jsimmons@infradead.org>
Date: Wed,  2 Mar 2016 17:02:06 -0500
Subject: [lustre-devel] [PATCH 23/27] staging: lustre: take extra refcount
	in kiblnd_connreq_done
In-Reply-To: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
References: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456956130-6110-24-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Liang Zhen <liang.zhen@intel.com>

From: Liang Zhen <liang.zhen@intel.com>

refcount taken by cmid is not reliable after kiblnd_connreq_done
released the glock because this connection is visible to other
threads, another thread can find and close this connection right
after kiblnd_connreq_done released the glock, if kiblnd_cm_callback
for RDMA_CM_EVENT_DISCONNECTED is called, it can release the
connection refcount taken by cmid. It means the connection could be
destroyed before kiblnd_connreq_done() finish operations on it.

Signed-off-by: Liang Zhen <liang.zhen@intel.com>
ntel-bug-id: https://jira.hpdd.intel.com/browse/LU-7210
Reviewed-on: http://review.whamcloud.com/17527
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Tested-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |   16 ++++++++++++----
 1 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index fb3873a..11e12ae 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -939,8 +939,6 @@ kiblnd_check_sends(kib_conn_t *conn)
 			kiblnd_queue_tx_locked(tx, conn);
 	}
 
-	kiblnd_conn_addref(conn); /* 1 ref for me.... (see b21911) */
-
 	for (;;) {
 		int credit;
 
@@ -966,8 +964,6 @@ kiblnd_check_sends(kib_conn_t *conn)
 	}
 
 	spin_unlock(&conn->ibc_lock);
-
-	kiblnd_conn_decref(conn); /* ...until here */
 }
 
 static void
@@ -2132,6 +2128,16 @@ kiblnd_connreq_done(kib_conn_t *conn, int status)
 		return;
 	}
 
+	/**
+	 * refcount taken by cmid is not reliable after I released the glock
+	 * because this connection is visible to other threads now, another
+	 * thread can find and close this connection right after I released
+	 * the glock, if kiblnd_cm_callback for RDMA_CM_EVENT_DISCONNECTED is
+	 * called, it can release the connection refcount taken by cmid.
+	 * It means the connection could be destroyed before I finish my
+	 * operations on it.
+	 */
+	kiblnd_conn_addref(conn);
 	write_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
 
 	/* Schedule blocked txs */
@@ -2147,6 +2153,8 @@ kiblnd_connreq_done(kib_conn_t *conn, int status)
 
 	/* schedule blocked rxs */
 	kiblnd_handle_early_rxs(conn);
+
+	kiblnd_conn_decref(conn);
 }
 
 static void
-- 
1.7.1
