From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Wed, 10 Jun 2015 17:50:55 +0000
Subject: [lustre-devel] wiretest.c
In-Reply-To: <6E6D936CCB2E3C428716BD24C5C6CDF26433AA@CFWEX01.americas.cray.com>
References: <6E6D936CCB2E3C428716BD24C5C6CDF264330C@CFWEX01.americas.cray.com>
	<299328B7-9D13-4854-BA51-2B1F3E1D9358@intel.com>,
	<6E6D936CCB2E3C428716BD24C5C6CDF26433AA@CFWEX01.americas.cray.com>
Message-ID: <BBE666A0-0C96-4682-B0AC-E41F6184C961@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I'm happy if you are removing otherwise unused constants or structures. 

Cheers, Andreas

> On Jun 10, 2015, at 08:01, Ben Evans <bevans@cray.com> wrote:
> 
> That much I assumed from context, it just strikes me as a strange way of going about it, since it just adds a second step to change a constant.  I figured code reviews would pick that stuff up pretty quickly.
> 
> Does using it as a method of identifying unused constants make sense to you?
> 
> -Ben
> 
> -----Original Message-----
> From: Dilger, Andreas [mailto:andreas.dilger at intel.com] 
> Sent: Tuesday, June 09, 2015 9:42 PM
> To: Ben Evans
> Cc: Drokin, Oleg; lustre-devel at lists.lustre.org
> Subject: Re: wiretest.c
> 
> Ben,
> The point of wiretest.c is that these values should basically never be changed. At compile time these checks should become no-ops unless they have changed, which would be a bug.
> 
> Cheers, Andreas
> 
> On Jun 9, 2015, at 13:49, Ben Evans <bevans at cray.com<mailto:bevans@cray.com>> wrote:
> 
> I'm trying to help out with the client code merging into the kernel project.  The first thing I dove into was ptlrpc, as it's a space that's been singled out as needing help.
> 
> In order to get my head around it, I'm just going through the code, and one of the first things that pops up is wiretest.c, which looks to be checking that things that have been #defined have the values that they are #defined to have, that structures are offset correctly (for a given value of 'correctly') etc.
> 
> So, I've started going through wiretest and seeing how much of the things that are defined are actually used in the code, and I find that some just aren't used at all, or at least not in other places than where they're defined, and wiretest. HSM_GHOST_COPY is a good example of it.  I can't find any usage in the mainline lustre-release code, or in the drivers/staging/lustre code.  Is this the sort of thing that should be flagged for deletion?
> 
> Secondly, if the code boils down to:
> #define SOME_VAR 10
> 
> and
> 
> LASSERT(SOME_VAR == 10);
> 
> What's the point from a design perspective other than making it mildly more difficult to change?
> 
> Thanks for any help, or insight you can give
> 
> -Ben Evans
