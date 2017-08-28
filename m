From: Ben Evans <bevans@cray.com>
Date: Mon, 28 Aug 2017 19:52:41 +0000
Subject: [lustre-devel] CONFIG_PROC_FS
Message-ID: <D5C9ECC8.DCEE%jevans@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I see that this flag is set for all kernels, and from what I can tell, will always be on.  Is there a reason that anyone knows of to keep it and the related #ifdef's?

I'm guessing that this is a holdover from the days were non-linux builds were still being considered.

-Ben

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20170828/4e52c58b/attachment.htm>
