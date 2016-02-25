From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 24 Feb 2016 22:00:36 -0500
Subject: [lustre-devel] [PATCH v2 53/84] staging/lustre/obdecho: Adjust
	comments to better conform to coding style
In-Reply-To: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
References: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456369267-904461-54-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

This patch fixes "Block comments use a trailing */ on a separate line"
warnings from checkpatch

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/obdecho/echo_client.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index ca87cc2..3be28c5 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -746,7 +746,8 @@ static struct lu_device *echo_device_alloc(const struct lu_env *env,
 	cleanup = 4;
 
 	/* if echo client is to be stacked upon ost device, the next is
-	 * NULL since ost is not a clio device so far */
+	 * NULL since ost is not a clio device so far
+	 */
 	if (next && !lu_device_is_cl(next))
 		next = NULL;
 
@@ -965,7 +966,8 @@ static struct echo_object *cl_echo_object_find(struct echo_device *d,
 	}
 
 	/* In the function below, .hs_keycmp resolves to
-	 * lu_obj_hop_keycmp() */
+	 * lu_obj_hop_keycmp()
+	 */
 	/* coverity[overrun-buffer-val] */
 	obj = cl_object_find(env, echo_dev2cl(d), fid, &conf->eoc_cl);
 	if (IS_ERR(obj)) {
@@ -1164,7 +1166,8 @@ static int cl_echo_object_brw(struct echo_object *eco, int rw, u64 offset,
 		cl_page_list_add(&queue->c2_qin, clp);
 
 		/* drop the reference count for cl_page_find, so that the page
-		 * will be freed in cl_2queue_fini. */
+		 * will be freed in cl_2queue_fini.
+		 */
 		cl_page_put(env, clp);
 		cl_page_clip(env, clp, 0, page_size);
 
-- 
2.1.0
