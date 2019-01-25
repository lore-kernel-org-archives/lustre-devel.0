From: Degremont, Aurelien <degremoa@amazon.com>
Date: Fri, 25 Jan 2019 13:26:57 +0000
Subject: [lustre-devel] LibCFS and LNET module versions
Message-ID: <41616FC6-B2B4-4B72-B7D6-69D1B5713653@amazon.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello,

All Lustre modules uses the Lustre version as their module version except for lnet and libcfs modules. Is there a specific reason to that?

These version are hardcoded and never change. Tools like dkms could think some libcfs modules are the same because the version is the same but actually it changed a lot.
Until we decide to properly manage a real version for these modules, could it be possible to also use Lustre version for them?


Aur?lien
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190125/b9c02d7a/attachment.html>
