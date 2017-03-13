From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 13 Mar 2017 15:11:10 +0300
Subject: [lustre-devel] [PATCH] staging: lustre fix constant comparision
 style issue in lu_object.h
In-Reply-To: <20170312133722.GC27791@kroah.com>
References: <20170311130740.11488-1-Craig@craiginches.com>
	<20170312133722.GC27791@kroah.com>
Message-ID: <20170313121110.GD4136@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg KH <gregkh@linuxfoundation.org>
Cc: Craig Inches <Craig@craiginches.com>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, oleg.drokin@intel.com, andreas.dilger@intel.com, lustre-devel@lists.lustre.org

On Sun, Mar 12, 2017 at 02:37:22PM +0100, Greg KH wrote:
> On Sat, Mar 11, 2017 at 01:07:40PM +0000, Craig Inches wrote:
> > This patch resolves the "Comparisons should place the constant on
> > the right side of the test" found with checkpatch tool.
> 
> Both are constants, I think checkpatch is the thing that is wrong here,
> don't you agree?

Sort of constant-ish...  The sizeof(*value) changes each time the macro
is used.  I feel like checkpatch is right.

regads,
dan carpenter
