From: kelly.zhang at emc.com <kelly.zhang@emc.com>
Date: Thu, 31 May 2012 06:17:10 -0400
Subject: [Lustre-devel] Lustre sanity test_226 fails
Message-ID: <F62E2618FCA29E42AB21F281C9511BB4137DACAF52@MX26A.corp.emc.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi all,

When running sanity.sh, sometimes test_226 would fail with the following error:

lfs fid2path /mnt/lustre [0x200000404:0x1a:0x0]

ioctl err -22: Invalid argument (22)

fid2path error: Invalid argument

We tried Whamcloud master (6b1daa840a66703446c238d1efb3f13dd93012ee), and get the same error.
Run test_226 twice, it is likely to meet one failure.

I did not find such error in Maloo, so would you please help to check this? Thanks a lot.

Best Regards,
Kelly(EMC)

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20120531/3d674c17/attachment.htm>
