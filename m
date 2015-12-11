From: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Date: Fri, 11 Dec 2015 18:04:24 -0500
Subject: [lustre-devel] [PATCH v2 5/6] Nuke an unsigned >= 0 assert
In-Reply-To: <1449875065-35182-1-git-send-email-Valdis.Kletnieks@vt.edu>
References: <1449875065-35182-1-git-send-email-Valdis.Kletnieks@vt.edu>
Message-ID: <1449875065-35182-6-git-send-email-Valdis.Kletnieks@vt.edu>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Writing asserts for almost-never-can-happen things can be valuable.
Writing an assert that tests that an "unsigned int" hasn't gone negative
isn't.

And it generates an *ugly* message:

drivers/staging/lustre/lustre/llite/rw.c:763:20: warning: comparison of unsigned expression >= 0 is always true [-Wtype-limits]
  LASSERTF(reserved >= 0, "reserved %lu\n", reserved);
                    ^
include/linux/compiler.h:137:45: note: in definition of macro 'unlikely'
 #  define unlikely(x) (__builtin_constant_p(x) ? !!(x) : __branch_check__(x, 0))
                                             ^
drivers/staging/lustre/lustre/llite/rw.c:763:2: note: in expansion of macro 'LASSERTF'
  LASSERTF(reserved >= 0, "reserved %lu\n", reserved);
  ^
drivers/staging/lustre/lustre/llite/rw.c:763:20: warning: comparison of unsigned expression >= 0 is always true [-Wtype-limits]
  LASSERTF(reserved >= 0, "reserved %lu\n", reserved);
                    ^
include/linux/compiler.h:137:53: note: in definition of macro 'unlikely'
 #  define unlikely(x) (__builtin_constant_p(x) ? !!(x) : __branch_check__(x, 0))
                                                     ^
drivers/staging/lustre/lustre/llite/rw.c:763:2: note: in expansion of macro 'LASSERTF'
  LASSERTF(reserved >= 0, "reserved %lu\n", reserved);
  ^
drivers/staging/lustre/lustre/llite/rw.c:763:20: warning: comparison of unsigned expression >= 0 is always true [-Wtype-limits]
  LASSERTF(reserved >= 0, "reserved %lu\n", reserved);
                    ^
include/linux/compiler.h:110:47: note: in definition of macro 'likely_notrace'
 #define likely_notrace(x) __builtin_expect(!!(x), 1)
                                               ^
include/linux/compiler.h:137:58: note: in expansion of macro '__branch_check__'
 #  define unlikely(x) (__builtin_constant_p(x) ? !!(x) : __branch_check__(x, 0))
                                                          ^
drivers/staging/lustre/lustre/llite/../include/linux/../../../include/linux/libcfs/libcfs_private.h:58:6: note: in expansion of macro 'unlikely'
  if (unlikely(!(cond))) {     \
      ^
drivers/staging/lustre/lustre/llite/rw.c:763:2: note: in expansion of macro 'LASSERTF'
  LASSERTF(reserved >= 0, "reserved %lu\n", reserved);
  ^

Umm, thank you, GCC.  We'll delete the problem line so we never see that spew again.

Signed-off-by: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
---
 drivers/staging/lustre/lustre/llite/rw.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index f79193fa2fb7..39390aab9da2 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -764,7 +764,6 @@ int ll_readahead(const struct lu_env *env, struct cl_io *io,
 	ret = ll_read_ahead_pages(env, io, queue,
 				  ria, &reserved, mapping, &ra_end);
 
-	LASSERTF(reserved >= 0, "reserved %lu\n", reserved);
 	if (reserved != 0)
 		ll_ra_count_put(ll_i2sbi(inode), reserved);
 
-- 
2.6.3
