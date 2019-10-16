From: Andreas Dilger <adilger@whamcloud.com>
Date: Wed, 16 Oct 2019 15:23:20 +0000
Subject: [lustre-devel] [testing] Maloo not scheduling tests
In-Reply-To: <c7942901-13ea-6126-5a65-be2271c37f22@cea.fr>
References: <c7942901-13ea-6126-5a65-be2271c37f22@cea.fr>
Message-ID: <FA82114A-33F6-458D-8919-45AE8667EF0A@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Oct 16, 2019, at 19:21, quentin.bouget at cea.fr<mailto:quentin.bouget@cea.fr> wrote:


Hello,

It seems like Maloo is not scheduling tests for this patch<https://review.whamcloud.com/#/c/36292/> since I added some test parameters yesterday:

Test-Parameters: fortestonly testlist=sanity clientarch=ppc64


Are there problems on Maloo, or am I doing something wrong?

The "fortestonly" keyword is for patches that are not intended for landing (e.g. work-in-progress patches for early review), so only a limited number of tests are run.

Cheers, Andreas
--
Andreas Dilger
Principal Lustre Architect
Whamcloud






-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20191016/01635e5b/attachment.html>
