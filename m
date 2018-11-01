From: Charlie Olmstead <charlie@whamcloud.com>
Date: Thu, 1 Nov 2018 16:55:06 +0000
Subject: [lustre-devel] lustre-reviews - new optional ARM test session
Message-ID: <E163B855-AF62-4C92-83F2-ADD178E36DC5@ddn.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello all,

We are adding an optional test session to lustre-reviews builds for testing ARM architecture. The session will run review-ldiskfs with 2 ARM clients. It does not need to pass in order to get a +1 so there?s no reason to retest it unless you want to. This optional session will only run if the Autotest instance has the capacity to run it immediately (it will not queue up and wait for resources).

Let me know if you have any questions,

Charlie Olmstead
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20181101/b66f6b0c/attachment.html>
