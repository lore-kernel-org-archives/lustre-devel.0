From: James Simmons <jsimmons@infradead.org>
Date: Mon, 7 Jan 2019 03:11:13 +0000 (GMT)
Subject: [lustre-devel] linux lustre client progress
Message-ID: <alpine.LFD.2.21.1901070208080.26665@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


Over the last few weeks the final major bugs have been resolved for the
linux lustre client as well as a port of PFL. Once these patches are 
merged the client will be at a 2.10 LTS release level. A few minor
patches are still out standing but they need more work before being 
acceptable in the kernel tree. The remaining test failures are the
same ones seen in the latest OpenSFS tree testing.

Before we jump into 2.11 porting I'm thinking some house cleaning with
checkpatch etc and then moving lustre out of the staging tree to
prepare for its eventual merger upstream. As for 2.11 I started to
look at the what is missing and outside of the DoM feature most
things have landed to the linux client. In fact the next patch missing
in the git logs is the first DoM patch. Dynamic LNet discovery already
has been landed so we are in good shape :-)
