From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 24 Nov 2016 14:10:39 +0300
Subject: [lustre-devel] [patch] staging: lustre: lnet: memory corruption in
	selftest
Message-ID: <20161124110934.GG17225@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

We want sizeof(struct lstcon_node) but instead we're getting the sizeof
a pointer.

Fixes: 8d78f0f2ba76 ("staging: lustre: lnet: cleanup some of the > 80 line issues")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index f2d11fa..f750b9c 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -86,7 +86,7 @@ lstcon_node_find(lnet_process_id_t id, struct lstcon_node **ndpp, int create)
 	if (!create)
 		return -ENOENT;
 
-	LIBCFS_ALLOC(*ndpp, sizeof(*ndpp) + sizeof(*ndl));
+	LIBCFS_ALLOC(*ndpp, sizeof(**ndpp) + sizeof(*ndl));
 	if (!*ndpp)
 		return -ENOMEM;
 
