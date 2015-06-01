From: Antonio Murdaca <antoniomurdaca@gmail.com>
Date: Mon,  1 Jun 2015 23:14:14 +0200
Subject: [lustre-devel] [PATCH] staging: lustre: lov: remove unnecessary
	parentheses
Message-ID: <1433193254-9211-1-git-send-email-antonio.murdaca@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

fix checkpatch.pl warning about unnecessary parentheses

Signed-off-by: Antonio Murdaca <antonio.murdaca@gmail.com>
---
 drivers/staging/lustre/lustre/lov/lov_obd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 054ca32..0a4f1771 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -1417,7 +1417,7 @@ static int lov_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 		__u32 flags;
 
 		memcpy(&index, data->ioc_inlbuf2, sizeof(__u32));
-		if ((index >= count))
+		if (index >= count)
 			return -ENODEV;
 
 		if (!lov->lov_tgts[index])
-- 
2.4.2
