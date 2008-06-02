From: Johann Lombardi <johann@sun.com>
Date: Mon, 02 Jun 2008 14:22:07 +0200
Subject: [Lustre-devel] Moving forward on Quotas
In-Reply-To: <C4682B4E.5615%peter.braam@sun.com>
References: <20080528080613.GN3582@lore> <C4682B4E.5615%peter.braam@sun.com>
Message-ID: <20080602122207.GD3628@lore>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Jun 01, 2008 at 10:32:46AM +0800, Peter Braam wrote:
> I am quite worried about the dynamic qunit patch.
> I am not convinced I want smaller qunits to stick around.
>
> Please PROVE RIGOROUSLY that qunits are grow large quickly again, otherwise
> they create too much server - server overhead.

I've _not_ been involved in the design of the adaptive qunit feature (the DLD
pre-dates my involvement with Sun/CFS), but here is how it basically works:
* if remaining quota space < 4 * #osts * current_qunit, the qunit size is
  divided by 2,
* if remaining quota space > 8 * #osts * current_qunit, the qunit size is
  multiplied by 2.
The initial bunit size (also the maximum value) is the default one (i.e. 128MB).
The "4" and "8" can be tuned through /proc and there is a minimum value for
qunit (by default, 1MB = PTLRPC_MAX_BRW_SIZE for bunit).

Let's consider a cluster with 500 OSTs:
* the initial qunit size for a particular uid/gid is 128MB (unless the quota
  limit is too low)
* when left_quota = 256GB, bunit is shrunk to 64MB
* when left_quota = 128GB, bunit is shrunk to 32MB
* when left_quota = 64GB, bunit is shrunk to 16MB
* when left_quota = 32GB, bunit is shrunk to 8MB
* when left_quota = 16GB, bunit is shrunk to 4MB
* when left_quota = 8GB, bunit is shrunk to 2MB
* when left_quota = 4GB, bunit is shrunk to 1MB

Similarly, bunit is grown when the remaining quota space hits the same
thresholds. The dynamic qunit patch also maintains an accurate accounting of
how many threads are waiting for quota space from the master. Thus, slaves
can ask for more than one qunit at a time in a single DQACQ request.
IMO, the current algorithm/parameters are probably too aggressive and the
correct tuning has not been found yet.

> The cost of 100MB of disk space is barely more than a cent now; what are we trying
> to address with tiny qunits?

Today, a couple of customers are asking for accurate quotas. We should probably
discuss with them to understand their motivations.
From my point of view, the interesting feature is not to support small quota
limits or tiny qunits, but to have the ability to adapt qunits for each uid/gid
depending on how much free quota space remains. We can now increase qunit
significantly without hurting quotas accuracy and performance should only be
impacted when getting closer to the quota limit (that was the original goal in
the DLD). That being said, adaptive qunits can be disabled easily by setting
the mininum qunit size to the default qunit size.

> Plan for 5000 OSS servers at the minimum and 1,000,000 clients, and up to
> 100TB/sec in I/O. Calculate quota RPC traffic from that. A server cannot
> handle more than 15,000 RPC's / sec.
>
> No arguing, or opinions here, numbers please.

With static qunits:
100TB/s / default_bunit_size ~ 1,000,000 RPCs / sec
To get below the 15,000 RPCs/s, we should increase bunit to ~6.7GB.
If each OST acquires 1 qunit ahead of time w/o actually using it, we "leak"
6.7GB * 5,000 OSTs = 33.5TB.

With adaptive qunits, we can set default bunit to a larger value (e.g. 10GB)
and the mininum bunit to 100MB. This way, quotas can remain "accurate" (maximum
leak is 500GB) and performane would be impacted (more RPCs sent) only when
getting close to the quota limit.
However, the current shrink/enlarge algorithm is definitely not suitable for
such a big cluster since it decreases qunit too quickly.

> The original design I did 4 years ago limited quota calls from one OSS to the
> master to one per second.
> Qunits were made adaptive without solid reasoning or design.

IMHO, adaptive qunits is not such a bad feature, even if there is definitely
room for improvements.

Johann
