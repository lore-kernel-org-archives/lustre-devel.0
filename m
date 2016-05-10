From: Hammond, John <john.hammond@intel.com>
Date: Tue, 10 May 2016 16:50:01 +0000
Subject: [lustre-devel] sanity-hsm failures on master
Message-ID: <C6D48C5819337145905EDC9DB164E6971F4CCFCE@fmsmsx120.amr.corp.intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

All,

A recent switch from CentOS 6.7 to CentOS 7 for the lustre-reviews test nodes has broken a subtest of sanity-hsm. Everything pushed against any recent revision of master is likely to fail until the fix http://review.whamcloud.com/20093 has landed. Please see LU-6937 for details.

So if you have something to push you might wait until 20093 has landed or base your change on 20093.

Sorry for the inconvenience.

Best,

John
