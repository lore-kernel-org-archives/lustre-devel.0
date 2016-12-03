From: Pan Bian <bianpan201602@163.com>
Date: Sat,  3 Dec 2016 20:52:55 +0800
Subject: [lustre-devel] [PATCH 1/1] staging: lustre: lnet: fix improper
	return value
Message-ID: <1480769575-6074-1-git-send-email-bianpan201602@163.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dmitry Eremin <dmitry.eremin@intel.com>, Frank Zago <fzago@cray.com>
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, Pan Bian <bianpan2016@163.com>

From: Pan Bian <bianpan2016@163.com>

At the end of function lstcon_group_info(), "return 0" seems improper.
It may be better to return the value of rc.

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=188811

Signed-off-by: Pan Bian <bianpan2016@163.com>
---
 drivers/staging/lustre/lnet/selftest/console.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index a0fcbf3..9a7c41a 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -820,7 +820,7 @@
 
 	lstcon_group_decref(grp);
 
-	return 0;
+	return rc;
 }
 
 static int
-- 
1.9.1
