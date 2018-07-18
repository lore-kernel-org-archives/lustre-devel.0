From: John Bent <johnbent@gmail.com>
Date: Wed, 18 Jul 2018 00:54:32 -0400
Subject: [lustre-devel] MDT test in rel2.11
In-Reply-To: <BN3PR1101MB1202842CCA5F086263EB93BCCB530@BN3PR1101MB1202.namprd11.prod.outlook.com>
References: <547D95FD-0CF3-4F04-B727-D22513D1C4B9@supermicro.com>
 <BN3PR1101MB12022B362116346208D0B5F2CB530@BN3PR1101MB1202.namprd11.prod.outlook.com>
 <CAGfFL-yEhYXiRngSm2FBOBC+VLjrnTTWcYC7Frvh_6uE2RAHiw@mail.gmail.com>
 <BN3PR1101MB1202842CCA5F086263EB93BCCB530@BN3PR1101MB1202.namprd11.prod.outlook.com>
Message-ID: <CAGfFL-ycwu=SOOoG_3Tmg_GuyCqgpJeyjN_H5win=eMriSqRMw@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Thanks Patrick.  That's interesting.  However, the exact motivation why
IO500 has the 'find' command is this same intended use case; stale results
therefore actually present an interesting dilemma to IO500.  They are not
POSIX compliant but that loss of compliance shouldn't necessarily
disqualify this result...

On Wed, Jul 18, 2018 at 12:49 AM, Patrick Farrell <paf@cray.com> wrote:

> Lazy SoM is not landed yet, and it won?t be improving benchmark scores -
> it?s never ?known 100% correct?, so it can?t be used for actual POSIX ops -
> if a file size read out is used for a write offset, then you?ve got data
> corruption.
>
> So for now it?s strictly limited to tools that know about it (accessed via
> an ioctl) and can accept information that may be stale.  The intended use
> case is scanning the FS for policy application.
>
> ------------------------------
> *From:* John Bent <johnbent@gmail.com>
> *Sent:* Tuesday, July 17, 2018 10:55:24 PM
> *To:* Patrick Farrell
> *Cc:* Abe Asraoui; lustre-devel at lists.lustre.org;
> lustre-discuss at lists.lustre.org
> *Subject:* Re: [lustre-devel] MDT test in rel2.11
>
> I'm curious about how DOM improves IO500 scores.  :)
> Also LSOM but I don't know actually whether that's in 2.11 or where.
>
> On Tue, Jul 17, 2018 at 11:33 PM, Patrick Farrell <paf@cray.com> wrote:
>
>
> Abe,
>
> Any benchmarking would be highly dependent on hardware, both client and
> server.  Is there a particular comparison (say, between versions) you?re
> interested in or something you?re concerned about?
>
> - Patrick
>
> ------------------------------
> *From:* lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of
> Abe Asraoui <AbeA@supermicro.com>
> *Sent:* Tuesday, July 17, 2018 9:23:10 PM
> *To:* lustre-devel at lists.lustre.org; lustre-discuss at lists.lustre.org; Abe
> Asraoui
> *Subject:* [lustre-devel] MDT test in rel2.11
>
> Hi All,
>
>
> Has anyone done any MDT testing under the latest rel2.11 and have
> benchmark data to share?
>
>
> Thanks,
> Abe
>
>
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>
>
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180718/59074a8e/attachment-0001.html>
