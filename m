From: Nic Henke <nic@cray.com>
Date: Sun, 22 Feb 2009 11:15:45 -0600
Subject: [Lustre-devel] moving obd_fail_check to libcfs
Message-ID: <49A18841.7030200@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Would there be any objection to a patch that'd move the current
obdclass-centric obd_fail_check and friends to libcfs ? I'd like to be
able to use the same logic inside LNET and our new LND without
replicating the code.

I'm thinking it would need to be renamed to CFS_FAIL_CHECK as well.

Thoughts or suggestions?

Nic
