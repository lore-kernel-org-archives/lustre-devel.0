From: NeilBrown <neilb@suse.de>
Date: Fri, 03 Jul 2020 16:37:17 +1000
Subject: [lustre-devel] [PATCH 00/45] lustre: merged OpenSFS client
 patches from April 30 to today
In-Reply-To: <87k0zx1dzs.fsf@notabene.neil.brown.name>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
 <87sgfj6ypq.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.2006012345440.1967@casper.infradead.org>
 <87pn9q1kxf.fsf@notabene.neil.brown.name>
 <B7168794-A621-413E-9DFA-AF1C02354F76@amazon.com>
 <87k0zx1dzs.fsf@notabene.neil.brown.name>
Message-ID: <87tuyp14v6.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Jun 24 2020, NeilBrown wrote:
>>
>> By the way, where's your tree available Neil? I'm checking your github account but not sure this is there.
>>
>
> In the "linux" repo I have quite a few branches.
>  "lustre/lustre" is the latest lustre code (as of late april).
>
> https://github.com/neilbrown/linux/tree/lustre/lustre

Just FYI, I've updated this to Linux 5.7 and *almost* current master.
There is one patch which causes all my testing to fail, so I've
postponed that one until I understand the problem.

NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20200703/5d6bb3ec/attachment.sig>
