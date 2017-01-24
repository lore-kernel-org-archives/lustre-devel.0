From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Tue, 24 Jan 2017 22:22:08 +0000
Subject: [lustre-devel] [PATCH 1/2] staging: lustre: libcfs: use octal
	permissions
In-Reply-To: <20170124174050.6534-1-ernestas.kulik@gmail.com>
References: <20170124174050.6534-1-ernestas.kulik@gmail.com>
Message-ID: <715A0C57-2EE3-486E-A5DE-E372366B6BE8@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ernestas Kulik <ernestas.kulik@gmail.com>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Jan 24, 2017, at 09:40, Ernestas Kulik <ernestas.kulik@gmail.com> wrote:
> 
> Using octal permissions instead of symbolic ones is preferred.

Typically the reverse is true - using symbolic constants is preferred over numeric ones.
Where does this recommendation come from?

Cheers, Andreas

> Signed-off-by: Ernestas Kulik <ernestas.kulik@gmail.com>
> ---
> drivers/staging/lustre/lnet/libcfs/module.c | 4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
> index 161e04226521..c388550c2d10 100644
> --- a/drivers/staging/lustre/lnet/libcfs/module.c
> +++ b/drivers/staging/lustre/lnet/libcfs/module.c
> @@ -488,10 +488,10 @@ static const struct file_operations lnet_debugfs_file_operations_wo = {
> 
> static const struct file_operations *lnet_debugfs_fops_select(umode_t mode)
> {
> -	if (!(mode & S_IWUGO))
> +	if (!(mode & 0222))
> 		return &lnet_debugfs_file_operations_ro;
> 
> -	if (!(mode & S_IRUGO))
> +	if (!(mode & 0444))
> 		return &lnet_debugfs_file_operations_wo;
> 
> 	return &lnet_debugfs_file_operations_rw;
> -- 
> 2.11.0
> 
