From: Oleg Drokin <green@linuxhacker.ru>
Date: Tue,  6 Dec 2016 23:57:37 -0500
Subject: [lustre-devel] [PATCH 2/5] staging/lustre/socklnd: Fix whitespace
	problem
In-Reply-To: <1481086660-1610943-1-git-send-email-green@linuxhacker.ru>
References: <1481086660-1610943-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1481086660-1610943-3-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

checkpatch highlighted there are 8 spaces that could be converted to a tab:
ERROR: code indent should use tabs where possible
+^I^I^I^I^I         */$

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
index 2978014..842c453 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
@@ -334,7 +334,7 @@ struct ksock_conn {
 	atomic_t           ksnc_conn_refcount;/* conn refcount */
 	atomic_t           ksnc_sock_refcount;/* sock refcount */
 	struct ksock_sched *ksnc_scheduler;	/* who schedules this connection
-					         */
+						 */
 	__u32              ksnc_myipaddr;     /* my IP */
 	__u32              ksnc_ipaddr;       /* peer's IP */
 	int                ksnc_port;         /* peer's port */
-- 
2.7.4
