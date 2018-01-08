From: James Simmons <jsimmons@infradead.org>
Date: Mon, 8 Jan 2018 16:21:50 +0000 (GMT)
Subject: [lustre-devel] [PATCH 5 v2: 00/19] staging: lustre: use
 standard wait_event macros
In-Reply-To: <20180108145943.GA5761@kroah.com>
References: <151538168618.23920.8261096424342988792.stgit@noble>
 <20180108145943.GA5761@kroah.com>
Message-ID: <alpine.LFD.2.21.1801081607120.1698@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: NeilBrown <neilb@suse.com>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>


> On Mon, Jan 08, 2018 at 02:28:13PM +1100, NeilBrown wrote:
> > Hi,
> >  this is a revised version of the patch series I sent under a similar
> >  subject in mid December.
> >  Improvements are:
> >    - new wait_event_idle* macros are now in include/linux/wait.h which
> >      Ack from peterz.
> >    - *all* waits are now TASK_IDLE or TASK_INTERRUPTIBLE and so don't
> >      affect the load average.  There is no need to choose whether load
> >      is appropriate or not in each case.
> >    - all l_wait_event() users are handled so l_wait_event() is
> >      removed.  The one case I had left out before uses
> >      wait_event_idle_exclusive() with and option of using
> >      wait_event_idle_exclusive_lifo() is that ever gets approved.
> > 
> >  I think this set is ready to go.
> >  If you only review two patches, please review
> > 
> >     staging: lustre: simplify waiting in ldlm_completion_ast()
> > and
> >     staging: lustre: remove back_to_sleep()
> > 
> >  as in both of those, the actual behaviour of the current code (as I
> >  understand it) doesn't seem to agree with comments/debug message, or
> >  just generally looks odd.
> 
> This series broke the build, so I'll roll back my tree and drop it.
> 
> Please fix it up and resend and test build it first...

Please don't merge these just yet. They need to be tested first. I don't 
want to be in a position where the lustre client is totally not usable 
like in the past. That kind of breakage makes no one want to use the
lustre client. We have a test suite for these kinds of changes. Neill do 
you know how to test your patches with the test suite? Also I have been 
working on several things for the last 4 months to merge upstream. I like
to coordinate with you so we don't step on each others toes.
