From: James Simmons <jsimmons@infradead.org>
Date: Mon,  5 Oct 2020 20:06:11 -0400
Subject: [lustre-devel] [PATCH 32/42] lustre: llite: it_lock_bits should be
 bit-wise tested
In-Reply-To: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
References: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1601942781-24950-33-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Shaun Tancheff <shaun.tancheff@hpe.com>

If lock_mode is not set then ensure that it_lock_bits has
the MDS_INODELOCK_OPEN bit set

Fixes: e476f2e55aa9e ("staging/lustre/llite: flatten struct lookup_intent")
HPE-bug-id: LUS-9198
WC-bug-id: https://jira.whamcloud.com/browse/LU-13940
Lustre-commit: 86868afde5a5eb ("LU-13940 llite: it_lock_bits should be bit-wise tested")
Signed-off-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-on: https://review.whamcloud.com/39797
Reviewed-by: Petros Koutoupis <petros.koutoupis@hpe.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Yingjin Qian <qian@ddn.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 1d2ab11..de22e191 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -1169,8 +1169,8 @@ static int ll_lease_och_release(struct inode *inode, struct file *file)
 
 	/* already get lease, handle lease lock */
 	ll_set_lock_data(sbi->ll_md_exp, inode, &it, NULL);
-	if (it.it_lock_mode == 0 ||
-	    it.it_lock_bits != MDS_INODELOCK_OPEN) {
+	if (!it.it_lock_mode ||
+	    !(it.it_lock_bits & MDS_INODELOCK_OPEN)) {
 		/* open lock must return for lease */
 		CERROR(DFID "lease granted but no open lock, %d/%llu.\n",
 		       PFID(ll_inode2fid(inode)), it.it_lock_mode,
-- 
1.8.3.1
