From: Shreeya Patel <shreeya.patel23498@gmail.com>
Date: Sun, 17 Jun 2018 16:46:55 +0530
Subject: [lustre-devel] [PATCH] Staging: lustre: Use kmemdup() instead of
 kzalloc and memcpy
Message-ID: <1529234215-4010-1-git-send-email-shreeya.patel23498@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, gregkh@linuxfoundation.org, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org
Cc: Shreeya Patel <shreeya.patel23498@gmail.com>

Replace calls to kzalloc or kmalloc followed by a memcpy with
a direct call to kmemdup to shorten the code.

The Coccinelle semantic patch used to make this change is as follows:
@@
expression from,to,size,flag;
statement S;
@@

-  to = \(kmalloc\|kzalloc\)(size,flag);
+  to = kmemdup(from,size,flag);
   if (to==NULL || ...) S
-  memcpy(to, from, size);

Signed-off-by: Shreeya Patel <shreeya.patel23498@gmail.com>
---
 drivers/staging/lustre/lnet/lnet/api-ni.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index f9ed697..36ea14e 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1271,15 +1271,14 @@ lnet_startup_lndni(struct lnet_ni *ni, struct lnet_ioctl_config_data *conf)
 		lnd_tunables = (struct lnet_ioctl_config_lnd_tunables *)conf->cfg_bulk;
 
 	if (lnd_tunables) {
-		ni->ni_lnd_tunables = kzalloc(sizeof(*ni->ni_lnd_tunables),
+		ni->ni_lnd_tunables = kmemdup(lnd_tunables,
+					      sizeof(*ni->ni_lnd_tunables),
 					      GFP_NOFS);
 		if (!ni->ni_lnd_tunables) {
 			mutex_unlock(&the_lnet.ln_lnd_mutex);
 			rc = -ENOMEM;
 			goto failed0;
 		}
-		memcpy(ni->ni_lnd_tunables, lnd_tunables,
-		       sizeof(*ni->ni_lnd_tunables));
 	}
 
 	/*
-- 
2.7.4
