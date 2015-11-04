From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Tue, 3 Nov 2015 17:23:51 -0800
Subject: [lustre-devel] [patch] staging: lustre: remove unused variable
In-Reply-To: <e882e5418520468ea1597a1719954b8b@EXCHCS32.ornl.gov>
References: <20151103221616.GD19280@mwanda>
	<e882e5418520468ea1597a1719954b8b@EXCHCS32.ornl.gov>
Message-ID: <20151104012351.GA9784@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Nov 03, 2015 at 10:38:15PM +0000, Simmons, James A. wrote:
> 
> >The "->lr_lvb_data" struct member is never used.  Delete it.
> >
> >Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> >---
> >I have compile tested this.  I looked through the history and it seems
> >to never have been used.  I wonder if we can remove the locking as well.
> 
> This is used by the quota and ofd layer which are both server side. 

What does that mean here?

confused,

greg k-h
