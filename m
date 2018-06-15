From: NeilBrown <neilb@suse.com>
Date: Fri, 15 Jun 2018 17:11:30 +1000
Subject: [lustre-devel] [PATCH 14/24] lustre: discard ext2* bit operations
In-Reply-To: <152904663333.10587.10934053155404014785.stgit@noble>
References: <152904663333.10587.10934053155404014785.stgit@noble>
Message-ID: <152904669056.10587.1595912848911465438.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Just use the relevant *_le bit operation directly.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lustre/include/lustre_compat.h  |    8 --------
 drivers/staging/lustre/lustre/obdclass/llog.c      |    6 +++---
 2 files changed, 3 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_compat.h b/drivers/staging/lustre/lustre/include/lustre_compat.h
index cb6e2aa35960..534846f5561d 100644
--- a/drivers/staging/lustre/lustre/include/lustre_compat.h
+++ b/drivers/staging/lustre/lustre/include/lustre_compat.h
@@ -49,14 +49,6 @@
 #define module_init(a)     late_initcall(a)
 #endif
 
-#if !defined(_ASM_GENERIC_BITOPS_EXT2_NON_ATOMIC_H_) && !defined(ext2_set_bit)
-# define ext2_set_bit	     __test_and_set_bit_le
-# define ext2_clear_bit	   __test_and_clear_bit_le
-# define ext2_test_bit	    test_bit_le
-# define ext2_find_first_zero_bit find_first_zero_bit_le
-# define ext2_find_next_zero_bit  find_next_zero_bit_le
-#endif
-
 #define TIMES_SET_FLAGS (ATTR_MTIME_SET | ATTR_ATIME_SET | ATTR_TIMES_SET)
 
 #endif /* _LUSTRE_COMPAT_H */
diff --git a/drivers/staging/lustre/lustre/obdclass/llog.c b/drivers/staging/lustre/lustre/obdclass/llog.c
index bba84eae1e19..53e723d990e4 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog.c
@@ -137,7 +137,7 @@ static int llog_read_header(const struct lu_env *env,
 		 */
 		len = llh->llh_hdr.lrh_len - llh->llh_bitmap_offset;
 		memset(LLOG_HDR_BITMAP(llh), 0, len - sizeof(llh->llh_tail));
-		ext2_set_bit(0, LLOG_HDR_BITMAP(llh));
+		set_bit_le(0, LLOG_HDR_BITMAP(llh));
 		LLOG_HDR_TAIL(llh)->lrt_len = llh->llh_hdr.lrh_len;
 		LLOG_HDR_TAIL(llh)->lrt_index = llh->llh_hdr.lrh_index;
 		rc = 0;
@@ -264,7 +264,7 @@ static int llog_process_thread(void *arg)
 
 		/* skip records not set in bitmap */
 		while (index <= last_index &&
-		       !ext2_test_bit(index, LLOG_HDR_BITMAP(llh)))
+		       !test_bit_le(index, LLOG_HDR_BITMAP(llh)))
 			++index;
 
 		if (index > last_index)
@@ -365,7 +365,7 @@ static int llog_process_thread(void *arg)
 						    chunk_offset;
 
 			/* if set, process the callback on this record */
-			if (ext2_test_bit(index, LLOG_HDR_BITMAP(llh))) {
+			if (test_bit_le(index, LLOG_HDR_BITMAP(llh))) {
 				rc = lpi->lpi_cb(lpi->lpi_env, loghandle, rec,
 						 lpi->lpi_cbdata);
 				last_called_index = index;
