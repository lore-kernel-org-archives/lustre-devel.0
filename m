From: James Simmons <jsimmons@infradead.org>
Date: Sun, 24 Feb 2019 17:15:16 +0000 (GMT)
Subject: [lustre-devel] [PATCH 11/37] lustre: kernelcomm: make
 libcfs_kkuc_msg_put static.
In-Reply-To: <155053494545.24125.14664274760505145343.stgit@noble.brown>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
 <155053494545.24125.14664274760505145343.stgit@noble.brown>
Message-ID: <alpine.LFD.2.21.1902241711110.22752@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> libcfs_kkuc_msg_put() is never used outside of kernelcomm.c,
> so make it static.

In the OpenSFS branch libcfs_kkuc_msg_put() is used by the
client and server code. While this is okay now in the future
this will be reverted. So do we keep it as is so it can handle
server code or do this change and then later do what I added
below:
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../lustre/lustre/include/lustre_kernelcomm.h      |    1 -
>  .../staging/lustre/lustre/obdclass/kernelcomm.c    |    3 +--
>  2 files changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/include/lustre_kernelcomm.h b/drivers/staging/lustre/lustre/include/lustre_kernelcomm.h
> index 8e3a99057a38..1ed41840ab8f 100644
> --- a/drivers/staging/lustre/lustre/include/lustre_kernelcomm.h
> +++ b/drivers/staging/lustre/lustre/include/lustre_kernelcomm.h
> @@ -46,7 +46,6 @@ typedef int (*libcfs_kkuc_cb_t)(void *data, void *cb_arg);
>  
>  /* Kernel methods */
>  void libcfs_kkuc_init(void);
#ifdef CONFIG_LUSTRE_SERVER
> -int libcfs_kkuc_msg_put(struct file *fp, void *payload);
#endif
>  int libcfs_kkuc_group_put(unsigned int group, void *payload);
>  int libcfs_kkuc_group_add(struct file *fp, int uid, unsigned int group,
>  			  void *data, size_t data_len);
> diff --git a/drivers/staging/lustre/lustre/obdclass/kernelcomm.c b/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
> index 09d0b1ab8d1c..27870952b1f0 100644
> --- a/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
> +++ b/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
> @@ -49,7 +49,7 @@
>   * @param payload Payload data.  First field of payload is always
>   *   struct kuc_hdr
>   */
#ifndef CONFIG_LUSTRE_SERVER
> -int libcfs_kkuc_msg_put(struct file *filp, void *payload)
#else
> +static int libcfs_kkuc_msg_put(struct file *filp, void *payload)
#endif
>  {
>  	struct kuc_hdr *kuch = (struct kuc_hdr *)payload;
>  	ssize_t count = kuch->kuc_msglen;
> @@ -80,7 +80,6 @@ int libcfs_kkuc_msg_put(struct file *filp, void *payload)
>  
>  	return rc;
>  }
#ifdef CONFIG_LUSTER_SERVER
> -EXPORT_SYMBOL(libcfs_kkuc_msg_put);
#endif

>  /*
>   * Broadcast groups are global across all mounted filesystems;

I do say the ifdef do look messy.
