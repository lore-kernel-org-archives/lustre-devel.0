From: NeilBrown <neilb@suse.com>
Date: Wed, 13 Dec 2017 14:15:55 +1100
Subject: [lustre-devel] [PATCH 11/12] staging: lustre: libcfs: discard
 KLASSERT()
In-Reply-To: <151313493380.27582.16490205348451477393.stgit@noble>
References: <151313493380.27582.16490205348451477393.stgit@noble>
Message-ID: <151313495508.27582.12134291439268599158.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

This appears to be intended for assertions that only make
sense in the kernel, but as this code is now kernel-only,
it doesn't make sense any more.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../lustre/include/linux/libcfs/libcfs_private.h   |    2 --
 drivers/staging/lustre/lustre/obdclass/cl_page.c   |    4 ++--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
index d32ce68e6c58..31403667be6b 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
@@ -74,8 +74,6 @@ do {									\
 # define LINVRNT(exp) ((void)sizeof !!(exp))
 #endif
 
-#define KLASSERT(e) LASSERT(e)
-
 void __noreturn lbug_with_loc(struct libcfs_debug_msg_data *msg);
 
 #define LBUG()							  \
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
index 7f65439f9b95..d3b25667bc3a 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
@@ -202,7 +202,7 @@ struct cl_page *cl_page_find(const struct lu_env *env,
 		 * vmpage lock is used to protect the child/parent
 		 * relationship
 		 */
-		KLASSERT(PageLocked(vmpage));
+		LASSERT(PageLocked(vmpage));
 		/*
 		 * cl_vmpage_page() can be called here without any locks as
 		 *
@@ -340,7 +340,7 @@ struct cl_page *cl_vmpage_page(struct page *vmpage, struct cl_object *obj)
 {
 	struct cl_page *page;
 
-	KLASSERT(PageLocked(vmpage));
+	LASSERT(PageLocked(vmpage));
 
 	/*
 	 * NOTE: absence of races and liveness of data are guaranteed by page
