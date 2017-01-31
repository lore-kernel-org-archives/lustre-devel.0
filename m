From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 31 Jan 2017 11:13:29 +0300
Subject: [lustre-devel] [PATCH 60/60] staging: lustre: libcfs: fix
 minimum size check for libcfs ioctl
In-Reply-To: <alpine.LFD.2.20.1701310203320.7738@casper.infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
	<1485648328-2141-61-git-send-email-jsimmons@infradead.org>
	<20170130105156.GA6881@mwanda>
	<alpine.LFD.2.20.1701310203320.7738@casper.infradead.org>
Message-ID: <20170131081329.GE6881@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Liang Zhen <liang.zhen@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Doug Oucharek <doug.s.oucharek@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, Amir Shehata <amir.shehata@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

On Tue, Jan 31, 2017 at 02:25:22AM +0000, James Simmons wrote:
> This sounds like a separate patch. I will open a ticket about this and
> your comments below.

There are a some other places that need a size requirement like
LNetCtl().

It really feels like it should be a part of this patch because this
patch is introducing a security breakage and it's just fixing a normal
bug.

regards,
dan carpenter
