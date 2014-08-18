From: Pratik Rupala <pratik.rupala@calsoftinc.com>
Date: Mon, 18 Aug 2014 17:19:07 +0530
Subject: [Lustre-devel] Question regarding lustre patches
Message-ID: <53F1E833.1040100@calsoftinc.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi,

In the older version of lustre, I can see a patch named 
"*raid5-merge-ios-rhel5.patch*" which is related to RAID performance 
improvement for RHEL5.

As per my understanding, it accumulates the bios in a single 
make_request function of RAID layer and sends them collectively by 
generic_make_request instead of sending them separately per stripe basis.
By this means, performance of RAID could be improved.

But this patch is not present in newer version of lustre and especially 
for RHEL6.

So, is it possible to port that patch for RHEL 6, provided RAID 
architecture is changed significantly and handling of stripe has been 
made asynchronous in RHEL 6 as compared to synchronous handling of 
stripe in RHEL 5?
And even if it can be ported for RHEL6, will it give advantage as it was 
giving in RHEL 5 with different RAID architecture?


Regards,
Pratik
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20140818/bb7ae0b3/attachment.htm>
