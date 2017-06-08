From: Roman Storozhenko <romeusmeister@gmail.com>
Date: Thu, 8 Jun 2017 20:25:41 +0300
Subject: [lustre-devel] [PATCH] staging: lustre: llite: Replace the symbolic
 file permission mode with the numeric one
Message-ID: <20170608172541.GA2314@home>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Replaces S_IRWXUGO with 0007. The reason is that symbolic permissions
considered harmful:
https://lwn.net/Articles/696229/

Signed-off-by: Roman Storozhenko <romeusmeister@gmail.com>
---
 drivers/staging/lustre/lustre/llite/dir.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 13b3592..de5b4bf 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -1141,7 +1141,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		}
 
 #if OBD_OCD_VERSION(2, 9, 50, 0) > LUSTRE_VERSION_CODE
-		mode = data->ioc_type != 0 ? data->ioc_type : S_IRWXUGO;
+		mode = data->ioc_type != 0 ? data->ioc_type : 0777;
 #else
 		mode = data->ioc_type;
 #endif
-- 
2.7.4
