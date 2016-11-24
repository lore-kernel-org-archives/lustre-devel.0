From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 24 Nov 2016 14:12:04 +0300
Subject: [lustre-devel] [patch] staging: lustre/ptlrpc: small leak on
	allocation failure
Message-ID: <20161124111204.GH17225@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>
Cc: Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Liang Zhen <liang.zhen@intel.com>, Vitaly Fertman <vitaly_fertman@xyratex.com>, frank zago <fzago@cray.com>, Sebastien Buisson <sebastien.buisson@bull.net>, Amir Shehata <amir.shehata@intel.com>, Niu Yawei <yawei.niu@intel.com>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org

We should free "desc" before returning NULL.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index ac959ef..8047413 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -128,12 +128,12 @@ struct ptlrpc_bulk_desc *ptlrpc_new_bulk(unsigned int nfrags,
 		GET_KIOV(desc) = kcalloc(nfrags, sizeof(*GET_KIOV(desc)),
 					 GFP_NOFS);
 		if (!GET_KIOV(desc))
-			goto out;
+			goto free_desc;
 	} else {
 		GET_KVEC(desc) = kcalloc(nfrags, sizeof(*GET_KVEC(desc)),
 					 GFP_NOFS);
 		if (!GET_KVEC(desc))
-			goto out;
+			goto free_desc;
 	}
 
 	spin_lock_init(&desc->bd_lock);
@@ -154,7 +154,8 @@ struct ptlrpc_bulk_desc *ptlrpc_new_bulk(unsigned int nfrags,
 		LNetInvalidateHandle(&desc->bd_mds[i]);
 
 	return desc;
-out:
+free_desc:
+	kfree(desc);
 	return NULL;
 }
 
