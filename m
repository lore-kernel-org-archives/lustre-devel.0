From: Craig Inches <xayto@xayto.net>
Date: Sun, 19 Jun 2016 20:53:12 +0100
Subject: [lustre-devel] [PATCH 2/3] staging: luster: Checkpatch Cleanup
In-Reply-To: <20160619020235.GA18034@kroah.com>
References: <cover.1466279901.git.craig@craiginches.com>
	<109b0da96b67ae70145433b585ada631a5f7c668.1466279901.git.craig@craiginches.com>
	<20160619020235.GA18034@kroah.com>
Message-ID: <20160619195312.GA6855@voyager>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

I did build the kernel 1 for each change, then a final with all changes
applied.

Apologies if I missed something,

Craig

On Sat, Jun 18, 2016 at 07:02:35PM -0700, Greg Kroah-Hartman wrote:
> On Sat, Jun 18, 2016 at 10:25:55PM +0100, Craig Inches wrote:
> > Macros with complex values should be enclosed in parenthesis
> > 
> > Signed-off-by: Craig Inches <craig@craiginches.com>
> > ---
> >  drivers/staging/lustre/lustre/include/cl_object.h | 4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> ALWAYS test build your patches, to not do so just makes maintainers
> grumpy...
> 
> Remember, checkpatch is a _hint_, it's not always right.
> 
> greg k-h
