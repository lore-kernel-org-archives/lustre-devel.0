From: NeilBrown <neilb@suse.com>
Date: Mon, 18 Dec 2017 12:41:42 +1100
Subject: [lustre-devel] [PATCH 4/4] staging: lustre: libcfs: remove prng
In-Reply-To: <151356119565.24290.5570928075046338898.stgit@noble>
References: <151356119565.24290.5570928075046338898.stgit@noble>
Message-ID: <151356130248.24290.2371669046568173867.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

The cfs prng is no longer used, so discard it.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/libcfs/libcfs.h   |   10 -
 drivers/staging/lustre/lnet/libcfs/Makefile        |    2 
 drivers/staging/lustre/lnet/libcfs/prng.c          |  137 --------------------
 3 files changed, 1 insertion(+), 148 deletions(-)
 delete mode 100644 drivers/staging/lustre/lnet/libcfs/prng.c

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index f2ba83ee5362..ca3472cc952f 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -73,16 +73,6 @@ sigset_t cfs_block_sigsinv(unsigned long sigs);
 void cfs_restore_sigs(sigset_t sigset);
 void cfs_clear_sigpending(void);
 
-/*
- * Random number handling
- */
-
-/* returns a random 32-bit integer */
-unsigned int cfs_rand(void);
-/* seed the generator */
-void cfs_srand(unsigned int seed1, unsigned int seed2);
-void cfs_get_random_bytes(void *buf, int size);
-
 struct libcfs_ioctl_handler {
 	struct list_head item;
 	int (*handle_ioctl)(unsigned int cmd, struct libcfs_ioctl_hdr *hdr);
diff --git a/drivers/staging/lustre/lnet/libcfs/Makefile b/drivers/staging/lustre/lnet/libcfs/Makefile
index 51b529434332..730f2c675047 100644
--- a/drivers/staging/lustre/lnet/libcfs/Makefile
+++ b/drivers/staging/lustre/lnet/libcfs/Makefile
@@ -15,7 +15,7 @@ libcfs-linux-objs += linux-mem.o
 libcfs-linux-objs := $(addprefix linux/,$(libcfs-linux-objs))
 
 libcfs-all-objs := debug.o fail.o module.o tracefile.o \
-		   libcfs_string.o hash.o prng.o \
+		   libcfs_string.o hash.o \
 		   libcfs_cpu.o libcfs_mem.o libcfs_lock.o
 
 libcfs-objs := $(libcfs-linux-objs) $(libcfs-all-objs)
diff --git a/drivers/staging/lustre/lnet/libcfs/prng.c b/drivers/staging/lustre/lnet/libcfs/prng.c
deleted file mode 100644
index f47cf67a92e3..000000000000
--- a/drivers/staging/lustre/lnet/libcfs/prng.c
+++ /dev/null
@@ -1,137 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
-/*
- * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- *
- * libcfs/libcfs/prng.c
- *
- * concatenation of following two 16-bit multiply with carry generators
- * x(n)=a*x(n-1)+carry mod 2^16 and y(n)=b*y(n-1)+carry mod 2^16,
- * number and carry packed within the same 32 bit integer.
- * algorithm recommended by Marsaglia
- */
-
-#include <linux/libcfs/libcfs.h>
-
-/*
- * From: George Marsaglia <geo@stat.fsu.edu>
- * Newsgroups: sci.math
- * Subject: Re: A RANDOM NUMBER GENERATOR FOR C
- * Date: Tue, 30 Sep 1997 05:29:35 -0700
- *
- * You may replace the two constants 36969 and 18000 by any
- * pair of distinct constants from this list:
- * 18000 18030 18273 18513 18879 19074 19098 19164 19215 19584
- * 19599 19950 20088 20508 20544 20664 20814 20970 21153 21243
- * 21423 21723 21954 22125 22188 22293 22860 22938 22965 22974
- * 23109 23124 23163 23208 23508 23520 23553 23658 23865 24114
- * 24219 24660 24699 24864 24948 25023 25308 25443 26004 26088
- * 26154 26550 26679 26838 27183 27258 27753 27795 27810 27834
- * 27960 28320 28380 28689 28710 28794 28854 28959 28980 29013
- * 29379 29889 30135 30345 30459 30714 30903 30963 31059 31083
- * (or any other 16-bit constants k for which both k*2^16-1
- * and k*2^15-1 are prime)
- */
-
-#define RANDOM_CONST_A 18030
-#define RANDOM_CONST_B 29013
-
-static unsigned int seed_x = 521288629;
-static unsigned int seed_y = 362436069;
-
-/**
- * cfs_rand - creates new seeds
- *
- * First it creates new seeds from the previous seeds. Then it generates a
- * new pseudo random number for use.
- *
- * Returns a pseudo-random 32-bit integer
- */
-unsigned int cfs_rand(void)
-{
-	seed_x = RANDOM_CONST_A * (seed_x & 65535) + (seed_x >> 16);
-	seed_y = RANDOM_CONST_B * (seed_y & 65535) + (seed_y >> 16);
-
-	return ((seed_x << 16) + (seed_y & 65535));
-}
-EXPORT_SYMBOL(cfs_rand);
-
-/**
- * cfs_srand - sets the initial seed
- * @seed1 : (seed_x) should have the most entropy in the low bits of the word
- * @seed2 : (seed_y) should have the most entropy in the high bits of the word
- *
- * Replaces the original seeds with new values. Used to generate a new pseudo
- * random numbers.
- */
-void cfs_srand(unsigned int seed1, unsigned int seed2)
-{
-	if (seed1)
-		seed_x = seed1; /* use default seeds if parameter is 0 */
-	if (seed2)
-		seed_y = seed2;
-}
-EXPORT_SYMBOL(cfs_srand);
-
-/**
- * cfs_get_random_bytes - generate a bunch of random numbers
- * @buf : buffer to fill with random numbers
- * @size: size of passed in buffer
- *
- * Fills a buffer with random bytes
- */
-void cfs_get_random_bytes(void *buf, int size)
-{
-	int *p = buf;
-	int rem, tmp;
-
-	LASSERT(size >= 0);
-
-	rem = min((int)((unsigned long)buf & (sizeof(int) - 1)), size);
-	if (rem) {
-		get_random_bytes(&tmp, sizeof(tmp));
-		tmp ^= cfs_rand();
-		memcpy(buf, &tmp, rem);
-		p = buf + rem;
-		size -= rem;
-	}
-
-	while (size >= sizeof(int)) {
-		get_random_bytes(&tmp, sizeof(tmp));
-		*p = cfs_rand() ^ tmp;
-		size -= sizeof(int);
-		p++;
-	}
-	buf = p;
-	if (size) {
-		get_random_bytes(&tmp, sizeof(tmp));
-		tmp ^= cfs_rand();
-		memcpy(buf, &tmp, size);
-	}
-}
-EXPORT_SYMBOL(cfs_get_random_bytes);
