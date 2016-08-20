From: Oleg Drokin <green@linuxhacker.ru>
Date: Sat, 20 Aug 2016 17:34:22 -0400
Subject: [lustre-devel] [PATCH 05/13] lustre: constify lib-move.c stuff
In-Reply-To: <1471728870-518753-1-git-send-email-green@linuxhacker.ru>
References: <1471728870-518753-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1471728870-518753-6-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Al Viro <viro@zeniv.linux.org.uk>, Oleg Drokin <green@linuxhacker.ru>

From: Al Viro <viro@zeniv.linux.org.uk>

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   | 28 +++++++++++-----------
 drivers/staging/lustre/lnet/lnet/lib-move.c        | 20 ++++++++--------
 2 files changed, 24 insertions(+), 24 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 513a822..1c5418e 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -605,34 +605,34 @@ void lnet_counters_reset(void);
 
 unsigned int lnet_iov_nob(unsigned int niov, struct kvec *iov);
 int lnet_extract_iov(int dst_niov, struct kvec *dst,
-		     int src_niov, struct kvec *src,
+		     int src_niov, const struct kvec *src,
 		      unsigned int offset, unsigned int len);
 
 unsigned int lnet_kiov_nob(unsigned int niov, lnet_kiov_t *iov);
 int lnet_extract_kiov(int dst_niov, lnet_kiov_t *dst,
-		      int src_niov, lnet_kiov_t *src,
+		      int src_niov, const lnet_kiov_t *src,
 		      unsigned int offset, unsigned int len);
 
