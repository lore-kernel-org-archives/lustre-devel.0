From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:20 -0500
Subject: [lustre-devel] [PATCH 212/622] lustre: llite: Initialize
 cl_dirty_max_pages
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-213-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <pfarrell@whamcloud.com>

cl_dirty_max_pages must be initialized to zero before
calling client_adjust_max_dirty.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11919
Lustre-commit: 2e9c896dec6d ("LU-11919 llite: Initialize cl_dirty_max_pages")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34173
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_lib.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/lustre/ldlm/ldlm_lib.c b/fs/lustre/ldlm/ldlm_lib.c
index 5fe5711..11955b1 100644
--- a/fs/lustre/ldlm/ldlm_lib.c
+++ b/fs/lustre/ldlm/ldlm_lib.c
@@ -315,6 +315,7 @@ int client_obd_setup(struct obd_device *obddev, struct lustre_cfg *lcfg)
 		     sizeof(server_uuid)));
 
 	cli->cl_dirty_pages = 0;
+	cli->cl_dirty_max_pages = 0;
 	cli->cl_avail_grant = 0;
 	/* FIXME: Should limit this for the sum of all cl_dirty_max_pages. */
 	/*
-- 
1.8.3.1
