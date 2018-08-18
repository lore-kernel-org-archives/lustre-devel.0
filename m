From: James Simmons <jsimmons@infradead.org>
Date: Sat, 18 Aug 2018 01:59:07 +0100 (BST)
Subject: [lustre-devel] [PATCH 32/38] lustre: osc: restore
 cl_loi_list_lock
In-Reply-To: <87sh3dqwkm.fsf@notabene.neil.brown.name>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
 <1534475441-15543-33-git-send-email-jsimmons@infradead.org>
 <87sh3dqwkm.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1808180136341.2829@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> > Access to struct client_obd should be protected with the spinlock
> > cl_loi_list_lock. This was dropped during the port to sysfs so
> > restore the proper locking.
> >
> > Signed-off-by: James Simmons <jsimmons@infradead.org>
> > ---
> >  drivers/staging/lustre/lustre/osc/lproc_osc.c | 36 +++++++++++++++++++++++----
> >  1 file changed, 31 insertions(+), 5 deletions(-)
> >
> > diff --git a/drivers/staging/lustre/lustre/osc/lproc_osc.c b/drivers/staging/lustre/lustre/osc/lproc_osc.c
> > index 3c31e98..5fb7a16 100644
> > --- a/drivers/staging/lustre/lustre/osc/lproc_osc.c
> > +++ b/drivers/staging/lustre/lustre/osc/lproc_osc.c
> > @@ -80,8 +80,13 @@ static ssize_t max_rpcs_in_flight_show(struct kobject *kobj,
> >  	struct obd_device *dev = container_of(kobj, struct obd_device,
> >  					      obd_kset.kobj);
> >  	struct client_obd *cli = &dev->u.cli;
> > +	ssize_t len;
> >  
> > -	return sprintf(buf, "%u\n", cli->cl_max_rpcs_in_flight);
> > +	spin_lock(&cli->cl_loi_list_lock);
> > +	len = sprintf(buf, "%u\n", cli->cl_max_rpcs_in_flight);
> > +	spin_unlock(&cli->cl_loi_list_lock);
> 
> Why do you think a spinlock is needed here?
> How could you even end up with an incorrect value?

I see both mdc sysfs and the osc sysfs layer being able to
modify cl_max_rpcs_in_flight. Andreas is the struct client_obd
shared between both the osc and mdc layer or does each subsystem
contain a unique cli in struct obd_device?
