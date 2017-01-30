From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 30 Jan 2017 13:51:56 +0300
Subject: [lustre-devel] [PATCH 60/60] staging: lustre: libcfs: fix
 minimum size check for libcfs ioctl
In-Reply-To: <1485648328-2141-61-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
	<1485648328-2141-61-git-send-email-jsimmons@infradead.org>
Message-ID: <20170130105156.GA6881@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>, Liang Zhen <liang.zhen@intel.com>, Amir Shehata <amir.shehata@intel.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

It looks like what happened is there were two patches applied out of
sync.  Let's add a fixes tag and CC the original author.

Fixes: ed2f549dc0f6 ("staging: lustre: libcfs: test if userland data is to small")

This patch was probably correct when it was written but commit
1290932728e5 ("staging: lustre: Dynamic LNet Configuration (DLC) IOCTL
changes") ended up getting applied first so the size was wrong.

The lstcon_ioctl_entry() function doesn't have enough size checking.
Also I'm uncomfortable with:

	data = container_of(hdr, struct libcfs_ioctl_data, ioc_hdr);

If hdr isn't the first member of the struct then the code is broken but
container_of() implies that that isn't a hard requirement.  It should
just be:

	data = (struct libcfs_ioctl_data *)hdr;

regards,
dan carpenter
