From: Greg KH <gregkh@linuxfoundation.org>
Date: Sun, 12 Mar 2017 14:37:22 +0100
Subject: [lustre-devel] [PATCH] staging: lustre fix constant comparision
 style issue in lu_object.h
In-Reply-To: <20170311130740.11488-1-Craig@craiginches.com>
References: <20170311130740.11488-1-Craig@craiginches.com>
Message-ID: <20170312133722.GC27791@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Craig Inches <Craig@craiginches.com>
Cc: oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

On Sat, Mar 11, 2017 at 01:07:40PM +0000, Craig Inches wrote:
> This patch resolves the "Comparisons should place the constant on
> the right side of the test" found with checkpatch tool.

Both are constants, I think checkpatch is the thing that is wrong here,
don't you agree?

thanks,

greg k-h
