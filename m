From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:37 -0400
Subject: [lustre-devel] [PATCH 078/151] lustre: hsm: don't release with
 wrong size
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-79-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alexander Boyko <c17825@cray.com>

The result of ll_merge_attr operation was ignored during
ll_hsm_release. For this case the released file could have
the wrong size on MDS, like
File: ?released.file?
Size: 0  Blocks: 0  IO Block: 4194304 regular empty file

WC-bug-id: https://jira.whamcloud.com/browse/LU-10271
Lustre-commit: 09b457fffc8a ("LU-10271 hsm: don't release with wrong size")
Signed-off-by: Alexander Boyko <c17825@cray.com>
Reviewed-on: https://review.whamcloud.com/30240
Reviewed-by: Henri Doreau <henri.doreau@cea.fr>
Reviewed-by: Sergey Cheremencev <c17829@cray.com>
Reviewed-by: Quentin Bouget <quentin.bouget@cea.fr>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_support.h |  1 +
 fs/lustre/llite/file.c          | 13 +++++++++++--
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index 1dce1c0..6a01af4 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -384,6 +384,7 @@
 #define OBD_FAIL_MDC_RPCS_SEM				0x804
 #define OBD_FAIL_MDC_LIGHTWEIGHT			0x805
 #define OBD_FAIL_MDC_CLOSE				0x806
+#define OBD_FAIL_MDC_MERGE				0x807
 
 #define OBD_FAIL_MGS					0x900
 #define OBD_FAIL_MGS_ALL_REQUEST_NET			0x901
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 22e3494..164948c 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -1133,7 +1133,10 @@ int ll_merge_attr(const struct lu_env *env, struct inode *inode)
 	ctime = inode->i_ctime.tv_sec;
 
 	cl_object_attr_lock(obj);
-	rc = cl_object_attr_get(env, obj, attr);
+	if (OBD_FAIL_CHECK(OBD_FAIL_MDC_MERGE))
+		rc = -EINVAL;
+	else
+		rc = cl_object_attr_get(env, obj, attr);
 	cl_object_attr_unlock(obj);
 
 	if (rc != 0) {
@@ -2050,9 +2053,15 @@ int ll_hsm_release(struct inode *inode)
 		goto out;
 	}
 
-	ll_merge_attr(env, inode);
+	rc = ll_merge_attr(env, inode);
 	cl_env_put(env, &refcheck);
 
+	/* If error happen, we have the wrong size for a file.
+	 * Don't release it.
+	 */
+	if (rc != 0)
+		goto out;
+
 	/* Release the file.
 	 * NB: lease lock handle is released in mdc_hsm_release_pack() because
 	 * we still need it to pack l_remote_handle to MDT.
-- 
1.8.3.1
