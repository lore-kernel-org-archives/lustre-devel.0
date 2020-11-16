From: James Simmons <jsimmons@infradead.org>
Date: Sun, 15 Nov 2020 19:59:43 -0500
Subject: [lustre-devel] [PATCH 10/28] lustre: lov: doesn't check lov_refcount
In-Reply-To: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
References: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1605488401-981-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Hongchao Zhang <hongchao@whamcloud.com>

In lov_cleanup, the check of each OSC is protected by
lov_tgt_getrefs, which will increment the "lov_refcount",
so the "lov_refcount" shouldn't be checked inside because
it is always larger than 0.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13719
Lustre-commit: 6ae92a7f1bd94c ("LU-13719 lov: doesn't check lov_refcount")
Signed-off-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/39702
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_obd.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/lustre/lov/lov_obd.c b/fs/lustre/lov/lov_obd.c
index d88d325..c8654bd 100644
--- a/fs/lustre/lov/lov_obd.c
+++ b/fs/lustre/lov/lov_obd.c
@@ -820,8 +820,7 @@ static int lov_cleanup(struct obd_device *obd)
 				continue;
 
 			/* Inactive targets may never have connected */
-			if (lov->lov_tgts[i]->ltd_active ||
-			    atomic_read(&lov->lov_refcount))
+			if (lov->lov_tgts[i]->ltd_active)
 			    /* We should never get here - these
 			     * should have been removed in the
 			     * disconnect.
-- 
1.8.3.1
