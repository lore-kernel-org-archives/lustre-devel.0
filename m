From: Eric Barton <eeb@sun.com>
Date: Tue, 24 Feb 2009 00:39:51 +0300
Subject: [Lustre-devel] moving obd_fail_check to libcfs
In-Reply-To: <56B06EF4-AAF5-448C-96C0-55E5E9A1AA44@sun.com>
References: <49A18841.7030200@cray.com>
	<56B06EF4-AAF5-448C-96C0-55E5E9A1AA44@sun.com>
Message-ID: <010b01c995ff$43083420$c9189c60$@com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Although I could agree that there should be levels of abstraction
above libcfs, it is, de facto, the place we put _all_ generic code
- not just stateless porting primitives, but everything that can be
used everywhere.

I don't actually think of obd_fail_check as inexorably bound with
/proc.  But since that's the current implementation, it's probably
my oversight not to have shared that sense of direction.

Nic, is the patch totally /proc - centric?  Wangdi is doing the work
to remove /proc-ness and make our tuneables, configurables and monitoring
more portable.  He needs to be involved...

    Cheers,
              Eric

> -----Original Message-----
> From: lustre-devel-bounces at lists.lustre.org [mailto:lustre-devel-bounces at lists.lustre.org] On Behalf Of Robert Read
> Sent: 23 February 2009 11:11 AM
> To: Nic Henke
> Cc: lustre-devel at lists.lustre.org
> Subject: Re: [Lustre-devel] moving obd_fail_check to libcfs
> 
> I don't think libcfs currently initializes any proc entries, so it's
> not clear how you will set obd_fail_loc.  In theory libcfs should just
> thin library of porting primitives, and things like logging and
> fail_check should be in a layer just above libcfs which could have a
> management interface.    So far we've just put some extra low-level
> functionality into libcfs, but at some point it should be refactored.
> I think when we need to add initialization code and an interface is
> that point.
> 
> robert
> 
> 
> On Feb 22, 2009, at 8:15 PM, Nic Henke wrote:
> 
> > Would there be any objection to a patch that'd move the current
> > obdclass-centric obd_fail_check and friends to libcfs ? I'd like to be
> > able to use the same logic inside LNET and our new LND without
> > replicating the code.
> >
> > I'm thinking it would need to be renamed to CFS_FAIL_CHECK as well.
> >
> > Thoughts or suggestions?
> >
> > Nic
> > _______________________________________________
> > Lustre-devel mailing list
> > Lustre-devel at lists.lustre.org
> > http://lists.lustre.org/mailman/listinfo/lustre-devel
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
