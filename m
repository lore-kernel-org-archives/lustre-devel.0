From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:12 -0500
Subject: [lustre-devel] [PATCH 144/622] lustre: osc: re-check target versus
 available grant
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-145-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alex Zhuravlev <bzzz@whamcloud.com>

- under the spinlock, otherwise it's possible that available
  grant has changed since target calculation and bytes to
  shrink go negative.
- tgt_grant_alloc() should avoid negative grants

WC-bug-id: https://jira.whamcloud.com/browse/LU-11288
Lustre-commit: fcbd8c981239 ("LU-11288 osc: re-check target versus available grant")
Signed-off-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33226
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_request.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 4524a98..18b99a9 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -811,6 +811,12 @@ int osc_shrink_grant_to_target(struct client_obd *cli, u64 target_bytes)
 	osc_announce_cached(cli, &body->oa, 0);
 
 	spin_lock(&cli->cl_loi_list_lock);
+	if (target_bytes >= cli->cl_avail_grant) {
+		/* available grant has changed since target calculation */
+		spin_unlock(&cli->cl_loi_list_lock);
+		rc = 0;
+		goto out_free;
+	}
 	body->oa.o_grant = cli->cl_avail_grant - target_bytes;
 	cli->cl_avail_grant = target_bytes;
 	spin_unlock(&cli->cl_loi_list_lock);
@@ -826,6 +832,7 @@ int osc_shrink_grant_to_target(struct client_obd *cli, u64 target_bytes)
 				sizeof(*body), body, NULL);
 	if (rc != 0)
 		__osc_update_grant(cli, body->oa.o_grant);
+out_free:
 	kfree(body);
 	return rc;
 }
-- 
1.8.3.1
