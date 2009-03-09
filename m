From: Yong Fan <Yong.Fan@Sun.COM>
Date: Tue, 10 Mar 2009 00:34:02 +0800
Subject: [Lustre-devel] statahead_performance.pdf - Adobe Reader
In-Reply-To: <070201c9a0c4$d6fe8b50$84fba1f0$@com>
References: <070201c9a0c4$d6fe8b50$84fba1f0$@com>
Message-ID: <49B544FA.9020009@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Eric Barton ??:
> Fan Yong,
>
> The attached PDF shows the results you gathered in a form
> that makes it easier to understand the results and helps
> comparison.  Please could you review it for correctness.
>
>   
Yes, it is much help to understand the performance improvement
by statahead with the chart.

But I think the first chart for "Statahead Dirents/second" maybe
some misguide, since the TCP result and IB result are from different
hardware environment (I mean the CPU and memory), that the speed
of stating under IB is faster than TCP case is meaningless.

Relatively, the second chart for "Statahead Speedup" is more useful,
which is relatively independent from hardware (CPU and memory).
It gives the trend of upper bound on performance improvement from
statahead under different network configure, and different dir/file ratio.


Thanks!
--
Fan Yong
>     Cheers,
>               Eric
>
>   
