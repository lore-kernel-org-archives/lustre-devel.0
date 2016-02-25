From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 24 Feb 2016 21:59:45 -0500
Subject: [lustre-devel] [PATCH v2 02/84] staging/lustre/fld: Remove useless
	typedefs
In-Reply-To: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
References: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456369267-904461-3-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Typedefs fld_hash_func_t and fld_scan_func_t are used exectly once in
the following structure so don't really help anything at all.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/fld/fld_internal.h | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lustre/fld/fld_internal.h b/drivers/staging/lustre/lustre/fld/fld_internal.h
index 59eabda..ee36d6b 100644
--- a/drivers/staging/lustre/lustre/fld/fld_internal.h
+++ b/drivers/staging/lustre/lustre/fld/fld_internal.h
@@ -58,15 +58,10 @@ struct fld_stats {
 	__u64   fst_inflight;
 };
 
-typedef int (*fld_hash_func_t) (struct lu_client_fld *, __u64);
-
-typedef struct lu_fld_target *
-(*fld_scan_func_t) (struct lu_client_fld *, __u64);
-
 struct lu_fld_hash {
 	const char	      *fh_name;
-	fld_hash_func_t	  fh_hash_func;
-	fld_scan_func_t	  fh_scan_func;
+	int (*fh_hash_func)(struct lu_client_fld *, __u64);
+	struct lu_fld_target *(*fh_scan_func)(struct lu_client_fld *, __u64);
 };
 
 struct fld_cache_entry {
-- 
2.1.0
