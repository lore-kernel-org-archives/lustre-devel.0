From: Colin Faber <colin.faber@seagate.com>
Date: Wed, 3 Jun 2015 14:32:53 -0600
Subject: [lustre-devel] OpenID 2.0 and Gerrit 2.11
In-Reply-To: <1637F3AC-75FF-4EEC-8777-4FBF9FCDB60B@intel.com>
References: <CAPALmn=6cNyRPhCQe_4A+hqJueP0yKh4vP13JE3KiucCk3SE4w@mail.gmail.com>
	<556F5BA7.1020301@llnl.gov>
	<CAPALmnmXbE_VLSvrUBA-NgLz1XDsr3Lz2m886KVNU8KYvwgbgg@mail.gmail.com>
	<1637F3AC-75FF-4EEC-8777-4FBF9FCDB60B@intel.com>
Message-ID: <CAPALmnkGyQ6Fas6qG-ivSGASCaxhAChT2hnPJx2L39hJnffB=A@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

So I guess coming back around to the original question, any ETA or idea
when / if this will be available?

=)

-cf


On Wed, Jun 3, 2015 at 2:14 PM, Read, Robert <robert.read@intel.com> wrote:

> Right, we need OAuth2, which is what Google calls Google OpenID Connect.
> It looks this has been addressed as of Gerrit 2.10.2.
>
> https://code.google.com/p/gerrit/issues/detail?id=2677
>
>
> robert
>
>
> On Jun 3, 2015, at 13:03 , Colin Faber <colin.faber@seagate.com<mailto:
> colin.faber at seagate.com>> wrote:
>
> Hi Chris,
>
> From what I can tell, the OAuth2 and OpenID 2.0 combo does work for google
> account authentication against gerrit:
>
>
> https://urldefense.proofpoint.com/v2/url?u=http-3A__gerrit.cloudlinux.com-3A8080_login_-2523-252Fq-252Fstatus-253Aopen&d=AwIFAg&c=IGDlg0lD0b-nebmJJ0Kp8A&r=x9pM59OqndbWw-lPPdr8w1Vud29EZigcxcNkz0uw5oQ&m=2TZ9J8tYpzP7LWdaW6rjmipw1eWHcfszrDgaL-Ok6dc&s=uIy4ooW8SY3s2WtLNxy4Av8Yu3YE6wUY9sCn7DDnEws&e=
>
>
> -cf
>
>
>
> On Wed, Jun 3, 2015 at 1:55 PM, Christopher J. Morrone <morrone2@llnl.gov
> <mailto:morrone2@llnl.gov>> wrote:
> I think you might have that backwards.  Google has _stopped_ supporting
> OpenID 2.0.  To the best of my knowledge no version of gerrit yet supports
> Google's new OpenID Connect system.
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
>
> https://urldefense.proofpoint.com/v2/url?u=http-3A__lists.lustre.org_listinfo.cgi_lustre-2Ddevel-2Dlustre.org&d=AwIFAg&c=IGDlg0lD0b-nebmJJ0Kp8A&r=x9pM59OqndbWw-lPPdr8w1Vud29EZigcxcNkz0uw5oQ&m=2TZ9J8tYpzP7LWdaW6rjmipw1eWHcfszrDgaL-Ok6dc&s=7ye70YNBCUYjesG3rFEiQo5M7y5yr4F6s_KuY1Ngaco&e=
>
>
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org<mailto:lustre-devel@lists.lustre.org>
>
> https://urldefense.proofpoint.com/v2/url?u=http-3A__lists.lustre.org_listinfo.cgi_lustre-2Ddevel-2Dlustre.org&d=AwIFAg&c=IGDlg0lD0b-nebmJJ0Kp8A&r=x9pM59OqndbWw-lPPdr8w1Vud29EZigcxcNkz0uw5oQ&m=2TZ9J8tYpzP7LWdaW6rjmipw1eWHcfszrDgaL-Ok6dc&s=7ye70YNBCUYjesG3rFEiQo5M7y5yr4F6s_KuY1Ngaco&e=
>
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org<mailto:lustre-devel@lists.lustre.org>
>
> https://urldefense.proofpoint.com/v2/url?u=http-3A__lists.lustre.org_listinfo.cgi_lustre-2Ddevel-2Dlustre.org&d=AwIFAg&c=IGDlg0lD0b-nebmJJ0Kp8A&r=x9pM59OqndbWw-lPPdr8w1Vud29EZigcxcNkz0uw5oQ&m=2TZ9J8tYpzP7LWdaW6rjmipw1eWHcfszrDgaL-Ok6dc&s=7ye70YNBCUYjesG3rFEiQo5M7y5yr4F6s_KuY1Ngaco&e=
>
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20150603/5408f298/attachment.htm>
