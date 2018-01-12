From: Olmstead, Charlie <charlie.olmstead@intel.com>
Date: Fri, 12 Jan 2018 17:31:33 +0000
Subject: [lustre-devel] Optional test session for lustre-reviews
Message-ID: <D67E3F04.B0604%charlie.olmstead@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello all,

We are adding an optional test session to lustre-reviews builds called dne-zfs-part-1. This optional session will only run if the Autotest instance has the capacity to run it immediately (it will not queue up and wait for resources). It runs the same test suites as dne-part-1 but has a ZFS filesystem. Its outcome does not impact the +/-1 sent by Maloo.
The ultimate goal is to replace all DNE sessions with dne-zfs sessions.

Let me know if you have any questions,

Charlie Olmstead

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180112/71615a6b/attachment.html>
