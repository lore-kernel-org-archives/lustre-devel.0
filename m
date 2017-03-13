From: Craig Inches <craig@craiginches.com>
Date: Mon, 13 Mar 2017 13:13:51 +0000
Subject: [lustre-devel] [PATCH] staging: lustre fix constant comparision
 style issue in lu_object.h
In-Reply-To: <20170313121110.GD4136@mwanda>
References: <20170311130740.11488-1-Craig@craiginches.com>
	<20170312133722.GC27791@kroah.com> <20170313121110.GD4136@mwanda>
Message-ID: <20170313131351.GA14108@starbase.xayto.local>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Greg KH <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, oleg.drokin@intel.com, andreas.dilger@intel.com, lustre-devel@lists.lustre.org

On Mon, Mar 13, 2017 at 03:11:10PM +0300, Dan Carpenter wrote:
> On Sun, Mar 12, 2017 at 02:37:22PM +0100, Greg KH wrote:
> > On Sat, Mar 11, 2017 at 01:07:40PM +0000, Craig Inches wrote:
> > > This patch resolves the "Comparisons should place the constant on
> > > the right side of the test" found with checkpatch tool.
> > 
> > Both are constants, I think checkpatch is the thing that is wrong here,
> > don't you agree?
> 
> Sort of constant-ish...  The sizeof(*value) changes each time the macro
> is used.  I feel like checkpatch is right.
> 
> regads,
> dan carpenter
> 

That was my take aswell.. PAGE_SIZE is constant for each boot, but
sizeof could change. Happy to be lead by the more experienced here
though.

Cheers
Craig
