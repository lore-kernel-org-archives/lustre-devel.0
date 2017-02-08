From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Wed, 8 Feb 2017 07:27:20 +0100
Subject: [lustre-devel] [PATCH 10/60] staging: lustre: obdclass: add
 more info to sysfs version string
In-Reply-To: <ED30DA8B-BDFC-432C-93A9-309272C1C406@intel.com>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
	<1485648328-2141-11-git-send-email-jsimmons@infradead.org>
	<20170203103304.GA2600@kroah.com>
	<ED30DA8B-BDFC-432C-93A9-309272C1C406@intel.com>
Message-ID: <20170208062720.GA24445@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Dilger, Andreas" <andreas.dilger@intel.com>
Cc: "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Wed, Feb 08, 2017 at 01:04:52AM +0000, Dilger, Andreas wrote:
> 
> > On Feb 3, 2017, at 03:33, Greg Kroah-Hartman <gregkh@linuxfoundation.org> wrote:
> > 
> > On Sat, Jan 28, 2017 at 07:04:38PM -0500, James Simmons wrote:
> >> From: Andreas Dilger <andreas.dilger@intel.com>
> >> 
> >> Update the sysfs "version" file to print "lustre: " with
> >> the version number.
> >> 
> >> Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
> >> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5969
> >> Reviewed-on: http://review.whamcloud.com/16721
> >> Reviewed-by: James Simmons <uja.ornl@yahoo.com>
> >> Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
> >> Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
> >> Signed-off-by: James Simmons <jsimmons@infradead.org>
> >> ---
> >> drivers/staging/lustre/lustre/obdclass/linux/linux-module.c | 2 +-
> >> 1 file changed, 1 insertion(+), 1 deletion(-)
> >> 
> >> diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
> >> index 9f5e829..22e6d1f 100644
> >> --- a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
> >> +++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
> >> @@ -208,7 +208,7 @@ struct miscdevice obd_psdev = {
> >> static ssize_t version_show(struct kobject *kobj, struct attribute *attr,
> >> 			    char *buf)
> >> {
> >> -	return sprintf(buf, "%s\n", LUSTRE_VERSION_STRING);
> >> +	return sprintf(buf, "lustre: %s\n", LUSTRE_VERSION_STRING);
> >> }
> > 
> > Why?  You "know" this is lustre, why say it again?  Doesn't this affect
> > userspace tools?
> 
> It included "lustre: " as a prefix until commit 8b8284450569 when the code
> moved from /proc to /sys, and is what the userspace tools expect.  Formerly
> there were multiple strings printed in this file, each with a different prefix,
> but the "lustre: " prefix was dropped in the move to sysfs.
> 
> That didn't matter until a userspace patch to stop using ioctl(IOC_GET_VERSION)
> and instead get the version from the existing /proc or /sys files, so that we
> can deprecate and eventually drop the IOC_GET_VERSION ioctl completely.
> 
> So this patch is returning to the previous format of the /proc file, but if
> there is a big objection to this patch we can also change the userspace tools
> to live with or without this prefix now that there is only a single value here.

Think about it, it's a sysfs file, which should only have one value to
start with, and you are opening it from userspace knowing exactly where
it is (somewhere in the lustre subtree), so of course you know it is
"lustre"...

greg k-h
