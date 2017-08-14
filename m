From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 Aug 2017 11:47:00 -0400
Subject: [lustre-devel] [PATCH 32/64] staging: lustre: libcfs: remove LOGL
	and LOGU macros
In-Reply-To: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
References: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1502725652-26280-33-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

The macro LOGU is not used anymore and LOGL is used in
one place. No reason to keep LOGL around anymore.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: https://review.whamcloud.com/22138
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/linux/libcfs/libcfs_private.h   | 14 --------------
 drivers/staging/lustre/lustre/ptlrpc/pack_generic.c        |  4 +++-
 2 files changed, 3 insertions(+), 15 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
index 005713b..709771d 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
@@ -296,18 +296,4 @@ static inline size_t cfs_round_strlen(char *fset)
 	return cfs_size_round((int)strlen(fset) + 1);
 }
 
-#define LOGL(var, len, ptr)				       \
-do {							    \
-	if (var)						\
-		memcpy((char *)ptr, (const char *)var, len);    \
-	ptr += cfs_size_round(len);			     \
-} while (0)
-
-#define LOGU(var, len, ptr)				       \
-do {							    \
-	if (var)						\
-		memcpy((char *)var, (const char *)ptr, len);    \
-	ptr += cfs_size_round(len);			     \
-} while (0)
-
 #endif
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index 55e8696e..f116995 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -186,7 +186,9 @@ void lustre_init_msg_v2(struct lustre_msg_v2 *msg, int count, __u32 *lens,
 	for (i = 0; i < count; i++) {
 		char *tmp = bufs[i];
 
-		LOGL(tmp, lens[i], ptr);
+		if (tmp)
+			memcpy(ptr, tmp, lens[i]);
+		ptr += cfs_size_round(lens[i]);
 	}
 }
 EXPORT_SYMBOL(lustre_init_msg_v2);
-- 
1.8.3.1
