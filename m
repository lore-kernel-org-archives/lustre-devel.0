Return-Path: <SRS0=8FdJ=GH=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5807CC433DB
	for <lustre-devel@archiver.kernel.org>; Mon,  4 Jan 2021 05:32:45 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 32BA0207B7
	for <lustre-devel@archiver.kernel.org>; Mon,  4 Jan 2021 05:32:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 32BA0207B7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 6D10021F2C1;
	Sun,  3 Jan 2021 21:32:43 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de [195.135.220.15])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 8FF7521F1CC
 for <lustre-devel@lists.lustre.org>; Sun,  3 Jan 2021 21:32:41 -0800 (PST)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.221.27])
 by mx2.suse.de (Postfix) with ESMTP id 42223AD11;
 Mon,  4 Jan 2021 05:32:40 +0000 (UTC)
From: NeilBrown <neilb@suse.de>
To: Andreas Dilger <adilger@whamcloud.com>
Date: Mon, 04 Jan 2021 16:32:34 +1100
In-Reply-To: <53FA16ED-D466-43C4-9958-6AE9452FA351@whamcloud.com>
References: <87o8j1j8e0.fsf@notabene.neil.brown.name>
 <53FA16ED-D466-43C4-9958-6AE9452FA351@whamcloud.com>
Message-ID: <87y2h9jmh9.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Subject: Re: [lustre-devel] An alternate approach to preparing lustre for
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: multipart/mixed; boundary="===============6120984811531540405=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============6120984811531540405==
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"

--=-=-=
Content-Type: text/plain


Hi Andreas,
 thanks for your thorough review.

 I've created

  LU-14291 - Improve use of HAVE_SERVER_SUPPORT and others for
    Linux-kernel client
  LU-14290 - Convert fault-injection framework to match the model using
    in linux
  LU-14289 - Restrict libcfs to compatibility code only
  LU-14288 - Enhance nodemap ranges to work better with IPv6

 With respect to CDEBUG(), while no-one else may have stated a
 requirement to remove CDEBUG() for upstream submission, it is something
 that I personally feel strongly about.
 It isn't CDEBUG itself that is the problem, it is the back-end code for
 gathering the logs and writing them out.  I wouldn't feel comfortable
 submitting that code upstream.  This is the ring-buffer code that you
 mentioned.

 While tracepoint are often quite verbose code-wise as you suggest, I
 don't think they have to be.  I think (without actually having tried
 it) that trace_printk() can be used to crate an alternate CDEBUG()
 macro, so that all the CDEBUG() calls can be left unchanged.
 Converting some or all of these to more traditional tracepoints could
 be done later as the need or desire arose.  I will see if I can make
 this work in due course.

 I'm looking forward to the 2.14.0 release :-)

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQJCBAEBCAAsFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAl/yqHIOHG5laWxiQHN1
c2UuZGUACgkQOeye3VZigbnKog//ZrIHQIJ3wuRn0amKfzSlfPm6ma5+smdIqWnh
zUvKdovweSx47no9KlFDluBzstAglRTvknctLyLTsgwJ2BFcd7yRQ7qbWzyM/EOX
JftrvGBMj8soGNYcQmTne0WMX5FvXe6umeqakYbyb0/AQ8S9BcyhERCUZdnObT3g
Crj6UcANQwgz6G1lte1rf1hMVBQ4z3dn+Vh+20y3heeFZChgPrKtHhXvM00IA14a
EGwZ6Ww9qXn79XwTUW+azynxGhMtGI7Cftts0QZ4OyzQt3nUB4Ba9ameivL0E+zr
iel4428CFJdb+6uMPHLp2Bnwaw/KvxNw2mV96oiwOetgXARx04mwIEMX5gbnMKX1
V3Z334S5Z/DgX8RmmI9sACIjc6EIDW3K8brKNOMsPxZphxfi62T4X3DdiPZp6L1W
c66d6L3KkH0gLpSa0nNV/JnSlNiwCxnATaBhYma1c5S4rv8Dv8DCaL4tmbYgtPTY
euX4g05e/J9iGllgAj2LUJ3KYsE22Sbi6uMulsU16xMvZ+Lpw3sAt5mbXlzUbKxM
j0XJf7//Zu8K5suy8K5oMRlcIY1LKh0cd9gIP1zA1PyQpoYXG5ovtK1+99MQE0FC
7KMmEJkygaf4Rxwe954cJ4a5zeqAJkw1PLUjTCLIx5IV4imHFMiXbFYJ97pVWv7A
QwNFQ7I=
=f9cV
-----END PGP SIGNATURE-----
--=-=-=--

--===============6120984811531540405==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============6120984811531540405==--
