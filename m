From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 29 Jun 2015 00:54:08 +0300
Subject: [lustre-devel] LIBCFS_ALLOC
In-Reply-To: <alpine.DEB.2.02.1506280844460.2103@localhost6.localdomain6>
References: <1434819550-3193-1-git-send-email-Julia.Lawall@lip6.fr>
	<1434819550-3193-2-git-send-email-Julia.Lawall@lip6.fr>
	<D1AECA61.F8DE5%andreas.dilger@intel.com>
	<alpine.DEB.2.02.1506280844460.2103@localhost6.localdomain6>
Message-ID: <20150628215408.GG28762@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Yeah.  You're right.  Doing a vmalloc() when kmalloc() doesn't have even
a tiny sliver of RAM isn't going to work.  It's easier to use
libcfs_kvzalloc() everywhere, but it's probably the wrong thing.

regards,
dan carpenter
