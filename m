From: Alexey Lyahkov <alexey_lyashkov@xyratex.com>
Date: Sat, 21 Sep 2013 10:39:28 +0200
Subject: [Lustre-devel] portability in lustre code.
Message-ID: <D90080E4-C334-44D0-8879-7381E21C7390@xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi All,

I "happy" to see moving to lustre kernel generate a first results.
my MacOS fuse client brooked to build after sources updates.

In file included from /Users/shadow/work/lustre/work/WC-review/mac-os/libcfs/include/libcfs/posix/libcfs.h:108,
                 from /Users/shadow/work/lustre/work/WC-review/mac-os/libcfs/include/libcfs/libcfs.h:45,
                 from nidstrings.c:43:
/Users/shadow/work/lustre/work/WC-review/mac-os/libcfs/include/libcfs/user-bitops.h:80: error: conflicting types for ?fls?
/usr/include/strings.h:90: error: previous declaration of ?fls? was here

that bug introduced by commit
>>
commit d38d331fa6525ffc02665f48fa52f94626360631
Author: James Simmons <uja.ornl@gmail.com>
Date:   Tue Aug 27 12:51:06 2013 -0400

    LU-1346 libcfs: cleanup macros in portals_compat25.h
>> 
so that commit - isn't correctly inspected for systems other to linux and introduce a new regression for systems other then Linux.
I was pointed about similar situation in past - but hit that in real world.
Andreas, did you remember my concerns about lost portability ?

batch changes code in way without ability to replace a cfs specific function to any existent in build env.
>>>
diff --git a/libcfs/include/libcfs/user-bitops.h b/libcfs/include/libcfs/user-bitops.h
index 2e31e88..1b16ca7 100644
--- a/libcfs/include/libcfs/user-bitops.h
+++ b/libcfs/include/libcfs/user-bitops.h
@@ -76,7 +76,7 @@ static inline int test_bit(int nr, const unsigned long *addr)
 }
 
 /* using binary seach */
-static __inline__ unsigned long __cfs_fls(long data)
+static __inline__ unsigned long fls(long data)
 {
        int pos = 32;
 
@@ -147,8 +147,8 @@ static __inline__ unsigned long __cfs_ffs(long data)
>>
but fls from BSD userland have a different prototype and we don't able to replace with flsl from build env.

from man page
FFS(3)                   BSD Library Functions Manual                   FFS(3)

NAME
     ffs, ffsl, fls, flsl -- find first or last bit set in a bit string
HISTORY
     The ffs() function appeared in 4.3BSD.  Its prototype existed previously in <string.h> before it was moved to <strings.h> for IEEE Std 1003.1-2001
     (``POSIX.1'') compliance.

     The ffsl(), fls(), and flsl() functions appeared in FreeBSD 5.3.


and we don't have a way to the replace fls with flsl for MacOS/BSD or use own implementation without reverting a cleanup for fls function.


----------------------------------------------
Alexey Lyahkov
alexey_lyashkov at xyratex.com
