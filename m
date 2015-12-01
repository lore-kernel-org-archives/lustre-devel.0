From: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Date: Tue,  1 Dec 2015 17:05:16 -0500
Subject: [lustre-devel] [lustre cleanups 3/6] Clean up another C warnining:
In-Reply-To: <1449007519-73974-1-git-send-email-Valdis.Kletnieks@vt.edu>
References: <1449007519-73974-1-git-send-email-Valdis.Kletnieks@vt.edu>
Message-ID: <1449007519-73974-4-git-send-email-Valdis.Kletnieks@vt.edu>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

drivers/staging/lustre/lustre/fid/../include/lustre_cfg.h: In function 'lustre_cfg_free':
drivers/staging/lustre/lustre/fid/../include/lustre_cfg.h:253:6: warning: variable 'len' set but not used [-Wunused-but-set-variable]
  int len;

Yep, we're just gonna call kfree, no need to calculate len. Bye-bye.

Signed-off-by: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
---
diff --git a/drivers/staging/lustre/lustre/include/lustre_cfg.h b/drivers/staging/lustre/lustre/include/lustre_cfg.h
index eb6b292b7b25..d30d8b054c92 100644
--- a/drivers/staging/lustre/lustre/include/lustre_cfg.h
+++ b/drivers/staging/lustre/lustre/include/lustre_cfg.h
@@ -252,10 +252,6 @@ static inline struct lustre_cfg *lustre_cfg_new(int cmd,
 
 static inline void lustre_cfg_free(struct lustre_cfg *lcfg)
 {
-	int len;
-
-	len = lustre_cfg_len(lcfg->lcfg_bufcount, lcfg->lcfg_buflens);
-
 	kfree(lcfg);
 	return;
 }
-- 
2.6.3
