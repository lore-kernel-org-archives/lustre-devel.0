From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Wed, 24 Jan 2018 15:29:54 +0100
Subject: [lustre-devel] [PATCH v3] staging: lustre: separate a
 connection destroy from free struct kib_conn
In-Reply-To: <1516803252-14266-1-git-send-email-dmitry.eremin@intel.com>
References: <20180122103924.GB23996@kroah.com>
 <1516803252-14266-1-git-send-email-dmitry.eremin@intel.com>
Message-ID: <20180124142954.GA4658@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dmitry Eremin <dmitry.eremin@intel.com>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

On Wed, Jan 24, 2018 at 05:14:12PM +0300, Dmitry Eremin wrote:
> Rewrite the logic of the original commit 4d99b2581eff ("staging: lustre: avoid
> intensive reconnecting for ko2iblnd") and move the freeing a struct kib_conn
> outside of the function kiblnd_destroy_conn(). The freeing of struct kib_conn
> should be depending on the second argument free_conn of function
> kiblnd_destroy_conn(struct kib_conn *conn, bool free_conn). If it true the
> structure should be freed.
> 
> Fixes: 4d99b2581eff ("staging: lustre: avoid intensive reconnecting for ko2iblnd")
> Signed-off-by: Dmitry Eremin <Dmitry.Eremin@intel.com>
> ---
>  drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    | 7 +++----
>  drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    | 2 +-
>  drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c | 6 ++++--
>  3 files changed, 8 insertions(+), 7 deletions(-)

What changed from version 2 and 1?  Always included that below the ---
line please.

4th try is a charm?  :)

thanks,

greg k-h
