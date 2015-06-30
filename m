From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 30 Jun 2015 20:38:34 +0300
Subject: [lustre-devel] LIBCFS_ALLOC
In-Reply-To: <d2c4fda0148a4e579b5636b586d32fbe@EXCHCS32.ornl.gov>
References: <1434819550-3193-1-git-send-email-Julia.Lawall@lip6.fr>
	<1434819550-3193-2-git-send-email-Julia.Lawall@lip6.fr>
	<D1AECA61.F8DE5%andreas.dilger@intel.com>
	<alpine.DEB.2.02.1506280844460.2103@localhost6.localdomain6>
	<20150628215408.GG28762@mwanda>
	<d2c4fda0148a4e579b5636b586d32fbe@EXCHCS32.ornl.gov>
Message-ID: <20150630173834.GQ28762@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

All that you are saying is true and stuff that Julia and I have
discussed before.  For this call site though we are not allocating 32k,
we're allocating 4 pointers so libcfs_kvzalloc() doesn't make sense.

regards,
dan carpenter
