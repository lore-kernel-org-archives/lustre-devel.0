From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:39 -0500
Subject: [lustre-devel] [PATCH 471/622] lustre: osc: remove oti_descr
 oti_handle oti_plist
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-472-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.com>

These three fields in 'struct osc_thread_info' are
unused, so remove them.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: 3bc9a5e32542 ("LU-6142 osc: remove oti_descr oti_handle oti_plist")
Signed-off-by: Mr NeilBrown <neilb@suse.com>
Reviewed-on: https://review.whamcloud.com/35889
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Arshad Hussain <arshad.super@gmail.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_osc.h | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index 37e56ef..044185d 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -176,10 +176,7 @@ struct osc_session {
 struct osc_thread_info {
 	struct ldlm_res_id	oti_resname;
 	union ldlm_policy_data	oti_policy;
-	struct cl_lock_descr	oti_descr;
 	struct cl_attr		oti_attr;
-	struct lustre_handle	oti_handle;
-	struct cl_page_list	oti_plist;
 	struct cl_io		oti_io;
 	struct pagevec		oti_pagevec;
 	void			*oti_pvec[OTI_PVEC_SIZE];
-- 
1.8.3.1
