From: Cory Spitz <spitzcor@cray.com>
Date: Wed, 18 Jul 2018 19:41:07 +0000
Subject: [lustre-devel] MDT test in rel2.11
In-Reply-To: <BN3PR1101MB1202842CCA5F086263EB93BCCB530@BN3PR1101MB1202.namprd11.prod.outlook.com>
References: <547D95FD-0CF3-4F04-B727-D22513D1C4B9@supermicro.com>
 <BN3PR1101MB12022B362116346208D0B5F2CB530@BN3PR1101MB1202.namprd11.prod.outlook.com>
 <CAGfFL-yEhYXiRngSm2FBOBC+VLjrnTTWcYC7Frvh_6uE2RAHiw@mail.gmail.com>
 <BN3PR1101MB1202842CCA5F086263EB93BCCB530@BN3PR1101MB1202.namprd11.prod.outlook.com>
Message-ID: <D05A283A-21D5-4E36-9142-70797E94692F@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Yes, if the IO500 is representing a use case where the file size or block count must be correct, then LSoM can?t be used.  However, the IO500 can be changed by consensus and perhaps there is a reason to include a use case which fits LSoM?

If so, the IO500 could be changed to allow `lfs find` and it in-turn could be used to get LSoM info as Andreas pointed out in his comment of LU-9538: https://jira.whamcloud.com/browse/LU-9538?focusedCommentId=230392&page=com.atlassian.jira.plugin.system.issuetabpanels:comment-tabpanel#comment-230392 .

-Cory


--


From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of Patrick Farrell <paf@cray.com>
Date: Tuesday, July 17, 2018 at 11:50 PM
To: John Bent <johnbent@gmail.com>
Cc: "lustre-discuss at lists.lustre.org" <lustre-discuss@lists.lustre.org>, "lustre-devel at lists.lustre.org" <lustre-devel@lists.lustre.org>
Subject: Re: [lustre-devel] MDT test in rel2.11

Lazy SoM is not landed yet, and it won?t be improving benchmark scores - it?s never ?known 100% correct?, so it can?t be used for actual POSIX ops - if a file size read out is used for a write offset, then you?ve got data corruption.

So for now it?s strictly limited to tools that know about it (accessed via an ioctl) and can accept information that may be stale.  The intended use case is scanning the FS for policy application.
________________________________
From: John Bent <johnbent@gmail.com>
Sent: Tuesday, July 17, 2018 10:55:24 PM
To: Patrick Farrell
Cc: Abe Asraoui; lustre-devel at lists.lustre.org; lustre-discuss at lists.lustre.org
Subject: Re: [lustre-devel] MDT test in rel2.11

I'm curious about how DOM improves IO500 scores.  :)
Also LSOM but I don't know actually whether that's in 2.11 or where.

On Tue, Jul 17, 2018 at 11:33 PM, Patrick Farrell <paf at cray.com<mailto:paf@cray.com>> wrote:

Abe,

Any benchmarking would be highly dependent on hardware, both client and server.  Is there a particular comparison (say, between versions) you?re interested in or something you?re concerned about?

- Patrick
________________________________
From: lustre-devel <lustre-devel-bounces at lists.lustre.org<mailto:lustre-devel-bounces@lists.lustre.org>> on behalf of Abe Asraoui <AbeA at supermicro.com<mailto:AbeA@supermicro.com>>
Sent: Tuesday, July 17, 2018 9:23:10 PM
To: lustre-devel at lists.lustre.org<mailto:lustre-devel@lists.lustre.org>; lustre-discuss at lists.lustre.org<mailto:lustre-discuss@lists.lustre.org>; Abe Asraoui
Subject: [lustre-devel] MDT test in rel2.11

Hi All,


Has anyone done any MDT testing under the latest rel2.11 and have benchmark data to share?


Thanks,
Abe


_______________________________________________
lustre-devel mailing list
lustre-devel at lists.lustre.org<mailto:lustre-devel@lists.lustre.org>
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

_______________________________________________
lustre-devel mailing list
lustre-devel at lists.lustre.org<mailto:lustre-devel@lists.lustre.org>
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180718/123aac39/attachment-0001.html>
