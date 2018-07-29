From: James Simmons <jsimmons@infradead.org>
Date: Sun, 29 Jul 2018 17:58:51 +0100 (BST)
Subject: [lustre-devel] [PATCH 1/9] lustre: merge linux-debug.c into
 debug.c
In-Reply-To: <153232698479.26222.16079606642992274567.stgit@noble>
References: <153232696720.26222.9658151633697867322.stgit@noble>
 <153232698479.26222.16079606642992274567.stgit@noble>
Message-ID: <alpine.LFD.2.21.1807291758420.2402@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> There is no important difference between the contents
> of these files, so merge them into one.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  drivers/staging/lustre/lnet/libcfs/Makefile      |    1 
>  drivers/staging/lustre/lnet/libcfs/debug.c       |   86 +++++++++++++
>  drivers/staging/lustre/lnet/libcfs/linux-debug.c |  142 ----------------------
>  drivers/staging/lustre/lnet/libcfs/tracefile.h   |    4 -
>  4 files changed, 86 insertions(+), 147 deletions(-)
>  delete mode 100644 drivers/staging/lustre/lnet/libcfs/linux-debug.c
> 
> diff --git a/drivers/staging/lustre/lnet/libcfs/Makefile b/drivers/staging/lustre/lnet/libcfs/Makefile
> index cd96434e3b03..a45f87af3faf 100644
> --- a/drivers/staging/lustre/lnet/libcfs/Makefile
> +++ b/drivers/staging/lustre/lnet/libcfs/Makefile
> @@ -4,7 +4,6 @@ ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
>  
>  obj-$(CONFIG_LNET) += libcfs.o
>  
> -libcfs-obj-y += linux-debug.o
>  libcfs-obj-y += linux-crypto.o
>  libcfs-obj-y += linux-crypto-adler.o
>  
> diff --git a/drivers/staging/lustre/lnet/libcfs/debug.c b/drivers/staging/lustre/lnet/libcfs/debug.c
> index 844543b2317f..0289f24698fa 100644
> --- a/drivers/staging/lustre/lnet/libcfs/debug.c
> +++ b/drivers/staging/lustre/lnet/libcfs/debug.c
> @@ -327,6 +327,40 @@ libcfs_debug_str2mask(int *mask, const char *str, int is_subsys)
>  			    0xffffffff);
>  }
>  
> +char lnet_debug_log_upcall[1024] = "/usr/lib/lustre/lnet_debug_log_upcall";
> +
> +/**
> + * Upcall function once a Lustre log has been dumped.
> + *
> + * \param file  path of the dumped log
> + */
> +static void libcfs_run_debug_log_upcall(char *file)
> +{
> +	char *argv[3];
> +	int rc;
> +	static const char * const envp[] = {
> +		"HOME=/",
> +		"PATH=/sbin:/bin:/usr/sbin:/usr/bin",
> +		NULL
> +	};
> +
> +	argv[0] = lnet_debug_log_upcall;
> +
> +	LASSERTF(file, "called on a null filename\n");
> +	argv[1] = file; /* only need to pass the path of the file */
> +
> +	argv[2] = NULL;
> +
> +	rc = call_usermodehelper(argv[0], argv, (char **)envp, 1);
> +	if (rc < 0 && rc != -ENOENT) {
> +		CERROR("Error %d invoking LNET debug log upcall %s %s; check /sys/kernel/debug/lnet/debug_log_upcall\n",
> +		       rc, argv[0], argv[1]);
> +	} else {
> +		CDEBUG(D_HA, "Invoked LNET debug log upcall %s %s\n",
> +		       argv[0], argv[1]);
> +	}
> +}
> +
>  /**
>   * Dump Lustre log to ::debug_file_path by calling tracefile_dump_all_pages()
>   */
> @@ -389,6 +423,58 @@ void libcfs_debug_dumplog(void)
>  }
>  EXPORT_SYMBOL(libcfs_debug_dumplog);
>  
> +/* coverity[+kill] */
> +void __noreturn lbug_with_loc(struct libcfs_debug_msg_data *msgdata)
> +{
> +	libcfs_catastrophe = 1;
> +	libcfs_debug_msg(msgdata, "LBUG\n");
> +
> +	if (in_interrupt()) {
> +		panic("LBUG in interrupt.\n");
> +		/* not reached */
> +	}
> +
> +	dump_stack();
> +	if (!libcfs_panic_on_lbug)
> +		libcfs_debug_dumplog();
> +	if (libcfs_panic_on_lbug)
> +		panic("LBUG");
> +	set_current_state(TASK_UNINTERRUPTIBLE);
> +	while (1)
> +		schedule();
> +}
> +EXPORT_SYMBOL(lbug_with_loc);
> +
> +static int panic_notifier(struct notifier_block *self, unsigned long unused1,
> +			  void *unused2)
> +{
> +	if (libcfs_panic_in_progress)
> +		return 0;
> +
> +	libcfs_panic_in_progress = 1;
> +	mb();
> +
> +	return 0;
> +}
> +
> +static struct notifier_block libcfs_panic_notifier = {
> +	.notifier_call	= panic_notifier,
> +	.next		= NULL,
> +	.priority	= 10000,
> +};
> +
> +static void libcfs_register_panic_notifier(void)
> +{
> +	atomic_notifier_chain_register(&panic_notifier_list,
> +				       &libcfs_panic_notifier);
> +}
> +
> +static void libcfs_unregister_panic_notifier(void)
> +{
> +	atomic_notifier_chain_unregister(&panic_notifier_list,
> +					 &libcfs_panic_notifier);
> +}
> +
>  int libcfs_debug_init(unsigned long bufsize)
>  {
>  	unsigned int max = libcfs_debug_mb;
> diff --git a/drivers/staging/lustre/lnet/libcfs/linux-debug.c b/drivers/staging/lustre/lnet/libcfs/linux-debug.c
> deleted file mode 100644
> index 15ab849374c2..000000000000
> --- a/drivers/staging/lustre/lnet/libcfs/linux-debug.c
> +++ /dev/null
> @@ -1,142 +0,0 @@
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
> - *
> - * libcfs/libcfs/linux/linux-debug.c
> - *
> - * Author: Phil Schwan <phil@clusterfs.com>
> - */
> -
> -#include <linux/module.h>
> -#include <linux/kmod.h>
> -#include <linux/notifier.h>
> -#include <linux/kernel.h>
> -#include <linux/mm.h>
> -#include <linux/string.h>
> -#include <linux/stat.h>
> -#include <linux/errno.h>
> -#include <linux/unistd.h>
> -#include <linux/interrupt.h>
> -#include <linux/completion.h>
> -#include <linux/fs.h>
> -#include <linux/uaccess.h>
> -
> -# define DEBUG_SUBSYSTEM S_LNET
> -
> -#include "tracefile.h"
> -
> -#include <linux/kallsyms.h>
> -
> -char lnet_debug_log_upcall[1024] = "/usr/lib/lustre/lnet_debug_log_upcall";
> -
> -/**
> - * Upcall function once a Lustre log has been dumped.
> - *
> - * \param file  path of the dumped log
> - */
> -void libcfs_run_debug_log_upcall(char *file)
> -{
> -	char *argv[3];
> -	int rc;
> -	static const char * const envp[] = {
> -		"HOME=/",
> -		"PATH=/sbin:/bin:/usr/sbin:/usr/bin",
> -		NULL
> -	};
> -
> -	argv[0] = lnet_debug_log_upcall;
> -
> -	LASSERTF(file, "called on a null filename\n");
> -	argv[1] = file; /* only need to pass the path of the file */
> -
> -	argv[2] = NULL;
> -
> -	rc = call_usermodehelper(argv[0], argv, (char **)envp, 1);
> -	if (rc < 0 && rc != -ENOENT) {
> -		CERROR("Error %d invoking LNET debug log upcall %s %s; check /sys/kernel/debug/lnet/debug_log_upcall\n",
> -		       rc, argv[0], argv[1]);
> -	} else {
> -		CDEBUG(D_HA, "Invoked LNET debug log upcall %s %s\n",
> -		       argv[0], argv[1]);
> -	}
> -}
> -
> -/* coverity[+kill] */
> -void __noreturn lbug_with_loc(struct libcfs_debug_msg_data *msgdata)
> -{
> -	libcfs_catastrophe = 1;
> -	libcfs_debug_msg(msgdata, "LBUG\n");
> -
> -	if (in_interrupt()) {
> -		panic("LBUG in interrupt.\n");
> -		/* not reached */
> -	}
> -
> -	dump_stack();
> -	if (!libcfs_panic_on_lbug)
> -		libcfs_debug_dumplog();
> -	if (libcfs_panic_on_lbug)
> -		panic("LBUG");
> -	set_current_state(TASK_UNINTERRUPTIBLE);
> -	while (1)
> -		schedule();
> -}
> -EXPORT_SYMBOL(lbug_with_loc);
> -
> -static int panic_notifier(struct notifier_block *self, unsigned long unused1,
> -			  void *unused2)
> -{
> -	if (libcfs_panic_in_progress)
> -		return 0;
> -
> -	libcfs_panic_in_progress = 1;
> -	mb();
> -
> -	return 0;
> -}
> -
> -static struct notifier_block libcfs_panic_notifier = {
> -	.notifier_call	= panic_notifier,
> -	.next		= NULL,
> -	.priority	= 10000,
> -};
> -
> -void libcfs_register_panic_notifier(void)
> -{
> -	atomic_notifier_chain_register(&panic_notifier_list,
> -				       &libcfs_panic_notifier);
> -}
> -
> -void libcfs_unregister_panic_notifier(void)
> -{
> -	atomic_notifier_chain_unregister(&panic_notifier_list,
> -					 &libcfs_panic_notifier);
> -}
> diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.h b/drivers/staging/lustre/lnet/libcfs/tracefile.h
> index 67107b1a705a..82f090fd8dfa 100644
> --- a/drivers/staging/lustre/lnet/libcfs/tracefile.h
> +++ b/drivers/staging/lustre/lnet/libcfs/tracefile.h
> @@ -51,8 +51,6 @@ extern long long cfs_tracefile_size;
>   */
>  extern char lnet_debug_log_upcall[1024];
>  
> -void libcfs_run_debug_log_upcall(char *file);
> -
>  int cfs_tracefile_dump_all_pages(char *filename);
>  void cfs_trace_debug_print(void);
>  void cfs_trace_flush_pages(void);
> @@ -73,8 +71,6 @@ int cfs_trace_set_debug_mb(int mb);
>  int cfs_trace_get_debug_mb(void);
>  
>  void libcfs_debug_dumplog_internal(void *arg);
> -void libcfs_register_panic_notifier(void);
> -void libcfs_unregister_panic_notifier(void);
>  extern int libcfs_panic_in_progress;
>  
>  #define TCD_MAX_PAGES (5 << (20 - PAGE_SHIFT))
> 
> 
> 
