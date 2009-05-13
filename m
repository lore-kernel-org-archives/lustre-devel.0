From: David Brown <dmlb2000@gmail.com>
Date: Wed, 13 May 2009 11:06:57 -0700
Subject: [Lustre-devel] Thinking of Hacks around bug #12329
Message-ID: <9c21eeae0905131106w23032105tdcf9a2399fb550df@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Okay so since bug #12329 isn't so much fixed yet and we've been trying
to do big I/O runs on our cluster but we keep bumping up to this
issue.

So I was thinking of some hacks to get around the issue with prep work
prior to obtaining the big cluster to do whatever we want.

Just a little background on what we've been doing. PNL (Pacific
Northwest National Labs) has a unique cluster in the amount of local
scratch disk we require on our compute nodes. Because of this fact we
can take the big machine occasionally to do large scale I/O tests with
Lustre. This helps us understand how Lustre scales for future use and
how we might have to change the way we deal with our production Lustre
systems when upgrading them. We have about 1Tb/s theoretical local
scratch bandwidth on all of our compute nodes, we've only gotten a
quarter of this in a lustre file system using half the system, as of
yet.

We've tried 4 times since to put that image on the entire cluster and
see how well things work not getting any numbers so far.

The file system created has the following characteristics

1) 700Tb when df -h returns
2) 4600 OSTs (well within the max of 8192)
3) 2300 OSSs

We could have an alternate configuration where we break the raid
arrays and go a bit wider, 18000 OSTs on 2300 OSSs. But this would
require modifications to lustre source code to make that happen.

The bug above really hits us hard on this system, even on lustre
1.8.0. It took 5 hours just to get 4096 OSTs mounted.

As this is going on everything is in a constant state of reconnect,
since the mgs/mdt is busy handling new incoming OSTs. I'm glad to say
that the reconnects keep up and everything goes through the recovery
as expected.  When we've paused the mount process, the cluster settles
back down and df -h returns about 5 minutes afterwards, which is very
acceptable. However, there's a linear increase in the amount of
reconnects and traffic associated with those reconnects as the number
of OSTs increase during the mounting. This causes an increase in time
for the next OSTs that has to mount. Keep in mind that this is on a
brand new file system, not upgrading, not currently running. I would
expect this behavior wouldn't happen (or would be slightly different)
if the file system was already created.

Which leads me into the hack to get around the bug. I'm just wondering
thoughts or ideas as to what to watch for (or if it would even work).

Precreate mdt/mgs and ost images in a small form factor prior to
production cluster time.

1) pick a system and put lustre on it.
2) setup an mdt/mgs combo and mount it
3) create an ost and mount it
4) umount it save the image (should only be 10M or so not sure what
the smallest size would be).
5) deactivate the new ost
6) go to step 3 with the same disk you used before

You'd end up with pre-created images of a lustre file system prior to
deployment that you could dd onto all the drives in parallel quite
fast.

You could then run resize2fs on the file systems to fill up the OST to
the appropriate size for that device (not sure how long this would
take).

Then you would run tunefs.lustre to change where the mgsnode and
fsname is for that file system.

Then all you'd have to do is mount and the bug may be averted, right?

Just wondering if anyone has any thoughts or ideas on how to get
around this issue.

Thanks,
- David Brown
