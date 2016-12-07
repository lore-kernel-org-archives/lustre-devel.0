From: Oleg Drokin <oleg.drokin@intel.com>
Date: Wed, 7 Dec 2016 12:22:41 -0500
Subject: [lustre-devel] [PATCH] staging: lustre: Fix a spatch warning
	due to an assignment from kernel to user space
In-Reply-To: <33d23121-e5ca-0e14-bfbb-632f883e0948@gmail.com>
References: <20161202173332.5100-1-lambert.quentin@gmail.com>
	<306D1D4D-A949-44F6-BAFE-44F08F609D9B@intel.com>
	<81821426-c32c-c45a-e9a3-82f9818fc986@gmail.com>
	<33d23121-e5ca-0e14-bfbb-632f883e0948@gmail.com>
Message-ID: <92C79E56-E447-46CB-9D4C-ECC862F2B43E@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Quentin Lambert <lambert.quentin@gmail.com>
Cc: Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org


On Dec 7, 2016, at 10:20 AM, Quentin Lambert wrote:

> Hi all,
> 
> I am looking at the drivers/staging/lustre/lustre/llite/dir.c:
> 
> 1469                 /* Call mdc_iocontrol */
> 1470                 rc = obd_iocontrol(LL_IOC_FID2MDTIDX, exp, sizeof(fid), &fid,
> 1471                                    &index);
> 1472                 if (rc)
> 
> and sparse says:
> 
> drivers/staging/lustre/lustre/llite/dir.c:1471:37: warning: incorrect type in argument 5 (different address spaces)
> 
> I was wondering if there was any value to add a cast to fix the warning?

These's a sister warning to this one, btw, in
drivers/staging/lustre/lustre/lmv/lmv_obd.c:996:19: warning: cast removes address space of expression

It is an ugly kludge and I guess needs to just be reworked somehow instead to avoid
these ugly games.