-void lnet_copy_iov2iov(unsigned int ndiov, struct kvec *diov,
+void lnet_copy_iov2iov(unsigned int ndiov, const struct kvec *diov,
 		       unsigned int doffset,
-			unsigned int nsiov, struct kvec *siov,
+			unsigned int nsiov, const struct kvec *siov,
 			unsigned int soffset, unsigned int nob);
-void lnet_copy_kiov2iov(unsigned int niov, struct kvec *iov,
+void lnet_copy_kiov2iov(unsigned int niov, const struct kvec *iov,
 			unsigned int iovoffset,
-			 unsigned int nkiov, lnet_kiov_t *kiov,
+			 unsigned int nkiov, const lnet_kiov_t *kiov,
 			 unsigned int kiovoffset, unsigned int nob);
-void lnet_copy_iov2kiov(unsigned int nkiov, lnet_kiov_t *kiov,
+void lnet_copy_iov2kiov(unsigned int nkiov, const lnet_kiov_t *kiov,
 			unsigned int kiovoffset,
-			 unsigned int niov, struct kvec *iov,
+			 unsigned int niov, const struct kvec *iov,
 			 unsigned int iovoffset, unsigned int nob);
-void lnet_copy_kiov2kiov(unsigned int ndkiov, lnet_kiov_t *dkiov,
+void lnet_copy_kiov2kiov(unsigned int ndkiov, const lnet_kiov_t *dkiov,
 			 unsigned int doffset,
-			  unsigned int nskiov, lnet_kiov_t *skiov,
+			  unsigned int nskiov, const lnet_kiov_t *skiov,
 			  unsigned int soffset, unsigned int nob);
 
 static inline void
 lnet_copy_iov2flat(int dlen, void *dest, unsigned int doffset,
-		   unsigned int nsiov, struct kvec *siov, unsigned int soffset,
+		   unsigned int nsiov, const struct kvec *siov, unsigned int soffset,
 		   unsigned int nob)
 {
 	struct kvec diov = {/*.iov_base = */ dest, /*.iov_len = */ dlen};
@@ -643,7 +643,7 @@ lnet_copy_iov2flat(int dlen, void *dest, unsigned int doffset,
 
 static inline void
 lnet_copy_kiov2flat(int dlen, void *dest, unsigned int doffset,
-		    unsigned int nsiov, lnet_kiov_t *skiov,
+		    unsigned int nsiov, const lnet_kiov_t *skiov,
 		    unsigned int soffset, unsigned int nob)
 {
 	struct kvec diov = {/* .iov_base = */ dest, /* .iov_len = */ dlen};
@@ -653,7 +653,7 @@ lnet_copy_kiov2flat(int dlen, void *dest, unsigned int doffset,
 }
 
 static inline void
-lnet_copy_flat2iov(unsigned int ndiov, struct kvec *diov, unsigned int doffset,
+lnet_copy_flat2iov(unsigned int ndiov, const struct kvec *diov, unsigned int doffset,
 		   int slen, void *src, unsigned int soffset, unsigned int nob)
 {
 	struct kvec siov = {/*.iov_base = */ src, /*.iov_len = */slen};
@@ -663,7 +663,7 @@ lnet_copy_flat2iov(unsigned int ndiov, struct kvec *diov, unsigned int doffset,
 }
 
 static inline void
-lnet_copy_flat2kiov(unsigned int ndiov, lnet_kiov_t *dkiov,
+lnet_copy_flat2kiov(unsigned int ndiov, const lnet_kiov_t *dkiov,
 		    unsigned int doffset, int slen, void *src,
 		    unsigned int soffset, unsigned int nob)
 {
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 6a3f2e1..7d8d2d6 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -166,8 +166,8 @@ lnet_iov_nob(unsigned int niov, struct kvec *iov)
 EXPORT_SYMBOL(lnet_iov_nob);
 
 void
-lnet_copy_iov2iov(unsigned int ndiov, struct kvec *diov, unsigned int doffset,
-		  unsigned int nsiov, struct kvec *siov, unsigned int soffset,
+lnet_copy_iov2iov(unsigned int ndiov, const struct kvec *diov, unsigned int doffset,
+		  unsigned int nsiov, const struct kvec *siov, unsigned int soffset,
 		  unsigned int nob)
 {
 	/* NB diov, siov are READ-ONLY */
@@ -226,7 +226,7 @@ EXPORT_SYMBOL(lnet_copy_iov2iov);
 
 int
 lnet_extract_iov(int dst_niov, struct kvec *dst,
-		 int src_niov, struct kvec *src,
+		 int src_niov, const struct kvec *src,
 		 unsigned int offset, unsigned int len)
 {
 	/*
@@ -287,8 +287,8 @@ lnet_kiov_nob(unsigned int niov, lnet_kiov_t *kiov)
 EXPORT_SYMBOL(lnet_kiov_nob);
 
 void
-lnet_copy_kiov2kiov(unsigned int ndiov, lnet_kiov_t *diov, unsigned int doffset,
-		    unsigned int nsiov, lnet_kiov_t *siov, unsigned int soffset,
+lnet_copy_kiov2kiov(unsigned int ndiov, const lnet_kiov_t *diov, unsigned int doffset,
+		    unsigned int nsiov, const lnet_kiov_t *siov, unsigned int soffset,
 		    unsigned int nob)
 {
 	/* NB diov, siov are READ-ONLY */
@@ -370,8 +370,8 @@ lnet_copy_kiov2kiov(unsigned int ndiov, lnet_kiov_t *diov, unsigned int doffset,
 EXPORT_SYMBOL(lnet_copy_kiov2kiov);
 
 void
-lnet_copy_kiov2iov(unsigned int niov, struct kvec *iov, unsigned int iovoffset,
-		   unsigned int nkiov, lnet_kiov_t *kiov,
+lnet_copy_kiov2iov(unsigned int niov, const struct kvec *iov, unsigned int iovoffset,
+		   unsigned int nkiov, const lnet_kiov_t *kiov,
 		   unsigned int kiovoffset, unsigned int nob)
 {
 	/* NB iov, kiov are READ-ONLY */
@@ -440,9 +440,9 @@ lnet_copy_kiov2iov(unsigned int niov, struct kvec *iov, unsigned int iovoffset,
 EXPORT_SYMBOL(lnet_copy_kiov2iov);
 
 void
-lnet_copy_iov2kiov(unsigned int nkiov, lnet_kiov_t *kiov,
+lnet_copy_iov2kiov(unsigned int nkiov, const lnet_kiov_t *kiov,
 		   unsigned int kiovoffset, unsigned int niov,
-		   struct kvec *iov, unsigned int iovoffset,
+		   const struct kvec *iov, unsigned int iovoffset,
 		   unsigned int nob)
 {
 	/* NB kiov, iov are READ-ONLY */
@@ -511,7 +511,7 @@ EXPORT_SYMBOL(lnet_copy_iov2kiov);
 
 int
 lnet_extract_kiov(int dst_niov, lnet_kiov_t *dst,
-		  int src_niov, lnet_kiov_t *src,
+		  int src_niov, const lnet_kiov_t *src,
 		  unsigned int offset, unsigned int len)
 {
 	/*
-- 
2.7.4
