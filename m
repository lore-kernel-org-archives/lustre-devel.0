From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Wed, 3 Feb 2016 14:41:55 -0800
Subject: [lustre-devel] [PATCH 1/7] staging:lustre: remove obsolete
 comment in libcfs_ioctl.h
In-Reply-To: <1452022519-6716-2-git-send-email-jsimmons@infradead.org>
References: <1452022519-6716-1-git-send-email-jsimmons@infradead.org>
	<1452022519-6716-2-git-send-email-jsimmons@infradead.org>
Message-ID: <20160203224155.GA15225@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Parinay Kondekar <parinay.kondekar@seagate.com>, James Simmons <uja.ornl@yahoo.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lustre-devel@lists.lustre.org

On Tue, Jan 05, 2016 at 02:35:13PM -0500, James Simmons wrote:
> From: Parinay Kondekar <parinay.kondekar@seagate.com>
> 
> The libcfs_ioctl.h header has a comment about a snapshot ioctl
> which has been removed for years. Lets remove the comment to
> avoid confusion. Broken out of patch 17492.
> 
> Signed-off-by: Parinay Kondekar <parinay.kondekar@seagate.com>
> Signed-off-by: James Simmons <uja.ornl@yahoo.com>
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5844
> Reviewed-on: http://review.whamcloud.com/17492
> Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
> Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
> Reviewed-by: John L. Hammond <john.hammond@intel.com>
> Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
> ---
>  .../lustre/include/linux/libcfs/libcfs_ioctl.h     |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)

Only this patch applied in this series, please rebase the rest of them
(fixing up the one I pointed out) and resend.

thanks,

greg k-h
