From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Tue, 17 Oct 2017 23:00:02 +0000
Subject: [lustre-devel] [PATCH 15/20] staging: lustre: llite: mark
 expected switch fall-through
In-Reply-To: <661e7cdf247c7662f4f27ac7c54fb4636fd9c1e3.1507781178.git.garsilva@embeddedor.com>
References: <cover.1507781178.git.garsilva@embeddedor.com>
 <661e7cdf247c7662f4f27ac7c54fb4636fd9c1e3.1507781178.git.garsilva@embeddedor.com>
Message-ID: <0B7757C2-00D8-47E2-A30D-B7C394E12832@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>


> On Oct 12, 2017, at 10:17, Gustavo A. R. Silva <garsilva@embeddedor.com> wrote:
> 
> In preparation to enabling -Wimplicit-fallthrough, mark switch cases
> where we are expecting to fall through.
> 
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

Not sure why you moved the "for mode = 0" comment to a separate line?
Not the end of the world though.

Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>

> ---
> drivers/staging/lustre/lustre/llite/namei.c | 4 +++-
> 1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
> index 5cc2b32..55e0d03 100644
> --- a/drivers/staging/lustre/lustre/llite/namei.c
> +++ b/drivers/staging/lustre/lustre/llite/namei.c
> @@ -949,7 +949,9 @@ static int ll_mknod(struct inode *dir, struct dentry *dchild,
> 
> 	switch (mode & S_IFMT) {
> 	case 0:
> -		mode |= S_IFREG; /* for mode = 0 case, fallthrough */
> +		mode |= S_IFREG;
> +		/* for mode = 0 case */
> +		/* fall through */
> 	case S_IFREG:
> 	case S_IFCHR:
> 	case S_IFBLK:
> -- 
> 2.7.4
> 

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
