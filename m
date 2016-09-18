From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Sun, 18 Sep 2016 21:27:30 +0000
Subject: [lustre-devel] [PATCH v2] staging: lustre: lustre/ldlm: Fixed
	sparse warnings
In-Reply-To: <1474233499-11369-1-git-send-email-itachi.opsrc@gmail.com>
References: <DAAEA517-69C8-4BDC-9F5E-526D7544F9B4@intel.com>
	<1474233499-11369-1-git-send-email-itachi.opsrc@gmail.com>
Message-ID: <804AE8F8-BF12-4847-9AAD-B652A0BFF288@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nayeemahmed Badebade <itachi.opsrc@gmail.com>
Cc: Greg KH <gregkh@linuxfoundation.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>


> On Sep 18, 2016, at 23:18, Nayeemahmed Badebade <itachi.opsrc@gmail.com> wrote:
> 
> Added __acquires / __releases sparse locking annotations
> to lock_res_and_lock() and unlock_res_and_lock() functions
> in l_lock.c, to fix below sparse warnings:
> 
> l_lock.c:47:22: warning: context imbalance in 'lock_res_and_lock' - wrong count at exit
> l_lock.c:61:6: warning: context imbalance in 'unlock_res_and_lock' - unexpected unlock
> 
> Signed-off-by: Nayeemahmed Badebade <itachi.opsrc@gmail.com>

Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>

> ---
> 
> Changes in v2:
> * Corrected sparse annotations for the lock
>   lock->l_resource->lr_lock
> 
> drivers/staging/lustre/lustre/ldlm/l_lock.c | 4 ++++
> 1 file changed, 4 insertions(+)
> 
> diff --git a/drivers/staging/lustre/lustre/ldlm/l_lock.c b/drivers/staging/lustre/lustre/ldlm/l_lock.c
> index ea8840c..3845f38 100644
> --- a/drivers/staging/lustre/lustre/ldlm/l_lock.c
> +++ b/drivers/staging/lustre/lustre/ldlm/l_lock.c
> @@ -45,6 +45,8 @@
>  * being an atomic operation.
>  */
> struct ldlm_resource *lock_res_and_lock(struct ldlm_lock *lock)
> +				__acquires(&lock->l_lock)
> +				__acquires(&lock->l_resource->lr_lock)
> {
> 	spin_lock(&lock->l_lock);
> 
> @@ -59,6 +61,8 @@ struct ldlm_resource *lock_res_and_lock(struct ldlm_lock *lock)
>  * Unlock a lock and its resource previously locked with lock_res_and_lock
>  */
> void unlock_res_and_lock(struct ldlm_lock *lock)
> +		__releases(&lock->l_resource->lr_lock)
> +		__releases(&lock->l_lock)
> {
> 	/* on server-side resource of lock doesn't change */
> 	ldlm_clear_res_locked(lock);
> --
> 1.9.1
> 
