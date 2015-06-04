From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 4 Jun 2015 10:41:07 +0300
Subject: [lustre-devel] [PATCH v4 4/7] staging:lustre: rename tcpip
 handling functions to lnet_* prefix
In-Reply-To: <20150604055710.GC6376@sudip-PC>
References: <1433361433-24976-1-git-send-email-jsimmons@infradead.org>
	<1433361433-24976-5-git-send-email-jsimmons@infradead.org>
	<20150604055710.GC6376@sudip-PC>
Message-ID: <20150604074107.GB28762@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Jun 04, 2015 at 11:27:10AM +0530, Sudip Mukherjee wrote:
> On Wed, Jun 03, 2015 at 03:57:10PM -0400, James Simmons wrote:
> > With all the TCPIP handling done in the lnet layer we should
> > rename all the functions with the prefix lnet_*. One other
> > change done was changing the remove argument of lnet_sock_getaddr
> > from a int to a bool.
> thats two different change.
> and apart from this:
> 1) the function declarations were renamed and moved from
> lustre/include/linux/libcfs/libcfs.h to drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> 
> 2) some functions you have changed the coding style. like:
> -     rc = libcfs_sock_getaddr(conn->ksnc_sock, 0,
> -                              &conn->ksnc_myipaddr, NULL);
> +     rc = lnet_sock_getaddr(conn->ksnc_sock, 0, &conn->ksnc_myipaddr, NULL);
> 

Those are tiny related changes.  They're fine.  When you rename
functions you normally have to change the indenting as well.

regards,
dan carpenter
