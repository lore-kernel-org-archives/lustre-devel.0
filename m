From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:50 -0500
Subject: [lustre-devel] [PATCH 422/622] lustre: lov: Correct write_intent
 end for trunc
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-423-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <pfarrell@whamcloud.com>

When instantiating a layout, the server interprets the
write intent from the client as the range [start, end), not
including the last byte.

This is correct for writes because the last byte given for
a write is actually 'endpos', the resulting file pointer
position, and so is not included.

However, truncate is specifying a size, not an endpos, so
truncate is [start, size].  To make this work with the
[start, end) processing for write_intents, we have to add
1 to the size when sending a write intent.

Without this, a truncate operation to the first byte of a
new layout component fails silently because the component
is not instantiated.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12586
Lustre-commit: c32c7401426d ("LU-12586 lov: Correct write_intent end for trunc")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35607
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_io.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index 9328240..6e86efa 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -555,7 +555,15 @@ static int lov_io_slice_init(struct lov_io *lio, struct lov_object *obj,
 	 */
 	if (cl_io_is_trunc(io)) {
 		io->ci_write_intent.e_start = 0;
-		io->ci_write_intent.e_end = io->u.ci_setattr.sa_attr.lvb_size;
+		/* for writes, e_end is endpos, the location of the file
+		 * pointer after the write is completed, so it is not accessed.
+		 * For truncate, 'end' is the size, and *is* acccessed.
+		 * In other words, writes are [start, end), but truncate is
+		 * [start, size], where both are included.  So add 1 to the
+		 * size when creating the write intent to account for this.
+		 */
+		io->ci_write_intent.e_end =
+			io->u.ci_setattr.sa_attr.lvb_size + 1;
 	} else {
 		io->ci_write_intent.e_start = lio->lis_pos;
 		io->ci_write_intent.e_end = lio->lis_endpos;
-- 
1.8.3.1
