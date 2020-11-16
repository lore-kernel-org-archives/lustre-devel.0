From: James Simmons <jsimmons@infradead.org>
Date: Sun, 15 Nov 2020 20:00:00 -0500
Subject: [lustre-devel] [PATCH 27/28] lustre: sec: require enc key in case
 of O_CREAT only
In-Reply-To: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
References: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1605488401-981-28-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sebastien Buisson <sbuisson@ddn.com>

In ll_atomic_open(), do not return -ENOKEY when trying to open
either a directory or a file without the encryption key, unless
O_CREAT flag is specified.
Indeed, listing directory content is allowed even without the key.
And in case of regular file, ll_file_open() already checks for the
presence of an encryption key.

Improve sanity-sec test_54 to verify this is working properly.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13975
Lustre-commit: f6daee15b2c8ec ("LU-13975 sec: require enc key in case of O_CREAT only")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/39983
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/namei.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index da6b729..b24f097 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -1113,18 +1113,19 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 	it->it_flags &= ~MDS_OPEN_FL_INTERNAL;
 
 	if (ll_sbi_has_encrypt(ll_i2sbi(dir)) && IS_ENCRYPTED(dir)) {
-		/* we know that we are going to create a regular file because
+		/* in case of create, this is going to be a regular file because
 		 * we set S_IFREG bit on it->it_create_mode above
 		 */
 		rc = llcrypt_get_encryption_info(dir);
 		if (rc)
 			goto out_release;
-		if (!llcrypt_has_encryption_key(dir)) {
-			rc = -ENOKEY;
-			goto out_release;
+		if (open_flags & O_CREAT) {
+			if (!llcrypt_has_encryption_key(dir)) {
+				rc = -ENOKEY;
+				goto out_release;
+			}
+			encrypt = true;
 		}
-		encrypt = true;
-		rc = 0;
 	}
 
 	OBD_FAIL_TIMEOUT(OBD_FAIL_LLITE_CREATE_FILE_PAUSE2, cfs_fail_val);
-- 
1.8.3.1
