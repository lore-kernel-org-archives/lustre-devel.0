From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 7 Dec 2016 18:32:14 +0300
Subject: [lustre-devel] [PATCH] staging: lustre: Fix a spatch warning
 due to an assignment from kernel to user space
In-Reply-To: <33d23121-e5ca-0e14-bfbb-632f883e0948@gmail.com>
References: <20161202173332.5100-1-lambert.quentin@gmail.com>
	<306D1D4D-A949-44F6-BAFE-44F08F609D9B@intel.com>
	<81821426-c32c-c45a-e9a3-82f9818fc986@gmail.com>
	<33d23121-e5ca-0e14-bfbb-632f883e0948@gmail.com>
Message-ID: <20161207153214.GN8176@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Quentin Lambert <lambert.quentin@gmail.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, devel@driverdev.osuosl.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org, Andreas Dilger <andreas.dilger@intel.com>, lustre-devel@lists.lustre.org

On Wed, Dec 07, 2016 at 04:20:06PM +0100, Quentin Lambert wrote:
> Hi all,
> 
> I am looking at the drivers/staging/lustre/lustre/llite/dir.c:
> 
> 1469                 /* Call mdc_iocontrol */
> 1470                 rc = obd_iocontrol(LL_IOC_FID2MDTIDX, exp,
> sizeof(fid), &fid,
> 1471                                    &index);
> 1472                 if (rc)
> 
> and sparse says:
> 
> drivers/staging/lustre/lustre/llite/dir.c:1471:37: warning:
> incorrect type in argument 5 (different address spaces)
> 
> I was wondering if there was any value to add a cast to fix the warning?
> And I guess this solution would also apply in my original patch to
> 
> drivers/staging/lustre/lnet/lnet/lib-socket.c

Just leave these alone until someone can come clean it up properly.

Warnings are good!  People have spent years and years to create
programs to print warnings.  Don't silence the warning by adding a cast.
The warning means show that the code is dangerous.

regards,
dan carpenter
