From: Joshua Walgenbach <jjw@iu.edu>
Date: Thu, 15 Mar 2012 15:51:45 -0400
Subject: [Lustre-devel] [Twg] Lustre and cross-platform portability
In-Reply-To: <C481511A-14DB-4032-9071-82AF5974E263@whamcloud.com>
References: <201203151845.q2FIjcXV029439@hedwig.cmf.nrl.navy.mil>
	<C481511A-14DB-4032-9071-82AF5974E263@whamcloud.com>
Message-ID: <4F624851.6030707@iu.edu>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1



On 03/15/2012 03:39 PM, Andreas Dilger wrote:

> Another alternative that has been proposed is FUSE for
> MacOS/Solaris. I'm not sure if FUSE exists for Windows or not.  Of
> course, this is only useful for casual access, and not for high
> performance usage.
> 

I think the FUSE for Windows project is defunct, but there is a user
space filesystem project for Windows called Dokan
(http://dokan-dev.net/en/) that had a release a little more than a
year ago.

For my part, a Lustre client on Windows or OS X would be used mostly
for visualization of data, rather than being computed against so a
slower user space implementation would be more than sufficient. There
are a few applications that are using an SMB exported Lustre
filesystem for data collection, but those applications are similarly
low bandwidth. It would be nice to remove the SMB server in the middle.

- -Josh

- --
Joshua Walgenbach, High Performance File Systems, Indiana University
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk9iSFEACgkQcqyJPuRTYp8dRgCePbaKA2P1Km80KBJM/YG6Nky1
8pgAn3RQW1i5omkhJfFZOG+0yhtXKJFB
=08vB
-----END PGP SIGNATURE-----
