From: Zhouyang Jia <jiazhouyang09@gmail.com>
Date: Tue, 12 Jun 2018 12:49:26 +0800
Subject: [lustre-devel] [PATCH] staging: lustre: add error handling for
 try_module_get
Message-ID: <1528778968-42225-1-git-send-email-jiazhouyang09@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Zhouyang Jia <jiazhouyang09@gmail.com>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, NeilBrown <neilb@suse.com>, Haneen Mohammed <hamohammed.sa@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, "Gustavo A. R. Silva" <garsilva@embeddedor.com>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

When try_module_get fails, the lack of error-handling code may
cause unexpected results.

This patch adds error-handling code after calling try_module_get.

Signed-off-by: Zhouyang Jia <jiazhouyang09@gmail.com>
---
 drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index 7086678..72a42bd 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -2422,7 +2422,10 @@ ksocknal_base_startup(void)
 
 	/* flag lists/ptrs/locks initialised */
 	ksocknal_data.ksnd_init = SOCKNAL_INIT_DATA;
-	try_module_get(THIS_MODULE);
+	if (!try_module_get(THIS_MODULE)) {
+		CERROR("%s: cannot get module\n", __func__);
+		goto failed;
+	}
 
 	ksocknal_data.ksnd_sched_info = cfs_percpt_alloc(lnet_cpt_table(),
 							 sizeof(*info));
-- 
2.7.4
