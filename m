From: Christopher J. Morrone <morrone2@llnl.gov>
Date: Wed, 03 Jun 2015 14:24:08 -0700
Subject: [lustre-devel] OpenID 2.0 and Gerrit 2.11
In-Reply-To: <1637F3AC-75FF-4EEC-8777-4FBF9FCDB60B@intel.com>
References: <CAPALmn=6cNyRPhCQe_4A+hqJueP0yKh4vP13JE3KiucCk3SE4w@mail.gmail.com>
	<556F5BA7.1020301@llnl.gov>
	<CAPALmnmXbE_VLSvrUBA-NgLz1XDsr3Lz2m886KVNU8KYvwgbgg@mail.gmail.com>
	<1637F3AC-75FF-4EEC-8777-4FBF9FCDB60B@intel.com>
Message-ID: <556F7078.1020407@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Is it perhaps that gerrit doesn't entirely support it natively, but 
there is an external gerrit plugin (gerrit-oauth-provier) that makes it 
work with gerrit 2.10.3.1 or 2.11?  Their documentation is none too clear.

Chris

On 06/03/2015 01:14 PM, Read, Robert wrote:
> Right, we need OAuth2, which is what Google calls Google OpenID Connect. It looks this has been addressed as of Gerrit 2.10.2.
>
> https://code.google.com/p/gerrit/issues/detail?id=2677
>
>
> robert
>
>
> On Jun 3, 2015, at 13:03 , Colin Faber <colin.faber at seagate.com<mailto:colin.faber@seagate.com>> wrote:
>
> Hi Chris,
>
>>From what I can tell, the OAuth2 and OpenID 2.0 combo does work for google account authentication against gerrit:
>
> http://gerrit.cloudlinux.com:8080/login/%23%2Fq%2Fstatus%3Aopen
>
>
> -cf
>
>
>
> On Wed, Jun 3, 2015 at 1:55 PM, Christopher J. Morrone <morrone2 at llnl.gov<mailto:morrone2@llnl.gov>> wrote:
> I think you might have that backwards.  Google has _stopped_ supporting OpenID 2.0.  To the best of my knowledge no version of gerrit yet supports Google's new OpenID Connect system.
>
> Chris
>
>
> On 06/03/2015 12:52 PM, Colin Faber wrote:
> Hi,
>
> This is probably more a question for the folks at Intel.. Is there an
> ETA or plan in place to upgrade to Gerrit 2.11 and OpenID 2.0? Such
> changes would allow for google logins to function correctly.
>
> -cf
>
>
>
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org<mailto:lustre-devel@lists.lustre.org>
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>
>
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org<mailto:lustre-devel@lists.lustre.org>
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org<mailto:lustre-devel@lists.lustre.org>
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>
>
