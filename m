From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:53 -0500
Subject: [lustre-devel] [PATCH 305/622] lnet: adds checking msg len
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-306-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alexander Boyko <c17825@cray.com>

The LNET can't handle a msg with len larger than LNET_MTU.
The next error occurred for DOM 1MB
 LNetError: 3137:0:(lib-move.c:4143:lnet_parse()) 192.168.8.1 at tcp,
 src 192.168.8.1 at tcp: bad PUT payload 1051832 (1048576 max expected)

The patch adds fragment size check.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12140
Lustre-commit: 4d43a6c3b182 ("LU-12140 lnet: adds checking msg len")
Signed-off-by: Alexander Boyko <c17825@cray.com>
Cray-bug-id: LUS-7174
Reviewed-on: https://review.whamcloud.com/34975
Reviewed-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-md.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/lnet/lnet/lib-md.c b/net/lnet/lnet/lib-md.c
index 7ea0f5e..4a70c76 100644
--- a/net/lnet/lnet/lib-md.c
+++ b/net/lnet/lnet/lib-md.c
@@ -325,6 +325,10 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
 		CERROR("Invalid option: too many fragments %u, %d max\n",
 		       umd->length, LNET_MAX_IOV);
 		return -EINVAL;
+	} else if (umd->length > LNET_MTU) {
+		CERROR("Invalid length: too big fragment size %u, %d max\n",
+		       umd->length, LNET_MTU);
+		return -EINVAL;
 	}
 
 	return 0;
-- 
1.8.3.1
