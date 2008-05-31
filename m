From: Alex Zhuravlev <Alex.Zhuravlev@sun.com>
Date: Sat, 31 May 2008 13:37:49 +0400
Subject: [Lustre-devel] Commit on share
In-Reply-To: <20080531024524.GB2992@webber.adilger.int>
References: <C4620704.5499%peter.braam@sun.com> <op.ubxfheh9atmt0c@goga>
	<20080531024524.GB2992@webber.adilger.int>
Message-ID: <48411C6D.5090306@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Andreas Dilger wrote:
> Maybe I'm misunderstanding something (I didn't read HLD), but the commit
> callback can be set per Lustre transaction (in fact multiple callbacks
> can exist per transaction) so there should not be any need to do searching
> for finding per-transaction cleanup.  What state is the GC thread supposed
> to be cleaning up?  Doing GC is also searching, and that is undesirable in
> any case.

I think removal *few* (usually two, sometimes upto 4) deps from every callback
is quite expensive as we need to take spinlock and in short period of time we
have to remove thousands deps. for SMP it's not that good. even worse for NUMA.

instead we can do lazy free - in many cases we have to scan whole bucket anyway
as we search for possible dependency. so, under single spinlock instance and
with free searching we can collect stale entries and free them (or move onto
special list to free later).

as entries are supposed to be distributed evenly, this algo should work in most
cases. only if we see some bucket is getting too many stale entries we start GC.

thanks, Alex
