From: James Simmons <jsimmons@infradead.org>
Date: Sun,  8 Nov 2015 14:17:16 -0500
Subject: [lustre-devel] [PATCH 11/13] staging: lustre: use proper braces in
	libcfs_kkuc_group_put
In-Reply-To: <1447010238-25775-1-git-send-email-jsimmons@infradead.org>
References: <1447010238-25775-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1447010238-25775-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Add in missing braces for libcfs_kkuc_group_put();.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/obdclass/kernelcomm.c    |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/kernelcomm.c b/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
index 709b1ab..46cb81a 100644
--- a/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
+++ b/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
@@ -192,9 +192,9 @@ int libcfs_kkuc_group_put(unsigned int group, void *payload)
 	list_for_each_entry(reg, &kkuc_groups[group], kr_chain) {
 		if (reg->kr_fp) {
 			rc = libcfs_kkuc_msg_put(reg->kr_fp, payload);
-			if (rc == 0)
+			if (rc == 0) {
 				one_success = 1;
-			else if (rc == -EPIPE) {
+			} else if (rc == -EPIPE) {
 				fput(reg->kr_fp);
 				reg->kr_fp = NULL;
 			}
-- 
1.7.1
