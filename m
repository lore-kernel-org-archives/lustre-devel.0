From: Greg KH <gregkh@linuxfoundation.org>
Date: Sat, 3 Jun 2017 17:50:35 +0900
Subject: [lustre-devel] [PATCH V2] libcfs: Fix a sleep-in-atomic bug in
	cfs_wi_exit
In-Reply-To: <1496217641-17002-1-git-send-email-baijiaju1990@163.com>
References: <1496217641-17002-1-git-send-email-baijiaju1990@163.com>
Message-ID: <20170603085035.GB23970@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jia-Ju Bai <baijiaju1990@163.com>
Cc: oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, bobijam.xu@intel.com, dmitry.eremin@intel.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

On Wed, May 31, 2017 at 04:00:41PM +0800, Jia-Ju Bai wrote:
> The driver may sleep under a spin lock, and the function call path is:
> cfs_wi_exit (acquire the lock by spin_lock)
>   LASSERT
>     lbug_with_loc
>       libcfs_debug_dumplog
>         schedule and kthread_run --> may sleep
> 
> To fix it, all "LASSERT" is placed out of the spin_lock and spin_unlock.
> 
> Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
> ---
>  drivers/staging/lustre/lnet/libcfs/workitem.c |   13 +++++++------
>  1 file changed, 7 insertions(+), 6 deletions(-)

What changed from v1?  You have to always tell us that.

Please redo all of these, if they are still valid patches, and send them
as a patch series, so I know what order they should be applied in.

thanks,

greg k-h
