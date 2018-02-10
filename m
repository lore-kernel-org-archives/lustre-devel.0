From: James Simmons <jsimmons@infradead.org>
Date: Sat, 10 Feb 2018 20:57:11 +0000 (GMT)
Subject: [lustre-devel] [PATCH 41/80] staging: lustre: lmv: separate
 master object with master stripe
In-Reply-To: <FC7E817D-BA15-4D0A-9976-F1343F9B022A@intel.com>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
 <1471378773-24590-42-git-send-email-jsimmons@infradead.org>
 <87r2pvkkl5.fsf@notabene.neil.brown.name>
 <09CE6CEC-52BC-4B29-B609-40DE68A64A33@intel.com>
 <87o9kylux7.fsf@notabene.neil.brown.name>
 <FC7E817D-BA15-4D0A-9976-F1343F9B022A@intel.com>
Message-ID: <alpine.LFD.2.21.1802102027560.5700@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>
Cc: devel@driverdev.osuosl.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, NeilBrown <neilb@suse.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, wang di <di.wang@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>


> > On Feb 8, 2018, at 10:10 PM, NeilBrown <neilb@suse.com> wrote:
> > 
> > On Thu, Feb 08 2018, Oleg Drokin wrote:
> > 
> >>> On Feb 8, 2018, at 8:39 PM, NeilBrown <neilb@suse.com> wrote:
> >>> 
> >>> On Tue, Aug 16 2016, James Simmons wrote:
> >> 
> >> my that?s an old patch
> >> 
> >>> 
> > ...
> >>> 
> >>> Whoever converted it to "!strcmp()" inverted the condition.  This is a
> >>> perfect example of why I absolutely *loathe* the "!strcmp()" construct!!
> >>> 
> >>> This causes many tests in the 'sanity' test suite to return
> >>> -ENOMEM (that had me puzzled for a while!!).
> >> 
> >> huh? I am not seeing anything of the sort and I was running sanity
> >> all the time until a recent pause (but going to resume).
> > 
> > That does surprised me - I reproduce it every time.
> > I have two VMs running a SLE12-SP2 kernel with patches from
> > lustre-release applied.  These are servers. They have 2 3G virtual disks
> > each.
> > I have two over VMs running current mainline.  These are clients.
> > 
> > I guess your 'recent pause' included between v4.15-rc1 (8e55b6fd0660)
> > and v4.15-rc6 (a93639090a27) - a full month when lustre wouldn't work at
> > all :-(
> 
> More than that, but I am pretty sure James Simmons is running tests all the time too
> (he has a different config, I only have tcp).

Yes I have been testing and haven't encountered this problem. Let me try 
the fix you pointed out. 
 
> > Do you have a list of requested cleanups?  I would find that to be
> > useful.
> 
> As Greg would tell you, ?if you don?t know what needs to be done,
> let?s just remove the whole thing from staging now?.
> 
> I assume you saw drivers/staging/lustre/TODO already, it?s only partially done.

Actually the complete list is at :

https://jira.hpdd.intel.com/browse/LU-9679

I need to move that to our TODO list. Sorry I have been short on cycles.
