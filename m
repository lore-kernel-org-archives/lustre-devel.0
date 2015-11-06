From: Drokin, Oleg <oleg.drokin@intel.com>
Date: Fri, 6 Nov 2015 14:39:47 +0000
Subject: [lustre-devel] Should we have fewer releases?
In-Reply-To: <563BCDDE.9060103@llnl.gov>
References: <D25FA9D2.89BFF%spitzcor@cray.com> <563A6351.4080407@llnl.gov>
	<D25FC1DB.89C48%spitzcor@cray.com> <563BCDDE.9060103@llnl.gov>
Message-ID: <7AE60ED4-FCA4-4263-887B-5DFC8A0866DA@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Nov 5, 2015, at 4:45 PM, Christopher J. Morrone wrote:
> On the contrary, we need to go in the opposite direction to achieve those goals.  We need to shorten the release cycle and have more frequent releases.  I would recommend that we move to to a roughly three month release cycle.  Some of the benefits might be:
> 
> * Less change and accumulate before the release
> * The penalty for missing a release landing window is reduced when releases are more often
> * Code reviewers have less pressure to land unfinished and/or insufficiently reviewed and tested code when the penalty is reduced
> * Less change means less to test and fix at release time
> * Bug authors are more likely to still remember what they did and participate in cleanup.
> * Less time before bugs that slip through the cracks appear in a major release
> * Reduces developer frustration with long freeze windows
> * Encourages developers to rally more frequently around the landing windows instead of falling into a long period of silence and then trying to shove a bunch of code in just before freeze.  (They'll still try to ram things in just before freeze, but with more frequent landing windows the amount will be smaller and more manageable.)

Bringing this to the logical extreme - we should just have one release per major feature.
Sadly, I think the stabilization process is not likely to get any shorter. Either that or interested parties would only jump into testing when enough of interesting features accumulate,
after which point there'd be a bunch of bugreports for the current feature plus the backlocd that did not get any significant real-world testing before. We have seen this pattern
to some degree already even with current releases. The releases that are ignored by community for one reason or another tend to be not very stable and then the follow-on release
gets this "testing debt" baggage that is paid at release time once testing outside of Intel picks up the pace.

Bye,
    Oleg
