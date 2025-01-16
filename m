Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id D3536E77188
	for <lustre-devel@archiver.kernel.org>; Thu, 16 Jan 2025 06:35:12 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YYY4t0XwFz1xNs;
	Wed, 15 Jan 2025 22:34:54 -0800 (PST)
Received: from mail-pj1-f46.google.com (mail-pj1-f46.google.com
 [209.85.216.46])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YYY4s25cdz1wnf
 for <lustre-devel@lists.lustre.org>; Wed, 15 Jan 2025 22:34:53 -0800 (PST)
Received: by mail-pj1-f46.google.com with SMTP id
 98e67ed59e1d1-2ef87d24c2dso862294a91.1
 for <lustre-devel@lists.lustre.org>; Wed, 15 Jan 2025 22:34:53 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=gmail.com; s=20230601; t=1737009292; x=1737614092; darn=lists.lustre.org;
 h=to:subject:message-id:date:from:mime-version:from:to:cc:subject
 :date:message-id:reply-to;
 bh=CailSdt0LxPBajZsPwa02bxxNwpgqJYuqKvQ64W7nPI=;
 b=aBQqCCLIEt02soCZOtOTkeaitquEky0rX5Xqg3cUkhydnkuRKv73O6MolxuiAviRtd
 Lz5+x+aba7yFlOtZsadqhUWJdd7TpEYORTN7qGq5p24tdVuVXG1CmuyxF5SwjFjb/xSv
 E1ixzm1URGnjc6MSTJsq2N54BX5DwQpimbJSTBdz/Hix/92tpqVijYpC45zgURwua4ZK
 8UcOKR0YGf/hWvS9ggZmnJuklUh3aPiuz2A9D1AmoFLwFOVAHMkRcvtui6LKJgzDAvEA
 GX9M0A+Jvy//92d0ikZNWkLr9XkhYi/L4RFLDPCBfUQmeSUZg43ZemKxyD5GHdzKHQyi
 d0EA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1737009292; x=1737614092;
 h=to:subject:message-id:date:from:mime-version:x-gm-message-state
 :from:to:cc:subject:date:message-id:reply-to;
 bh=CailSdt0LxPBajZsPwa02bxxNwpgqJYuqKvQ64W7nPI=;
 b=wl2+eW+5TJNYhsroJNgV1pkKTdMx3ijuaaLp+iUIdEmOq2wnmul1pjHqkm1dCSCH2A
 uIbCDO4zPR0QcixVF4VD8ZL2pXpwha1Ty0gBxrk1pc0zx8b0kooiRTj6zKgdxuCgWtfa
 Worva/HQn9Dy7IGLiu3PPOY93EJmoSfiE2tCLxp6PnbkstVddb2g+KhPCTkf4IyZRN9z
 pdZNO+66vqulo10ZE5d+pB2x4y5xiSEtFtJfbdY1CDf/vT1yBluYKaFnKnPhEvwY5mEm
 Macse4K+7SnvAn78CdSk6ClqSx5yvS5mhHG1fV9lBjpRYWdNvlpzFxfvNECIbqMJx8yS
 ovIA==
X-Gm-Message-State: AOJu0YxnUoDaUS44exKinkThINtaN5QoZKR51YnqLctzf/a9fl9WTMjg
 o4QzOnSOXrZwiORpPDfBhQxR5IpuBLrXy22wqaG9a6xgEGZkO/Q1OlpRyaT6ATqCTMQ7WdUmI4l
 aWc+sj6D2mel7562dH15vv66yh35KQaSlPCc=
X-Gm-Gg: ASbGncsIvFJDhMZgfBbNrVr3bD0ud/f6xp7y9HyxI7FIfQD2RZYBqfr2OBWlAIeQdpY
 TTqZNV5yHCfgFtE4cGBPXws0JIs8gJKD/EjThrrc=
X-Google-Smtp-Source: AGHT+IHKZyTqOKE4BsfC6Jv4o+wFylt68xTv8Nsu49EYnarOef7dXnirSBONtaq/ntkzS2SndbLdE8mhpHeB5ZpdHMk=
X-Received: by 2002:a17:90b:54c4:b0:2ee:c6c8:d89f with SMTP id
 98e67ed59e1d1-2f548f33c2cmr50011416a91.14.1737009292172; Wed, 15 Jan 2025
 22:34:52 -0800 (PST)
MIME-Version: 1.0
From: keguang xu <squalfof@gmail.com>
Date: Thu, 16 Jan 2025 14:34:40 +0800
X-Gm-Features: AbW1kvbEXdC0kzbsxd0JgdQuuUImg4B6zZ5QZWtfqC551GnRTe8UFyStYOMG1gs
Message-ID: <CAF83deQP-kUCt0BNdAOajQ02Gqi-s0+yjipAW2fL8pz1uxxzNg@mail.gmail.com>
To: lustre-devel@lists.lustre.org
Subject: [lustre-devel] HELP: why introduce BFL
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
Content-Type: multipart/mixed; boundary="===============2469673376072427078=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============2469673376072427078==
Content-Type: multipart/alternative; boundary="000000000000d4e450062bccfdb6"

--000000000000d4e450062bccfdb6
Content-Type: text/plain; charset="UTF-8"

Hi Lustre devs,

I came across *mdt_reint_rename*() and noticed the global lock *BFL.* Given
that parent and child locks are already acquired in a consistent order,
preventing deadlock, I'm unclear about the necessity of the BFL lock
specifically for cross-MDT renames. Furthermore, when setting `remote` only
source parent/object are considered, why exclude the target parent?

Correct me if I misunderstood the code above. Thank you for your input.

Best regards,
kg.xu

--000000000000d4e450062bccfdb6
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi Lustre devs,<div><br></div><div>I came across <b>mdt_re=
int_rename</b>() and noticed the global lock <b>BFL.</b>=C2=A0Given that pa=
rent and child locks are already acquired in a consistent order, preventing=
 deadlock, I&#39;m unclear about the necessity of the BFL lock specifically=
 for cross-MDT renames.  Furthermore, when setting `remote` only source par=
ent/object are considered, why exclude the target parent?</div><div><br></d=
iv><div>Correct me if I misunderstood the code above. Thank you for your in=
put.</div><div><br></div><div>Best regards,</div><div>kg.xu</div><div><br><=
/div><div><br></div></div>

--000000000000d4e450062bccfdb6--

--===============2469673376072427078==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============2469673376072427078==--
