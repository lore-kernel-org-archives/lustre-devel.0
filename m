From: Patrick Farrell <paf@cray.com>
Date: Mon, 28 Aug 2017 20:02:56 +0000
Subject: [lustre-devel] CONFIG_PROC_FS
In-Reply-To: <D5C9ECC8.DCEE%jevans@cray.com>
References: <D5C9ECC8.DCEE%jevans@cray.com>
Message-ID: <MWHPR1101MB2143C0814385AEB1C90C8A6FCB9E0@MWHPR1101MB2143.namprd11.prod.outlook.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

No, this is a kernel config thing (check a kernel source tree), not defined by Lustre - You can build Linux without /proc.  I imagine that's for the tiny kernel people.


- Patrick

________________________________
From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of Ben Evans <bevans@cray.com>
Sent: Monday, August 28, 2017 2:52:41 PM
To: lustre-devel at lists.lustre.org
Subject: [lustre-devel] CONFIG_PROC_FS

I see that this flag is set for all kernels, and from what I can tell, will always be on.  Is there a reason that anyone knows of to keep it and the related #ifdef's?

I'm guessing that this is a holdover from the days were non-linux builds were still being considered.

-Ben

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20170828/dad2752c/attachment.htm>
