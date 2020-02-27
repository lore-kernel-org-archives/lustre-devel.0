From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:57 -0500
Subject: [lustre-devel] [PATCH 249/622] lustre: obdclass: improve llog
 config record message
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-250-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Improve the config record message in class_config_parse_rec()
by removing the newline and formating to match the other
entires for the output dump buffer.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11566
Lustre-commit: 2ec11b04dd76 ("LU-11566 utils: improve usage/docs for lctl llog commands")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34004
Reviewed-by: Joseph Gmitter <jgmitter@whamcloud.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/obd_config.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/lustre/obdclass/obd_config.c b/fs/lustre/obdclass/obd_config.c
index 398f888..4b1848f 100644
--- a/fs/lustre/obdclass/obd_config.c
+++ b/fs/lustre/obdclass/obd_config.c
@@ -1561,7 +1561,7 @@ static int class_config_parse_rec(struct llog_rec_hdr *rec, char *buf,
 		char nidstr[LNET_NIDSTR_SIZE];
 
 		libcfs_nid2str_r(lcfg->lcfg_nid, nidstr, sizeof(nidstr));
-		ptr += snprintf(ptr, end - ptr, "nid=%s(%#llx)\n     ",
+		ptr += snprintf(ptr, end - ptr, "nid=%s(%#llx)  ",
 				nidstr, lcfg->lcfg_nid);
 	}
 
-- 
1.8.3.1
