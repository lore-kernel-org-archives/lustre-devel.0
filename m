From: Joe Perches <joe@perches.com>
Date: Sat, 12 Mar 2016 11:29:30 -0800
Subject: [lustre-devel] [PATCH 1/6] staging: lustre: Correct missing
 newline for CERROR call in sfw_handle_server_rpc
In-Reply-To: <FA14ED53-EE7A-4DF4-9D98-1ABD9229BDCB@intel.com>
References: <1457805636-23859-1-git-send-email-jsimmons@infradead.org>
	<1457805636-23859-2-git-send-email-jsimmons@infradead.org>
	<1457807005.11972.9.camel@perches.com>
	<5A0A38B8-B387-436D-B72A-7D8247B6A00D@intel.com>
	<1457808989.11972.22.camel@perches.com>
	<FA14ED53-EE7A-4DF4-9D98-1ABD9229BDCB@intel.com>
Message-ID: <1457810970.11972.28.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Drokin, Oleg" <oleg.drokin@intel.com>
Cc: James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "<devel@driverdev.osuosl.org>" <devel@driverdev.osuosl.org>, "Dilger, Andreas" <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "Nunez, James A" <james.a.nunez@intel.com>

On Sat, 2016-03-12 at 19:17 +0000, Drokin, Oleg wrote:
> On Mar 12, 2016, at 1:56 PM, Joe Perches wrote:
> > On Sat, 2016-03-12 at 18:32 +0000, Drokin, Oleg wrote:
> > > On Mar 12, 2016, at 1:23 PM, Joe Perches wrote:
> > > > On Sat, 2016-03-12 at 13:00 -0500, James Simmons wrote:
> > > > > From: James Nunez <james.a.nunez@intel.com>
> > > > > 
> > > > > This is one of the fixes broken out of patch 10000 that was
> > > > > missed in the merger. With this fix the CERROR called in
> > > > > sfw_handle_server_rpc will print out correctly.
> > > > Speaking of CERROR and logging, it it really useful
> > > > for each CERROR use to have 2 static structs?
> > > > 
> > > > In CERROR -> CDEBUG_LIMIT there is a:
> > > > 	static struct cfs_debug_limit_state cdls;
> > > > 	(12 or 16 bytes depending on 32/64 bit arch)
> > > > 
> > > > and in CDEBUG_LIMIT -> _CDEBUG
> > > > 	static struct libcfs_debug_msg_data msgdata;
> > > > 	(24 or 36 bytes depending on 32/64 bit arch)
> > > > 
> > > > That seems a largish bit of data and code to initialize
> > > > these structs for over a thousand call sites.
> > > > 
> > > > Wouldn't a single static suffice?
> > > Single static would not work because the code is parallel so it'll
> > > stomp over each other.
> > Sure, but would that matter in practice?
> Well. The bits about the callsite would certainly matter since
> we need to know where the message is coming from.
> Overwriting them in a racy way would make the messages unreliable.
> > net_ratelimit() has similar parallelization and it doesn't
> > seem to matter there.
> That one seems to rate limit all prints together.
> We are trying limit each individual one.
> So if you have a bunch of print1 and a bunch of print2, but a few
> of print3, you see the print3, but ratelimit the first two
> and get something like this in the logs:
> 
> print1
> print2
> print3
> print2 condensed: the message was repeated a gazillion times
> print3
> print1 condensed: the message was repeated two gazillion times.

Sure. ?It's up to you to control your output and
I don't know if it matters or not. ?You do.

> > > or do you mean to have a common
> > > structure for every callsite (but instantiated separately)?
> > That might help a tiny bit.
> > 
> > Some possibly unnecessary bits:
> > 
> > o .msg_cdls
> How are we going to rate-limit this stuff without remembering some
> information between the calls?

Doesn't msg_cdls just point to the other structure?
Combining the 2 into one might be useful.

> > o __FILE__, __func__ and __LINE__ fields have marginal value
> Probably not as important in the kernel indeed, but on the
> other hand if the message has moved compared to the source developer has
> then there is evidence some patches were applied and that could be asked
> about.

> > o .msg_subsys seems set only to DEBUG_SUBSYSTEM.
> This is redefined in every source file:

Thanks. ?I didn't look hard.
