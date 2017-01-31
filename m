From: James Simmons <jsimmons@infradead.org>
Date: Tue, 31 Jan 2017 01:00:59 +0000 (GMT)
Subject: [lustre-devel] [PATCH 13/60] staging: lustre: obdclass:
 health_check to report unhealthy upon LBUG
In-Reply-To: <20170130120352.GC6881@mwanda>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
	<1485648328-2141-14-git-send-email-jsimmons@infradead.org>
	<20170130120352.GC6881@mwanda>
Message-ID: <alpine.LFD.2.20.1701310054180.25626@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: e@mwanda
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Bruno Faccini <bruno.faccini@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>


> Wat?
> 
> I'm sorry but this patch makes no sense at all.
> 
> On Sat, Jan 28, 2017 at 07:04:41PM -0500, James Simmons wrote:
> > From: Bruno Faccini <bruno.faccini@intel.com>
> > 
> > When a LBUG has occurred, without panic_on_lbug being set,
> > health_check sysfs file must return an unhealthy state.
> 
> Why?

Its a patch being applied out of order issue. Originally this
patch was written before this was moved to sysfs and the original
code didn't return right after printing "LBUG". The move to
sysfs changed this behavior. I will fix up the out of tree code
in this case.
 
> > 
> > Signed-off-by: Bruno Faccini <bruno.faccini@intel.com>
> > Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7486
> > Reviewed-on: http://review.whamcloud.com/17981
> > Reviewed-by: Bobi Jam <bobijam@hotmail.com>
> > Reviewed-by: Niu Yawei <yawei.niu@intel.com>
> > Reviewed-by: James Simmons <uja.ornl@yahoo.com>
> > Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
> > Signed-off-by: James Simmons <jsimmons@infradead.org>
> > ---
> >  drivers/staging/lustre/lustre/obdclass/linux/linux-module.c | 6 ++++--
> >  1 file changed, 4 insertions(+), 2 deletions(-)
> > 
> > diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
> > index 22e6d1f..ef25db6 100644
> > --- a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
> > +++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
> > @@ -224,8 +224,10 @@ static ssize_t pinger_show(struct kobject *kobj, struct attribute *attr,
> >  	int i;
> >  	size_t len = 0;
> >  
> > -	if (libcfs_catastrophe)
> > -		return sprintf(buf, "LBUG\n");
> > +	if (libcfs_catastrophe) {
> > +		len = sprintf(buf, "LBUG\n");
> 
> This line is dead code, now.
> 
> > +		healthy = false;
> > +	}
> >  
> 
> regards,
> dan carpenter
> 
> 
