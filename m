Return-Path: <SRS0=0Ngw=FP=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5AD25C433FE
	for <lustre-devel@archiver.kernel.org>; Fri, 11 Dec 2020 04:04:36 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id ED05F23ED0
	for <lustre-devel@archiver.kernel.org>; Fri, 11 Dec 2020 04:04:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ED05F23ED0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 5BB2821F72A;
	Thu, 10 Dec 2020 20:04:35 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de [195.135.220.15])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B28F621F64E
 for <lustre-devel@lists.lustre.org>; Thu, 10 Dec 2020 20:04:33 -0800 (PST)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.221.27])
 by mx2.suse.de (Postfix) with ESMTP id 47C92AB91;
 Fri, 11 Dec 2020 04:04:32 +0000 (UTC)
From: NeilBrown <neilb@suse.de>
To: Lustre Development List <lustre-devel@lists.lustre.org>
Date: Fri, 11 Dec 2020 15:04:23 +1100
Message-ID: <87o8j1j8e0.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Subject: [lustre-devel] An alternate approach to preparing lustre for
 upstream submission
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Content-Type: multipart/mixed; boundary="===============7537849023780759856=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============7537849023780759856==
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"

--=-=-=
Content-Type: text/plain


Hi,
 I've been exploring an alternate approach to preparing lustre code for
 upstream submission.

 As you probably know, the approach we have been following is based on
 the code that was removed from 'drivers/staging' a couple of years ago.
 I reverted that removal patch and have ported all the relevant patches
 from lustre "master" across to that tree, as well as other cleanups and
 fixes.

 A problem with this approach is that I find that I don't trust it.
 I've found multiple examples of patches being ported across
 incorrectly, of patches being missed, and of bugs introduced while the
 code was in drivers/staging.
 I've found and fixed a lot of issues.  I doubt that I've found them
 all.
 While I do some testing of this code, as does James, it is minimal
 compared to the testing done on lustre/master.  And as we should all
 remember: untested code is buggy code.

 People who use lustre don't only want correctness and performance, they
 want confidence, and I'm not confident of this code.

 My alternate approach is to use the code straight out of lustre/master,
 transformed to match upstream requirements by a relatively simple
 script.  There is clearly still room for the script to introduce
 problems, but it is much less likely and any problems introduced are
 less likely to go unnoticed.

 I have written such a script, based largely on sed, unifdef, and spatch
 (the latter from the coccinelle project).

 Not all changes that I want can be achieved with these tools so I also
 have a collection of patches to lustre which hopefully will be
 submitted in due course.  Many are the same sorts of cleanups that I've
 been submitting for a while.  Others are a bit different.  For example
 I add a lot more "#ifdef HAVE_SERVER_SUPPORT" preprocessor directives
 so that "unifdef" can strip out more server-only code.  I've also added
 some "#ifndef UPSTREAM_LINUX" directives to remove code that cannot go
 upstream, like the code for extracting a jobid from the environment.

 You can see my current lustre tree at
   https://github.com/neilbrown/lustre/tree/lustre-next
 This contains 119 patches on top of master, some of which have already
 been submitted to gerrit, others could be easily, others need a lot of
 work first.
 The last patch adds the "copy-client" script.

 In
   https://github.com/neilbrown/linux/tree/lustre/lustre-next
 you can find a very recent linux/master tree with two patches added.
 The first was auto-generated by the script from lustre/lustre-next.
 The second fixes some compile errors with fscrypt() (though it may
 actually break the code, I don't know).

 Note that the copied LNET code is TCP-only.  I left out the o2ib code
 as I don't think we need that for the first code drop.

 Apart from providing the code mentioned above, this little project has
 also helped me form a clearer picture of what needs to be done before
 upstream submission is worth attempting.  My list includes:

 - IPv6 support.  I have a lot of patches which add support for extended
   NIDs which can store IPv6 addresses.  There is more to be done here
   (and thanks to Andreas for his review which I haven't responded to
   yet).
   One awkwardness in the conversion that I haven't addressed at all yet
   is ptlrpc/nodemap_range.c.  This allows a range of IP address to have
   a particular nodemap.  This might make sense for IPv4, but makes
   somewhat less sense for IPv6.
   I'm storing IPv6 addresses in network-byte-order (which is the normal
   way to store addresses), and that make ranges particularly cumbersome.
   One idea is to use netmasks rather than ranges to define subsets, for
   IPv6 at least.

 - fscrypt.  There is a comment in lustre-core.m4 which suggests that
    lustre does not support file name encryption, and so cannot use
    the fscrypt support in Linux.  If I understand that correctly, then
    this needs to be rectified.

 - I want to deprecate libcfs as there isn't anywhere convenient to put
   it - as a whole - in the linux kernel. It currently contains a
   mixture of things:
   = back-compat code, which Linux obviously doesn't needed

   - workitem.c and hash.c which are being replaced by
     workqueue and rhashables

   - cpt code, which is largely used by lnet, so can go in lnet/lnet

   - heap tree, which can go in lustre/ptlrpc as it is only used by nrs.

   - fail.c error injection.  It would be nice to convert lustre to
     use the error-injection in linux/lib.  This is a completely
     different user-space interface management.
     Is the current interface seen as a "stable api", or is it only
     used by lustre/tests (which can obviously be changed).

   - tracefile/debug.  I think this should be changed to use
     tracepoints. I believe the capabilities are similar, though the
     details are different.  I think I've raised this before and had an
     explanation of why people aren't keen.  Maybe it is time to revisit
     that.
     LU-8980 was closed "Won't Fix" with no explanatory comment...

   - libcfs_string - I've converted nearly all of this to use
     functionality already in Linux.  Only cfs_str2mask() remains.

   - adler32 - hopefully this can be copied to crypto/ in linux.

 - move stuff out of /proc
    I understand that part of this is statistics, which don't fit in
    debugfs as that is root-only, and don't fit in /sys at that is
    one-value-per-file.
    Firstly I'd like to resolve everything that is not stats.
    James has a netlink proposal for stats.
    NFS uses /proc/self/mountstats to present stats info.

 I plan to create some jira issues to cover:
  - moving code out of libcfs
  - fault injection
  - adding more HAVE_SERVER_SUPPORT and UPSTREAM_LINUX directives

 and start submitting some of the patches I have, and work on some more.

 I'll probably keep my existing linux-lustre tree (based on
 drivers/staging) up to date, as there is still valuable stuff in there
 to be ported across, and being able to 'diff' the two (with filtering)
 helps.

 Thoughts?

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQJCBAEBCAAsFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAl/S78kOHG5laWxiQHN1
c2UuZGUACgkQOeye3VZigbm90w/+PNftF52Hb6eJyHBLWtPQ7uceyFGUhrnDhZYB
DuIxUpdU6vaq/vdNSPBhqEIPzqbdgtuMROhYiIigZGDMRGByz7UFxqf3fZP2TvvU
5n5NFn2+8qKyr3CuN7FssZcRxTVQ28/OB3yR/TyGHJLx8bNJN2AsY4jdzQmS4Dbe
HJZbQWGUQ7DEmiuAtNY3e5ma1E+m2MUat/sbwHYb51u4kFjJ1+wWzlvHBMzozkMm
d33u5ZFg+V/6TTXje31tjxtkbH1vC2R8SiPDo/EbRNDjp3t45r6N7LWsKFtzuGAU
kFIkKfpblKu5DUvs97+gA4z/ImEFWkH7oXSoQLM/nzjUWopH2tqeV3u/7ISbrv9T
DmNWvR1N9Il5c6pW3+Pn4Hdo8u54xysbWIdKcFXEGFxUDqXFoKVZ0R/XsCnNak/f
c+Girc4Gs9BMHaxH7txmSlVym7VzmZPT703c6s5VgJ+PZFzJiGLEj4DT7O+RYXCk
qRjRC48m31NnD0mBj7ccyNUVH+kBWwDz1HTM53hX/PqU4bFtG3g9bIP0rennAFb2
k+uQe8+8YNz0XrVFMtrFrZih7Od70+FNGpClgAThooYrdiBJg6TovmSdGYUmVGEw
cBrcmcM/1JHm9GUC4gIkNq0fpnT9qVRSY3R9Iv3sCFWjl58UdJgzb2NcOvx1zv1t
zI+c+1Y=
=5mC1
-----END PGP SIGNATURE-----
--=-=-=--

--===============7537849023780759856==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============7537849023780759856==--
