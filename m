From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Thu, 10 Nov 2016 13:21:08 +0100
Subject: [lustre-devel] [PATCH] staging: lustre: ldlm: pl_recalc time
 handling is wrong
In-Reply-To: <1594836.LAbS3nYoXQ@wuerfel>
References: <1478573240-12850-1-git-send-email-jsimmons@infradead.org>
	<4C1355CC-5CF8-4AB3-95F1-B356EC357D00@intel.com>
	<1594836.LAbS3nYoXQ@wuerfel>
Message-ID: <20161110122108.GA7580@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: "Dilger, Andreas" <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Wed, Nov 09, 2016 at 05:00:42PM +0100, Arnd Bergmann wrote:
> On Wednesday, November 9, 2016 3:50:29 AM CET Dilger, Andreas wrote:
> > On Nov 7, 2016, at 19:47, James Simmons <jsimmons@infradead.org> wrote:
> > > 
> > > The ldlm_pool field pl_recalc_time is set to the current
> > > monotonic clock value but the interval period is calculated
> > > with the wall clock. This means the interval period will
> > > always be far larger than the pl_recalc_period, which is
> > > just a small interval time period. The correct thing to
> > > do is to use monotomic clock current value instead of the
> > > wall clocks value when calculating recalc_interval_sec.
> > 
> > It looks like this was introduced by commit 8f83409cf
> > "staging/lustre: use 64-bit time for pl_recalc" but that patch changed
> > get_seconds() to a mix of ktime_get_seconds() and ktime_get_real_seconds()
> > for an unknown reason.  It doesn't appear that there is any difference
> > in overhead between the two (on 64-bit at least).
> 
> It was meant to use ktime_get_real_seconds() consistently, very sorry
> about the mistake. I don't remember exactly how we got there, I assume
> I had started out using ktime_get_seconds() and then moved to
> ktime_get_real_seconds() later but missed the last three instances.
> 
> > Since the ldlm pool recalculation interval is actually driven in response to
> > load on the server, it makes sense to use the "real" time instead of the
> > monotonic time (if I understand correctly) if the client is in a VM that
> > may periodically be blocked and "miss time" compared to the outside world.
> > Using the "real" clock, the recalc_interval_sec will correctly reflect the
> > actual elapsed time rather than just the number of ticks inside the VM.
> > 
> > Is my understanding of these different clocks correct?
> 
> No, this is not the difference: monotonic and real time always tick
> at exactly the same rate, the only difference is the starting point.
> monotonic time starts at boot and can not be adjusted, while real
> time is set to reflect the UTC time base and gets initialized
> from the real time clock at boot, or using settimeofday(2) or
> NTP later on.
> 
> In my changelog text, I wrote
> 
>     keeping the 'real' instead of 'monotonic' time because of the
>     debug prints.
> 
> the intention here is simply to have the console log keep the
> same numbers as "date +%s" for absolute values. The patch that
> James suggested converting everything to ktime_get_seconds()
> would result in the same intervals that have always been there
> (until I broke it by using time domains inconsistently), but
> would mean we could use a u32 type for pl_recalc_time and
> pl_recalc_period because that doesn't overflow until 136 years
> after booting. (signed time_t overflows 68 years after 1970,
> i.e 2038).

So, is this patch correct and should be merged to the tree, or not?

confused,

greg k-h
