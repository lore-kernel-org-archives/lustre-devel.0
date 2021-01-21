Return-Path: <SRS0=NZgA=GY=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA470C433E6
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 03:51:50 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 442FB2071C
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 03:51:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 442FB2071C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 36AC721EB73;
	Wed, 20 Jan 2021 19:51:49 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de [195.135.220.15])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B100721CBD9
 for <lustre-devel@lists.lustre.org>; Wed, 20 Jan 2021 19:51:46 -0800 (PST)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.221.27])
 by mx2.suse.de (Postfix) with ESMTP id 7E23EABDA;
 Thu, 21 Jan 2021 03:51:45 +0000 (UTC)
From: NeilBrown <neilb@suse.de>
To: Sudheendra Sampath <sudheendra.sampath@gmail.com>,
 lustre-devel@lists.lustre.org
Date: Thu, 21 Jan 2021 14:51:39 +1100
In-Reply-To: <CABnqofw_6U0gV8_A3gMOpX=wYMEFH5A6Pdy833EQoAWE271eXw@mail.gmail.com>
References: <CABnqofw_6U0gV8_A3gMOpX=wYMEFH5A6Pdy833EQoAWE271eXw@mail.gmail.com>
Message-ID: <87o8hjhrqs.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Subject: Re: [lustre-devel] Isn't there a memory leak here !!!
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
Content-Type: multipart/mixed; boundary="===============6356328626188900435=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============6356328626188900435==
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Jan 20 2021, Sudheendra Sampath wrote:

> Hi,
>
> While doing transaction code analysis, I found the following in
> lustre/target/tgt_lastrcvd.c.
>
>     552 int tgt_new_client_cb_add(struct thandle *th, struct obd_export
> *exp)
>     553 {
>     554         struct tgt_new_client_callback  *ccb;
>     555         struct dt_txn_commit_cb         *dcb;
>     556         int                              rc;
>     557
> *    558         OBD_ALLOC_PTR(ccb);*
>     559         if (ccb =3D=3D NULL)
>     560                 return -ENOMEM;
>     561
>     562         ccb->lncc_exp =3D class_export_cb_get(exp);
>     563
>     564         dcb =3D &ccb->lncc_cb;
>     565         dcb->dcb_func =3D tgt_cb_new_client;
>     566         INIT_LIST_HEAD(&dcb->dcb_linkage);
>     567         strlcpy(dcb->dcb_name, "tgt_cb_new_client",
> sizeof(dcb->dcb_name));
>     568
>     569         rc =3D dt_trans_cb_add(th, dcb);
>     570         if (rc) {
>     571                 class_export_cb_put(exp);
> *    572                 OBD_FREE_PTR(ccb);*
>     573         }
>     574         return rc;
>     575 }
>
> OBD_FREE_PTR() is in the condition block which means that the expectation
> is dt_trans_cb_add() returns something "!=3D 0".
>
> From the code, osd_trans_cb_add() and osp_trans_cb_add() returns zero
> value.  So, my point is OBD_FREE_PTR() should be outside the condition
> block.
>
> Please correct me if my understanding is incorrect.

If dt_trans_cb_add() returns zero, then 'dcb' has been added to some
list of transactions.  dcb is a pointer to a 'struct dt_txn_commit_cb'
structure embedded inside 'ccb'.

So when rc=3D=3D0, the memory allocated for ccb is now attached to a list of
transactions, so it would be wrong to free it.  If the attachment
(dt_trans_cb_add()) failed, then it needs to be freed.

So I think the code is correct as it stands.

Thanks,
NeilBrown


>
> --=20
> Regards
>
> Sudheendra Sampath
> _______________________________________________
> lustre-devel mailing list
> lustre-devel@lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQJCBAEBCAAsFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAmAI+ksOHG5laWxiQHN1
c2UuZGUACgkQOeye3VZigbmH8g/+JHbMGzdtjVgu4W4rzlVi7BwPJG6kcQAM20yI
InkIlAXlCIP72Hny8cutk+fjf28g+VknBwuaWS+N4918UYtsyrrQYxf7Ri8PaVa1
qLJ2MkpvEMd7DWn2LDQcIrq/Ka6/WrTTeCYiX5MMQBJT57WNn+irocPrM0mBuR/J
yqZamEhSPNl0gQl8KCr+smSSx5hgb/k3eZlcVc2Jw650Qh8yis0AC9SF6S/JSNWe
69e5vC/lhJZujKm3Fl6c8kiQ4VTrGDwAdHch+IycHLxYdvBe4fLvbYB54otsxvk2
vK+FWRGF+HTtlOYVSXaItU5zk9yts2Vk+m6xgE624wZj9jc5SI2ZQMHFaWk/mbhl
HuHg5aclQhaebRoabOypXXqYowTviRsnIabhf4eqLtvYHMhEX5J3ku3aRXw8disJ
1hXM6kQBDAWbb+06cQ9XrzIGyQ2Q9O3FIFtvG4urKViiGdbwsfJ/UTLieKsutJ+P
QC3vipAsiekwUV0IoumuiyEznBj2p7usy6OiR2WEBcxINDd1X248UltrMB+Mileh
JARkwck51IB1ubnItDA2DBode1rUJO110Hv803H3gdsd5tacH3Kl+ni/6vLpNgyk
SB4wzgl47VRCgRXGdcv08x75EWxgBg2KVYjXa7JBc3Mtsvu3TOFCDd9wHCIM/M8C
gVsR+FM=
=sHKw
-----END PGP SIGNATURE-----
--=-=-=--

--===============6356328626188900435==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============6356328626188900435==--
