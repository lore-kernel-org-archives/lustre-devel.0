Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 45F46C433FE
	for <lustre-devel@archiver.kernel.org>; Wed, 23 Nov 2022 13:37:30 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4NHMcm0HT6z1wbY;
	Wed, 23 Nov 2022 05:37:28 -0800 (PST)
Received: from mail-lj1-f174.google.com (mail-lj1-f174.google.com
 [209.85.208.174])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4NHMcK3QChz1wLc
 for <lustre-devel@lists.lustre.org>; Wed, 23 Nov 2022 05:37:05 -0800 (PST)
Received: by mail-lj1-f174.google.com with SMTP id z4so4497242ljq.6
 for <lustre-devel@lists.lustre.org>; Wed, 23 Nov 2022 05:37:05 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=uncc.edu; s=google;
 h=to:subject:message-id:date:from:mime-version:from:to:cc:subject
 :date:message-id:reply-to;
 bh=0czsbRsPJQ/SX18VmGI8VIeCPQU8oLuszUZGoGC5gwQ=;
 b=Am52yhEOYRs6nxGTS7M/5RVk5PVAv58lL5tdDkDbbrv9cyApLruQxYsKtqTLi4yzNo
 03nbzjNjwYoH1AzNzdWr515ewujHmCrg2p/wfPRo3S2OsVf8b+V2onZG3BR0uw5z9b8q
 LM4+r2e8P141XE9tbxJnXAD+w6Hqv1/X0ulcU=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20210112;
 h=to:subject:message-id:date:from:mime-version:x-gm-message-state
 :from:to:cc:subject:date:message-id:reply-to;
 bh=0czsbRsPJQ/SX18VmGI8VIeCPQU8oLuszUZGoGC5gwQ=;
 b=Ebz+uRQQ0XHkn1A4Q+gPwlwO9Y8qunnITTc3i8kZWpq/Oh1UGelgJ9UCvIidMjuqP8
 adQtkEDOibtq3b9jx5s5qrDKQcntFTtRP2yCTC8TdbqzjPHn1NQaOswg7wvQ22hvb+4L
 wupb4XBT6rgU5fE5Bms+4vuP0/XV7OTF6TgNzmQfE1H1v8AxVQlePzuCnrQpeiXLTVnz
 sQyYYDhkHLjv24gM6x4IgrK9RP3qmgY80DpsSEafZLCh7WWwqBo1XZThEfMFqPBfjZbd
 IZFqqVxUwmCRXQhhK2Vaa+x3PzMj/Ttjt7SQuxr8wiu/IsfYfk8j1Dg7Nk+ZAF/e8g/1
 mfBg==
X-Gm-Message-State: ANoB5pkbz7fK0XGaHNhoxrsJC00LUomjEYQnhBXxJHmIyRMfAAPxwHlg
 fJUrIwkWFjMDcZFye2KLEnKgkhkD14KIhdnJTVU7UifD/Xt0Ig==
X-Google-Smtp-Source: AA0mqf5TXCT3zLaVZ/w8EjlQXmWve2XthtzJT3lkuK6HLrVD0YGKYCqhMstgfTAcUshBjeVV+Zx6hJa6eKzzklYVCas=
X-Received: by 2002:a2e:908e:0:b0:277:515b:3dcd with SMTP id
 l14-20020a2e908e000000b00277515b3dcdmr8715655ljg.501.1669210622039; Wed, 23
 Nov 2022 05:37:02 -0800 (PST)
MIME-Version: 1.0
Date: Wed, 23 Nov 2022 08:36:51 -0500
Message-ID: <CACyzrcRce01W3_8C1TsOJEQrtSj7qnBTWW6TDpcz_1kEKgCvhw@mail.gmail.com>
To: lustre-devel@lists.lustre.org
Subject: [lustre-devel] Question about how online LFSCK works
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
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
From: Saisha Kamat via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Saisha Kamat <skamat1@uncc.edu>
Content-Type: multipart/mixed; boundary="===============1465833545474963503=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============1465833545474963503==
Content-Type: multipart/alternative; boundary="0000000000002f0ee005ee236220"

--0000000000002f0ee005ee236220
Content-Type: text/plain; charset="UTF-8"

Hi all,
I am a Ph.D student at UNC-Charlotte, working on Lustre File System Checker.

I had a question related to how online LFSCK works. Specifically, how does
LFSCK differentiate old metadata and new metadata created
during its execution? Will the new metadata be checked? and if yes, when
will they be checked by LFSCK? Can you please point me to the source code
to understand more details?

Thanks very much!
Saisha

--0000000000002f0ee005ee236220
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><table cellpadding=3D"0" class=3D"gmail-ajC" style=3D"bord=
er-spacing:0px;line-height:20px;font-family:&quot;Google Sans&quot;,Roboto,=
RobotoDraft,Helvetica,Arial,sans-serif;font-size:14px"><tbody><tr class=3D"=
gmail-ajv"><td colspan=3D"2" tabindex=3D"0" class=3D"gmail-gL" style=3D"ver=
tical-align:top;width:auto;padding:2px 0px"><span class=3D"gmail-gI" style=
=3D"vertical-align:top">Hi all,<br>I am a Ph.D student at UNC-Charlotte, wo=
rking on Lustre File System Checker.<br><br>I had a question related to how=
 online LFSCK works. Specifically, how does LFSCK differentiate old metadat=
a and new metadata created during=C2=A0its=C2=A0execution? Will the new met=
adata be checked? and if yes, when will they be checked by LFSCK? Can you p=
lease point me=C2=A0to the source code to understand more details?<br><br>T=
hanks very much!<br><span aria-label=3D"" class=3D"gmail-c-mrkdwn__br" styl=
e=3D"box-sizing:inherit;display:block;height:8px;font-family:Slack-Lato,Sla=
ck-Fractions,appleLogo,sans-serif;font-size:15px;font-variant-ligatures:com=
mon-ligatures"></span>Saisha<br><br></span></td></tr></tbody></table></div>

--0000000000002f0ee005ee236220--

--===============1465833545474963503==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============1465833545474963503==--
