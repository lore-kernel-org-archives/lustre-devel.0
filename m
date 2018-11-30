From: James Simmons <jsimmons@infradead.org>
Date: Fri, 30 Nov 2018 02:59:51 +0000 (GMT)
Subject: [lustre-devel] reviving whamcloud linux lustre client
Message-ID: <alpine.LFD.2.21.1811300245590.16646@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


Hello :-)

    With the linux lustre client getting into shape its time to revive
the whamcloud linux tree for testing. Currently 

ssh://user at review.whamcloud.com:29418/fs/linux-staging

points to an outdated staging tree hosted by Greg. Can you migrate
the tree hosting to the following:

https://github.com/neilbrown/linux
    branches:
	remotes/origin/lustre/lustre
        remotes/origin/lustre/lustre-testing
        remotes/origin/lustre/lustre-wip

Can you use the current lustre 2.10 LTS test suite for testing and enabled
all the test!!!
