From: Oleg Drokin <green@linuxhacker.ru>
Date: Mon, 20 Jun 2016 16:55:44 -0400
Subject: [lustre-devel] [PATCH v2 21/29] staging/lustre/llite: don't panic
	when fid is insane
In-Reply-To: <1466456152-2199975-1-git-send-email-green@linuxhacker.ru>
References: <1466456152-2199975-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1466456152-2199975-22-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Sergey Cheremencev <sergey.cheremencev@seagate.com>, Oleg Drokin <green@linuxhacker.ru>

From: Sergey Cheremencev <sergey.cheremencev@seagate.com>

LASSERT should never be done on data that is
received to over the network. Return EINVAL
when server returns invalid fid despite of
it_status == 0.

Signed-off-by: Sergey Cheremencev <sergey.cheremencev@seagate.com>
Seagate-bug-id: MRP-3073
Reviewed-on: http://review.whamcloud.com/17985
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7422
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/llite_lib.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 539fdd1..118e41d 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1971,7 +1971,13 @@ int ll_prep_inode(struct inode **inode, struct ptlrpc_request *req,
 		 * At this point server returns to client's same fid as client
 		 * generated for creating. So using ->fid1 is okay here.
 		 */
-		LASSERT(fid_is_sane(&md.body->fid1));
+		if (!fid_is_sane(&md.body->fid1)) {
+			CERROR("%s: Fid is insane " DFID "\n",
+			       ll_get_fsname(sb, NULL, 0),
+			       PFID(&md.body->fid1));
+			rc = -EINVAL;
+			goto out;
+		}
 
 		*inode = ll_iget(sb, cl_fid_build_ino(&md.body->fid1,
 					     sbi->ll_flags & LL_SBI_32BIT_API),
-- 
2.7.4
