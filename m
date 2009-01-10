From: Andreas Dilger <adilger@sun.com>
Date: Fri, 09 Jan 2009 17:50:16 -0700
Subject: [Lustre-devel] imperative recovery
In-Reply-To: <C8209894-129B-4115-94BC-0F4B80EFADCE@sun.com>
References: <1906DB02-F9DF-4F49-9A9A-23FE7E799EA8@sun.com>
	<046101c95ef4$2fe3a8d0$8faafa70$@com> <494AAF4A.4030304@sun.com>
	<49676CF9.5050805@cray.com>
	<C8209894-129B-4115-94BC-0F4B80EFADCE@sun.com>
Message-ID: <20090110005016.GL13721@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jan 09, 2009  09:04 -0800, Robert Read wrote:
> On Jan 9, 2009, at 07:27 , Nicholas Henke wrote:
> > This would be a great enhancement for OSS failover or reboot, it is  
> > really the only way we'll get to recovery times under ~2.5 x obd_timeout.  
> >
> > I do think this will miss a significant case: combo MGS+MDS. A  
> > majority of our customers are deploying with this configuration.
> > Perhaps exposing this mechanism on the clients via a /proc file
> > would be enough - that way a failover framework
> > could manually trigger the timeout and/or nid switching.
> 
> Yes, exactly what I was thinking. Exposing this feature via proc (or  
> lctl) on the clients is the first step. It's has minimal impact,  
> requires no changes to the server, and should integrate well with  
> existing failover frameworks.  We also need to get the server to end  
> recovery sooner (without waiting for all the stale exports), but VBR  
> should help with that.

Hey, wouldn't (essentially) "lctl --device $foo recover" do the trick
today?


Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
