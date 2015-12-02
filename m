From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 2 Dec 2015 15:34:50 +0300
Subject: [lustre-devel] [PATCH 19/40] staging: lustre: copy out libcfs
 ioctl inline buffer
In-Reply-To: <1448062576-23757-20-git-send-email-jsimmons@infradead.org>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
	<1448062576-23757-20-git-send-email-jsimmons@infradead.org>
Message-ID: <20151202123450.GQ18797@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, Nov 20, 2015 at 06:35:55PM -0500, James Simmons wrote:
> From: Liang Zhen <liang.zhen@intel.com>
> 
>   - libcfs_ioctl_popdata should copy out inline buffers.
>   - code cleanup for libcfs ioctl handler
>   - error number fix for obd_ioctl_getdata
>   - add new function libcfs_ioctl_unpack for upcoming patches
> 

Without looking at the patch, I can already tell you it should be four
separate patches instead of one.  Don't mix bug fixes and cleanups.
This should not be a new rule for anyone.

Guys, what the actual heck is going on???  This patchset is making me
really depressed and I'm not even half way through.

> Signed-off-by: Liang Zhen <liang.zhen@intel.com>
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5435
> Reviewed-on: http://review.whamcloud.com/11313
> Reviewed-by: Bobi Jam <bobijam@gmail.com>
> Reviewed-by: Johann Lombardi <johann.lombardi@intel.com>
> Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
> ---
>  .../lustre/include/linux/libcfs/libcfs_ioctl.h     |   24 +++-
>  drivers/staging/lustre/lnet/lnet/api-ni.c          |    2 +
>  .../lustre/lustre/libcfs/linux/linux-module.c      |   45 +++++---
>  drivers/staging/lustre/lustre/libcfs/module.c      |  119 ++++++++------------
>  .../lustre/lustre/obdclass/linux/linux-module.c    |   17 +--
>  5 files changed, 97 insertions(+), 110 deletions(-)
> 
> diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
> index f24330d..3468933 100644
> --- a/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
> +++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
> @@ -49,6 +49,9 @@ struct libcfs_ioctl_hdr {
>  	__u32 ioc_version;
>  };
>  
> +/** max size to copy from userspace */
> +#define LIBCFS_IOC_DATA_MAX	(128 * 1024)
> +
>  struct libcfs_ioctl_data {
>  	struct libcfs_ioctl_hdr ioc_hdr;
>  
> @@ -240,11 +243,22 @@ static inline bool libcfs_ioctl_is_invalid(struct libcfs_ioctl_data *data)
>  
>  int libcfs_register_ioctl(struct libcfs_ioctl_handler *hand);
>  int libcfs_deregister_ioctl(struct libcfs_ioctl_handler *hand);
> -int libcfs_ioctl_getdata(struct libcfs_ioctl_hdr *buf, __u32 buf_len,
> -			 const void __user *arg);
> -int libcfs_ioctl_getdata_len(const struct libcfs_ioctl_hdr __user *arg,
> -			     __u32 *buf_len);
> -int libcfs_ioctl_popdata(void *arg, void *buf, int size);
> +int libcfs_ioctl_getdata(struct libcfs_ioctl_hdr **hdr_pp,
> +			 struct libcfs_ioctl_hdr __user *uparam);
> +
> +static inline int libcfs_ioctl_popdata(struct libcfs_ioctl_hdr *hdr,
> +				       struct libcfs_ioctl_hdr __user *uparam)
> +{
> +	if (copy_to_user(uparam, hdr, hdr->ioc_len))
> +		return -EFAULT;
> +	return 0;
> +}

No.  Don't do this.

> +
> +static inline void libcfs_ioctl_freedata(struct libcfs_ioctl_hdr *hdr)
> +{
> +	LIBCFS_FREE(hdr, hdr->ioc_len);
> +}

No.  We need to transition to kmalloc() and kfree() instead of adding
even more abstraction layers.  In this patchset we add new calls to
ALLOC() when we should be using normal kernel functions like kstrdup()
but we can't because then we wouldn't have a size parameter to pass to
LIBCFS_FREE().

> +
>  int libcfs_ioctl_data_adjust(struct libcfs_ioctl_data *data);
>  
>  #endif /* __LIBCFS_IOCTL_H__ */
> diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
> index 949fa2f..4c4e6d3 100644
> --- a/drivers/staging/lustre/lnet/lnet/api-ni.c
> +++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
> @@ -1838,6 +1838,8 @@ LNetCtl(unsigned int cmd, void *arg)
>  	int rc;
>  	unsigned long secs_passed;
>  
> +	CLASSERT(sizeof(struct lnet_ioctl_net_config) +
> +		 sizeof(struct lnet_ioctl_config_data) < LIBCFS_IOC_DATA_MAX);


BUILD_BUG_ON().

>  	LASSERT(the_lnet.ln_init);
>  
>  	switch (cmd) {
> diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-module.c b/drivers/staging/lustre/lustre/libcfs/linux/linux-module.c
> index 1c31e2e..50a5464 100644
> --- a/drivers/staging/lustre/lustre/libcfs/linux/linux-module.c
> +++ b/drivers/staging/lustre/lustre/libcfs/linux/linux-module.c
> @@ -43,7 +43,7 @@
>  int libcfs_ioctl_data_adjust(struct libcfs_ioctl_data *data)
>  {
>  	if (libcfs_ioctl_is_invalid(data)) {
> -		CERROR("LNET: ioctl not correctly formatted\n");
> +		CERROR("libcfs ioctl: parameter not correctly formatted\n");
>  		return -EINVAL;
>  	}
>  
> @@ -57,39 +57,46 @@ int libcfs_ioctl_data_adjust(struct libcfs_ioctl_data *data)
>  	return 0;
>  }
>  
> -int libcfs_ioctl_getdata_len(const struct libcfs_ioctl_hdr __user *arg,
> -			     __u32 *len)
> +int libcfs_ioctl_getdata(struct libcfs_ioctl_hdr **hdr_pp,
> +			 struct libcfs_ioctl_hdr __user *uhdr)
>  {
>  	struct libcfs_ioctl_hdr hdr;
> +	int err = 0;
>  
> -	if (copy_from_user(&hdr, arg, sizeof(hdr)))
> +	if (copy_from_user(&hdr, uhdr, sizeof(hdr)))
>  		return -EFAULT;
>  
>  	if (hdr.ioc_version != LIBCFS_IOCTL_VERSION &&
>  	    hdr.ioc_version != LIBCFS_IOCTL_VERSION2) {
> -		CERROR("LNET: version mismatch expected %#x, got %#x\n",
> +		CERROR("libcfs ioctl: version mismatch expected %#x, got %#x\n",
>  		       LIBCFS_IOCTL_VERSION, hdr.ioc_version);
>  		return -EINVAL;
>  	}
>  
> -	*len = hdr.ioc_len;
> +	if (hdr.ioc_len < sizeof(struct libcfs_ioctl_data)) {
> +		CERROR("libcfs ioctl: user buffer too small for ioctl\n");
> +		return -EINVAL;
> +	}

It's sort of good to check here, but we will need to add all the other
checks I mentioned as well.  Also don't fix introduce bugs and fix them
in the same patchset, the fix has to be folded into the buggy patch.

>  
> -	return 0;
> -}
> +	if (hdr.ioc_len > LIBCFS_IOC_DATA_MAX) {
> +		CERROR("libcfs ioctl: user buffer is too large %d/%d\n",
> +		       hdr.ioc_len, LIBCFS_IOC_DATA_MAX);
> +		return -EINVAL;
> +	}
>  
> -int libcfs_ioctl_getdata(struct libcfs_ioctl_hdr *buf, __u32 buf_len,
> -			  const void __user *arg)
> -{
> -	if (copy_from_user(buf, arg, buf_len))
> -		return -EFAULT;
> -	return 0;
> -}
> +	LIBCFS_ALLOC(*hdr_pp, hdr.ioc_len);
> +	if (!*hdr_pp)
> +		return -ENOMEM;
> +
> +	if (copy_from_user(*hdr_pp, uhdr, hdr.ioc_len)) {
> +		err = -EFAULT;
> +		goto failed;
> +	}

We still need to re-check hdr.ioc_len after re-reading it from the user.

Anyway, break this patch up and I will review it properly.

regards,
dan carpenter
