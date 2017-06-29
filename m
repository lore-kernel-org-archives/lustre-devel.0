From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Thu, 29 Jun 2017 16:32:24 +0200
Subject: [lustre-devel] [PATCH] staging: lustre: lnet: remove dead code
In-Reply-To: <1498711356-14270-1-git-send-email-dmitriy@oss-tech.org>
References: <1498711356-14270-1-git-send-email-dmitriy@oss-tech.org>
Message-ID: <20170629143224.GA19857@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dmitriy Cherkasov <dmitriy@oss-tech.org>
Cc: devel@driverdev.osuosl.org, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Wed, Jun 28, 2017 at 09:42:36PM -0700, Dmitriy Cherkasov wrote:
> Remove code which was permanently disabled with ifdefs.
> 
> This also resolves the following checkpatch warning which was
> triggered by the dead code:
> 
> WARNING: space prohibited before semicolon
> 
> Signed-off-by: Dmitriy Cherkasov <dmitriy@oss-tech.org>
> ---
>  drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h | 6 ------
>  1 file changed, 6 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
> index 5540de6..7c487fa 100644
> --- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
> +++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
> @@ -521,13 +521,7 @@ struct ksock_proto {
>  
>  static inline __u32 ksocknal_csum(__u32 crc, unsigned char const *p, size_t len)
>  {
> -#if 1
>  	return crc32_le(crc, p, len);

Even better yet, why not just replace the callers of this tiny function,
with crc32_le() instead and delete this useless wrapper?

thanks,

greg k-h
