From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 24 Feb 2016 22:01:05 -0500
Subject: [lustre-devel] [PATCH v2 82/84] staging/lustre: Rework MAX_DIO_SIZE
	macro
In-Reply-To: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
References: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456369267-904461-83-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

KMALLOC_MAX_SIZE is always defined in the kernel, so no point
in checking for it, just use t directly.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/rw26.c | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index b9d8e73..7a5db67 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -350,20 +350,14 @@ static ssize_t ll_direct_IO_26_seg(const struct lu_env *env, struct cl_io *io,
 	return ll_direct_rw_pages(env, io, rw, inode, &pvec);
 }
 
-#ifdef KMALLOC_MAX_SIZE
-#define MAX_MALLOC KMALLOC_MAX_SIZE
-#else
-#define MAX_MALLOC (128 * 1024)
-#endif
-
 /* This is the maximum size of a single O_DIRECT request, based on the
  * kmalloc limit.  We need to fit all of the brw_page structs, each one
  * representing PAGE_SIZE worth of user data, into a single buffer, and
  * then truncate this to be a full-sized RPC.  For 4kB PAGE_SIZE this is
  * up to 22MB for 128kB kmalloc and up to 682MB for 4MB kmalloc.
  */
-#define MAX_DIO_SIZE ((MAX_MALLOC / sizeof(struct brw_page) * PAGE_CACHE_SIZE) & \
-		      ~(DT_MAX_BRW_SIZE - 1))
+#define MAX_DIO_SIZE ((KMALLOC_MAX_SIZE / sizeof(struct brw_page) *	  \
+		       PAGE_CACHE_SIZE) & ~(DT_MAX_BRW_SIZE - 1))
 static ssize_t ll_direct_IO_26(struct kiocb *iocb, struct iov_iter *iter,
 			       loff_t file_offset)
 {
-- 
2.1.0
