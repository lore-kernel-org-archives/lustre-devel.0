From: Ricardo M. Correia <Ricardo.M.Correia@Sun.COM>
Date: Wed, 25 Jun 2008 22:01:40 +0100
Subject: [Lustre-devel] Changes in b_hd_dmu and zfs-lustre
Message-ID: <1214427700.6751.45.camel@localhost>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi,

If you are using or developing in the b_hd_dmu branch and/or zfs-lustre,
please be aware of the following points to avoid problems due to the
recent changes related to bug 14778:

* If you have any zfs-lustre tools installed in your machine, please run
"scons -c install" or manually remove
the /usr/local/sbin/{lzfs,lzfsd,lztest,lzdb,lzpool} files before
updating your tree.
The new tools will be installed in /usr/sbin by default (similarly to
lustre).

* If you have any local patches against zfs-lustre, you will need to
update them to use the new library paths.
You can do that with the following 2 commands:


$ sed -i "s/\/src\/lib\/lib/\/src\/lib\//" <patch>
$ sed -i "s/\/src\/lib\/dmu-ctl\//\/src\/lib\/ctl\//" <patch>


* The build procedure has been simplified, SCons is no longer required
to be installed.
As always, please refer to
http://wiki.lustre.org/index.php?title=Lustre_OSS/MDS_with_ZFS_DMU for
instructions.
Note that the "--with-dmu" configure option no longer exists, you will
need to use the zfs-lustre tree that lustrecvs sets up in
lustre/zfs-lustre.

Please let me know if you have any problems.

Best regards,
Ricardo

--

Ricardo Manuel Correia
Lustre Engineering

Sun Microsystems, Inc.
Portugal
Phone +351.214134023 / x58723
Mobile +351.912590825
Email Ricardo.M.Correia at Sun.COM
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080625/ad40cb97/attachment.htm>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: 6g_top.gif
Type: image/gif
Size: 1257 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080625/ad40cb97/attachment.gif>
