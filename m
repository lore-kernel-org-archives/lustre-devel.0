From: James Simmons <jsimmons@infradead.org>
Date: Mon,  5 Oct 2020 20:05:44 -0400
Subject: [lustre-devel] [PATCH 05/42] lustre: llite: add test to check
 client deadlock selinux
In-Reply-To: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
References: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1601942781-24950-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alexander Boyko <alexander.boyko@hpe.com>

Add kernel fault injection to check client deadlock
and MDS eviction for it.

Cray-bug-id: LUS-8924
WC-bug-id: https://jira.whamcloud.com/browse/LU-13617
Lustre-commit: f519f22c8ba3a ("LU-13617 tests: check client deadlock selinux")
Signed-off-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-on: https://review.whamcloud.com/38793
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Andrew Perepechko <andrew.perepechko@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_support.h | 1 +
 fs/lustre/llite/namei.c         | 2 ++
 2 files changed, 3 insertions(+)

diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index 35c7ef3..c678c8b 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -475,6 +475,7 @@
 #define OBD_FAIL_LLITE_PCC_MKWRITE_PAUSE		0x1413
 #define OBD_FAIL_LLITE_PCC_ATTACH_PAUSE			0x1414
 #define OBD_FAIL_LLITE_SHORT_COMMIT			0x1415
+#define OBD_FAIL_LLITE_CREATE_FILE_PAUSE2		0x1416
 
 #define OBD_FAIL_FID_INDIR				0x1501
 #define OBD_FAIL_FID_INLMA				0x1502
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 014a470..ce6cd19 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -1113,6 +1113,8 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 		rc = 0;
 	}
 
+	OBD_FAIL_TIMEOUT(OBD_FAIL_LLITE_CREATE_FILE_PAUSE2, cfs_fail_val);
+
 	/* Dentry added to dcache tree in ll_lookup_it */
 	de = ll_lookup_it(dir, dentry, it, &secctx, &secctxlen, &pca, encrypt,
 			  &encctx, &encctxlen);
-- 
1.8.3.1
