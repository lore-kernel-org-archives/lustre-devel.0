From: Andreas Dilger <adilger@sun.com>
Date: Thu, 18 Jun 2009 02:40:01 -0600
Subject: [Lustre-devel] Thinking of Hacks around bug #12329
In-Reply-To: <4A385D3C.6080906@sun.com>
References: <9c21eeae0905131106w23032105tdcf9a2399fb550df@mail.gmail.com>
	<20090514062224.GD3209@webber.adilger.int>
	<13983758-B9C5-4770-A4AC-39AAF75C6980@sun.com>
	<C4317953-7323-4FD0-9D36-A78DA94EF216@sun.com>
	<20090514212833.GN3209@webber.adilger.int> <4A385D3C.6080906@sun.com>
Message-ID: <20090618084001.GN13073@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jun 16, 2009  20:04 -0700, Nathaniel Rutman wrote:
> Andreas Dilger wrote:
> > On May 14, 2009  11:48 -0400, Oleg Drokin wrote:
> >   
> >> On May 14, 2009, at 10:25 AM, Oleg Drokin wrote:
> >>> Actually just to combat situqtion like this MGCs are doing a bit of a
> >>> pause
> >>> for a few seconds before refetching config, I remember there was a bug
> >>> and this measure was introduced as a fix.
> >>       
> >> Nic actually tuned in and said that the backoff (set at 3 seconds now)
> >> is certainly not enough, since it takes this long to only mount actual
> >> on-disk fs
>
> This is probably the easiest thing to try out for fixing bug 12329.   
> Put this up at 30s or 60s or something -- it's just the amount of time 
> it takes to update after a config change.  These will be rare and 
> asynchronous, so there's no real penalty for waiting.  Preventing 
> thousands of clients from trying to re-read the config log every few 
> seconds seems like a no-brainer.  See mgc_requeue_thread.

The one potential problem with this is that if the MDS creates a file
on one of the newly-added OSTs, but the clients don't see this OST for
60s then there is a big window for hitting an IO error due to the "bad"
striping (from the POV of that client).  I don't _think_ there is any
coordiation between refreshing the config lock and doing other IO...

> >> Anyway that got me thinking that we have a "coarse-grained" locking  
> >> problem.  Since OSTs don't connect to other OSTs, they do not care about
> >> OST connections, and perhaps if we introduce bit-locks to MGS locks as
> >> well to indicate client type, then locks from OSTs would only be revoked
> >> when MDS connects or disconnects, MDS locks would only be revoked when
> >> OSTs connect or disconnect and client locks would be revoked always.
> >> Or alternatively we can split our single resource right now to a few  
> >> separate:
> >>     
> >> one for osts one for MDSes for example, sure that would mean clients  
> >> would not have to take two locks, but on the other hand there would
> >> be supposedly less information to reparse when one of those locks is
> >> invalidated.
> >
> > I would tend to prefer the latter.  Having separate resource IDs for
> > the different llogs makes it a lot cleaner in the end.  Ideally,
> > picking a relatively unique resource ID for that config log would
> > allow us to separate the configs between different filesystems.
> >
> > The OSTs in fact don't really need to read the same llog as the client for
> > very many things (some shared tunables, perhaps), and there also isn't
> > a big problem IMHO to store the same tunables in two different config
> > llogs (one for servers and one for clients).  Generally, the server-side
> > tunables are not used by the client, and vice versa.  Probably the only
> > place that would need to read two config llogs is the MDS, which is both
> > a server and a client of the OSTs.
>   
> The OSTs in fact do read a separate llog than the client.  But there is 
> still a single config lock per fs on the MGS, so that doesn't really matter.
> Revoking the lock causes everybody in the fs to try to update, even if
> there's nothing new in their particular log.  Oleg's fine-grained idea,
> or simply separate locks, would help in this case.

Yes, I think this is fairly important for very large filesystems, since
there appears to be some kind of O(n^2) behaviour going on with respect
to many OSTs connecting, trying to get the single config lock (which
they don't really need in the end) and then slowing everything down.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
