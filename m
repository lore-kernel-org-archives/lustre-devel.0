From: James Simmons <jsimmons@infradead.org>
Date: Fri, 30 Mar 2018 20:03:02 +0100 (BST)
Subject: [lustre-devel] [PATCH 13/17] staging: lustre: libcfs: remove
 cfs_timeout_cap()
In-Reply-To: <152229760874.27689.12453214678546053828.stgit@noble>
References: <152229732768.27689.4800156943561963977.stgit@noble>
 <152229760874.27689.12453214678546053828.stgit@noble>
Message-ID: <alpine.LFD.2.21.1803302002410.9681@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>


> This wrapper is only used once, so open-code it as max().
> 
> This allows us to remove the libcfs_time.h include file.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../staging/lustre/include/linux/libcfs/libcfs.h   |    1 
>  .../lustre/include/linux/libcfs/libcfs_time.h      |   50 --------------------
>  .../lustre/include/linux/libcfs/linux/linux-time.h |    2 -
>  drivers/staging/lustre/lustre/ptlrpc/import.c      |    4 +-
>  4 files changed, 3 insertions(+), 54 deletions(-)
>  delete mode 100644 drivers/staging/lustre/include/linux/libcfs/libcfs_time.h
> 
> diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
> index 3b751c436b3d..3d3fa52858e5 100644
> --- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
> +++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
> @@ -43,7 +43,6 @@
>  #include <linux/libcfs/libcfs_private.h>
>  #include <linux/libcfs/libcfs_cpu.h>
>  #include <linux/libcfs/libcfs_prim.h>
> -#include <linux/libcfs/libcfs_time.h>
>  #include <linux/libcfs/libcfs_string.h>
>  #include <linux/libcfs/libcfs_hash.h>
>  #include <linux/libcfs/libcfs_fail.h>
> diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_time.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_time.h
> deleted file mode 100644
> index 172a8872e3f3..000000000000
> --- a/drivers/staging/lustre/include/linux/libcfs/libcfs_time.h
> +++ /dev/null
> @@ -1,50 +0,0 @@
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
> - */
> -/*
> - * This file is part of Lustre, http://www.lustre.org/
> - * Lustre is a trademark of Sun Microsystems, Inc.
> - *
> - * libcfs/include/libcfs/libcfs_time.h
> - *
> - * Time functions.
> - *
> - */
> -
> -#ifndef __LIBCFS_TIME_H__
> -#define __LIBCFS_TIME_H__
> -/*
> - * return valid time-out based on user supplied one. Currently we only check
> - * that time-out is not shorted than allowed.
> - */
> -static inline long cfs_timeout_cap(long timeout)
> -{
> -	if (timeout < CFS_TICK)
> -		timeout = CFS_TICK;
> -	return timeout;
> -}
> -
> -#endif
> diff --git a/drivers/staging/lustre/include/linux/libcfs/linux/linux-time.h b/drivers/staging/lustre/include/linux/libcfs/linux/linux-time.h
> index ff3aae2f1231..ecb2126a9e6f 100644
> --- a/drivers/staging/lustre/include/linux/libcfs/linux/linux-time.h
> +++ b/drivers/staging/lustre/include/linux/libcfs/linux/linux-time.h
> @@ -78,7 +78,7 @@ static inline int cfs_time_beforeq_64(u64 t1, u64 t2)
>  /*
>   * One jiffy
>   */
> -#define CFS_TICK		(1)
> +#define CFS_TICK		(1UL)
>  
>  #define CFS_DURATION_T	  "%ld"
>  
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
> index 4a9d1f189d01..dd4fd54128dd 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/import.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
> @@ -1486,7 +1486,7 @@ int ptlrpc_disconnect_import(struct obd_import *imp, int noclose)
>  	}
>  
>  	if (ptlrpc_import_in_recovery(imp)) {
> -		long timeout;
> +		unsigned long timeout;
>  
>  		if (AT_OFF) {
>  			if (imp->imp_server_timeout)
> @@ -1501,7 +1501,7 @@ int ptlrpc_disconnect_import(struct obd_import *imp, int noclose)
>  
>  		if (wait_event_idle_timeout(imp->imp_recovery_waitq,
>  					    !ptlrpc_import_in_recovery(imp),
> -					    cfs_timeout_cap(timeout)) == 0)
> +					    max(timeout, CFS_TICK)) == 0)
>  			l_wait_event_abortable(
>  				imp->imp_recovery_waitq,
>  				!ptlrpc_import_in_recovery(imp));
> 
> 
> 
