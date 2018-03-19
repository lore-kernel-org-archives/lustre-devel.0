From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Mon, 19 Mar 2018 17:16:32 +0100
Subject: [lustre-devel] [PATCH] staging: lustre: o2iblnd: Fix FastReg
 map/unmap for MLX5
In-Reply-To: <B5E4E902-16A7-4279-BE5A-8117E23286E9@me.com>
References: <B5E4E902-16A7-4279-BE5A-8117E23286E9@me.com>
Message-ID: <20180319161632.GB26103@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Doug Oucharek <dougso@me.com>
Cc: devel@driverdev.osuosl.org, "Dilger, Andreas" <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Drokin,
 Oleg" <oleg.drokin@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

On Wed, Mar 14, 2018 at 11:18:30PM -0700, Doug Oucharek wrote:
> The FastReg support in ko2iblnd was not unmapping pool items
> causing the items to leak.  In addition, the mapping code
> is not growing the pool like we do with FMR.
> 
> This patch makes sure we are unmapping FastReg pool elements
> when we are done with them.  It also makes sure the pool
> will grow when we depleat the pool.
> 
> Signed-off-by: Doug Oucharek <doug.s.oucharek@intel.com>
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-9472
> Reviewed-on: https://review.whamcloud.com/27015
> Reviewed-by: Andrew Perepechko <andrew.perepechko@seagate.com>
> Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
> Reviewed-by: James Simmons <uja.ornl@yahoo.com>
> Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
> Signed-off-by: Doug Oucharek <dougso@me.com>
> ---
> drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |  2 +-
> drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c | 12 ++++--------
> 2 files changed, 5 insertions(+), 9 deletions(-)

Also does not apply :(

Please rebase and resend.

thanks,

greg k-h
