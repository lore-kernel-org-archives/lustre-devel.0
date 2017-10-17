From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Tue, 17 Oct 2017 23:00:26 +0000
Subject: [lustre-devel] [PATCH 16/20] staging: lustre: lprocfs: mark
 expected switch fall-throughs
In-Reply-To: <734912e09d855035cfa64746101cc24b8695bf3e.1507781178.git.garsilva@embeddedor.com>
References: <cover.1507781178.git.garsilva@embeddedor.com>
 <734912e09d855035cfa64746101cc24b8695bf3e.1507781178.git.garsilva@embeddedor.com>
Message-ID: <113524DE-3EF5-4437-A1AF-93D5CCD85A93@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Oct 12, 2017, at 10:17, Gustavo A. R. Silva <garsilva@embeddedor.com> wrote:
> 
> In preparation to enabling -Wimplicit-fallthrough, mark switch cases
> where we are expecting to fall through.
> 
> Addresses-Coverity-ID: 1271166
> Addresses-Coverity-ID: 1271167
> Addresses-Coverity-ID: 1271168
> Addresses-Coverity-ID: 1271169
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>

> ---
> drivers/staging/lustre/lustre/obdclass/lprocfs_status.c | 4 ++++
> 1 file changed, 4 insertions(+)
> 
> diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
> index e79485b..4ec582f 100644
> --- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
> +++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
> @@ -1507,12 +1507,16 @@ int lprocfs_write_frac_u64_helper(const char __user *buffer,
> 		switch (tolower(*end)) {
> 		case 'p':
> 			units <<= 10;
> +			/* fall through */
> 		case 't':
> 			units <<= 10;
> +			/* fall through */
> 		case 'g':
> 			units <<= 10;
> +			/* fall through */
> 		case 'm':
> 			units <<= 10;
> +			/* fall through */
> 		case 'k':
> 			units <<= 10;
> 		}
> -- 
> 2.7.4
> 

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
