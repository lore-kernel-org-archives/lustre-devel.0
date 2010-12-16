From: Christopher J. Morrone <morrone2@llnl.gov>
Date: Thu, 16 Dec 2010 10:53:24 -0800
Subject: [Lustre-devel] Cannot easily build from master source anymore
In-Reply-To: <4D09F5C3.5060401@cea.fr>
References: <4CF6209A.6020401@cea.fr>	<alpine.LFD.2.00.1012011944370.22096@casper.infradead.org>	<DA432BB3-C1EC-433B-8936-923B98D7C446@oracle.com>	<4CF7ABC2.3000400@cea.fr>	<1292345822.4080.46.camel@brian-laptop>
	<4D09F5C3.5060401@cea.fr>
Message-ID: <4D0A6024.7030403@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 12/16/2010 03:19 AM, Aurelien Degremont wrote:
> Brian J. Murrell a ?crit :
>> Is this in fact the problem you run into?  You didn't actually say what
>> the problem you had was in your original posting, just that there was a
>> problem.  It's usually a good idea to at least print the error message
>> when you are reporting a failure.
>
> Indeed it was my issue.
> But I've realized that I cannot reproduce the issue anymore.
>
> 'git bisect' told me that it was this commit which fix the issue:
>
> commit e1a8487277a83449fa2c92ba363162b692c3ebef
> Author: Terry Rutledge<terry.rutledge@oracle.com>
> Date:   Fri Dec 3 21:19:03 2010 -0800
>
>       Needed to create a new tag for 2.1.0 build 09.  For some reason the
>       previous tag was not being propagated out, so v2_0_58_0 is being
>       created for this build.
>
> (configure now say : "buildid: none... congratulations, you must be on a tag"
>
> So this is ok for me, but i'm surprised that nobody from oracle hit this issue in-between.

I believe the reason it starts working at that commit is the annotated 
tag that points to it.  Previous to that tag, Oracle was using simple 
lightweight tags (which is git tag's default option).  With older 
versions of git, "git describe" only stopped at annotated tags, not 
lightweight tags.

So Oracle folks are probably just using newer versions of git than you.

Chris
