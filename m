From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Mon, 23 Apr 2018 15:12:27 +0200
Subject: [lustre-devel] [PATCH 5/6] staging: lustre: move misc-device
 registration closer to related code.
In-Reply-To: <152383935745.23409.17743342143483291145.stgit@noble>
References: <152383910760.23409.2327082725637657049.stgit@noble>
 <152383935745.23409.17743342143483291145.stgit@noble>
Message-ID: <20180423131227.GA7401@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Mon, Apr 16, 2018 at 10:42:37AM +1000, NeilBrown wrote:
> The ioctl handler for the misc device is in  lnet/libcfs/module.c
> but is it registered in lnet/libcfs/linux/linux-module.c.
> 
> Keeping related code together make maintenance easier, so move the
> code.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>

This and patch 6/6 did not apply due to something else changing these
files before these were sent in.

Can you rebase and resend?

thanks,

greg k-h
