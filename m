From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 13 Jan 2017 08:41:52 +0100
Subject: [lustre-devel] [PATCH 2/5] staging/lustre/mgc: Combine two
 seq_printf() calls into one call in lprocfs_mgc_rd_ir_state()
In-Reply-To: <C204F97C-59ED-4558-9322-0EC7B63AA44B@intel.com>
References: <45ae8939-a775-865b-ade0-9e38a7ff2b5d@users.sourceforge.net>
	<25b07069-c624-cdd4-ca7b-85aaae51e79e@users.sourceforge.net>
	<C204F97C-59ED-4558-9322-0EC7B63AA44B@intel.com>
Message-ID: <20170113074152.GA16646@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>
Cc: SF Markus Elfring <elfring@users.sourceforge.net>, devel@driverdev.osuosl.org, lustre-devel@lists.lustre.org, Andreas Dilger <andreas.dilger@intel.com>, Ben Evans <bevans@cray.com>, Bobi Jam <bobijam.xu@intel.com>, Emoly Liu <emoly.liu@intel.com>, Fan Yong <fan.yong@intel.com>, Gregoire Pichon <gregoire.pichon@bull.net>, Henri Doreau <henri.doreau@cea.fr>, James Simmons <jsimmons@infradead.org>, Jinshan Xiong <jinshan.xiong@intel.com>, "John L. Hammond" <john.hammond@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Lai Siyao <lai.siyao@intel.com>, Sebastien Buisson <sbuisson@ddn.com>, Stephen Champion <schamp@sgi.com>, wang di <di.wang@intel.com>, LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org

On Fri, Jan 13, 2017 at 01:58:37AM -0500, Oleg Drokin wrote:
> 
> On Jan 1, 2017, at 11:35 AM, SF Markus Elfring wrote:

<snip>

Oleg, please realize that I have blacklisted this patch author, and
don't take contributions from them, unless you, or someone else wishes
to properly review and pass them on.  I've found that personally, it's
just a waste of time working with them, but you are free to do whatever
you wish...

good luck!

greg k-h
