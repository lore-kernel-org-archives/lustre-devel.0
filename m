From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:08:01 -0400
Subject: [lustre-devel] [PATCH 24/45] lnet: Add MD options for response
 tracking
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-25-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <hornc@cray.com>

These MD options will allow response tracking on a particular MD to
override the behavior specified by the lnet_response_tracking
parameter.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13502
Lustre-commit: 448834b8e575f ("LU-13502 lnet: Add MD options for response tracking")
Signed-off-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/38450
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/uapi/linux/lnet/lnet-types.h | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/include/uapi/linux/lnet/lnet-types.h b/include/uapi/linux/lnet/lnet-types.h
index 947ed7f..70fab42 100644
--- a/include/uapi/linux/lnet/lnet-types.h
+++ b/include/uapi/linux/lnet/lnet-types.h
@@ -483,6 +483,10 @@ struct lnet_md {
 	 *   struct bio_vec.
 	 * - LNET_MD_MAX_SIZE: The max_size field is valid.
 	 * - LNET_MD_BULK_HANDLE: The bulk_handle field is valid.
+	 * - LNET_MD_TRACK_RESPONSE: Enable response tracking on this MD
+	 *   regardless of the value of the lnet_response_tracking param.
+	 * - LNET_MD_NO_TRACK_RESPONSE: Disable response tracking on this MD
+	 *   regardless of the value of the lnet_response_tracking param.
 	 *
 	 * Note:
 	 * - LNET_MD_KIOV allows for a scatter/gather capability for memory
@@ -545,6 +549,10 @@ struct lnet_md {
 #define LNET_MD_KIOV		(1 << 8)
 /** See lnet_md::options. */
 #define LNET_MD_BULK_HANDLE	(1 << 9)
+/** See struct lnet_md::options. */
+#define LNET_MD_TRACK_RESPONSE		(1 << 10)
+/** See struct lnet_md::options. */
+#define LNET_MD_NO_TRACK_RESPONSE	(1 << 11)
 
 /* For compatibility with Cray Portals */
 #define LNET_MD_PHYS		0
-- 
1.8.3.1
