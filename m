From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Mon, 21 Sep 2015 09:41:23 +0000
Subject: [lustre-devel] adding IOCTL for ping
In-Reply-To: <D21DABBC.C8F%jevans@cray.com>
References: <D21DABBC.C8F%jevans@cray.com>
Message-ID: <F29A015B-AF57-4564-8B69-A8DC05292784@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Maybe I'm missing something here, but why not disable pinging altogether at this point and depend on the external health network? That is already possible today via https://jira.hpdd.intel.com/browse/LU-2467.

Cheers, Andreas

On Sep 15, 2015, at 17:05, Ben Evans <bevans at cray.com<mailto:bevans@cray.com>> wrote:

Would there be any interest in adding an IOCTL to update the ping time/status for a particular NID?

This should allow for implementation of a pinger in userspace which updates the kernel on the status of various NIDs, and if I understand the ping code well enough, would greatly curtail any pings that is sent by the kernel.

This might allow for things like Eric?s gossip implementation to simply bolt on top of Lustre without any internal kernel changes, or for integration of external monitoring systems to tell Lustre that failovers have occurred, etc.

-Ben Evans
_______________________________________________
lustre-devel mailing list
lustre-devel at lists.lustre.org<mailto:lustre-devel@lists.lustre.org>
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
