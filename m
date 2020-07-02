From: James Simmons <jsimmons@infradead.org>
Date: Wed,  1 Jul 2020 20:04:41 -0400
Subject: [lustre-devel] [PATCH 01/18] lnet: restore an maximal fragments
 count
In-Reply-To: <1593648298-10571-1-git-send-email-jsimmons@infradead.org>
References: <1593648298-10571-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1593648298-10571-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alexey Lyashkov <c17817@cray.com>

Lowering a number of fragments blocks a connection from older clients
who wants to use 256 fragments to transfer. Let's restore this number
to the original value.

Fixes: ab7e089b8eda ("lustre: lnet: make LNET_MAX_IOV dependent on page size")

Cray-bug-id: LUS-8139
WC-bug-id: https://jira.whamcloud.com/browse/LU-10157
Lustre-commit: 4072d863c240f ("LU-10157 lnet: restore an maximal fragments count")
Signed-off-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-on: https://review.whamcloud.com/37385
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-types.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 6aa691e..1c016fd 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -51,7 +51,7 @@
 /* Max payload size */
 #define LNET_MAX_PAYLOAD	LNET_MTU
 
-#define LNET_MAX_IOV		(LNET_MAX_PAYLOAD >> PAGE_SHIFT)
+#define LNET_MAX_IOV		256
 
 /*
  * This is the maximum health value.
-- 
1.8.3.1
