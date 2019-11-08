From: Peter Jones <pjones@whamcloud.com>
Date: Fri, 8 Nov 2019 23:21:59 +0000
Subject: [lustre-devel] New tag and branch split
Message-ID: <D41466BC-F528-47BF-A101-413969363B03@ddn.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Alex

The release numbering convention is that for build numbers x.y.z that the numbers 50 to 99 are reserved for development builds for the release y+1. So, it is orthogonal to the 2.12.x LTS releases, which are based on the b2_12 branch, not the master branch

Peter

From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of Alexander I Kulyavtsev <aik@fnal.gov>
Date: Friday, November 8, 2019 at 2:36 PM
To: Oleg Drokin <green@whamcloud.com>, Lustre Development List <lustre-devel@lists.lustre.org>
Subject: Re: [lustre-devel] New tag and branch split

What does  2.12.90 tag mean on  branch 2.12 ?

Last release on LTS branch 2.12 ?
Or am I reading in it too much ?

Alex.

________________________________
From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of Oleg Drokin <odrokin@ddn.com>
Sent: Friday, November 8, 2019 11:51 AM
To: Lustre Development List <lustre-devel@lists.lustre.org>
Subject: [lustre-devel] New tag and branch split

Hello!

  I just split off b2_13 branch from master for final touches of 2.13 release and so we can continue landing other patches (of which there?s now quite a backlog)
  b2_13 in in codefreeze and will be tagged RC soon.

  Here?s the changelog:

... cut ...

Oleg Drokin (4):
... cut ...
      New tag 2.12.90

_______________________________________________
lustre-devel mailing list
lustre-devel at lists.lustre.org
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20191108/4f5f89dc/attachment.html>
