From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 30 Jan 2017 13:54:46 +0300
Subject: [lustre-devel] [PATCH 60/60] staging: lustre: libcfs: fix
 minimum size check for libcfs ioctl
In-Reply-To: <20170130105156.GA6881@mwanda>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
	<1485648328-2141-61-git-send-email-jsimmons@infradead.org>
	<20170130105156.GA6881@mwanda>
Message-ID: <20170130105446.GA6970@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>, Liang Zhen <liang.zhen@intel.com>, Amir Shehata <amir.shehata@intel.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Mon, Jan 30, 2017 at 01:51:56PM +0300, Dan Carpenter wrote:
> The lstcon_ioctl_entry() function doesn't have enough size checking.

Actually, the lstcon_ioctl_entry() would have been fine before we apply
this [patch 60/60]...  As near as I can tell, no in kernel code is
negatively affected by the bug this patch fixes.

regards,
dan carpenter
