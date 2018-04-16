From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Apr 2018 04:52:55 +0100 (BST)
Subject: [lustre-devel] [PATCH 3/6] staging: lustre: remove
 include/linux/libcfs/linux/linux-cpu.h
In-Reply-To: <152383935737.23409.2271901486597092772.stgit@noble>
References: <152383910760.23409.2327082725637657049.stgit@noble>
 <152383935737.23409.2271901486597092772.stgit@noble>
Message-ID: <alpine.LFD.2.21.1804160448410.16188@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>


> This include file contains definitions used when CONFIG_SMP
> is in effect.  Other includes contain corresponding definitions
> for when it isn't.
> This can be hard to follow, so move the definitions to the one place.
> 
> As HAVE_LIBCFS_CPT is defined precisely when CONFIG_SMP, we discard
> that macro and just use CONFIG_SMP when needed.

Nak. The lustre SMP is broken and needed to badly be reworked. I have it 
ready and can push it. I was waiting to see if I had to rebase it once
the rc1 stuff but since their is a push to get everything out their I will
push it.

> ---
>  .../staging/lustre/include/linux/libcfs/libcfs.h   |    1 
>  .../lustre/include/linux/libcfs/libcfs_cpu.h       |   33 ++++++++
>  .../lustre/include/linux/libcfs/linux/linux-cpu.h  |   78 --------------------
>  drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c    |    4 +
>  4 files changed, 35 insertions(+), 81 deletions(-)
>  delete mode 100644 drivers/staging/lustre/include/linux/libcfs/linux/linux-cpu.h
> 
> diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
> index e59d107d6482..aca1f19c4977 100644
> --- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
> +++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
> @@ -78,7 +78,6 @@
>  #include <linux/timex.h>
>  #include <linux/uaccess.h>
>  #include <stdarg.h>
> -#include <linux/libcfs/linux/linux-cpu.h>
>  
>  #include <linux/libcfs/libcfs_debug.h>
>  #include <linux/libcfs/libcfs_private.h>
> diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
> index 61bce77fddd6..829c35e68db8 100644
> --- a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
> +++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
> @@ -72,10 +72,43 @@
>  #ifndef __LIBCFS_CPU_H__
>  #define __LIBCFS_CPU_H__
>  
> +#include <linux/cpu.h>
> +#include <linux/cpuset.h>
> +#include <linux/topology.h>
> +
>  /* any CPU partition */
>  #define CFS_CPT_ANY		(-1)
>  
>  #ifdef CONFIG_SMP
> +/** virtual processing unit */
> +struct cfs_cpu_partition {
> +	/* CPUs mask for this partition */
> +	cpumask_var_t			cpt_cpumask;
> +	/* nodes mask for this partition */
> +	nodemask_t			*cpt_nodemask;
> +	/* spread rotor for NUMA allocator */
> +	unsigned int			cpt_spread_rotor;
> +};
> +
> +
> +/** descriptor for CPU partitions */
> +struct cfs_cpt_table {
> +	/* version, reserved for hotplug */
> +	unsigned int			ctb_version;
> +	/* spread rotor for NUMA allocator */
> +	unsigned int			ctb_spread_rotor;
> +	/* # of CPU partitions */
> +	unsigned int			ctb_nparts;
> +	/* partitions tables */
> +	struct cfs_cpu_partition	*ctb_parts;
> +	/* shadow HW CPU to CPU partition ID */
> +	int				*ctb_cpu2cpt;
> +	/* all cpus in this partition table */
> +	cpumask_var_t			ctb_cpumask;
> +	/* all nodes in this partition table */
> +	nodemask_t			*ctb_nodemask;
> +};
> +
>  /**
>   * return cpumask of CPU partition \a cpt
>   */
> diff --git a/drivers/staging/lustre/include/linux/libcfs/linux/linux-cpu.h b/drivers/staging/lustre/include/linux/libcfs/linux/linux-cpu.h
> deleted file mode 100644
> index 6035376f2830..000000000000
> --- a/drivers/staging/lustre/include/linux/libcfs/linux/linux-cpu.h
> +++ /dev/null
> @@ -1,78 +0,0 @@
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
> - * GPL HEADER END
> - */
> -/*
> - * Copyright (c) 2010, Oracle and/or its affiliates. All rights reserved.
> - * Copyright (c) 2012, Intel Corporation.
> - */
> -/*
> - * This file is part of Lustre, http://www.lustre.org/
> - * Lustre is a trademark of Sun Microsystems, Inc.
> - *
> - * libcfs/include/libcfs/linux/linux-cpu.h
> - *
> - * Basic library routines.
> - *
> - * Author: liang at whamcloud.com
> - */
> -
> -#ifndef __LIBCFS_LINUX_CPU_H__
> -#define __LIBCFS_LINUX_CPU_H__
> -
> -#ifndef __LIBCFS_LIBCFS_H__
> -#error Do not #include this file directly. #include <linux/libcfs/libcfs.h> instead
> -#endif
> -
> -#include <linux/cpu.h>
> -#include <linux/cpuset.h>
> -#include <linux/topology.h>
> -
> -#ifdef CONFIG_SMP
> -
> -#define HAVE_LIBCFS_CPT
> -
> -/** virtual processing unit */
> -struct cfs_cpu_partition {
> -	/* CPUs mask for this partition */
> -	cpumask_var_t			cpt_cpumask;
> -	/* nodes mask for this partition */
> -	nodemask_t			*cpt_nodemask;
> -	/* spread rotor for NUMA allocator */
> -	unsigned int			cpt_spread_rotor;
> -};
> -
> -/** descriptor for CPU partitions */
> -struct cfs_cpt_table {
> -	/* version, reserved for hotplug */
> -	unsigned int			ctb_version;
> -	/* spread rotor for NUMA allocator */
> -	unsigned int			ctb_spread_rotor;
> -	/* # of CPU partitions */
> -	unsigned int			ctb_nparts;
> -	/* partitions tables */
> -	struct cfs_cpu_partition	*ctb_parts;
> -	/* shadow HW CPU to CPU partition ID */
> -	int				*ctb_cpu2cpt;
> -	/* all cpus in this partition table */
> -	cpumask_var_t			ctb_cpumask;
> -	/* all nodes in this partition table */
> -	nodemask_t			*ctb_nodemask;
> -};
> -
> -#endif /* CONFIG_SMP */
> -#endif /* __LIBCFS_LINUX_CPU_H__ */
> diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
> index 76291a350406..5818f641455f 100644
> --- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
> +++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
> @@ -37,7 +37,7 @@
>  struct cfs_cpt_table   *cfs_cpt_table __read_mostly;
>  EXPORT_SYMBOL(cfs_cpt_table);
>  
> -#ifndef HAVE_LIBCFS_CPT
> +#ifndef CONFIG_SMP
>  
>  #define CFS_CPU_VERSION_MAGIC	   0xbabecafe
>  
> @@ -225,4 +225,4 @@ cfs_cpu_init(void)
>  	return cfs_cpt_table ? 0 : -1;
>  }
>  
> -#endif /* HAVE_LIBCFS_CPT */
> +#endif /* CONFIG_SMP */
> 
> 
> 
