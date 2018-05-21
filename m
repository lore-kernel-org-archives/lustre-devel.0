From: NeilBrown <neilb@suse.com>
Date: Mon, 21 May 2018 14:35:12 +1000
Subject: [lustre-devel] [PATCH 01/30] staging: lustre: osc: tidy up
 osc_init()
In-Reply-To: <152687724799.24196.7718555295926047576.stgit@noble>
References: <152687724799.24196.7718555295926047576.stgit@noble>
Message-ID: <152687731236.24196.10368250333367714084.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

A module_init() function that registers the services
of the module should do that last, after all other
initialization has succeeded.
This patch moves the class_register_type() call to the
end and ensures everything else that might have been
set up, is cleaned up on error.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/osc/osc_request.c |   29 +++++++++++++----------
 1 file changed, 16 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 0038e555e905..0b5245741e42 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -2837,19 +2837,14 @@ static int __init osc_init(void)
 
 	lprocfs_osc_init_vars(&lvars);
 
-	rc = class_register_type(&osc_obd_ops, NULL,
-				 LUSTRE_OSC_NAME, &osc_device_type);
-	if (rc)
-		goto out_kmem;
-
 	rc = register_shrinker(&osc_cache_shrinker);
 	if (rc)
-		goto out_type;
+		goto err;
 
 	/* This is obviously too much memory, only prevent overflow here */
 	if (osc_reqpool_mem_max >= 1 << 12 || osc_reqpool_mem_max == 0) {
 		rc = -EINVAL;
-		goto out_type;
+		goto err;
 	}
 
 	reqpool_size = osc_reqpool_mem_max << 20;
@@ -2870,14 +2865,22 @@ static int __init osc_init(void)
 	osc_rq_pool = ptlrpc_init_rq_pool(0, OST_MAXREQSIZE,
 					  ptlrpc_add_rqs_to_pool);
 
-	if (osc_rq_pool)
-		return 0;
-
 	rc = -ENOMEM;
 
-out_type:
-	class_unregister_type(LUSTRE_OSC_NAME);
-out_kmem:
+	if (!osc_rq_pool)
+		goto err;
+
+	rc = class_register_type(&osc_obd_ops, NULL,
+				 LUSTRE_OSC_NAME, &osc_device_type);
+	if (rc)
+		goto err;
+
+	return rc;
+
+err:
+	if (osc_rq_pool)
+		ptlrpc_free_rq_pool(osc_rq_pool);
+	unregister_shrinker(&osc_cache_shrinker);
 	lu_kmem_fini(osc_caches);
 	return rc;
 }
