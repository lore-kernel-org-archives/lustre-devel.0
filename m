From: James Simmons <jsimmons@infradead.org>
Date: Wed, 22 Jun 2011 17:00:51 +0100 (BST)
Subject: [Lustre-devel] SuSE server support
Message-ID: <alpine.LFD.2.00.1106221653050.5547@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


Hello.

	I just finsihed up the SuSE code port of ldiskfs for Lustre 2.1.
The link is http://jira.whamcloud.com/browse/LU-335 and the git branch is
http://review.whamcloud.com/#change,575. Currently two SuSE versions are 
supported.

SuSE SP0 - 2.6.27.48-0.12.1
SuSE SP1 - 2.6.32.12-0.7
 
SP0 is at the end line but at my work we still will need to support it. As 
for SP1 that is a moving target. In order for SP1 support to work at all 
parties involved must agree on a single kernel version to work with, which 
is one of the reasons I posted this message. The second reason is to have
people test this code out. Please don't use it in a production 
environment :-) It could eat your data!! Thank  you.
 
