From: Ken Hornstein <kenh@cmf.nrl.navy.mil>
Date: Fri, 16 Mar 2012 10:38:27 -0400
Subject: [Lustre-devel] [Twg] Lustre and cross-platform portability
In-Reply-To: <C481511A-14DB-4032-9071-82AF5974E263@whamcloud.com>
Message-ID: <201203161438.q2GEcSVL005257@hedwig.cmf.nrl.navy.mil>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>Ken, my apologies for this misstatement.  I guess that my faulty memory
>is to blame for the fact that I didn't recall the MacOS code was made
>publicly available for download.

No problem.  Back when I gave the talk at LUG the source wasn't available
yet due to issues here, but we got that worked out and I was pushing
my changes to a publically available Oracle git repo.  I did send out
email to everyone about that, but I'm sure it was easy to miss.

>I don't think I've ever seen patches sent from you to either Oracle or
>Whamcloud, and unfortunately nobody on our side has had the bandwidth or
>user demand/funding to be pulling such changes either.

Well, I did actually submit patches to Oracle to start the process of
working out at least the portability issues, but I believe that was
when Oracle started to implode the Lustre group so things sort of
stalled.  I'll take 75% of the blame for that if we assign 25% to
Larry Ellison :-)

>This isn't strictly correct.  It would be possible to change the libcfs
>portability layer to export the same API as the Linux kernel to MacOS
>and Windows.  This would simplify getting the client into the Linux
>kernel, but still allow a native client on MacOS.

Well ... that shifts the burden to cross-platform people basically having
to re-implment the Linux kernel.  For some things, that's possible without
too much pain.  For other things, it's not.

--Ken
