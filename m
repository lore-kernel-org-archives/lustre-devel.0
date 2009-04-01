From: di wang <di.wang@sun.com>
Date: Tue, 31 Mar 2009 23:35:24 -0400
Subject: [Lustre-devel] Oleg/Mike Work on Apps Metrics - FW: Mike	Booth
 week ending 2009.03.15
In-Reply-To: <20090331185111.GL3199@webber.adilger.int>
References: <D691F7E6-6030-4EB9-896C-77201445D865@Sun.COM>
	<C5E2A328.36EE0%Daniel.Ferber@Sun.Com>
	<015c01c9a5a7$cb2f83a0$618e8ae0$@com>
	<52E982EB-3ADE-46FA-A7BC-D1645961DF0B@Sun.COM>
	<018101c9a5b6$25dbc300$71934900$@com>
	<48A6CF99-F630-4581-9FFC-05E3AFF66FA0@Sun.COM>
	<023201c9a636$a987e4b0$fc97ae10$@com>
	<5CE22E46-771C-47EE-9CAC-26A37C87C466@sun.com>
	<20090331185111.GL3199@webber.adilger.int>
Message-ID: <49D2E0FC.4040605@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello,
Andreas Dilger wrote:
> If each compute timestep takes 0.1s during IO vs 0.01s without IO and
> you would get 990 timesteps during the write flush in the second case
> until the cache was cleared, vs. none in the first case.  I suspect
> that the overhead of the MPI communication on the Lustre IO is small,
> since the IO will be limited by the OST network and disk bandwidth,
> which is generally a small fraction of the cross-sectional bandwidth.
>
> This could be tested fairly easily with a real application that is
> doing computation between IO, instead of a benchmark that is only doing
> IO or only sleeping between IO, simply by increasing the per-OSC write
> cache limit from 32MB to e.g. 1GB in the above case (or 2GB to avoid the
> case where 2 processes on the same node are writing to the same OST).
> Then, measure the time taken for the application to do, say, 1M timesteps
> and 100 checkpoints with the 32MB and the 2GB write cache sizes.
>
>   
Can we implement aio here? for  example  the  aio buffer can be treated  
different as other dirty buffer, not
being pushed aggressively to server. It seems with buffer_write, the 
user have to deal with fs buffer cache
issue in his application, not sure it is good for them, and we may not 
even output these features to the
application.

Thanks
WangDi
