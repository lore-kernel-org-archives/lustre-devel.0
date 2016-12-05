From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 5 Dec 2016 23:57:15 +0300
Subject: [lustre-devel] [PATCH 05/22] staging: lustre: lmv: remove nlink
 check in lmv_revalidate_slaves
In-Reply-To: <1480726409-20350-6-git-send-email-jsimmons@infradead.org>
References: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
	<1480726409-20350-6-git-send-email-jsimmons@infradead.org>
Message-ID: <20161205205715.GC31465@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, wang di <di.wang@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Fri, Dec 02, 2016 at 07:53:12PM -0500, James Simmons wrote:
> From: wang di <di.wang@intel.com>
> 
> Remove nlink < 2 check in lmv_revalidate_slaves, because
> after nlink reaches to LDISKFS_LINK_MAX (65000), the inode
> nlink will be set to 1.
> 

I don't understand how this changelog matches the patch...

The changelog says we're removing a check but really this is a NULL
dereference fix, right?  We're not really removing a check at all, just
changing it for something else.  We do remove a printk, though.

regards,
dan carpenter
