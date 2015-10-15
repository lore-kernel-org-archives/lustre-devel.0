From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 15 Oct 2015 14:43:50 +0300
Subject: [lustre-devel] staging: add Lustre file system client support
In-Reply-To: <20151015113845.GQ7289@mwanda>
References: <20151015111419.GA24704@mwanda>
 <20151015113845.GQ7289@mwanda>
Message-ID: <20151015114350.GR7289@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Oct 15, 2015 at 02:38:45PM +0300, Dan Carpenter wrote:
> Actually this we can't overflow here, it will return -EFAULT if param is
> NULL and paramlen is non-zero.  I'll send a patch to clean this up.

Ugh... No, I won't send a patch for this.  That LIBCFS_ALLOC() macro is
inscrutible and I am not emotionally prepared to look at it.

regards,
dan carpenter
