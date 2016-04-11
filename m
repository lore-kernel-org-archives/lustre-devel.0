From: Drokin, Oleg <oleg.drokin@intel.com>
Date: Mon, 11 Apr 2016 22:16:47 +0000
Subject: [lustre-devel] [PATCH] staging: lustre: libcfs: Fix warnings
 reported by 'make C=1'
In-Reply-To: <87bn5fan0a.fsf@hp.cfotr.com>
References: <87bn5fan0a.fsf@hp.cfotr.com>
Message-ID: <51E52CE1-EB1C-40CB-AC27-392F2003EA4E@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Apr 11, 2016, at 4:50 PM, Aleksey Fedotov wrote:

> From 08473aa48a1726c09dbab43e99059be9b0e88af2 Mon Sep 17 00:00:00 2001
> From: Aleksei Fedotov <lexa@cfotr.com>
> Date: Mon, 11 Apr 2016 21:13:27 +0300
> Subject: [PATCH] staging: lustre: libcfs: Fix warnings reported by sparse

A better title would be something like:
staging: lustre: libcfs: Fix libcfs_ioctl() prototype.

Thanks.

> 
> This patch fixes sparse warnings:
> 
> lustre/lnet/libcfs/linux/linux-module.c:177:35: warning: incorrect type
> in argument 2 (different address spaces)
> 
> lustre/lnet/libcfs/module.c:101:5: error: symbol 'libcfs_ioctl'
> redeclared with different type
> 
> Signed-off-by: Aleksey Fedotov <lexa@cfotr.com>
> ---
> drivers/staging/lustre/include/linux/libcfs/libcfs.h | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
> index 9158c61..4141afb 100644
> --- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
> +++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
> @@ -106,7 +106,7 @@ int libcfs_deregister_ioctl(struct libcfs_ioctl_handler *hand);
> int libcfs_ioctl_getdata(struct libcfs_ioctl_hdr **hdr_pp,
> 			 const struct libcfs_ioctl_hdr __user *uparam);
> int libcfs_ioctl_data_adjust(struct libcfs_ioctl_data *data);
> -int libcfs_ioctl(unsigned long cmd, void *arg);
> +int libcfs_ioctl(unsigned long cmd, void __user *arg);
> 
> /* container_of depends on "likely" which is defined in libcfs_private.h */
> static inline void *__container_of(void *ptr, unsigned long shift)
> -- 
> 2.5.5
> 
