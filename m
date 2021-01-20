Return-Path: <SRS0=mxas=GX=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: **
X-Spam-Status: No, score=2.5 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0D0EC433DB
	for <lustre-devel@archiver.kernel.org>; Wed, 20 Jan 2021 21:56:37 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 71B16235F9
	for <lustre-devel@archiver.kernel.org>; Wed, 20 Jan 2021 21:56:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 71B16235F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 9ADA221E019;
	Wed, 20 Jan 2021 13:56:36 -0800 (PST)
Received: from mail-wm1-f51.google.com (mail-wm1-f51.google.com
 [209.85.128.51])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 31AE021CABE
 for <lustre-devel@lists.lustre.org>; Wed, 20 Jan 2021 13:56:34 -0800 (PST)
Received: by mail-wm1-f51.google.com with SMTP id s24so4034137wmj.0
 for <lustre-devel@lists.lustre.org>; Wed, 20 Jan 2021 13:56:34 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:from:date:message-id:subject:to;
 bh=L9x6VzPIc5Mz/uaa1TxlDdQfdTm/GXlN5JwF4ffrwYA=;
 b=YzsgOKLiYMuNfv041Fb+YS3pIhPrRU2KUpE3u+B0bBzgJp4CMRJa7Ey80iaiObB1WX
 uJVRQQuFZeHXivYZBh6r0h71yxdU+A6b0N592BIp7ABrE22O/Y5pdBnp8bx3dKkDoKYY
 EobvvSVITZMe6Am3r4Ia9BkvlP9UGxnaINvjymAPxJFSo154PGWjZbzPOl8Kya159/s7
 6fCp+PlmqR/z6M87rnLtvQEUm3LZP/vO/FmeHeY1iq333JFG8ecN2SeZkR9GYD9OGNLq
 h9SCIZuCLTwZq7yXdl7e0Hgr8LPiTDgRxpgXLcpmUswCC67mziW6RHHUvAhIXBpy5ioG
 4JaA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:from:date:message-id:subject:to;
 bh=L9x6VzPIc5Mz/uaa1TxlDdQfdTm/GXlN5JwF4ffrwYA=;
 b=HnEV4Rud+J7OQ9ChZDaXOLRQqipy8kTXp3oL4imi6faoE5rJwfDXpKeOL5kRF6MbpF
 lrtQzQ2TsYUfccTRZHKj3AQLqj0KiEA62sNbDC+wKIKyQ1IAp3SvWfnaYH88z0Oj+fMG
 4VsxL8uDOBYBZpnxzK7UJWaYpelZW+XUbmT0rWBpvmpmt2c86ji3D/33gt/Lkm5wIig0
 dYjGD3goQy13zHaSEuZZS6MzbAbF6US3o8tioQeFdhLfs46RRAUYLzDNLMSzjvY2xr5+
 pQm/Wyxjo/qSVnpMcLhfXtjudL3hhY4DI3QnnBxevtG1W+NY6Wg9CembUb9nvb1cW2gl
 IDLg==
X-Gm-Message-State: AOAM531uZiwMXruZC1DezLcmwCbhT8l10K1ow++DsDkNJ0IzRx1eXeoC
 +IdKmpYeD+z1YDoxU75ltW/XOG0mXwhceI9J5ad0RVpL9ERqIg==
X-Google-Smtp-Source: ABdhPJzxLhwDdAKwkvtxGA5ScTxUW84b7AbDpO0njys9yMMKMQFYChg4Hn2OQKM9bKGp3ZkSTAIXGH3iGNvLjqqyDY0=
X-Received: by 2002:a1c:ba83:: with SMTP id k125mr6134959wmf.5.1611179792055; 
 Wed, 20 Jan 2021 13:56:32 -0800 (PST)
MIME-Version: 1.0
From: Sudheendra Sampath <sudheendra.sampath@gmail.com>
Date: Wed, 20 Jan 2021 13:55:56 -0800
Message-ID: <CABnqofw_6U0gV8_A3gMOpX=wYMEFH5A6Pdy833EQoAWE271eXw@mail.gmail.com>
To: lustre-devel@lists.lustre.org
Subject: [lustre-devel] Isn't there a memory leak here !!!
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
Content-Type: multipart/mixed; boundary="===============4448396000186247266=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============4448396000186247266==
Content-Type: multipart/alternative; boundary="0000000000002cc0e105b95c0771"

--0000000000002cc0e105b95c0771
Content-Type: text/plain; charset="UTF-8"

Hi,

