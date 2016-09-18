From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 20:43:18 +0100 (BST)
Subject: [lustre-devel] [PATCH] staging: lustre: lmv: add missing
	function declaration
In-Reply-To: <1474198793-25108-1-git-send-email-baoyou.xie@linaro.org>
References: <1474198793-25108-1-git-send-email-baoyou.xie@linaro.org>
Message-ID: <alpine.LFD.2.20.1609182035370.31599@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Baoyou Xie <baoyou.xie@linaro.org>
Cc: oleg.drokin@intel.com, andreas.dilger@intel.com, gregkh@linuxfoundation.org, di.wang@intel.com, john.hammond@intel.com, fan.yong@intel.com, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, arnd@arndb.de, xie.baoyou@zte.com.cn


> We get 1 warning when building kernel with W=1:
> drivers/staging/lustre/lustre/lmv/lmv_obd.c:2774:5: warning: no previous prototype for 'lmv_pack_md' [-Wmissing-prototypes]
> 
> In fact, this function is not declared in any file,but should be
> declared in a header file, thus can be recognized in other file.
> 
> So this patch adds the declarations into
> drivers/staging/lustre/lustre/include/lustre_lmv.h.
> 
> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
> ---
>  drivers/staging/lustre/lustre/include/lustre_lmv.h | 2 ++
>  1 file changed, 2 insertions(+)

Nak. I'm not seeing this error with W=1. Also if you look
lmv_pack_md() is only used in lmv_obd.c and the function
appears early in the file before it is used, so no prototype
missing errors should happen. 
 
> diff --git a/drivers/staging/lustre/lustre/include/lustre_lmv.h b/drivers/staging/lustre/lustre/include/lustre_lmv.h
> index 085e596..21302c7 100644
> --- a/drivers/staging/lustre/lustre/include/lustre_lmv.h
> +++ b/drivers/staging/lustre/lustre/include/lustre_lmv.h
> @@ -119,3 +119,5 @@ static inline void lmv_le_to_cpu(union lmv_mds_md *lmv_dst,
>  }
> 
> +int lmv_pack_md(union lmv_mds_md **lmmp, const struct lmv_stripe_md *lsm,
> +		int stripe_count);
>  #endif
> -- 
> 2.7.4
> 
> 
