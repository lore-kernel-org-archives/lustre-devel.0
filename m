From: Andreas Dilger <adilger@whamcloud.com>
Date: Tue, 7 Jan 2020 01:53:59 +0000
Subject: [lustre-devel] Lustre upstreaming status.
In-Reply-To: <alpine.LFD.2.21.2001062316450.26511@casper.infradead.org>
References: <alpine.LFD.2.21.1802112308150.3291@casper.infradead.org>
 <87sglgg9ub.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.2001062316450.26511@casper.infradead.org>
Message-ID: <8E3FD560-7730-49D7-B5F5-0EC2BD08E149@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jan 6, 2020, at 17:02, James Simmons <jsimmons at infradead.org<mailto:jsimmons@infradead.org>> wrote:


Hi all,
At the LUG in Houston, I said that I hoped to submit something upstream
by the end of 2019.  Clearly that isn't going to happen now.

The main reason that caused me to not even try is IPv6 support.
It became apparent to me that LNet would not be accepted until it has
working IPv6 support, and that doesn't exist yet.
I hope to put some development time into IPv6, and to have something
that works and is worth reviewing by the end of January 2020.

That would be awesome. I believe the original plan was for IPv6 support
for 2.14 but USDP didn't make it in for 2.13 so everything got delayed.

The other issue is that development has progressed slowly because
there is no spare review bandwidth.  James has contributed a lot, and
others have helped, but reviewing patches for two code streams (OpenSFS
and Linux-upstream) turns out to be too much to ask for.
So I've decided to take a different approach.  From now on I'm not
going to wait for reviews for patches going into my linux-lustre tree.
Part of my justification for this is that historically, review hasn't
really provided much promise of correctness.  Patches go missing.
Random lines from patches go missing.  Errors creep in in other ways.

I have been going over the patches from your backport tree to find
missing patches and test for regressions. I think all regressions I
saw was stomped out for everything for 2.12. I'm doing full regression
right now. The only bug I see now is very unique to the linux client.

[snip]

I also have started working through the 2.13 release. I'm up to 2.12.54
but no heavy testing as of yet of those patches. Once I'm done testing
2.12 in depth I can push quickly through 2.13 and even sync up to
OpenSFS branch. I think the back porting work can be wrapped up by the
end of the month.

I thought the goal was to stop at 2.12.x (following the b2_12 branch to get
important fixes) and try to get that included upstream?  That gives a good
point-in-time to track, and ensures that the upstream code is aligned with
a relatively stable version of the code.  It also has the major benefit that
2.12 is an LTS branch and we will need to keep compatibility with that for
a long time, which isn't always true of intermediate releases.

Cheers, Andreas
--
Andreas Dilger
Principal Lustre Architect
Whamcloud






-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20200107/b5a019db/attachment.html>