While doing transaction code analysis, I found the following in
lustre/target/tgt_lastrcvd.c.

    552 int tgt_new_client_cb_add(struct thandle *th, struct obd_export
*exp)
    553 {
    554         struct tgt_new_client_callback  *ccb;
    555         struct dt_txn_commit_cb         *dcb;
    556         int                              rc;
    557
*    558         OBD_ALLOC_PTR(ccb);*
    559         if (ccb == NULL)
    560                 return -ENOMEM;
    561
    562         ccb->lncc_exp = class_export_cb_get(exp);
    563
    564         dcb = &ccb->lncc_cb;
    565         dcb->dcb_func = tgt_cb_new_client;
    566         INIT_LIST_HEAD(&dcb->dcb_linkage);
    567         strlcpy(dcb->dcb_name, "tgt_cb_new_client",
sizeof(dcb->dcb_name));
    568
    569         rc = dt_trans_cb_add(th, dcb);
    570         if (rc) {
    571                 class_export_cb_put(exp);
*    572                 OBD_FREE_PTR(ccb);*
    573         }
    574         return rc;
    575 }

OBD_FREE_PTR() is in the condition block which means that the expectation
is dt_trans_cb_add() returns something "!= 0".

From the code, osd_trans_cb_add() and osp_trans_cb_add() returns zero
value.  So, my point is OBD_FREE_PTR() should be outside the condition
block.

Please correct me if my understanding is incorrect.

-- 
Regards

Sudheendra Sampath

--0000000000002cc0e105b95c0771
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi,<div><br></div><div>While doing transaction=C2=A0code a=
nalysis, I found the following in lustre/target/tgt_lastrcvd.c.</div><div><=
br></div><div><div>=C2=A0 =C2=A0 552 int tgt_new_client_cb_add(struct thand=
le *th, struct obd_export *exp)<br>=C2=A0 =C2=A0 553 {<br>=C2=A0 =C2=A0 554=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct tgt_new_client_callback =C2=A0*ccb;<br>=
=C2=A0 =C2=A0 555 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct dt_txn_commit_cb =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 *dcb;<br>=C2=A0 =C2=A0 556 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 int =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0rc;<br>=C2=A0 =C2=A0 557<br><b><fo=
nt color=3D"#ff0000">=C2=A0 =C2=A0 558 =C2=A0 =C2=A0 =C2=A0 =C2=A0 OBD_ALLO=
C_PTR(ccb);</font></b><br>=C2=A0 =C2=A0 559 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if =
(ccb =3D=3D NULL)<br>=C2=A0 =C2=A0 560 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 return -ENOMEM;<br>=C2=A0 =C2=A0 561<br>=C2=A0 =C2=A0 =
562 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ccb-&gt;lncc_exp =3D class_export_cb_get(ex=
p);<br>=C2=A0 =C2=A0 563<br>=C2=A0 =C2=A0 564 =C2=A0 =C2=A0 =C2=A0 =C2=A0 d=
cb =3D &amp;ccb-&gt;lncc_cb;<br>=C2=A0 =C2=A0 565 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 dcb-&gt;dcb_func =3D tgt_cb_new_client;<br>=C2=A0 =C2=A0 566 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 INIT_LIST_HEAD(&amp;dcb-&gt;dcb_linkage);<br>=C2=A0 =C2=
=A0 567 =C2=A0 =C2=A0 =C2=A0 =C2=A0 strlcpy(dcb-&gt;dcb_name, &quot;tgt_cb_=
new_client&quot;, sizeof(dcb-&gt;dcb_name));<br>=C2=A0 =C2=A0 568<br>=C2=A0=
 =C2=A0 569 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rc =3D dt_trans_cb_add(th, dcb);<br=
>=C2=A0 =C2=A0 570 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (rc) {<br>=C2=A0 =C2=A0 5=
71 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 class_export_cb_=
put(exp);<br><b><font color=3D"#ff0000">=C2=A0 =C2=A0 572 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 OBD_FREE_PTR(ccb);</font></b><br>=C2=
=A0 =C2=A0 573 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>=C2=A0 =C2=A0 574 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 return rc;<br>=C2=A0 =C2=A0 575 }<br></div><div><br></=
div><div>OBD_FREE_PTR() is in the condition block which means that the expe=
ctation is dt_trans_cb_add() returns something &quot;!=3D 0&quot;.</div><di=
v><br></div><div>From the code,=C2=A0osd_trans_cb_add() and=C2=A0osp_trans_=
cb_add() returns zero value.=C2=A0 So, my point is OBD_FREE_PTR() should be=
 outside the condition block.</div><div><br></div><div>Please correct me if=
 my understanding is incorrect.</div><div><br></div>-- <br><div dir=3D"ltr"=
 class=3D"gmail_signature" data-smartmail=3D"gmail_signature">Regards<br><b=
r>Sudheendra Sampath</div></div></div>

--0000000000002cc0e105b95c0771--

--===============4448396000186247266==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============4448396000186247266==--
