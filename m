From: Greg KH <gregkh@linuxfoundation.org>
Date: Mon, 12 Sep 2016 12:27:47 +0200
Subject: [lustre-devel] [PATCH] staging: lustre: lustre/ldlm: Fixed
	sparse warnings
In-Reply-To: <1473434435-27025-1-git-send-email-itachi.opsrc@gmail.com>
References: <1473434435-27025-1-git-send-email-itachi.opsrc@gmail.com>
Message-ID: <20160912102747.GA13621@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nayeemahmed Badebade <itachi.opsrc@gmail.com>
Cc: oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, Keith.Mannthey@intel.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, bruce.korb@gmail.com, lustre-devel@lists.lustre.org

On Fri, Sep 09, 2016 at 08:50:35PM +0530, Nayeemahmed Badebade wrote:
> Added __acquires / __releases sparse locking annotations
> to lock_res_and_lock and unlock_res_and_lock functions in
> l_lock.c, to fix below sparse warnings:
> 
>  l_lock.c:47:22: warning: context imbalance in 'lock_res_and_lock' - wrong count at exit
>  l_lock.c:62:6: warning: context imbalance in 'unlock_res_and_lock' - unexpected unlock
> 
> Signed-off-by: Nayeemahmed Badebade <itachi.opsrc@gmail.com>
> ---
>  drivers/staging/lustre/lustre/ldlm/l_lock.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/drivers/staging/lustre/lustre/ldlm/l_lock.c b/drivers/staging/lustre/lustre/ldlm/l_lock.c
> index ea8840c..c4b9612 100644
> --- a/drivers/staging/lustre/lustre/ldlm/l_lock.c
> +++ b/drivers/staging/lustre/lustre/ldlm/l_lock.c
> @@ -45,6 +45,8 @@
>   * being an atomic operation.
>   */
>  struct ldlm_resource *lock_res_and_lock(struct ldlm_lock *lock)
> +				__acquires(&lock->l_lock)
> +				__acquires(lock->l_resource)

Hm, these are tricky, I don't want to take this type of change without
an ack from the lustre developers...

thanks,

greg k-h
