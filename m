From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 22 Jan 2018 13:26:14 +0300
Subject: [lustre-devel] [PATCH] staging: lustre: libcfs: Prevent harmless
 read underflow
Message-ID: <20180122102614.GC23912@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Because this is a post-op instead of a pre-op, then it means we check
if knl_buffer[-1] is a space.  It doesn't really hurt anything, but
it causes a static checker warning so let's fix it.

Fixes: d7e09d0397e8 ("staging: add Lustre file system client support")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.c b/drivers/staging/lustre/lnet/libcfs/tracefile.c
index da2844f37edf..57913aae1d88 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.c
@@ -785,7 +785,7 @@ int cfs_trace_copyin_string(char *knl_buffer, int knl_buffer_nob,
 		return -EFAULT;
 
 	nob = strnlen(knl_buffer, usr_buffer_nob);
-	while (nob-- >= 0)		      /* strip trailing whitespace */
+	while (--nob >= 0)		      /* strip trailing whitespace */
 		if (!isspace(knl_buffer[nob]))
 			break;
 
