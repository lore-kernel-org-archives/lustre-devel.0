From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Sat, 18 Jun 2016 19:02:35 -0700
Subject: [lustre-devel] [PATCH 2/3] staging: luster: Checkpatch Cleanup
In-Reply-To: <109b0da96b67ae70145433b585ada631a5f7c668.1466279901.git.craig@craiginches.com>
References: <cover.1466279901.git.craig@craiginches.com>
	<109b0da96b67ae70145433b585ada631a5f7c668.1466279901.git.craig@craiginches.com>
Message-ID: <20160619020235.GA18034@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Craig Inches <craig@craiginches.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On Sat, Jun 18, 2016 at 10:25:55PM +0100, Craig Inches wrote:
> Macros with complex values should be enclosed in parenthesis
> 
> Signed-off-by: Craig Inches <craig@craiginches.com>
> ---
>  drivers/staging/lustre/lustre/include/cl_object.h | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)

ALWAYS test build your patches, to not do so just makes maintainers
grumpy...

Remember, checkpatch is a _hint_, it's not always right.

greg k-h
