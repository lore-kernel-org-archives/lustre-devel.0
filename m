From: Oleg Drokin <green@linuxhacker.ru>
Date: Tue,  6 Dec 2016 23:57:40 -0500
Subject: [lustre-devel] [PATCH 5/5] staging/lustre/o2iblnd: Fix misspelled
	attemps->attempts
In-Reply-To: <1481086660-1610943-1-git-send-email-green@linuxhacker.ru>
References: <1481086660-1610943-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1481086660-1610943-6-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

Highlighted by checkpatch:
WARNING: 'attemps' may be misspelled - perhaps 'attempts'?
#20278: FILE: drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c:3272:
+ * reconnection attemps.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index bea408d..c7917ab 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -3269,7 +3269,7 @@ kiblnd_disconnect_conn(struct kib_conn *conn)
 #define KIB_RECONN_HIGH_RACE	10
 /**
  * Allow connd to take a break and handle other things after consecutive
- * reconnection attemps.
+ * reconnection attempts.
  */
 #define KIB_RECONN_BREAK	100
 
-- 
2.7.4
