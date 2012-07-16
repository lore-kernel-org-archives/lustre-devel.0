From: Roman Grigoryev <Roman_Grigoryev@xyratex.com>
Date: Mon, 16 Jul 2012 11:31:32 -0700
Subject: [Lustre-devel] [cdwg] broader Lustre testing
In-Reply-To: <4FFF3A44.30106@llnl.gov>
References: <A58D7719023A5D47A6D3BEAF8C0BE67509EA751B@CFWEX01.americas.cray.com>
	<97EB7132-D1FA-4BFF-9EDC-9AEA4D1807E7@xyratex.com>
	<4FFF3A44.30106@llnl.gov>
Message-ID: <FFB285B9CC9ECE4B9EE7CA48EEB45E8D084F42@XYUS-EX21.xyus.xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Christopher,

.....
>
> The automated regression suite that we use is great.  We should continue
> to improve that over time.  But I would content that it is not, and
> never will be, sufficient to tells us if Lustre is stable.
>
> I would argue that the regressions tests are, in fact, a very low bar.
> And Lustre is just too complicated, networks are too complicated, we
> have too few developers, to ever come up with an automated suite with
> any thing but a relatively low confidence level in the stability of the
> software.
>
> And human testers are given a very different set of goals then
> developers.  A developer's job is to make things work.  A tester's is to
> do whatever they can to break it.  And then create a good report of how
> they broke it so the developers can fix it.
>
.............

Just for proving your statement that it is not enough just execute
automated regression suite (acc-small) for testing quality I would like to
share coverage summary which we got:

958 tests was executed
                     Hit	Total	Coverage
Lines:	        79691	128935	61.8 %
Functions:	6206	7935	78.2 %
Branches:	49287	113914	43.3 %

Thanks,
	Roman
