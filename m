From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Fri, 9 Mar 2018 00:37:07 +0000
Subject: [lustre-devel] [PATCH 17/17] Revert "staging: Disable lustre
 file system for MIPS, SH, and XTENSA"
In-Reply-To: <151994708565.7628.14283641203455668904.stgit@noble>
References: <151994679573.7628.1024109499321778846.stgit@noble>
 <151994708565.7628.14283641203455668904.stgit@noble>
Message-ID: <607D7FFB-CF2F-43DF-A19A-5A713C959670@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Linux
 Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Mar 1, 2018, at 16:31, NeilBrown <neilb@suse.com> wrote:
> 
> This reverts commit 16f1eeb660bd2bfd223704ee6350706b39c55a7a.
> 
> The reason for this patch was that lustre used copy_from_user_page.
> Commit 76133e66b141 ("staging/lustre: Replace jobid acquiring with per
> node setting") removed that usage.
> So the arch restrictions can go.

I don't think these platforms will be used with Lustre any time soon,
but who knows... :-)

In any case, thanks for this patch series, definitely a lot of good
cleanups in there.

Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>

> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
> drivers/staging/lustre/lustre/Kconfig |    1 -
> 1 file changed, 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/lustre/Kconfig b/drivers/staging/lustre/lustre/Kconfig
> index c669c8fa0cc6..ccb78a945995 100644
> --- a/drivers/staging/lustre/lustre/Kconfig
> +++ b/drivers/staging/lustre/lustre/Kconfig
> @@ -1,6 +1,5 @@
> config LUSTRE_FS
> 	tristate "Lustre file system client support"
> -	depends on !MIPS && !XTENSA && !SUPERH
> 	depends on LNET
> 	select CRYPTO
> 	select CRYPTO_CRC32
> 
> 

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
