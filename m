From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Date: Sun,  6 Dec 2015 01:41:31 +0100
Subject: [lustre-devel] [PATCH] staging: lustre: fix %.2X versus signed char
	issue
Message-ID: <1449362492-20779-1-git-send-email-linux@rasmusvillemoes.dk>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

When char is signed and one of the bytes in lmm happens to have a byte
value above 127, the result of printing that with %.2X will be 8 hex
chars, the first 6 of which are 'F'. Worst case, we'll overrun our
'carefully' allocated buffer.

I didn't have the tenacity to work through the gazillion and seven
layers of macros behind CERROR, but I assume it'll all end at some
function implemented in terms of the kernel's vsnprintf. Use %*phN for
a hexdump. That'll cap the number of dumped bytes at 64. If that's a
problem, the loop could be replaced by "bin2hex(buffer, lmm,
lmm_bytes);".

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
 drivers/staging/lustre/lustre/lov/lov_pack.c | 15 +--------------
 1 file changed, 1 insertion(+), 14 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
index 2fb1e974cc70..7f18d08929a5 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pack.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
@@ -258,22 +258,9 @@ static int lov_verify_lmm(void *lmm, int lmm_bytes, __u16 *stripe_count)
 	int rc;
 
 	if (lsm_op_find(le32_to_cpu(*(__u32 *)lmm)) == NULL) {
-		char *buffer;
-		int sz;
-
 		CERROR("bad disk LOV MAGIC: 0x%08X; dumping LMM (size=%d):\n",
 		       le32_to_cpu(*(__u32 *)lmm), lmm_bytes);
-		sz = lmm_bytes * 2 + 1;
-		buffer = libcfs_kvzalloc(sz, GFP_NOFS);
-		if (buffer != NULL) {
-			int i;
-
-			for (i = 0; i < lmm_bytes; i++)
-				sprintf(buffer+2*i, "%.2X", ((char *)lmm)[i]);
-			buffer[sz - 1] = '\0';
-			CERROR("%s\n", buffer);
-			kvfree(buffer);
-		}
+		CERROR("%*phN\n", lmm_bytes, lmm);
 		return -EINVAL;
 	}
 	rc = lsm_op_find(le32_to_cpu(*(__u32 *)lmm))->lsm_lmm_verify(lmm,
-- 
2.6.1
