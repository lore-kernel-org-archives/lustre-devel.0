From: Ben Evans <bevans@cray.com>
Date: Tue, 15 Sep 2015 15:04:29 +0000
Subject: [lustre-devel] adding IOCTL for ping
Message-ID: <D21DABBC.C8F%jevans@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Would there be any interest in adding an IOCTL to update the ping time/status for a particular NID?

This should allow for implementation of a pinger in userspace which updates the kernel on the status of various NIDs, and if I understand the ping code well enough, would greatly curtail any pings that is sent by the kernel.

This might allow for things like Eric?s gossip implementation to simply bolt on top of Lustre without any internal kernel changes, or for integration of external monitoring systems to tell Lustre that failovers have occurred, etc.

-Ben Evans
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20150915/cc9d8a86/attachment.htm>
