From: James Simmons <jsimmons@infradead.org>
Date: Thu, 29 Oct 2015 19:28:23 -0400
Subject: [lustre-devel] [PATCH 3/3] staging: lustre: checkpatch cleanups for
	nidstr.h
In-Reply-To: <1446161303-798-1-git-send-email-jsimmons@infradead.org>
References: <1446161303-798-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1446161303-798-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

With nidstr.h now having the latest fixes we can
now clean up all the remaining checkpatch errors
for this header.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/nidstr.h |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/nidstr.h b/drivers/staging/lustre/include/linux/lnet/nidstr.h
index 46ad914..ad591d2 100644
--- a/drivers/staging/lustre/include/linux/lnet/nidstr.h
+++ b/drivers/staging/lustre/include/linux/lnet/nidstr.h
@@ -34,8 +34,10 @@
  *  Lustre Network Driver types.
  */
 enum {
-	/* Only add to these values (i.e. don't ever change or redefine them):
-	 * network addresses depend on them... */
+	/*
+	 * Only add to these values (i.e. don't ever change or redefine them):
+	 * network addresses depend on them...
+	 */
 	QSWLND		= 1,
 	SOCKLND		= 2,
 	GMLND		= 3,
@@ -67,6 +69,7 @@ static inline char *libcfs_lnd2str(__u32 lnd)
 	return libcfs_lnd2str_r(lnd, libcfs_next_nidstring(),
 				LNET_NIDSTR_SIZE);
 }
+
 int libcfs_str2lnd(const char *str);
 char *libcfs_net2str_r(__u32 net, char *buf, size_t buf_size);
 static inline char *libcfs_net2str(__u32 net)
@@ -74,12 +77,14 @@ static inline char *libcfs_net2str(__u32 net)
 	return libcfs_net2str_r(net, libcfs_next_nidstring(),
 				LNET_NIDSTR_SIZE);
 }
+
 char *libcfs_nid2str_r(lnet_nid_t nid, char *buf, size_t buf_size);
 static inline char *libcfs_nid2str(lnet_nid_t nid)
 {
 	return libcfs_nid2str_r(nid, libcfs_next_nidstring(),
 				LNET_NIDSTR_SIZE);
 }
+
 __u32 libcfs_str2net(const char *str);
 lnet_nid_t libcfs_str2nid(const char *str);
 int libcfs_str2anynid(lnet_nid_t *nid, const char *str);
-- 
1.7.1
