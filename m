From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Apr 2018 04:35:38 +0100 (BST)
Subject: [lustre-devel] [PATCH 2/6] staging: lustre: remove
 libcfs/linux/libcfs.h
In-Reply-To: <152383935734.23409.11654775387996961581.stgit@noble>
References: <152383910760.23409.2327082725637657049.stgit@noble>
 <152383935734.23409.11654775387996961581.stgit@noble>
Message-ID: <alpine.LFD.2.21.1804160431550.16188@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>


> This include file is only included in one place,
> and only contains a list of other include directives.
> So just move all those to the place where this file
> is included, and discard the file.
> 
> One include directive uses a local name ("linux-cpu.h"), so
> that needs to be given a proper path.
> 
> Probably many of these should be remove from here, and moved to
> just the files that need them.

Nak. Dumping all the extra headers from linux/libcfs.h to libcfs.h is
the wrong approach. The one header, libcfs.h, to be the only header
in all lustre files is the wrong approach. I have been looking to
unroll that mess. I have patch that I need to polish you that I can
submit.
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../staging/lustre/include/linux/libcfs/libcfs.h   |   43 ++++++++++
>  .../lustre/include/linux/libcfs/linux/libcfs.h     |   83 --------------------
>  2 files changed, 42 insertions(+), 84 deletions(-)
>  delete mode 100644 drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h
> 
> diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
> index 62e46aa3c554..e59d107d6482 100644
> --- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
> +++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
> @@ -38,7 +38,48 @@
>  #include <linux/list.h>
>  
>  #include <uapi/linux/lnet/libcfs_ioctl.h>
> -#include <linux/libcfs/linux/libcfs.h>
> +#include <linux/bitops.h>
> +#include <linux/compiler.h>
> +#include <linux/ctype.h>
> +#include <linux/errno.h>
> +#include <linux/file.h>
> +#include <linux/fs.h>
> +#include <linux/highmem.h>
> +#include <linux/interrupt.h>
> +#include <linux/kallsyms.h>
> +#include <linux/kernel.h>
> +#include <linux/kmod.h>
> +#include <linux/kthread.h>
> +#include <linux/mm.h>
> +#include <linux/mm_inline.h>
> +#include <linux/module.h>
> +#include <linux/moduleparam.h>
> +#include <linux/mutex.h>
> +#include <linux/notifier.h>
> +#include <linux/pagemap.h>
> +#include <linux/random.h>
> +#include <linux/rbtree.h>
> +#include <linux/rwsem.h>
> +#include <linux/scatterlist.h>
> +#include <linux/sched.h>
> +#include <linux/signal.h>
> +#include <linux/slab.h>
> +#include <linux/smp.h>
> +#include <linux/stat.h>
> +#include <linux/string.h>
> +#include <linux/time.h>
> +#include <linux/timer.h>
> +#include <linux/types.h>
> +#include <linux/unistd.h>
> +#include <linux/vmalloc.h>
> +#include <net/sock.h>
> +#include <linux/atomic.h>
> +#include <asm/div64.h>
> +#include <linux/timex.h>
> +#include <linux/uaccess.h>
> +#include <stdarg.h>
> +#include <linux/libcfs/linux/linux-cpu.h>
> +
>  #include <linux/libcfs/libcfs_debug.h>
>  #include <linux/libcfs/libcfs_private.h>
>  #include <linux/libcfs/libcfs_cpu.h>
> diff --git a/drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h
> deleted file mode 100644
> index 83aec9c7698f..000000000000
> --- a/drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h
> +++ /dev/null
> @@ -1,83 +0,0 @@
> -// SPDX-License-Identifier: GPL-2.0
> -/*
> - * GPL HEADER START
> - *
> - * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
> - *
> - * This program is free software; you can redistribute it and/or modify
> - * it under the terms of the GNU General Public License version 2 only,
> - * as published by the Free Software Foundation.
> - *
> - * This program is distributed in the hope that it will be useful, but
> - * WITHOUT ANY WARRANTY; without even the implied warranty of
> - * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
> - * General Public License version 2 for more details (a copy is included
> - * in the LICENSE file that accompanied this code).
> - *
> - * You should have received a copy of the GNU General Public License
> - * version 2 along with this program; If not, see
> - * http://www.gnu.org/licenses/gpl-2.0.html
> - *
> - * GPL HEADER END
> - */
> -/*
> - * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
> - * Use is subject to license terms.
> - *
> - * Copyright (c) 2012, Intel Corporation.
> - */
> -/*
> - * This file is part of Lustre, http://www.lustre.org/
> - * Lustre is a trademark of Sun Microsystems, Inc.
> - */
> -
> -#ifndef __LIBCFS_LINUX_LIBCFS_H__
> -#define __LIBCFS_LINUX_LIBCFS_H__
> -
> -#ifndef __LIBCFS_LIBCFS_H__
> -#error Do not #include this file directly. #include <linux/libcfs/libcfs.h> instead
> -#endif
> -
> -#include <linux/bitops.h>
> -#include <linux/compiler.h>
> -#include <linux/ctype.h>
> -#include <linux/errno.h>
> -#include <linux/file.h>
> -#include <linux/fs.h>
> -#include <linux/highmem.h>
> -#include <linux/interrupt.h>
> -#include <linux/kallsyms.h>
> -#include <linux/kernel.h>
> -#include <linux/kmod.h>
> -#include <linux/kthread.h>
> -#include <linux/mm.h>
> -#include <linux/mm_inline.h>
> -#include <linux/module.h>
> -#include <linux/moduleparam.h>
> -#include <linux/mutex.h>
> -#include <linux/notifier.h>
> -#include <linux/pagemap.h>
> -#include <linux/random.h>
> -#include <linux/rbtree.h>
> -#include <linux/rwsem.h>
> -#include <linux/scatterlist.h>
> -#include <linux/sched.h>
> -#include <linux/signal.h>
> -#include <linux/slab.h>
> -#include <linux/smp.h>
> -#include <linux/stat.h>
> -#include <linux/string.h>
> -#include <linux/time.h>
> -#include <linux/timer.h>
> -#include <linux/types.h>
> -#include <linux/unistd.h>
> -#include <linux/vmalloc.h>
> -#include <net/sock.h>
> -#include <linux/atomic.h>
> -#include <asm/div64.h>
> -#include <linux/timex.h>
> -#include <linux/uaccess.h>
> -#include <stdarg.h>
> -#include "linux-cpu.h"
> -
> -#endif /* _LINUX_LIBCFS_H */
> 
> 
> 
