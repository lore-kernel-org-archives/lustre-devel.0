From: James Simmons <jsimmons@infradead.org>
Date: Sat,  7 Jul 2018 20:14:20 -0400
Subject: [lustre-devel] [PATCH v4 06/14] lustre: libcfs: fix
 cfs_print_to_console()
In-Reply-To: <1531008868-4194-1-git-send-email-jsimmons@infradead.org>
References: <1531008868-4194-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1531008868-4194-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The original code for cfs_print_to_console() used printk() and
used tricks to select which printk level to use. Later a cleanup
patch landed the just converted printk directly to pr_info which
is not exactly correct. Instead of converting back to printk lets
move everything to pr_* type functions which simplify the code.
This allows us to fold both dbghdr_to_err_string() and the
function dbghdr_to_info_string() into cfs_print_to_console().

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/libcfs/linux-tracefile.c   | 69 ++++++++--------------
 1 file changed, 26 insertions(+), 43 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c b/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c
index 7c864d0..ef26835 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c
@@ -149,55 +149,38 @@ enum cfs_trace_buf_type cfs_trace_buf_idx_get(void)
 	header->ph_extern_pid = 0;
 }
 
-static char *
-dbghdr_to_err_string(struct ptldebug_header *hdr)
-{
-	switch (hdr->ph_subsys) {
-	case S_LND:
-	case S_LNET:
-		return "LNetError";
-	default:
-		return "LustreError";
-	}
-}
-
-static char *
-dbghdr_to_info_string(struct ptldebug_header *hdr)
-{
-	switch (hdr->ph_subsys) {
-	case S_LND:
-	case S_LNET:
-		return "LNet";
-	default:
-		return "Lustre";
-	}
-}
-
 void cfs_print_to_console(struct ptldebug_header *hdr, int mask,
 			  const char *buf, int len, const char *file,
 			  const char *fn)
 {
-	char *prefix = "Lustre", *ptype = NULL;
-
-	if (mask & D_EMERG) {
-		prefix = dbghdr_to_err_string(hdr);
-		ptype = KERN_EMERG;
-	} else if (mask & D_ERROR) {
-		prefix = dbghdr_to_err_string(hdr);
-		ptype = KERN_ERR;
-	} else if (mask & D_WARNING) {
-		prefix = dbghdr_to_info_string(hdr);
-		ptype = KERN_WARNING;
-	} else if (mask & (D_CONSOLE | libcfs_printk)) {
-		prefix = dbghdr_to_info_string(hdr);
-		ptype = KERN_INFO;
-	}
+	char *prefix = "Lustre";
+
+	if (hdr->ph_subsys == S_LND || hdr->ph_subsys == S_LNET)
+		prefix = "LNet";
 
 	if (mask & D_CONSOLE) {
-		pr_info("%s%s: %.*s", ptype, prefix, len, buf);
+		if (mask & D_EMERG)
+			pr_emerg("%sError: %.*s", prefix, len, buf);
+		else if (mask & D_ERROR)
+			pr_err("%sError: %.*s", prefix, len, buf);
+		else if (mask & D_WARNING)
+			pr_warn("%s: %.*s", prefix, len, buf);
+		else if (mask & libcfs_printk)
+			pr_info("%s: %.*s", prefix, len, buf);
 	} else {
-		pr_info("%s%s: %d:%d:(%s:%d:%s()) %.*s", ptype, prefix,
-			hdr->ph_pid, hdr->ph_extern_pid, file,
-			hdr->ph_line_num, fn, len, buf);
+		if (mask & D_EMERG)
+			pr_emerg("%sError: %d:%d:(%s:%d:%s()) %.*s", prefix,
+				 hdr->ph_pid, hdr->ph_extern_pid, file,
+				 hdr->ph_line_num, fn, len, buf);
+		else if (mask & D_ERROR)
+			pr_err("%sError: %d:%d:(%s:%d:%s()) %.*s", prefix,
+			       hdr->ph_pid, hdr->ph_extern_pid, file,
+			       hdr->ph_line_num, fn, len, buf);
+		else if (mask & D_WARNING)
+			pr_warn("%s: %d:%d:(%s:%d:%s()) %.*s", prefix,
+				hdr->ph_pid, hdr->ph_extern_pid, file,
+				hdr->ph_line_num, fn, len, buf);
+		else if (mask & (D_CONSOLE | libcfs_printk))
+			pr_info("%s: %.*s", prefix, len, buf);
 	}
 }
-- 
1.8.3.1
