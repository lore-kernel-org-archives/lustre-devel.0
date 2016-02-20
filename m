From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Sat, 20 Feb 2016 15:34:21 -0800
Subject: [lustre-devel] [PATCH] staging: lusture: obdclass: Remove
	unnecessary NULL check
In-Reply-To: <20160218152539.GA28252@Karyakshetra>
References: <20160218152539.GA28252@Karyakshetra>
Message-ID: <20160220233421.GA25164@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Dmitry Eremin <dmiter4ever@gmail.com>, Bhumika Goyal <bhumirks@gmail.com>, Julia Lawall <Julia.Lawall@lip6.fr>, Cihangir Akturk <cakturk@gmail.com>, Joe Perches <joe@perches.com>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

On Thu, Feb 18, 2016 at 08:55:39PM +0530, Bhaktipriya Shridhar wrote:
> NULL check before the  debugfs_remove_recursive function is not needed.
> 
> This was detected using scripts/coccinelle/free/ifnullfree.cocci
> 
> Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
> ---
>  drivers/staging/lustre/lustre/obdclass/linux/linux-module.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)


Doesn't apply to my tree :(
