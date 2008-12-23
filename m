From: Alex Zhuravlev <Alex.Zhuravlev@Sun.COM>
Date: Tue, 23 Dec 2008 16:11:18 +0300
Subject: [Lustre-devel] global epochs [an alternative proposal,
	long and dry].
In-Reply-To: <18768.56976.692985.84810@gargle.gargle.HOWL>
References: <18767.18277.958956.959956@gargle.gargle.HOWL>
	<494F7F6B.9080509@sun.com>
	<18767.35839.133024.625896@gargle.gargle.HOWL>
	<494FA7E8.7030200@sun.com>
	<18767.52005.485425.412677@gargle.gargle.HOWL>
	<494FD020.70909@sun.com> <18767.58149.550264.505562@gargle.gargle.HOWL>
	<495088CB.5070506@sun.com>
	<18768.46808.716111.644627@gargle.gargle.HOWL>
	<4950BBBD.4030405@sun.com>
	<18768.50762.865900.238376@gargle.gargle.HOWL>
	<4950CC18.1090005@sun.com>
	<18768.56976.692985.84810@gargle.gargle.HOWL>
Message-ID: <4950E376.70300@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nikita Danilov wrote:
> The question was about SC being the single point of failure. This can be
> eliminated by replicating stability messages to a few nodes.

more complexity to workaround initial problem?

> But "works" always means at least "meet requirements". There is no such
> thing as efficient (or scalable), but incorrect program. Ordinary Lustre
> recovery was implemented years ago and it is still has problems. I bet
> it looked very easy in the beginning, so it was tempting to optimize it.

then we can just proceed with synchronous IO if scalability isn't a requirement.
and BKL is much better because of simplicity.

> So let's suppose we have four servers and three operations:
> 
>      S0   S1   S2   S3
> OP0  U1   U2
> OP1       U3   U4
> OP2            U5   U6
> 
> Where `U?' means that a given operation sent an update to a given
> server, and all updates happen to be conflicting.
> 
> Suppose that transaction groups with these updates commit at the same
> time and servers are ready to send information to each other. What
> information each server sends and where?

I'll prepare a detailed description in a separate mail.

>  > yes, it's well written and proven thing. the point is different - if it's clear that
>  > in some cases it doesn't work well (see sync requirement), what the proof does?
> 
> It assures you that it _works_. Maybe sub-optimally, but it does. The
> program that is lighting fast, consumes zero memory and scales across
> the galaxy is useless if it is incorrect.

interesting point. sounds like it's absolutely impossible to prove (somehow)
another approach. having something "proved" doesn't mean we shouldn't try
another approach to avoid sub-optimal but important cases?


thanks, Alex
