From: kelly.zhang at emc.com <kelly.zhang@emc.com>
Date: Wed, 15 Feb 2012 20:28:41 -0500
Subject: [Lustre-devel] Some questions about Lustre testing
Message-ID: <F62E2618FCA29E42AB21F281C9511BB413745D3428@MX26A.corp.emc.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi,

I have some part uncertain about Lustre testing, would somebody please  help to answer, thank you very much!

1. Before checkins, the tests which must complete successfully are the ones listed in "acceptance-small.sh", right? Like the
following:
DEFAULT_SUITES="runtests sanity sanity-benchmark sanityn lfsck liblustre ..."

2. When testing 2.x Lustre, is acceptance-small.sh or auster used? And what is the main difference between them?
Is there a wiki page introducing auster?
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20120215/811c5d8e/attachment.htm>
