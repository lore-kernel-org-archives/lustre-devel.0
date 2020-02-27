From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:09 -0500
Subject: [lustre-devel] [PATCH 141/622] lustre: uapi: add new changerec_type
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-142-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Qian Yingjin <qian@ddn.com>

The Lazy Size on MDT is causing the trusted.som xattr to be logged
in the changelog whenever a file is needed to update this xattr
data casued by file open/close or truncate operations.

The original patch landed to the OpenSFS branch fixes this problem
to avoid logging this xattr for every file. This introduces a new
changelog_rec_type that the mdc changelog code needs to be aware
of.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11450
Lustre-commit: faf6f514c172 ("LU-11450 mdd: avoid logging trusted.som xattr in changelogs")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/33323
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/uapi/linux/lustre/lustre_user.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index bff6f76..844e50e 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -966,6 +966,7 @@ enum la_valid {
 /********* Changelogs **********/
 /** Changelog record types */
 enum changelog_rec_type {
+	CL_NONE		= -1,
 	CL_MARK		= 0,
 	CL_CREATE	= 1,  /* namespace */
 	CL_MKDIR	= 2,  /* namespace */
-- 
1.8.3.1
