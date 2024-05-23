Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id C74DFC27C5F
	for <lustre-devel@archiver.kernel.org>; Tue, 11 Jun 2024 01:43:56 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Vys040W9Sz1y7K;
	Mon, 10 Jun 2024 18:43:48 -0700 (PDT)
Received: from mail-yb1-f171.google.com (mail-yb1-f171.google.com
 [209.85.219.171])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4VlbKr2kKFz1wNQ
 for <lustre-devel@lists.lustre.org>; Thu, 23 May 2024 10:50:08 -0700 (PDT)
Received: by mail-yb1-f171.google.com with SMTP id
 3f1490d57ef6-df771b6cc9cso32019276.3
 for <lustre-devel@lists.lustre.org>; Thu, 23 May 2024 10:50:08 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=charlotte.edu; s=google; t=1716486607; x=1717091407; darn=lists.lustre.org; 
 h=to:subject:message-id:date:from:mime-version:from:to:cc:subject
 :date:message-id:reply-to;
 bh=1fRpnTBZgMS+4OFqsRg3gxBKK0bYuS0NCxH3yBOGN7o=;
 b=NCPQNMIofDP/MJ1RZUija3Jrw2078GmeMk0hW36woTovT7sU1GIzU2Fp/h4Jx1zPAN
 yI6cFa5EiBdpEafOd51GT2bsQRAmHjbgZfe8Gedozi6OBWvOEnKxweTzhXpxIThSA2+5
 ZlqrU3Ze/V6dKocmCgHkXZsFbJrhSRfHTA14OTOBbvBA3DVPU5hPWuhi4Yg60ajHkhxv
 GEETvcv/HH7mkd70mygIPS2oYvgnPDBVXMWHojqBxS8Cb1ftFK0A+c9OmPu9amei0Lg9
 Kk2qrIA4AmaCCS2sUPbsXW8hyKTPMoYVjcr+zh7n3H032QhNyF6TRcTxgCkiRdefLTL1
 CbQQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1716486607; x=1717091407;
 h=to:subject:message-id:date:from:mime-version:x-gm-message-state
 :from:to:cc:subject:date:message-id:reply-to;
 bh=1fRpnTBZgMS+4OFqsRg3gxBKK0bYuS0NCxH3yBOGN7o=;
 b=oh996/e9Ga/AJ3I7i69PLVRqaiJUvZOrMWDLNM6r5KHPgoFXUTlVUMnvYaGdbqvZnM
 igf+Kmci9f3VN8/e/trVqQei4BsQ4hH3t0TyO5pn9gjnc3EFcSCnRmY+4YwhVKkYQXoO
 tIXr/S/jGQ9uzNPJDzkZ1snliQmodPkiZd6Z7XOZizk5uFp1xvGXS/y9xI9y1krEp05K
 aR6zzUjncHzlRl8q2HdcjquhLhC5PW6sXcJUIhMUjgY5SGFFn7YpW/RHyvV076zKB4r5
 ZWpgaUcZh3Ei0Oqnb080SnrltVQ45vNNk0Nh6Kx933U7U4ZsHxfVTfqTmmWlxZeJMf+k
 enDw==
X-Gm-Message-State: AOJu0YzNyaIywpaoazz5gpL0gnKw/qFGtC+NQgphzGhylfA5LuvidyXb
 +C4zYP8z37LmeKuu4KTfI83851XWAWU7l3rV8DZBVQPSJRoHn2Pcqn7OiLTdvqOTLxDjiFs0qj/
 9RTFoaVfZOebYjJuscsCV3s4KXXujDp9aOcCtfX88H42JDxFdd9k=
X-Google-Smtp-Source: AGHT+IHwMtnNZNvP+uxXblOKvgkHylPdeVO+RzhuFIyDcWxQcd78ten1/DQqmKc5oy/WwrrgqJ8b6fkNGUMLY/polfc=
X-Received: by 2002:a25:7494:0:b0:df7:71b7:c353 with SMTP id
 3f1490d57ef6-df771b7c66dmr61151276.51.1716486606882; Thu, 23 May 2024
 10:50:06 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 23 May 2024 13:49:55 -0400
Message-ID: <CACyzrcRKWoumFKgDGBbiusP9jWsccHdE4o4kFmnCVy4z4_ge=Q@mail.gmail.com>
To: lustre-devel@lists.lustre.org
X-Mailman-Approved-At: Mon, 10 Jun 2024 18:43:43 -0700
Subject: [lustre-devel] Inquiry About Using Checksum for Lustre Extended
 Attributes
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
Reply-To: Saisha Kamat <skamat1@charlotte.edu>
Content-Type: multipart/mixed; boundary="===============3001214433548852552=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============3001214433548852552==
Content-Type: multipart/alternative; boundary="0000000000007729c5061922aee2"

--0000000000007729c5061922aee2
Content-Type: text/plain; charset="UTF-8"

Hello,

I hope this message finds you well.

I am currently exploring the possibility of using checksum to verify Lustre
extended attributes. I understand that ext4 supports xattr checksum, but I
would like to know if this functionality extends to Lustre as well.

Could you please provide some insights or direct me to relevant
documentation on this matter?

Thanks and Regards,
Saisha

--0000000000007729c5061922aee2
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hello,<br><br>I hope this message finds you well.<br><br>I=
 am currently exploring the possibility of using checksum to verify Lustre =
extended attributes. I understand that ext4 supports xattr checksum, but I =
would like to know if this functionality extends to Lustre as well.<br><br>=
Could you please provide some insights or direct me to relevant documentati=
on on this matter?<div><br></div><div>Thanks and Regards,=C2=A0<br>Saisha</=
div></div>

--0000000000007729c5061922aee2--

--===============3001214433548852552==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============3001214433548852552==--
