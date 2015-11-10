From: Simmons, James A. <simmonsja@ornl.gov>
Date: Tue, 10 Nov 2015 00:50:04 +0000
Subject: [lustre-devel] AnonHugePages Virtual Memory Commit bug
In-Reply-To: <CAD-PXqLoZ1Lsn07N6Q548s8hVQX5f7o=EnBa=LcB1Seb7Km_Zg@mail.gmail.com>
References: <CAD-PXqLoZ1Lsn07N6Q548s8hVQX5f7o=EnBa=LcB1Seb7Km_Zg@mail.gmail.com>
Message-ID: <f07110b6881d4c7a8d3e861b6b41fbcb@EXCHCS32.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>Dear All,
>
>Sorry to intervene and being rude and send this message directly to you folks. I have made several attempts to reach to linux-kernel at vger.kernel.org<mailto:linux-kernel@vger.kernel.org> and my attempts have failed miserably and I have not be able make any >progress on this issue I have had for months now.
>
>With all humbleness I request your help so that I can get assistance with this issue of mine. Please guide me. I get hundreds-thousands of emails from vger.kernel.org<http://vger.kernel.org>, not a problem, but I cannot post my >question to the email above. Any help will be like God's grace for me now.
>
>My ISSUE:
>
>
>I feel this is a bug. I am at kernel: 2.6.32-431.17.1.el6.x86_64
>
>I have run into this many a times and only reboot has been the fix.
>
>Issue is on every idle(not running any user processes) machine(diskless node, & no swap) I see AnonHugePages limits the amount of memory that can be allocated to any new process/program on that that system.
>
>When ever I see this happen, atop always show vmcom > vmlim, i a situation where there is no swap disk I am thinking this is causing the system to lock up that memory from use by any other process on that system.

Since you are new from my reading it looks like you are using the OpenSFS branch of Lustre. In that case please don?t  post to the staging driver mailing list or the kernel mailing list. Which version are you using for your clients and servers and what distro?
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20151110/bacce5ae/attachment.htm>
