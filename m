From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Thu, 31 May 2018 18:54:26 +0200
Subject: [lustre-devel] [PATCH v2 6/6] staging: lustre: mdc: use large
 xattr buffers for old servers
In-Reply-To: <1527603705-30450-7-git-send-email-jsimmons@infradead.org>
References: <1527603705-30450-1-git-send-email-jsimmons@infradead.org>
 <1527603705-30450-7-git-send-email-jsimmons@infradead.org>
Message-ID: <20180531165426.GA23414@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>, "John L. Hammond" <john.hammond@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Tue, May 29, 2018 at 10:21:45AM -0400, James Simmons wrote:
> From: "John L. Hammond" <john.hammond@intel.com>
> 
> Pre 2.10.1 MDTs will crash when they receive a listxattr (MDS_GETXATTR
> with OBD_MD_FLXATTRLS) RPC for an orphan or dead object. So for
> clients connected to these older MDTs, try to avoid sending listxattr
> RPCs by making the bulk getxattr (MDS_GETXATTR with OBD_MD_FLXATTRALL)
> more likely to succeed and thereby reducing the chances of falling
> back to listxattr.
> 
> Signed-off-by: John L. Hammond <john.hammond@intel.com>
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-10912
> Reviewed-on: https://review.whamcloud.com/31990
> Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
> Reviewed-by: Fan Yong <fan.yong@intel.com>
> Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
> Changelog:
> 
> v1) Initial patch
> v2) Rebased patch. No changes
> 
>  drivers/staging/lustre/lustre/mdc/mdc_locks.c | 31 +++++++++++++++++++++------
>  1 file changed, 24 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
> index a8aa0fa..b991c6f 100644
> --- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
> +++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
> @@ -326,8 +326,10 @@ static void mdc_realloc_openmsg(struct ptlrpc_request *req,
>  {
>  	struct ptlrpc_request	*req;
>  	struct ldlm_intent	*lit;
> +	u32 min_buf_size = 0;
>  	int rc, count = 0;
>  	LIST_HEAD(cancels);
> +	u32 buf_size = 0;
>  
>  	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
>  				   &RQF_LDLM_INTENT_GETXATTR);
> @@ -344,18 +346,33 @@ static void mdc_realloc_openmsg(struct ptlrpc_request *req,
>  	lit = req_capsule_client_get(&req->rq_pill, &RMF_LDLM_INTENT);
>  	lit->opc = IT_GETXATTR;
>  
> +#if LUSTRE_VERSION_CODE < OBD_OCD_VERSION(3, 0, 53, 0)

Why are you adding pointless version checks to mainline?  Please don't
add new ones of these, you need to be working on removing the existing
ones.

thanks,

greg k-h
