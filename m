From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:17 -0500
Subject: [lustre-devel] [PATCH 509/622] lustre: llite: limit max xattr size
 by kernel value
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-510-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Limit the maximum xattr size returned to userspace from the MDS to
what the currently-running kernel supports (XATTR_SIZE_MAX=65536
bytes typically).  While it is possible a Lustre backing filesystem
may store larger xattrs than this, it wouldn't be possible for users
to access a larger xattr via kernel xattr interfaces.

This fixes interop problems when newer clients and tests are running
against older servers:

  sanity.sh: line 8946: /usr/bin/setfattr: Argument list too long

Skip subtests for new features in 2.13 so 2.12 interop testing passes.

Fix test-framework.sh::large_xattr_enabled() to return true for ZFS.
Fix test-framework.sh::max_xattr_size() to return the actual value
returned from the MDS rather than computing it locally.

Fixes: 4c9f501e6d5 ("lustre: osd: Set max ea size to XATTR_SIZE_MAX")
WC-bug-id: https://jira.whamcloud.com/browse/LU-12784
Lustre-commit: 84097792f56c ("LU-12784 llite: limit max xattr size by kernel value")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/36240
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/lproc_llite.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index c2ec3fb..439c096 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -925,7 +925,9 @@ static ssize_t max_easize_show(struct kobject *kobj,
 	if (rc)
 		return rc;
 
-	return sprintf(buf, "%u\n", ealen);
+	/* Limit xattr size returned to userspace based on kernel maximum */
+	return snprintf(buf, PAGE_SIZE, "%u\n",
+			ealen > XATTR_SIZE_MAX ? XATTR_SIZE_MAX : ealen);
 }
 LUSTRE_RO_ATTR(max_easize);
 
@@ -954,7 +956,9 @@ static ssize_t default_easize_show(struct kobject *kobj,
 	if (rc)
 		return rc;
 
-	return sprintf(buf, "%u\n", ealen);
+	/* Limit xattr size returned to userspace based on kernel maximum */
+	return snprintf(buf, PAGE_SIZE, "%u\n",
+			ealen > XATTR_SIZE_MAX ? XATTR_SIZE_MAX : ealen);
 }
 
 /**
-- 
1.8.3.1
