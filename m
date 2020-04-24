From: NeilBrown <neilb@suse.de>
Date: Fri, 24 Apr 2020 16:01:54 +1000
Subject: [lustre-devel] [PATCH 000/622] lustre: sync closely to 2.13.52
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <87r1wdqv59.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Feb 27 2020, James Simmons wrote:

> These patches need to be applied to the lustre-backport branch
> starting at commit a436653f641e4b3e2841f38113620535e918dd3f.

Hi James et al,
 I applied these patches on top of a43.... then added the other patches I
 had an looked for difference to my previous tree.
 I found a bunch of improvements you had made, plus some errors that
 came through your patches, plus some other problems that already
 existed...

 I've then added patches from OpenSFS master to get uptodate.
 The result is not on my github tree in the lustre/lustre branch.  It
 has 226 patches on top of the set you posted.

 git log 823691f8d49c~3..823691f8d49c

 will show you some error I fixed, in case you are interested.

NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20200424/d1f49362/attachment.sig>
