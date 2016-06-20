From: Oleg Drokin <green@linuxhacker.ru>
Date: Sun, 19 Jun 2016 22:07:40 -0400
Subject: [lustre-devel] [PATCH 25/28] staging/lustre/llite:
	IOC_MDC_GETFILEINFO returns the wrong ino
In-Reply-To: <1466388463-1817551-1-git-send-email-green@linuxhacker.ru>
References: <1466388463-1817551-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1466388463-1817551-26-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, akam kumar bharathi <azurelustre@gmail.com>, John Hammond <john.hammond@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: akam kumar bharathi <azurelustre@gmail.com>

req_capsule_server_get() through  __req_capsule_get in ll_dir_ioctl()
returns a pointer to a PTLRPC request or reply buffer, which is assigned
to struct mdt_body.

If the command is IOC_MDS_GETFILEINFO then the inode "st.st_ino" should
be assigned from one extracted from mdt_body through cl_fid_build_ino().

Signed-off-by: John Hammond <john.hammond@intel.com>
Signed-off-by: akam kumar bharathi <azurelustre@gmail.com>
Reviewed-on: http://review.whamcloud.com/17618
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5954
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/dir.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index f0eb64b..7e7425d 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -1528,7 +1528,9 @@ skip_lmm:
 			st.st_atime   = body->atime;
 			st.st_mtime   = body->mtime;
 			st.st_ctime   = body->ctime;
-			st.st_ino     = inode->i_ino;
+			st.st_ino     = cl_fid_build_ino(&body->fid1,
+							 sbi->ll_flags &
+							 LL_SBI_32BIT_API);
 
 			lmdp = (struct lov_user_mds_data __user *)arg;
 			if (copy_to_user(&lmdp->lmd_st, &st, sizeof(st))) {
-- 
2.7.4
