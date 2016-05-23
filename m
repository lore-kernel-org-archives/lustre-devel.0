From: Tobin C Harding <me@tobin.cc>
Date: Mon, 23 May 2016 10:14:22 +1000
Subject: [lustre-devel] [PATCH v2] staging: lustre: llite:
	kzalloc/copy_to_user to memdup_user
Message-ID: <1463962462-14335-1-git-send-email-me@tobin.cc>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

kzalloc call followed by copy_to_user can be replaced by call to memdup_user.

Signed-off-by: Tobin C Harding <me@tobin.cc>
---
 drivers/staging/lustre/lustre/llite/dir.c | 12 +++---------
 1 file changed, 3 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 4b00d1a..85c50e0 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -1076,17 +1076,11 @@ static int copy_and_ioctl(int cmd, struct obd_export *exp,
 	void *copy;
 	int rc;
 
-	copy = kzalloc(size, GFP_NOFS);
-	if (!copy)
-		return -ENOMEM;
-
-	if (copy_from_user(copy, data, size)) {
-		rc = -EFAULT;
-		goto out;
-	}
+	copy = memdup_user(data, size);
+	if (IS_ERR(copy))
+		return PTR_ERR(copy);
 
 	rc = obd_iocontrol(cmd, exp, size, copy, NULL);
-out:
 	kfree(copy);
 
 	return rc;
-- 
2.8.2
