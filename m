From: Nicholas Henke <nic@cray.com>
Date: Mon, 09 Mar 2009 15:26:25 -0500
Subject: [Lustre-devel] moving obd_fail_check to libcfs
In-Reply-To: <49A18841.7030200@cray.com>
References: <49A18841.7030200@cray.com>
Message-ID: <49B57B71.2060603@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nic Henke wrote:
> Would there be any objection to a patch that'd move the current
> obdclass-centric obd_fail_check and friends to libcfs ? I'd like to be
> able to use the same logic inside LNET and our new LND without
> replicating the code.
> 
> I'm thinking it would need to be renamed to CFS_FAIL_CHECK as well.
> 
> Thoughts or suggestions?
> 
> Nic

For those of you playing the at-home game, bug 18750 is filed for this.

Nic
