From: quentin.bouget at cea.fr <quentin.bouget@cea.fr>
Date: Tue, 21 Feb 2017 09:27:48 +0100
Subject: [lustre-devel]  [Maloo] using gdb in sanity-hsm
Message-ID: <59ab1ca2-dbae-cd99-950b-82a5dd26d08b@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi everyone,

I am trying to speed up tests in sanity-hsm. On some occasions I would 
like to use gdb, but it does not seem to work on the test servers. It 
appears gdb is a privileged command:

timeout: failed to run command 'gdb': Permission denied

Is this by design? Is there a chance this can change or should I find 
another way to run the tests?

Here is a link to the patch: https://review.whamcloud.com/#/c/24394/
and here is a link to Maloo's report: 
https://testing.hpdd.intel.com/test_sets/b252d2ca-f787-11e6-b118-5254006e85c2

Regards,
Quentin Bouget
