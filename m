From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:05:22 -0500
Subject: [lustre-devel] [PATCH 54/60] staging: lustre: fid: Change
	positional struct initializers to C99
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-55-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Steve Guminski <stephenx.guminski@intel.com>, James Simmons <jsimmons@infradead.org>

From: Steve Guminski <stephenx.guminski@intel.com>

This patch makes no functional changes.  Struct initializers in the
fid directory that use C89 or GCC-only syntax are updated to C99
syntax.

The C99 syntax prevents incorrect initialization if values are
accidently placed in the wrong position, allows changes in the struct
definition, and clears any members that are not given an explicit
value.

The following struct initializers have been updated:

lustre/fid/fid_lib.c:
        const struct lu_seq_range LUSTRE_SEQ_SPACE_RANGE
        const struct lu_seq_range LUSTRE_SEQ_ZERO_RANGE
lustre/fid/lproc_fid.c:
        struct lprocfs_vars seq_client_debugfs_list

Signed-off-by: Steve Guminski <stephenx.guminski@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6210
Reviewed-on: https://review.whamcloud.com/23789
Reviewed-by: Nathaniel Clark <nathaniel.l.clark@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/fid/fid_lib.c   |  7 +++----
 drivers/staging/lustre/lustre/fid/lproc_fid.c | 12 ++++++++----
 2 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/lustre/fid/fid_lib.c b/drivers/staging/lustre/lustre/fid/fid_lib.c
index 4e49cb3..9eb4059 100644
--- a/drivers/staging/lustre/lustre/fid/fid_lib.c
+++ b/drivers/staging/lustre/lustre/fid/fid_lib.c
@@ -60,14 +60,13 @@
  * FID_SEQ_START + 2 is for .lustre directory and its objects
  */
 const struct lu_seq_range LUSTRE_SEQ_SPACE_RANGE = {
-	FID_SEQ_NORMAL,
-	(__u64)~0ULL
+	.lsr_start	= FID_SEQ_NORMAL,
+	.lsr_end	= (__u64)~0ULL,
 };
 
 /* Zero range, used for init and other purposes. */
 const struct lu_seq_range LUSTRE_SEQ_ZERO_RANGE = {
-	0,
-	0
+	.lsr_start	= 0,
 };
 
 /* Lustre Big Fs Lock fid. */
diff --git a/drivers/staging/lustre/lustre/fid/lproc_fid.c b/drivers/staging/lustre/lustre/fid/lproc_fid.c
index 97d4849..3eed838 100644
--- a/drivers/staging/lustre/lustre/fid/lproc_fid.c
+++ b/drivers/staging/lustre/lustre/fid/lproc_fid.c
@@ -203,9 +203,13 @@
 LPROC_SEQ_FOPS_RO(ldebugfs_fid_fid);
 
 struct lprocfs_vars seq_client_debugfs_list[] = {
-	{ "space", &ldebugfs_fid_space_fops },
-	{ "width", &ldebugfs_fid_width_fops },
-	{ "server", &ldebugfs_fid_server_fops },
-	{ "fid", &ldebugfs_fid_fid_fops },
+	{ .name =	"space",
+	  .fops =	&ldebugfs_fid_space_fops },
+	{ .name	=	"width",
+	  .fops =	&ldebugfs_fid_width_fops },
+	{ .name =	"server",
+	  .fops =	&ldebugfs_fid_server_fops },
+	{ .name	=	"fid",
+	  .fops =	&ldebugfs_fid_fid_fops },
 	{ NULL }
 };
-- 
1.8.3.1
