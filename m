From: NeilBrown <neilb@suse.com>
Date: Fri, 26 Oct 2018 12:39:38 +1100
Subject: [lustre-devel] [PATCH] lustre: initialize libcfs_debug_file_path
Message-ID: <87y3al4hb9.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


This variable is assumed by the code to either
be "NONE" or a file name - it shouldn't be NULL.

So initialise to the compiled default.

Signed-off-by: NeilBrown <neilb@suse.com>
---

I'm going though failed tests, looking for things to fix.
This fixes 77c.

 drivers/staging/lustre/lnet/libcfs/debug.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/debug.c b/drivers/staging/lustre/lnet/libcfs/debug.c
index 90d756c83520..f9544367389d 100644
--- a/drivers/staging/lustre/lnet/libcfs/debug.c
+++ b/drivers/staging/lustre/lnet/libcfs/debug.c
@@ -224,7 +224,7 @@ char libcfs_debug_file_path_arr[PATH_MAX] = LIBCFS_DEBUG_FILE_PATH_DEFAULT;
 EXPORT_SYMBOL(libcfs_debug_file_path_arr);
 
 /* We need to pass a pointer here, but elsewhere this must be a const */
-static char *libcfs_debug_file_path;
+static char *libcfs_debug_file_path = LIBCFS_DEBUG_FILE_PATH_DEFAULT;
 module_param(libcfs_debug_file_path, charp, 0644);
 MODULE_PARM_DESC(libcfs_debug_file_path,
 		 "Path for dumping debug logs, set 'NONE' to prevent log dumping");
-- 
2.14.0.rc0.dirty

-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20181026/457e3ef3/attachment.sig>
