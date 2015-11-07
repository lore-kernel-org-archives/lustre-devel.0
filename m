From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 6 Nov 2015 19:27:47 -0800
Subject: [lustre-devel] [PATCH] staging: lustre: remove
	IOC_LIBCFS_PING_TEST ioctl
In-Reply-To: <563d5d08.0347370a.f9d83.2af9SMTPIN_ADDED_BROKEN@mx.google.com>
References: <563d5d08.0347370a.f9d83.2af9SMTPIN_ADDED_BROKEN@mx.google.com>
Message-ID: <20151107032747.GA14108@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, Nov 06, 2015 at 09:08:03PM -0500, y at ccs.ornl.gov wrote:
> From: James Simmons <uja.ornl@yahoo.com>
> 
> The ioctl IOC_LIBCFS_PING_TEST has not been used in
> ages. The recent nidstring changes which moved all
> the nidstring operations from libcfs to the LNet
> layer but this ioctl code was still using an
> nidstring operation that was causing an circular
> dependency loop between libcfs and LNet.
> 
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  .../lustre/include/linux/libcfs/libcfs_ioctl.h     |    1 -
>  drivers/staging/lustre/lustre/libcfs/module.c      |   17 -----------------
>  2 files changed, 0 insertions(+), 18 deletions(-)

You sent me 2 copies of this, which am I supposed to apply?  I've
dropped both, please resend the correct one.

thanks,

greg k-h
